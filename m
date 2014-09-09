Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5342B6B00A5
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:53:21 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so6734886pdj.37
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:53:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kk6si24708551pdb.192.2014.09.09.12.53.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 12:53:20 -0700 (PDT)
Date: Tue, 9 Sep 2014 12:53:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: Fix setting of ZONE_FAIR_DEPLETED on UP
 v2
Message-Id: <20140909125318.b07aee9f77b5a15d6b3041f1@linux-foundation.org>
In-Reply-To: <20140908115718.GL17501@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
	<1404893588-21371-7-git-send-email-mgorman@suse.de>
	<53E4EC53.1050904@suse.cz>
	<20140811121241.GD7970@suse.de>
	<53E8B83D.1070004@suse.cz>
	<20140902140116.GD29501@cmpxchg.org>
	<20140905101451.GF17501@suse.de>
	<CALq1K=JO2b-=iq40RRvK8JFFbrzyH5EyAp5jyS50CeV0P3eQcA@mail.gmail.com>
	<20140908115718.GL17501@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Leon Romanovsky <leon@leon.nu>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Mon, 8 Sep 2014 12:57:18 +0100 Mel Gorman <mgorman@suse.de> wrote:

> zone_page_state is an API hazard because of the difference in behaviour
> between SMP and UP is very surprising. There is a good reason to allow
> NR_ALLOC_BATCH to go negative -- when the counter is reset the negative
> value takes recent activity into account. This patch makes zone_page_state
> behave the same on SMP and UP as saving one branch on UP is not likely to
> make a measurable performance difference.
> 
> ...
>
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -131,10 +131,8 @@ static inline unsigned long zone_page_state(struct zone *zone,
>  					enum zone_stat_item item)
>  {
>  	long x = atomic_long_read(&zone->vm_stat[item]);
> -#ifdef CONFIG_SMP
>  	if (x < 0)
>  		x = 0;
> -#endif
>  	return x;
>  }

We now have three fixes for the same thing.  I'm presently holding on
to hannes's mm-page_alloc-fix-zone-allocation-fairness-on-up.patch.

Regularizing zone_page_state() in this fashion seems a good idea and is
presumably safe because callers have been tested with SMP.  So unless
shouted at I think I'll queue this one for 3.18?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
