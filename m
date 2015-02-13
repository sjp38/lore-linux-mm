Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0E78E6B0081
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 13:10:39 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id hz1so20383588pad.9
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 10:10:38 -0800 (PST)
Received: from nm50.bullet.mail.gq1.yahoo.com (nm50.bullet.mail.gq1.yahoo.com. [67.195.87.86])
        by mx.google.com with ESMTPS id bz4si2082039pdb.113.2015.02.13.10.10.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 10:10:38 -0800 (PST)
Date: Fri, 13 Feb 2015 18:07:10 +0000 (UTC)
From: Cheng Rk <crquan@ymail.com>
Reply-To: Cheng Rk <crquan@ymail.com>
Message-ID: <1447872036.2240531.1423850830637.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <131740628.109294.1423821136530.JavaMail.yahoo@mail.yahoo.com>
References: <CALYGNiP-CKYsVzLpUdUWM3ftfg1vPvKWQvbegXVLoNovtNWS6Q@mail.gmail.com> <131740628.109294.1423821136530.JavaMail.yahoo@mail.yahoo.com>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>



On Thursday, February 12, 2015 11:34 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:

>>
>> -bash-4.2$ sudo losetup -a
>> /dev/loop0: [0005]:16512 (/dev/dm-2)
>> -bash-4.2$ free -m
>>                 total          used         free      shared       buffers     cached
>> Mem:             48094         46081         2012          40         40324       2085
>> -/+ buffers/cache:              3671       44422
>> Swap:             8191             5         8186
>>
>> I've tried sysctl mm.vfs_cache_pressure=10000 but that seems working to Cached
>> memory, I wonder is there another sysctl for reclaming Buffers?

> AFAIK "Buffers" is just a page-cache of block devices.
> From reclaimer's point of view they have no difference from file page-cache.

> Could you post oom-killer log, there should be a lot of numbers
> describing memory state.


in this case, 40GB memory got stuck in Buffers, and 90+% of them are reclaimable (can be verified by vm.drop_caches manual reclaim)
if Buffers are treated same as Cached, why mm.vfs_cache_pressure=10000 (or even I tried up to 1,000,000) can't get Buffers reclaimed early?

I have some oom-killer msgs but were with older kernels, after set vm.overcommit_memory=2, it simply returns -ENOMEM, unable to spawn any new container, why doesn't it even try to reclaim some memory from those 40GB Buffers,


The Buffers in use is 44GB, from total memory of 48GB, it's the Inactive(file) 41GB consumed the most, why this much memory is reclaimable to vm/drop_caches but not to application requesting memory?


Is there a sysctl can make Buffers / Inactive(file) be reclaimed early and often ?

(since to this system it's mounting /dev/loop0 and have a lot of small temporary files created there, keeping them in Buffers for longer time is useless, how can I make it reclaimed earlier than later when applications need memory? )



-bash-4.2$ cat /proc/meminfo 
MemTotal:       49286656 kB
MemFree:         2040944 kB
MemAvailable:   47809824 kB
Buffers:        44258776 kB
Cached:           456868 kB
SwapCached:            0 kB
Active:          3783592 kB
Inactive:       41535112 kB
Active(anon):     402776 kB
Inactive(anon):   282308 kB
Active(file):    3380816 kB
Inactive(file): 41252804 kB


Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
