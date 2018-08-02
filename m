Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7D696B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 12:17:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20-v6so968311edq.10
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 09:17:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v13-v6si502126edk.456.2018.08.02.09.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 09:17:45 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz>
 <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz>
 <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz>
 <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
 <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
Date: Thu, 2 Aug 2018 18:15:22 +0200
MIME-Version: 1.0
In-Reply-To: <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On 07/31/2018 12:08 AM, Marinko Catovic wrote:
> 
>> Can you provide (a single snapshot) /proc/pagetypeinfo and
>> /proc/slabinfo from a system that's currently experiencing the issue,
>> also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.
> 
> your request came in just one day after I 2>drop_caches again when the
> ram usage
> was really really low again. Up until now it did not reoccur on any of
> the 2 hosts,
> where one shows 550MB/11G with 37G of totally free ram for now - so not
> that low
> like last time when I dropped it, I think it was like 300M/8G or so, but
> I hope it helps:

Thanks.
 
> /proc/pagetypeinfoA  https://pastebin.com/6QWEZagL

Yep, looks like fragmented by reclaimable slabs:

Node    0, zone   Normal, type    Unmovable  29101  32754   8372   2790   1334    354     23      3      4      0      0 
Node    0, zone   Normal, type      Movable 142449  83386  99426  69177  36761  12931   1378     24      0      0      0 
Node    0, zone   Normal, type  Reclaimable 467195 530638 355045 192638  80358  15627   2029    231     18      0      0 

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic      Isolate 
Node 0, zone      DMA            1            7            0            0            0 
Node 0, zone    DMA32           34          703          375            0            0 
Node 0, zone   Normal         1672        14276        15659            1            0

Half of the memory is marked as reclaimable (2 megabyte) pageblocks.
zoneinfo has nr_slab_reclaimable 1679817 so the reclaimable slabs occupy
only 3280 (6G) pageblocks, yet they are spread over 5 times as much.
It's also possible they pollute the Movable pageblocks as well, but the
stats can't tell us. Either the page grouping mobility heuristics are
broken here, or the worst case scenario happened - memory was at some point
really wholly filled with reclaimable slabs, and the rather random reclaim
did not result in whole pageblocks being freed.

> /proc/slabinfoA  https://pastebin.com/81QAFgke

Largest caches seem to be:
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ext4_inode_cache  3107754 3759573   1080    3    1 : tunables   24   12    8 : slabdata 1253191 1253191      0
dentry            2840237 7328181    192   21    1 : tunables  120   60    8 : slabdata 348961 348961    120

The internal framentation of dentry cache is significant as well.
Dunno if some of those objects pin movable pages as well...

So looks like there's insufficient slab reclaim (shrinker activity), and
possibly problems with page grouping by mobility heuristics as well...

> /proc/vmstatA  https://pastebin.com/S7mrQx1s
> /proc/zoneinfoA  https://pastebin.com/csGeqNyX
> 
> also please note - whether this makes any difference: there is no swap
> file/partition
> I am using this without swap space. imho this should not be necessary since
> applications running on the hosts would not consume more than 20GB, the rest
> should be used by buffers/cache.
> 
