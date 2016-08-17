Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 300F76B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 04:16:12 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id r91so230785310uar.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:16:12 -0700 (PDT)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id c8si7253040vke.43.2016.08.17.01.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 01:16:11 -0700 (PDT)
Received: by mail-ua0-x243.google.com with SMTP id 74so8505832uau.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:16:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8db47fdf-2d6a-d234-479e-6cc81be98655@suse.cz>
References: <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz> <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz> <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com> <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com> <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz> <20160816031222.GC16913@js1304-P5Q-DELUXE>
 <ef85bac4-cbaa-8def-bf76-11741301dc87@Quantum.com> <8db47fdf-2d6a-d234-479e-6cc81be98655@suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Wed, 17 Aug 2016 17:16:10 +0900
Message-ID: <CAAmzW4M0gmhn1Nub=kB-4gfxviCunmWYEMhj-uVfX+k5pVtmeA@mail.gmail.com>
Subject: Re: OOM killer changes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-08-17 16:56 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 08/17/2016 06:48 AM, Ralf-Peter Rohbeck wrote:
>>> ------------>8-----------
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 9affb29..965eddd 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -1082,10 +1082,6 @@ static void isolate_freepages(struct compact_control *cc)
>>>                  if (!page)
>>>                          continue;
>>>
>>> -               /* Check the block is suitable for migration */
>>> -               if (!suitable_migration_target(page))
>>> -                       continue;
>>> -
>>>                  /* If isolation recently failed, do not retry */
>>>                  if (!isolation_suitable(cc, page))
>>>                          continue;
>>>
>> That seemed to help a little (subjectively) but still OOM killed a
>> kernel build. The logs are attached.
>
>> grep XXX messages
> Aug 16 20:29:13 fs kernel: [ 6850.467250] XXX: compaction_failed
>
> pagetypeinfo_after:
> Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic      Isolate
> Node 0, zone      DMA            1            7            0            0            0
> Node 0, zone    DMA32          879           93           44            0            0
> Node 0, zone   Normal         2862          136           74            0            0
>
> vmstat_after:
> pgmigrate_success 5123
> pgmigrate_fail 4106
> compact_migrate_scanned 62019
> compact_free_scanned 44314328
> compact_isolated 18572
> compact_stall 327
> compact_fail 236
> compact_success 91
> compact_daemon_wake 1162
>
>> grep try_to_release trace_pipe.log | wc -l
> 0
>
> Again, migration failures are there but not so many, and failures to
> isolate freepages stand out. I assume it's because the kernel build
> workload and not the btrfs balance one.
>
> I think the patches in mmotm could make compaction try harder and use
> more appropriate watermarks, but it's not guaranteed that will help.
> The free scanner seems to become more and more a fundamental problem.

Following trace is last compaction trial before triggering OOM.
Free scanner start at 0x27fe00 but actual scan happens at 0x186a00.
And, although log is snipped, compaction fails because it doesn't find
any freepage.

It skips half of pageblocks in that zone. It would be due to
migratetype or skipbit.
Both Vlastimil's recent patches and my work-around should be applied to solve
this problem.

Other part of trace looks like that my work-around isn't applied.
Could you confirm
that?

Thanks.

              sh-14869 [000] ....  6850.456639:
mm_compaction_try_to_compact_pages: order=2 gfp_mask=0x27000c0 mode=1
              sh-14869 [000] ....  6850.456640:
mm_compaction_suitable: node=0 zone=Normal   order=2 ret=continue
              sh-14869 [000] ....  6850.456641: mm_compaction_begin:
zone_start=0x100000 migrate_pfn=0x100000 free_pfn=0x27fe00
zone_end=0x280000, mode=sync
              sh-14869 [000] ....  6850.456641:
mm_compaction_finished: node=0 zone=Normal   order=2 ret=continue
              sh-14869 [000] ....  6850.456648:
mm_compaction_isolate_migratepages: range=(0x100000 ~ 0x10002d)
nr_scanned=45 nr_taken=32
              sh-14869 [000] ....  6850.456834:
mm_compaction_isolate_freepages: range=(0x186a00 ~ 0x186c00)
nr_scanned=512 nr_taken=0
              sh-14869 [000] ....  6850.456842:
mm_compaction_isolate_freepages: range=(0x186800 ~ 0x186a00)
nr_scanned=512 nr_taken=0


> And I really wonder how did all those unmovable pageblocks happen.
> AFAICS zoneinfo shows that most of memory is occupied by file lru pages.
> These should be movable.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
