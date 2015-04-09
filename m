Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 864E16B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 16:47:03 -0400 (EDT)
Received: by pdea3 with SMTP id a3so165003095pde.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 13:47:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yj2si22699798pbc.91.2015.04.09.13.47.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 13:47:02 -0700 (PDT)
Date: Thu, 9 Apr 2015 13:47:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: show free pages per each migrate type
Message-Id: <20150409134701.5903cb5217f5742bbacc73da@linux-foundation.org>
In-Reply-To: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
References: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neil Zhang <neilzhang1123@hotmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 9 Apr 2015 10:19:10 +0800 Neil Zhang <neilzhang1123@hotmail.com> wrote:

> show detailed free pages per each migrate type in show_free_areas.
> 
> After apply this patch, the log printed out will be changed from
> 
> [   558.212844@0] Normal: 218*4kB (UEMC) 207*8kB (UEMC) 126*16kB (UEMC) 21*32kB (UC) 5*64kB (C) 3*128kB (C) 1*256kB (C) 1*512kB (C) 0*1024kB 0*2048kB 1*4096kB (R) = 10784kB
> [   558.227840@0] HighMem: 3*4kB (UMR) 3*8kB (UMR) 2*16kB (UM) 3*32kB (UMR) 0*64kB 1*128kB (M) 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 548kB
> 
> to
> 
> [   806.506450@1] Normal: 8969*4kB 4370*8kB 2*16kB 3*32kB 2*64kB 3*128kB 3*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 74804kB
> [   806.517456@1]       orders:      0      1      2      3      4      5      6      7      8      9     10
> [   806.527077@1]    Unmovable:   8287   4370      0      0      0      0      0      0      0      0      0
> [   806.536699@1]  Reclaimable:    681      0      0      0      0      0      0      0      0      0      0
> [   806.546321@1]      Movable:      1      0      0      0      0      0      0      0      0      0      0
> [   806.555942@1]      Reserve:      0      0      2      3      2      3      3      1      0      1      0
> [   806.565564@1]          CMA:      0      0      0      0      0      0      0      0      0      0      0
> [   806.575187@1]      Isolate:      0      0      0      0      0      0      0      0      0      0      0
> [   806.584810@1] HighMem: 80*4kB 15*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 440kB
> [   806.595383@1]       orders:      0      1      2      3      4      5      6      7      8      9     10
> [   806.605004@1]    Unmovable:     12      0      0      0      0      0      0      0      0      0      0
> [   806.614626@1]  Reclaimable:      0      0      0      0      0      0      0      0      0      0      0
> [   806.624248@1]      Movable:     11     15      0      0      0      0      0      0      0      0      0
> [   806.633869@1]      Reserve:     57      0      0      0      0      0      0      0      0      0      0
> [   806.643491@1]          CMA:      0      0      0      0      0      0      0      0      0      0      0
> [   806.653113@1]      Isolate:      0      0      0      0      0      0      0      0      0      0      0

Thanks.  The proposed output does indeed look a lot better.

The columns don't line up, but I guess we can live with that ;)


> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3327,7 +3313,7 @@ void show_free_areas(unsigned int filter)
>  
>  	for_each_populated_zone(zone) {
>  		unsigned long nr[MAX_ORDER], flags, order, total = 0;
> -		unsigned char types[MAX_ORDER];
> +		unsigned long nr_free[MAX_ORDER][MIGRATE_TYPES], mtype;
>  
>  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>  			continue;

nr_free[][] is an 8x11 array of 8, I think?  That's 704 bytes of stack,
and show_free_areas() is called from very deep call stacks - from the
oom-killer, for example.  We shouldn't do this.

I think we can eliminate nr_free[][]:

> +		for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
> +			printk("%12s: ", migratetype_names[mtype]);
> +			for (order = 0; order < MAX_ORDER; order++)
> +				printk("%6lu ", nr_free[order][mtype]);
> +			printk("\n");
> +		}

In the above loop, take zone->lock and calculate the nr_free for this
particular order/mtype, then release zone->lock.

That will be slower, but show_free_areas() doesn't need to be fast.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
