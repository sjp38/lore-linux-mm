Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 427C26B000D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 05:42:54 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l16-v6so3823755edq.18
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 02:42:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6-v6si2558985edj.407.2018.08.06.02.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 02:42:52 -0700 (PDT)
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
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
 <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
Date: Mon, 6 Aug 2018 11:40:28 +0200
MIME-Version: 1.0
In-Reply-To: <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On 08/03/2018 04:13 PM, Marinko Catovic wrote:
> Thanks for the analysis.
> 
> So since I am no mem management dev, what exactly does this mean?
> Is there any way of workaround or quickfix or something that can/will
> be fixed at some point in time?

Workaround would be the manual / periodic cache flushing, unfortunately.

Maybe a memcg with kmemcg limit? Michal could know more.

A long-term generic solution will be much harder to find :(

> I can not imagine that I am the only one who is affected by this, nor do I
> know why my use case would be so much different from any other.
> Most 'cloud' services should be affected as well.

Hmm, either your workload is specific in being hungry for fs metadata
and not much data (page cache). And/Or there's some source of the
high-order allocations that others don't have, possibly related to some
piece of hardware?

> Tell me if you need any other snapshots or whatever info.
> 
> 2018-08-02 18:15 GMT+02:00 Vlastimil Babka <vbabka@suse.cz
> <mailto:vbabka@suse.cz>>:
> 
>     On 07/31/2018 12:08 AM, Marinko Catovic wrote:
>     > 
>     >> Can you provide (a single snapshot) /proc/pagetypeinfo and
>     >> /proc/slabinfo from a system that's currently experiencing the issue,
>     >> also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.
>     > 
>     > your request came in just one day after I 2>drop_caches again when the
>     > ram usage
>     > was really really low again. Up until now it did not reoccur on any of
>     > the 2 hosts,
>     > where one shows 550MB/11G with 37G of totally free ram for now - so not
>     > that low
>     > like last time when I dropped it, I think it was like 300M/8G or so, but
>     > I hope it helps:
> 
>     Thanks.
> 
>     > /proc/pagetypeinfoA  https://pastebin.com/6QWEZagL
> 
>     Yep, looks like fragmented by reclaimable slabs:
> 
>     NodeA  A  0, zoneA  A Normal, typeA  A  UnmovableA  29101A  32754A  A 8372A 
>     A 2790A  A 1334A  A  354A  A  A 23A  A  A  3A  A  A  4A  A  A  0A  A  A  0
>     NodeA  A  0, zoneA  A Normal, typeA  A  A  Movable 142449A  83386A  99426A 
>     69177A  36761A  12931A  A 1378A  A  A 24A  A  A  0A  A  A  0A  A  A  0
>     NodeA  A  0, zoneA  A Normal, typeA  Reclaimable 467195 530638 355045
>     192638A  80358A  15627A  A 2029A  A  231A  A  A 18A  A  A  0A  A  A  0
> 
>     Number of blocks typeA  A  A UnmovableA  A  A  MovableA  ReclaimableA 
>     A HighAtomicA  A  A  Isolate
>     Node 0, zoneA  A  A  DMAA  A  A  A  A  A  1A  A  A  A  A  A  7A  A  A  A  A  A  0A  A  A  A 
>     A  A  0A  A  A  A  A  A  0
>     Node 0, zoneA  A  DMA32A  A  A  A  A  A 34A  A  A  A  A  703A  A  A  A  A  375A  A  A  A 
>     A  A  0A  A  A  A  A  A  0
>     Node 0, zoneA  A NormalA  A  A  A  A 1672A  A  A  A  14276A  A  A  A  15659A  A  A  A 
>     A  A  1A  A  A  A  A  A  0
> 
>     Half of the memory is marked as reclaimable (2 megabyte) pageblocks.
>     zoneinfo has nr_slab_reclaimable 1679817 so the reclaimable slabs occupy
>     only 3280 (6G) pageblocks, yet they are spread over 5 times as much.
>     It's also possible they pollute the Movable pageblocks as well, but the
>     stats can't tell us. Either the page grouping mobility heuristics are
>     broken here, or the worst case scenario happened - memory was at
>     some point
>     really wholly filled with reclaimable slabs, and the rather random
>     reclaim
>     did not result in whole pageblocks being freed.
> 
>     > /proc/slabinfoA  https://pastebin.com/81QAFgke
> 
>     Largest caches seem to be:
>     # nameA  A  A  A  A  A  <active_objs> <num_objs> <objsize> <objperslab>
>     <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> :
>     slabdata <active_slabs> <num_slabs> <sharedavail>
>     ext4_inode_cacheA  3107754 3759573A  A 1080A  A  3A  A  1 : tunablesA  A 24A 
>     A 12A  A  8 : slabdata 1253191 1253191A  A  A  0
>     dentryA  A  A  A  A  A  2840237 7328181A  A  192A  A 21A  A  1 : tunablesA  120A 
>     A 60A  A  8 : slabdata 348961 348961A  A  120
> 
>     The internal framentation of dentry cache is significant as well.
>     Dunno if some of those objects pin movable pages as well...
> 
>     So looks like there's insufficient slab reclaim (shrinker activity), and
>     possibly problems with page grouping by mobility heuristics as well...
> 
>     > /proc/vmstatA  https://pastebin.com/S7mrQx1s
>     > /proc/zoneinfoA  https://pastebin.com/csGeqNyX
>     >
>     > also please note - whether this makes any difference: there is no swap
>     > file/partition
>     > I am using this without swap space. imho this should not be
>     necessary since
>     > applications running on the hosts would not consume more than
>     20GB, the rest
>     > should be used by buffers/cache.
>     >
> 
> 
