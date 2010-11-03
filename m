Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 797708D0007
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:55 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 66 of 66] add debug checks for mapcount related invariants
Message-Id: <7a16f7e9cfd3510e89af.1288798121@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add debug checks for invariants that if broken could lead to mapcount vs
page_mapcount debug checks to trigger later in split_huge_page.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -804,6 +804,7 @@ static inline int copy_pmd_range(struct 
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*src_pmd)) {
 			int err;
+			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
 			err = copy_huge_pmd(dst_mm, src_mm,
 					    dst_pmd, src_pmd, addr, vma);
 			if (err == -ENOMEM)
@@ -1015,9 +1016,10 @@ static inline unsigned long zap_pmd_rang
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
-			if (next-addr != HPAGE_PMD_SIZE)
+			if (next-addr != HPAGE_PMD_SIZE) {
+				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
 				split_huge_page_pmd(vma->vm_mm, pmd);
-			else if (zap_huge_pmd(tlb, vma, pmd)) {
+			} else if (zap_huge_pmd(tlb, vma, pmd)) {
 				(*zap_work)--;
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
