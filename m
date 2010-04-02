Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E67866B01F1
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:45:20 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-Id: <patchbomb.1270168887@v2.random>
Date: Fri, 02 Apr 2010 02:41:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hello,

With some heavy forking and split_huge_page stressing testcase, I found a
slight problem probably made visible by the anon_vma_chain: during the
anon_vma walk of __split_huge_page_splitting, page_check_address_pmd run in a
pmd that had the splitting bit set. The splitting but was set by a previously
forked process calling split_huge_page on its private page belonging to the
child anon_vma. The parent still has visiblity on the vma of the child so the
rmap walk of the parent covers the child too, but the split of the child page
can happen in parallel now. This triggered a VM_BUG_ON false positive and it
was enough to move the check on the page above the check to fix it. (it would
not have been noticeable with CONFIG_DEBUG_VM=n). All runs back flawless now
with the debug turned on.

@@ -1109,9 +1109,11 @@ new file mode 100644
 +	pmd = pmd_offset(pud, address);
 +	if (pmd_none(*pmd))
 +		goto out;
++	if (pmd_page(*pmd) != page)
++		goto out;
 +	VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG &&
 +		  pmd_trans_splitting(*pmd));
-+	if (pmd_trans_huge(*pmd) && pmd_page(*pmd) == page) {
++	if (pmd_trans_huge(*pmd)) {
 +		VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG &&
 +			  !pmd_trans_splitting(*pmd));
 +		ret = pmd;

Then there was one more issues while testing ksm and khugepaged co-existing and
mergeing and collapsing pages on the same vma simultanously (which works fine
now in #17). One check for PageTransCompound was missing in ksm and another
had to be converted from PageTransHuge to PageTransCompound.

This also has the fixed version of the remove-PG_buddy patch, that moves
memory_hotplug bootmem typing code to use page->lru.next with a proper enum to
freeup mapcount -2 for PG_buddy semantics.

Not included by email but available in the directory there is the
latest version of the ksm-swapcache fix (waiting a comment from Hugh to
deliver it separately).

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-17/
	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-17.gz

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
