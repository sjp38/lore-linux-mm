Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4A86B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:05:57 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so23896490lbb.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:05:56 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id lk2si8087095lac.107.2015.06.10.01.05.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 01:05:55 -0700 (PDT)
Received: by labko7 with SMTP id ko7so27538675lab.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:05:54 -0700 (PDT)
Date: Wed, 10 Jun 2015 11:05:50 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 3/6] mm: mark dirty bit on swapped-in page
Message-ID: <20150610080550.GC13008@uranus>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
 <1433312145-19386-4-git-send-email-minchan@kernel.org>
 <20150609190737.GV13008@uranus>
 <20150609235206.GB12689@bgram>
 <20150610072305.GB13008@uranus>
 <20150610080035.GA32731@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610080035.GA32731@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Yalin Wang <yalin.wang@sonymobile.com>

On Wed, Jun 10, 2015 at 05:00:35PM +0900, Minchan Kim wrote:
> > 
> > Ah, I recall. If there is no way to escape dirtifying the page in pte itself
> > maybe we should at least not make it softdirty on read faults?
> 
> You mean this? 
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e1c45d0..c95340d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2557,9 +2557,14 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>         inc_mm_counter_fast(mm, MM_ANONPAGES);
>         dec_mm_counter_fast(mm, MM_SWAPENTS);
> -       pte = mk_pte(page, vma->vm_page_prot);
> +
> +       /* Mark dirty bit of page table because MADV_FREE relies on it */
> +       pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
> +       if (!flgas & FAULT_FLAG_WRITE)
> +               pte = pte_clear_flags(pte, _PAGE_SOFT_DIRTY)
> +
>         if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> -               pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> +               pte = maybe_mkwrite(pte, vma);
>                 flags &= ~FAULT_FLAG_WRITE;
>                 ret |= VM_FAULT_WRITE;
>                 exclusive = 1;
> 
> It could be doable if everyone doesn't have strong objection
> on this patchset.
> 
> I will wait more review.

Yeah, something like this. Lets wait for opinions, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
