Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5C516B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 00:48:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j6so99344062qkc.3
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 21:48:20 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id em5si18206607wjb.257.2016.08.14.21.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 21:48:19 -0700 (PDT)
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Subject: Re: OOM killer changes
References: <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
Message-ID: <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
Date: Sun, 14 Aug 2016 21:48:08 -0700
MIME-Version: 1.0
In-Reply-To: <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On 02.08.2016 12:25, Ralf-Peter Rohbeck wrote:
> I can do that but it'll be later this week.
>
> Ralf-Peter
> On 08/02/2016 12:10 AM, Michal Hocko wrote:
>> On Mon 01-08-16 14:27:51, Ralf-Peter Rohbeck wrote:
>>> On 01.08.2016 14:14, Ralf-Peter Rohbeck wrote:
>>>> On 01.08.2016 13:26, Michal Hocko wrote:
>>>>>> sdc, sdd and sde each at max speed, with a little bit of garden
>>>>>> variety IO
>>>>>> on sda and sdb.
>>>>> So do I get it right that the majority of the IO is to those 
>>>>> slower USB
>>>>> disks?  If yes then does lowering the dirty_bytes to something 
>>>>> smaller
>>>>> help?
>>>> ADMIN
>>>> Yes, the vast majority.
>>>>
>>>> I set dirty_bytes to 128MiB and started a fairly IO and memory 
>>>> intensive
>>>> process and the OOM killer kicked in within a few seconds.
>>>>
>>>> Same with 16MiB dirty_bytes and 1MiB.
>>>>
>>>> Some additional IO load from my fast subsystem is enough:
>>>>
>>>> At 1MiB dirty_bytes,
>>>>
>>>> find /btrfs0/ -type f -exec md5sum {} \;
>>>>
>>>> was enough (where /btrfs0 is on a LVM2 LV and the PV is on sda.) It 
>>>> read
>>>> a few dozen files (random stuff with very mixed file sizes, none very
>>>> big) until the OOM killer kicked in.
>>>>
>>>> I'll try 4.6.
>>> With Debian 4.6.0.1 (4.6.4-1) it works: Writing to 3 USB drives and 
>>> running
>>> each of the 3 tests that triggered the OOM killer in parallel, with 
>>> default
>>> dirty settings.
>> Thanks for retesting! Now that it seems you are able to reproduce this,
>> could you do some experiments, please? First of all it would be great to
>> find out why we do not retry the compaction and whether it could make
>> some progress. The patch below will tell us the first part. Tracepoints
>> can tell us the other part. Vlastimil, could you recommend some which
>> would give us some hints without generating way too much output?
>> ---
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 8b3e1341b754..a10b29a918d4 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3274,6 +3274,7 @@ should_compact_retry(struct alloc_context *ac, 
>> int order, int alloc_flags,
>>               *migrate_mode = MIGRATE_SYNC_LIGHT;
>>               return true;
>>           }
>> +        pr_info("XXX: compaction_failed\n");
>>           return false;
>>       }
>>   @@ -3283,8 +3284,12 @@ should_compact_retry(struct alloc_context 
>> *ac, int order, int alloc_flags,
>>        * But do not retry if the given zonelist is not suitable for
>>        * compaction.
>>        */
>> -    if (compaction_withdrawn(compact_result))
>> -        return compaction_zonelist_suitable(ac, order, alloc_flags);
>> +    if (compaction_withdrawn(compact_result)) {
>> +        int ret = compaction_zonelist_suitable(ac, order, alloc_flags);
>> +        if (!ret)
>> +            pr_info("XXX: no zone suitable for compaction\n");
>> +        return ret;
>> +    }
>>         /*
>>        * !costly requests are much more important than __GFP_REPEAT
>> @@ -3299,6 +3304,7 @@ should_compact_retry(struct alloc_context *ac, 
>> int order, int alloc_flags,
>>       if (compaction_retries <= max_retries)
>>           return true;
>>   +    pr_info("XXX: compaction retries fail after %d\n", 
>> compaction_retries);
>>       return false;
>>   }
>>   #else
>>
>
Took me a little longer than expected due to work. The failure wouldn't 
happen for a while and so I started a couple of scripts and let them 
run. When I checked today the server didn't respond on the network and 
sure enough it had killed everything. This is with 4.7.0 with the config 
based on Debian 4.7-rc7.

trace_pipe got a little big (5GB) so I uploaded the logs to 
https://filebin.net/box0wycfouvhl6sr/OOM_4.7.0.tar.bz2. before_btrfs is 
before the btrfs filesystems were mounted.
I did run a btrfs balance because it creates IO load and I needed to 
balance anyway. Maybe that's what caused it?

I'll make the changes requested by Michal and try again.

Thanks,
Ralf-Peter


----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
