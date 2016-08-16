Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 548D46B025E
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:44:41 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id f123so152195924ywd.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 00:44:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sx4si24078137wjb.213.2016.08.16.00.44.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 00:44:40 -0700 (PDT)
Subject: Re: OOM killer changes
References: <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160816031222.GC16913@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b6cf97a4-9260-0b9a-d2f7-00905325d773@suse.cz>
Date: Tue, 16 Aug 2016 09:44:34 +0200
MIME-Version: 1.0
In-Reply-To: <20160816031222.GC16913@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/16/2016 05:12 AM, Joonsoo Kim wrote:
> On Mon, Aug 15, 2016 at 11:16:36AM +0200, Vlastimil Babka wrote:
>> On 08/15/2016 06:48 AM, Ralf-Peter Rohbeck wrote:
>>> On 02.08.2016 12:25, Ralf-Peter Rohbeck wrote:
>>>>
>>> Took me a little longer than expected due to work. The failure wouldn't 
>>> happen for a while and so I started a couple of scripts and let them 
>>> run. When I checked today the server didn't respond on the network and 
>>> sure enough it had killed everything. This is with 4.7.0 with the config 
>>> based on Debian 4.7-rc7.
>>>
>>> trace_pipe got a little big (5GB) so I uploaded the logs to 
>>> https://filebin.net/box0wycfouvhl6sr/OOM_4.7.0.tar.bz2. before_btrfs is 
>>> before the btrfs filesystems were mounted.
>>> I did run a btrfs balance because it creates IO load and I needed to 
>>> balance anyway. Maybe that's what caused it?
>>
>> pgmigrate_success        46738962
>> pgmigrate_fail          135649772
>> compact_migrate_scanned 309726659
>> compact_free_scanned   9715615169
>> compact_isolated        229689596
>> compact_stall 4777
>> compact_fail 3068
>> compact_success 1709
>> compact_daemon_wake 207834
>>
>> The migration failures are quite enormous. Very quick analysis of the
>> trace seems to confirm that these are mostly "real", as opposed to result
>> of failure to isolate free pages for migration targets, although the free
>> scanner spent a lot of time:
> 
> I don't think that main reason of OOM is 'real' migration failure.
> If it is the case, compaction would find next migratable pages and
> eventually some of pages would be migrated successfully.
> 
> pagetypeinfo shows that there are too many unmovable pageblock.

Hmm, well spotted. And also somewhat suspicious, I would expect
filesystem activity to result in reclaimable allocations, not unmovable
(not that it makes any difference for compaction).

Checking nr_slab_* in zoneinfo shows that it really should be mostly
reclaimable:

nr_slab_reclaimable 0
nr_slab_unreclaimable 0
nr_slab_reclaimable 32709
nr_slab_unreclaimable 2764
nr_slab_reclaimable 101525
nr_slab_unreclaimable 10852

Compared with:

Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic      Isolate 
Node 0, zone      DMA            1            7            0            0            0 
Node 0, zone    DMA32          893           72           51            0            0 
Node 0, zone   Normal         2780          155          137            0            0 

We have 188 reclaimable blocks, that's 96256 pages. sum of nr_slab_reclaimable
is 134234, which suggests some fallbacks into unmovable blocks. But the rest
of all of those unmovable pageblocks must be filled by something else... some
btrfs buffers maybe?

> Freepage scanner don't scan those pageblocks so there is a large
> possibility that it cannot find freepages even if the system has many
> freepages. I think that this is the root cause of the problem.
> 
> It's better to check that following work-around help the problem.

Yes this might be good idea, minimally for higher compaction priorities.

Thanks.

> Thanks.
> 
> ------------>8-----------
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9affb29..965eddd 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1082,10 +1082,6 @@ static void isolate_freepages(struct compact_control *cc)
>                 if (!page)
>                         continue;
>  
> -               /* Check the block is suitable for migration */
> -               if (!suitable_migration_target(page))
> -                       continue;
> -
>                 /* If isolation recently failed, do not retry */
>                 if (!isolation_suitable(cc, page))
>                         continue;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
