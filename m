Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2BC76B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:08:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o16-v6so1033391pgv.21
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:08:00 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 61-v6si1928232plf.63.2018.07.17.16.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 16:07:59 -0700 (PDT)
Message-ID: <1531868610.3541.21.camel@intel.com>
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 17 Jul 2018 16:03:30 -0700
In-Reply-To: <45a85b01-e005-8cb6-af96-b23ce9b5fca7@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-17-yu-cheng.yu@intel.com>
	 <de510df6-7ea9-edc6-9c49-2f80f16472b4@linux.intel.com>
	 <1531328731.15351.3.camel@intel.com>
	 <45a85b01-e005-8cb6-af96-b23ce9b5fca7@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, 2018-07-13 at 11:26 -0700, Dave Hansen wrote:
> On 07/11/2018 10:05 AM, Yu-cheng Yu wrote:
> > 
> > My understanding is that we don't want to follow write pte if the page
> > is shared as read-only. A For a SHSTK page, that is (R/O + DIRTY_SW),
> > which means the SHSTK page has not been COW'ed. A Is that right?
> Let's look at the code again:
> 
> > 
> > -static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
> > +static inline bool can_follow_write_pte(pte_t pte, unsigned int flags,
> > +					bool shstk)
> > A {
> > +	bool pte_cowed = shstk ? is_shstk_pte(pte):pte_dirty(pte);
> > +
> > A 	return pte_write(pte) ||
> > -		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
> > +		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_cowed);
> > A }
> This is another case where the naming of pte_*() is biting us vs. the
> perversion of the PTE bits.A A The lack of comments and explanation inthe
> patch is compounding the confusion.
> 
> We need to find a way to differentiate "someone can write to this PTE"
> from "the write bit is set in this PTE".
> 
> In this particular hunk, we need to make it clear that pte_write() is
> *never* true for shadowstack PTEs.A A In other words, shadow stack VMAs
> will (should?) never even *see* a pte_write() PTE.
> 
> I think this is a case where you just need to bite the bullet and
> bifurcate can_follow_write_pte().A A Just separate the shadowstack and
> non-shadowstack parts.

In case I don't understand the exact issue.
What about the following.

diff --git a/mm/gup.c b/mm/gup.c
index fc5f98069f4e..45a0837b27f9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -70,6 +70,12 @@ static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
A 		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
A }
A 
+static inline bool can_follow_write_shstk_pte(pte_t pte, unsigned int flags)
+{
+	return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+		is_shstk_pte(pte));
+}
+
A static struct page *follow_page_pte(struct vm_area_struct *vma,
A 		unsigned long address, pmd_t *pmd, unsigned int flags)
A {
@@ -105,9 +111,16 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
A 	}
A 	if ((flags & FOLL_NUMA) && pte_protnone(pte))
A 		goto no_page;
-	if ((flags & FOLL_WRITE) && !can_follow_write_pte(pte, flags)) {
-		pte_unmap_unlock(ptep, ptl);
-		return NULL;
+	if (flags & FOLL_WRITE) {
+		if (is_shstk_mapping(vma->vm_flags)) {
+			if (!can_follow_write_shstk_pte(pte, flags)) {
+				pte_unmap_unlock(ptep, ptl);
+				return NULL;
+			}
+		} else if (!can_follow_write_pte(pte, flags) {
+			pte_unmap_unlock(ptep, ptl);
+			return NULL;
+		}
A 	}
A 
A 	page = vm_normal_page(vma, address, pte);
