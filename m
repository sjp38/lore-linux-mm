Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 76ABD6B0035
	for <linux-mm@kvack.org>; Sun,  7 Sep 2014 02:32:43 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so14050168vcb.16
        for <linux-mm@kvack.org>; Sat, 06 Sep 2014 23:32:43 -0700 (PDT)
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
        by mx.google.com with ESMTPS id k7si3382893vdf.18.2014.09.06.23.32.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Sep 2014 23:32:42 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id hy10so619215vcb.31
        for <linux-mm@kvack.org>; Sat, 06 Sep 2014 23:32:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140905101451.GF17501@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de> <53E4EC53.1050904@suse.cz>
 <20140811121241.GD7970@suse.de> <53E8B83D.1070004@suse.cz>
 <20140902140116.GD29501@cmpxchg.org> <20140905101451.GF17501@suse.de>
From: Leon Romanovsky <leon@leon.nu>
Date: Sun, 7 Sep 2014 09:32:20 +0300
Message-ID: <CALq1K=JO2b-=iq40RRvK8JFFbrzyH5EyAp5jyS50CeV0P3eQcA@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: Fix setting of ZONE_FAIR_DEPLETED on UP
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Hi Mel,
>         __mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> -       if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
> +       if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0 &&
zone_page_state is declared to return unsigned long value [1], so it
should never be below 0.
So interesting question: what zone_page_state will return for negative
atomic_long_read(&zone->vm_stat[item]) ?

130 static inline unsigned long zone_page_state(struct zone *zone,
131                                         enum zone_stat_item item)
132 {
133         long x = atomic_long_read(&zone->vm_stat[item]);
134 #ifdef CONFIG_SMP
135         if (x < 0)
136                 x = 0;
137 #endif
138         return x;
139 }

[1] https://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/tree/include/linux/vmstat.h#n130

-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
