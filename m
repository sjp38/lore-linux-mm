Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5CAFB6B00BC
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:36 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 31 of 66] split_huge_page anon_vma ordering dependency
Message-Id: <804df7cc44c4e27bdad3.1288798086@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

This documents how split_huge_page is safe vs new vma inserctions into
the anon_vma that may have already released the anon_vma->lock but not
established pmds yet when split_huge_page starts.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -840,6 +840,19 @@ static void __split_huge_page(struct pag
 			continue;
 		mapcount += __split_huge_page_splitting(page, vma, addr);
 	}
+	/*
+	 * It is critical that new vmas are added to the tail of the
+	 * anon_vma list. This guarantes that if copy_huge_pmd() runs
+	 * and establishes a child pmd before
+	 * __split_huge_page_splitting() freezes the parent pmd (so if
+	 * we fail to prevent copy_huge_pmd() from running until the
+	 * whole __split_huge_page() is complete), we will still see
+	 * the newly established pmd of the child later during the
+	 * walk, to be able to set it as pmd_trans_splitting too.
+	 */
+	if (mapcount != page_mapcount(page))
+		printk(KERN_ERR "mapcount %d page_mapcount %d\n",
+		       mapcount, page_mapcount(page));
 	BUG_ON(mapcount != page_mapcount(page));
 
 	__split_huge_page_refcount(page);
@@ -852,6 +865,9 @@ static void __split_huge_page(struct pag
 			continue;
 		mapcount2 += __split_huge_page_map(page, vma, addr);
 	}
+	if (mapcount != mapcount2)
+		printk(KERN_ERR "mapcount %d mapcount2 %d page_mapcount %d\n",
+		       mapcount, mapcount2, page_mapcount(page));
 	BUG_ON(mapcount != mapcount2);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -177,6 +177,10 @@ static void anon_vma_chain_link(struct v
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
 
 	anon_vma_lock(anon_vma);
+	/*
+	 * It's critical to add new vmas to the tail of the anon_vma,
+	 * see comment in huge_memory.c:__split_huge_page().
+	 */
 	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
 	anon_vma_unlock(anon_vma);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
