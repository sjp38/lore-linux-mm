Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3D292802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 21:34:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u17so227206949pfa.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:34:12 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id n5si11595678pfn.374.2017.07.27.18.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 18:34:11 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id q85so19402374pfq.2
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:34:11 -0700 (PDT)
Date: Fri, 28 Jul 2017 10:34:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 1/2] mm: migrate: prevent racy access to
 tlb_flush_pending
Message-ID: <20170728013423.GA358@jagdpanzerIV.localdomain>
References: <20170727114015.3452-1-namit@vmware.com>
 <20170727114015.3452-2-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727114015.3452-2-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

just my 5 silly cents,

On (07/27/17 04:40), Nadav Amit wrote:
[..]
>  static inline void set_tlb_flush_pending(struct mm_struct *mm)
>  {
> -	mm->tlb_flush_pending = true;
> +	atomic_inc(&mm->tlb_flush_pending);
>  
>  	/*
>  	 * Guarantee that the tlb_flush_pending store does not leak into the
> @@ -544,7 +544,7 @@ static inline void set_tlb_flush_pending(struct mm_struct *mm)
>  static inline void clear_tlb_flush_pending(struct mm_struct *mm)
>  {
>  	barrier();
> -	mm->tlb_flush_pending = false;
> +	atomic_dec(&mm->tlb_flush_pending);
>  }

so, _technically_, set_tlb_flush_pending() can be nested, right? IOW,

	set_tlb_flush_pending()
	set_tlb_flush_pending()
	flush_tlb_range()
	clear_tlb_flush_pending()
	clear_tlb_flush_pending()  // if we miss this one, then
				   // ->tlb_flush_pending is !clear,
				   // even though we called
				   // clear_tlb_flush_pending()

if so then set_ and clear_ are a bit misleading names for something
that does atomic_inc()/atomic_dec() internally.

especially when one sees this part

> -	clear_tlb_flush_pending(mm);
> +#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> +	atomic_set(&mm->tlb_flush_pending, 0);
> +#endif

so we have clear_tlb_flush_pending() function which probably should
set it to 0 as the name suggests (I see what you did tho), yet still
do atomic_set() under ifdef-s.

well, just nitpicks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
