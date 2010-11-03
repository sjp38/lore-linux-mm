Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E17346B00C2
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:41 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 58 of 66] don't allow transparent hugepage support without PSE
Message-Id: <22cb0bee434c44460aac.1288798113@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Archs implementing Transparent Hugepage Support must implement a
function called has_transparent_hugepage to be sure the virtual or
physical CPU supports Transparent Hugepages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -160,6 +160,11 @@ static inline int pmd_trans_huge(pmd_t p
 {
 	return pmd_val(pmd) & _PAGE_PSE;
 }
+
+static inline int has_transparent_hugepage(void)
+{
+	return cpu_has_pse;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -487,7 +487,15 @@ static int __init hugepage_init(void)
 	int err;
 #ifdef CONFIG_SYSFS
 	static struct kobject *hugepage_kobj;
+#endif
 
+	err = -EINVAL;
+	if (!has_transparent_hugepage()) {
+		transparent_hugepage_flags = 0;
+		goto out;
+	}
+
+#ifdef CONFIG_SYSFS
 	err = -ENOMEM;
 	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
 	if (unlikely(!hugepage_kobj)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
