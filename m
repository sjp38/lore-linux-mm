Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2126B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 03:56:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g124so221251691qkd.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 00:56:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 75si24394423wmy.134.2016.08.17.00.56.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Aug 2016 00:56:29 -0700 (PDT)
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
 <ef85bac4-cbaa-8def-bf76-11741301dc87@Quantum.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8db47fdf-2d6a-d234-479e-6cc81be98655@suse.cz>
Date: Wed, 17 Aug 2016 09:56:27 +0200
MIME-Version: 1.0
In-Reply-To: <ef85bac4-cbaa-8def-bf76-11741301dc87@Quantum.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/17/2016 06:48 AM, Ralf-Peter Rohbeck wrote:
>> ------------>8-----------
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 9affb29..965eddd 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1082,10 +1082,6 @@ static void isolate_freepages(struct compact_control *cc)
>>                  if (!page)
>>                          continue;
>>   
>> -               /* Check the block is suitable for migration */
>> -               if (!suitable_migration_target(page))
>> -                       continue;
>> -
>>                  /* If isolation recently failed, do not retry */
>>                  if (!isolation_suitable(cc, page))
>>                          continue;
>>
> That seemed to help a little (subjectively) but still OOM killed a 
> kernel build. The logs are attached.

> grep XXX messages 
Aug 16 20:29:13 fs kernel: [ 6850.467250] XXX: compaction_failed

pagetypeinfo_after:
Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic      Isolate 
Node 0, zone      DMA            1            7            0            0            0 
Node 0, zone    DMA32          879           93           44            0            0 
Node 0, zone   Normal         2862          136           74            0            0 

vmstat_after:
pgmigrate_success 5123
pgmigrate_fail 4106
compact_migrate_scanned 62019
compact_free_scanned 44314328
compact_isolated 18572
compact_stall 327
compact_fail 236
compact_success 91
compact_daemon_wake 1162

> grep try_to_release trace_pipe.log | wc -l
0

Again, migration failures are there but not so many, and failures to
isolate freepages stand out. I assume it's because the kernel build
workload and not the btrfs balance one.

I think the patches in mmotm could make compaction try harder and use
more appropriate watermarks, but it's not guaranteed that will help.
The free scanner seems to become more and more a fundamental problem.

And I really wonder how did all those unmovable pageblocks happen.
AFAICS zoneinfo shows that most of memory is occupied by file lru pages.
These should be movable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
