Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19F3C6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:40:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n4-v6so2504107edr.5
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:40:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 37-v6si3768214edt.319.2018.07.30.07.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:40:49 -0700 (PDT)
Date: Mon, 30 Jul 2018 16:40:48 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180730144048.GW24267@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz>
 <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz>
 <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz>
 <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, linux-mm@kvack.org

On Fri 27-07-18 13:15:33, Vlastimil Babka wrote:
> On 07/21/2018 12:03 AM, Marinko Catovic wrote:
> > I let this run for 3 days now, so it is quite a lot, there you go:
> > https://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz
> 
> The stats show that compaction has very bad results. Between first and
> last snapshot, compact_fail grew by 80k and compact_success by 1300.
> High-order allocations will thus cycle between (failing) compaction and
> reclaim that removes the buffer/caches from memory.

I guess you are right. I've just looked at random large direct reclaim activity
$ grep -w pgscan_direct  vmstat*| awk  '{diff=$2-old; if (old && diff > 100000) printf "%s %d\n", $1, diff; old=$2}'
vmstat.1531957422:pgscan_direct 114334
vmstat.1532047588:pgscan_direct 111796

$ paste-with-diff.sh vmstat.1532047578 vmstat.1532047588 | grep "pgscan\|pgsteal\|compact\|pgalloc" | sort
# counter			value1		value2-value1
compact_daemon_free_scanned     2628160139      0
compact_daemon_migrate_scanned  797948703       0
compact_daemon_wake     23634   0
compact_fail    124806  108
compact_free_scanned    226181616304    295560271
compact_isolated        2881602028      480577
compact_migrate_scanned 147900786550    27834455
compact_stall   146749  108
compact_success 21943   0
pgalloc_dma     0       0
pgalloc_dma32   1577060946      10752
pgalloc_movable 0       0
pgalloc_normal  29389246430     343249
pgscan_direct   737335028       111796
pgscan_direct_throttle  0       0
pgscan_kswapd   1177909394      0
pgsteal_direct  704542843       111784
pgsteal_kswapd  898170720       0

There is zero kswapd activity so this must have been higher order
allocation activity and all the direct compaction failed so we keep
reclaiming.
-- 
Michal Hocko
SUSE Labs
