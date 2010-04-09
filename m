Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DF46360037E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 11:38:13 -0400 (EDT)
Date: Fri, 9 Apr 2010 17:37:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100409153728.GA5708@random.random>
References: <a86f1d01d86dffb4ab53.1270691499@v2.random>
 <20100408161814.GC28964@cmpxchg.org>
 <20100408164630.GL5749@random.random>
 <20100408170948.GQ5749@random.random>
 <20100408171458.GS5749@random.random>
 <20100408175604.GD28964@cmpxchg.org>
 <20100408175847.GV5749@random.random>
 <20100408184842.GE28964@cmpxchg.org>
 <20100408212332.GD5749@random.random>
 <20100409105127.GK25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100409105127.GK25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 09, 2010 at 11:51:27AM +0100, Mel Gorman wrote:
> 4 irq-safe locked ops. I don't know off-hand what the cycle cost of disabling
> and enabling IRQs is but I'd expect it to be longer than what it takes to
> scan over a few pages.

Agreed.

BTW, after the #19 release the rmap_mapcount != page_mapcount error
that triggered also without memory compaction never happened again, so
that error was most certainly caused by the anon-vma changes, that I
backed out in #19 (as the fixes didn't work yet for me).

The bug in remove_migration_pte happened again once but this time I
tracked it down and fixed. rmap_walk will have lookup in parent or
child vmas that may have been cowed and collapsed by khugepaged.

You can find this already in 8707120d97e7052ffb45f9879efce8e7bd361711
in aa.git (soon I'll post a -20 release, I wanted to add numa
awareness to alloc_hugepage first). I've been running with
8707120d97e7052ffb45f9879efce8e7bd361711 with heavy load on multiple
systems with memory compaction enabled in direct reclaim of hugepage
faults, and there's zero problem. So we're fully stable now (again).

diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -100,6 +100,13 @@ static int remove_migration_pte(struct p
 		goto out;
 
 	pmd = pmd_offset(pud, addr);
+	if (pmd_trans_huge(*pmd)) {
+		/* verify this pmd isn't mapping our old page */
+		BUG_ON(!pmd_present(*pmd));
+		BUG_ON(PageTransCompound(old));
+		BUG_ON(pmd_page(*pmd) == old);
+		goto out;
+	}
 	if (!pmd_present(*pmd))
 		goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
