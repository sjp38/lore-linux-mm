Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 493B96B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:18:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so3153748pll.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:18:35 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t67-v6si3759662pfd.364.2018.07.18.13.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 13:18:33 -0700 (PDT)
Message-ID: <1531944882.10738.1.camel@intel.com>
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 18 Jul 2018 13:14:42 -0700
In-Reply-To: <fa9db8c5-41c8-05e9-ad8d-dc6aaf11cb04@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-17-yu-cheng.yu@intel.com>
	 <de510df6-7ea9-edc6-9c49-2f80f16472b4@linux.intel.com>
	 <1531328731.15351.3.camel@intel.com>
	 <45a85b01-e005-8cb6-af96-b23ce9b5fca7@linux.intel.com>
	 <1531868610.3541.21.camel@intel.com>
	 <fa9db8c5-41c8-05e9-ad8d-dc6aaf11cb04@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-07-17 at 16:15 -0700, Dave Hansen wrote:
> On 07/17/2018 04:03 PM, Yu-cheng Yu wrote:
> > 
> > We need to find a way to differentiate "someone can write to this PTE"
> > from "the write bit is set in this PTE".
> Please think about this:
> 
> 	Should pte_write() tell us whether PTE.W=1, or should it tell us
> 	that *something* can write to the PTE, which would include
> 	PTE.W=0/D=1?


Is it better now?


Subject: [PATCH] mm: Modify can_follow_write_pte/pmd for shadow stack

can_follow_write_pte/pmd look for the (RO & DIRTY) PTE/PMD to
verify a non-sharing RO page still exists after a broken COW.

However, a shadow stack PTE is always RO & DIRTY; it can be:

A  RO & DIRTY_HW - is_shstk_pte(pte) is true; or
A  RO & DIRTY_SW - the page is being shared.

Update these functions to check a non-sharing shadow stack page
still exists after the COW.

Also rename can_follow_write_pte/pmd() to can_follow_write() to
make their meaning clear; i.e. "Can we write to the page?", not
"Is the PTE writable?"

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
A mm/gup.cA A A A A A A A A | 38 ++++++++++++++++++++++++++++++++++----
A mm/huge_memory.c | 19 ++++++++++++++-----
A 2 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index fc5f98069f4e..316967996232 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -63,11 +63,41 @@ static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
A /*
A  * FOLL_FORCE can write to even unwritable pte's, but only
A  * after we've gone through a COW cycle and they are dirty.
+ *
+ * Background:
+ *
+ * When we force-write to a read-only page, the page fault
+ * handler copies the page and sets the new page's PTE to
+ * RO & DIRTY.A A This routine tells
+ *
+ *A A A A A "Can we write to the page?"
+ *
+ * by checking:
+ *
+ *A A A A A (1) The page has been copied, i.e. FOLL_COW is set;
+ *A A A A A (2) The copy still exists and its PTE is RO & DIRTY.
+ *
+ * However, a shadow stack PTE is always RO & DIRTY; it can
+ * be:
+ *
+ *A A A A A RO & DIRTY_HW: when is_shstk_pte(pte) is true; or
+ *A A A A A RO & DIRTY_SW: when the page is being shared.
+ *
+ * To test a shadow stack's non-sharing page still exists,
+ * we verify that the new page's PTE is_shstk_pte(pte).
A  */
-static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
+static inline bool can_follow_write(pte_t pte, unsigned int flags,
+				A A A A struct vm_area_struct *vma)
A {
-	return pte_write(pte) ||
-		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
+	if (!is_shstk_mapping(vma->vm_flags)) {
+		if (pte_write(pte))
+			return true;
+		return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+			pte_dirty(pte));
+	} else {
+		return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+			is_shstk_pte(pte));
+	}
A }
A 
A static struct page *follow_page_pte(struct vm_area_struct *vma,
@@ -105,7 +135,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
A 	}
A 	if ((flags & FOLL_NUMA) && pte_protnone(pte))
A 		goto no_page;
-	if ((flags & FOLL_WRITE) && !can_follow_write_pte(pte, flags)) {
+	if ((flags & FOLL_WRITE) && !can_follow_write(pte, flags, vma)) {
A 		pte_unmap_unlock(ptep, ptl);
A 		return NULL;
A 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7f3e11d3b64a..822a563678b5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1388,11 +1388,20 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
A /*
A  * FOLL_FORCE can write to even unwritable pmd's, but only
A  * after we've gone through a COW cycle and they are dirty.
+ * See comments in mm/gup.c, can_follow_write().
A  */
-static inline bool can_follow_write_pmd(pmd_t pmd, unsigned int flags)
-{
-	return pmd_write(pmd) ||
-	A A A A A A A ((flags & FOLL_FORCE) && (flags & FOLL_COW) && pmd_dirty(pmd));
+static inline bool can_follow_write(pmd_t pmd, unsigned int flags,
+				A A A A struct vm_area_struct *vma)
+{
+	if (!is_shstk_mapping(vma->vm_flags)) {
+		if (pmd_write(pmd))
+			return true;
+		return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+			pmd_dirty(pmd));
+	} else {
+		return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+			is_shstk_pmd(pmd));
+	}
A }
A 
A struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
@@ -1405,7 +1414,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
A 
A 	assert_spin_locked(pmd_lockptr(mm, pmd));
A 
-	if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
+	if (flags & FOLL_WRITE && !can_follow_write(*pmd, flags, vma))
A 		goto out;
A 
A 	/* Avoid dumping huge zero page */
--A 
