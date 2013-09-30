Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 776616B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 10:11:20 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so5949545pab.17
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 07:11:19 -0700 (PDT)
Date: Mon, 30 Sep 2013 10:10:48 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 11/63] mm: Close races between THP migration and PMD
 numa clearing
Message-ID: <20130930101048.55fa2acd@annuminas.surriel.com>
In-Reply-To: <20130930084735.GA2425@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
	<1380288468-5551-12-git-send-email-mgorman@suse.de>
	<20130930084735.GA2425@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, jstancek@redhat.com

On Mon, 30 Sep 2013 09:52:59 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Fri, Sep 27, 2013 at 02:26:56PM +0100, Mel Gorman wrote:
> > @@ -1732,9 +1732,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> >  	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> >  	entry = pmd_mkhuge(entry);
> >  
> > -	page_add_new_anon_rmap(new_page, vma, haddr);
> > -
> > +	pmdp_clear_flush(vma, address, pmd);
> >  	set_pmd_at(mm, haddr, pmd, entry);
> > +	page_add_new_anon_rmap(new_page, vma, haddr);
> >  	update_mmu_cache_pmd(vma, address, &entry);
> >  	page_remove_rmap(page);
> >  	/*
> 
> pmdp_clear_flush should have used haddr

Dang, we both discovered this over the weekend? :)

In related news, it looks like update_mmu_cache_pmd should
probably use haddr, too...

----

Subject: mm,numa: make THP migration mmu calls use haddr

The THP NUMA migration function migrate_misplaced_transhuge_page makes
several calls into the architecture specific MMU code. Those calls all
expect the virtual address of the huge page boundary, not the fault
address from somewhere inside the huge page.

This fixes the below bug.

[   80.106362] kernel BUG at mm/pgtable-generic.c:103! 
...
[   80.333720] Call Trace: 
[   80.336450]  [<ffffffff811d5f8b>] migrate_misplaced_transhuge_page+0x1eb/0x500 
[   80.344505]  [<ffffffff811d8883>] do_huge_pmd_numa_page+0x1a3/0x330 
[   80.351497]  [<ffffffff811a3cc5>] handle_mm_fault+0x285/0x370 
[   80.357898]  [<ffffffff816d7df2>] __do_page_fault+0x172/0x5a0 
[   80.364307]  [<ffffffff8137a3dd>] ? trace_hardirqs_off_thunk+0x3a/0x3c 
[   80.371585]  [<ffffffff816d822e>] do_page_fault+0xe/0x10 
[   80.377510]  [<ffffffff816d41c8>] page_fault+0x28/0x30 

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
---
 mm/migrate.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 1e1dbc9..5454151 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1736,10 +1736,10 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 	entry = pmd_mkhuge(entry);
 
-	pmdp_clear_flush(vma, address, pmd);
+	pmdp_clear_flush(vma, haddr, pmd);
 	set_pmd_at(mm, haddr, pmd, entry);
 	page_add_new_anon_rmap(new_page, vma, haddr);
-	update_mmu_cache_pmd(vma, address, &entry);
+	update_mmu_cache_pmd(vma, haddr, &entry);
 	page_remove_rmap(page);
 	/*
 	 * Finish the charge transaction under the page table lock to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
