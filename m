Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3967E6B0037
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 04:53:06 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so5283271pbb.6
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 01:53:05 -0700 (PDT)
Date: Mon, 30 Sep 2013 09:52:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/63] mm: Close races between THP migration and PMD numa
 clearing
Message-ID: <20130930084735.GA2425@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
 <1380288468-5551-12-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1380288468-5551-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 27, 2013 at 02:26:56PM +0100, Mel Gorman wrote:
> @@ -1732,9 +1732,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>  	entry = pmd_mkhuge(entry);
>  
> -	page_add_new_anon_rmap(new_page, vma, haddr);
> -
> +	pmdp_clear_flush(vma, address, pmd);
>  	set_pmd_at(mm, haddr, pmd, entry);
> +	page_add_new_anon_rmap(new_page, vma, haddr);
>  	update_mmu_cache_pmd(vma, address, &entry);
>  	page_remove_rmap(page);
>  	/*

pmdp_clear_flush should have used haddr

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
