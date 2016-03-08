Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B1F226B0257
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:57:03 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so132786977wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:57:03 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id q14si21046896wmb.105.2016.03.08.05.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:57:02 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id p65so4237018wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:57:02 -0800 (PST)
Date: Tue, 8 Mar 2016 14:57:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160308135700.GH13542@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <20160308095824.GA457@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160308095824.GA457@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue 08-03-16 18:58:24, Sergey Senozhatsky wrote:
> On (03/07/16 17:08), Michal Hocko wrote:
> > On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> > > Andrew,
> > > could you queue this one as well, please? This is more a band aid than a
> > > real solution which I will be working on as soon as I am able to
> > > reproduce the issue but the patch should help to some degree at least.
> > 
> > Joonsoo wasn't very happy about this approach so let me try a different
> > way. What do you think about the following? Hugh, Sergey does it help
> > for your load? I have tested it with the Hugh's load and there was no
> > major difference from the previous testing so at least nothing has blown
> > up as I am not able to reproduce the issue here.
> > 
> > Other changes in the compaction are still needed but I would like to not
> > depend on them right now.
> 
> works fine for me.
> 
> $  cat /proc/vmstat | egrep -e "compact|swap"
> pgsteal_kswapd_dma 7
> pgsteal_kswapd_dma32 6457075
> pgsteal_kswapd_normal 1462767
> pgsteal_kswapd_movable 0
> pgscan_kswapd_dma 18
> pgscan_kswapd_dma32 6544126
> pgscan_kswapd_normal 1495604
> pgscan_kswapd_movable 0
> kswapd_inodesteal 29
> kswapd_low_wmark_hit_quickly 1168
> kswapd_high_wmark_hit_quickly 1627
> compact_migrate_scanned 5762793
> compact_free_scanned 54090239
> compact_isolated 1303895
> compact_stall 1542
> compact_fail 1117
> compact_success 425
> compact_kcompatd_wake 0
> 
> no OOM-kills after 6 rounds of tests.
> 
> Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks for retesting!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
