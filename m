Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0A86B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 22:25:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f53so11018588qte.15
        for <linux-mm@kvack.org>; Thu, 04 May 2017 19:25:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q3si3220940qte.107.2017.05.04.19.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 19:25:01 -0700 (PDT)
Subject: Re: [PATCH] swap: add block io poll in swapin path
References: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
 <b1fec49f-5e22-3d0c-1725-09625b3047b0@fb.com>
 <20170504212725.GA26681@MacBook-Pro.dhcp.thefacebook.com>
 <196d941b-39cb-4526-1763-e480ba326a98@fb.com>
 <045D8A5597B93E4EBEDDCBF1FC15F50935CE8E53@fmsmsx104.amr.corp.intel.com>
From: Jens Axboe <axboe@fb.com>
Message-ID: <c4a4f340-2f02-c1ec-8682-20d4ca2763ba@fb.com>
Date: Thu, 4 May 2017 20:24:48 -0600
MIME-Version: 1.0
In-Reply-To: <045D8A5597B93E4EBEDDCBF1FC15F50935CE8E53@fmsmsx104.amr.corp.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>, Shaohua Li <shli@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kernel-team@fb.com" <Kernel-team@fb.com>, "Huang, Ying" <ying.huang@intel.com>

On 05/04/2017 05:23 PM, Chen, Tim C wrote:
>> -----Original Message-----
>> From: Jens Axboe [mailto:axboe@fb.com]
>> Sent: Thursday, May 04, 2017 2:29 PM
>> To: Shaohua Li
>> Cc: linux-mm@kvack.org; Andrew Morton; Kernel-team@fb.com; Chen, Tim C;
>> Huang, Ying
>> Subject: Re: [PATCH] swap: add block io poll in swapin path
>>
>> On 05/04/2017 03:27 PM, Shaohua Li wrote:
>>> On Thu, May 04, 2017 at 02:53:59PM -0600, Jens Axboe wrote:
>>>> On 05/04/2017 02:42 PM, Shaohua Li wrote:
>>>>> For fast flash disk, async IO could introduce overhead because of
>>>>> context switch. block-mq now supports IO poll, which improves
>>>>> performance and latency a lot. swapin is a good place to use this
>>>>> technique, because the task is waitting for the swapin page to
>>>>> continue execution.
>>>>
>>>> Nitfy!
>>>>
>>>>> In my virtual machine, directly read 4k data from a NVMe with iopoll
>>>>> is about 60% better than that without poll. With iopoll support in
>>>>> swapin patch, my microbenchmark (a task does random memory write) is
>>>>> about 10% ~ 25% faster. CPU utilization increases a lot though, 2x
>>>>> and even 3x CPU utilization. This will depend on disk speed though.
>>>>> While iopoll in swapin isn't intended for all usage cases, it's a
>>>>> win for latency sensistive workloads with high speed swap disk.
>>>>> block layer has knob to control poll in runtime. If poll isn't
>>>>> enabled in block layer, there should be no noticeable change in swapin.
>>>>
>>>> Did you try with hybrid polling enabled? We should be able to achieve
>>>> most of the latency win at much less CPU cost with that.
>>>
>>> Hybrid poll is much slower than classic in my test, I tried different settings.
>>> maybe because this is a vm though.
>>
>> It's probably a vm issue, I bet the timed sleep are just too slow to be useful in a
>> vm.
>>
> 
> The speedup is quite nice.  The high CPU utilization is somewhat of a
> concern.   But this is directly proportional to the poll time or
> latency of the drive's response.  The latest generation of SSD drive's
> latency is a factor of 7 or more compared to the previous one, so the
> poll time could go down quite a bit, depending on what drive you were
> using in your test.

That was my point with the hybrid comment. In hybrid mode, there's no
reason why we can't get the same latencies as pure polling, at a
drastically reduced overhead. The latencies of the drive should not
matter, as we use the actual completion times to decide how long to
sleep and spin.

There's room for a bit of improvement, though. We should be tracking the
time it takes to do sleep+wakeup, and factor that into our wait cycle.
Currently we just blindly use half the average completion time. But even
with that, testing by others have shown basically identical latencies
with hybrid polling, burning only half a core instead of a full one.
Compared to strict sync irq driven mode, that's still a bit higher in
terms of CPU, but not really that much.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
