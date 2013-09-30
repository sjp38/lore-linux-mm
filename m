Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id E5FF86B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 11:18:10 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so5730148pbc.15
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 08:18:10 -0700 (PDT)
Date: Mon, 30 Sep 2013 16:18:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/63] mm: Close races between THP migration and PMD numa
 clearing
Message-ID: <20130930151802.GG2425@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
 <1380288468-5551-12-git-send-email-mgorman@suse.de>
 <20130930084735.GA2425@suse.de>
 <20130930101048.55fa2acd@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130930101048.55fa2acd@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, jstancek@redhat.com

On Mon, Sep 30, 2013 at 10:10:48AM -0400, Rik van Riel wrote:
> On Mon, 30 Sep 2013 09:52:59 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Fri, Sep 27, 2013 at 02:26:56PM +0100, Mel Gorman wrote:
> > > @@ -1732,9 +1732,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> > >  	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> > >  	entry = pmd_mkhuge(entry);
> > >  
> > > -	page_add_new_anon_rmap(new_page, vma, haddr);
> > > -
> > > +	pmdp_clear_flush(vma, address, pmd);
> > >  	set_pmd_at(mm, haddr, pmd, entry);
> > > +	page_add_new_anon_rmap(new_page, vma, haddr);
> > >  	update_mmu_cache_pmd(vma, address, &entry);
> > >  	page_remove_rmap(page);
> > >  	/*
> > 
> > pmdp_clear_flush should have used haddr
> 
> Dang, we both discovered this over the weekend? :)
> 

Saw it this morning running a debugging build.

> In related news, it looks like update_mmu_cache_pmd should
> probably use haddr, too...
> 

Does anything care? Other calls to update_mmu_cache_pmd are using address
and not haddr so if this is a problem, it's a problem in a few places. Of
the arches that support THP, only sparc appears to do anything useful and
it shifts the address HPAGE_SHIFT so it does not matter if the address
was aligned or not.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
