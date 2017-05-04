Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24CD96B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 19:23:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o3so23529627pgn.13
        for <linux-mm@kvack.org>; Thu, 04 May 2017 16:23:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r7si3657462pli.26.2017.05.04.16.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 16:23:18 -0700 (PDT)
From: "Chen, Tim C" <tim.c.chen@intel.com>
Subject: RE: [PATCH] swap: add block io poll in swapin path
Date: Thu, 4 May 2017 23:23:15 +0000
Message-ID: <045D8A5597B93E4EBEDDCBF1FC15F50935CE8E53@fmsmsx104.amr.corp.intel.com>
References: <7dd0349ba5d321af557d7a09e08610f2486ea29e.1493930299.git.shli@fb.com>
 <b1fec49f-5e22-3d0c-1725-09625b3047b0@fb.com>
 <20170504212725.GA26681@MacBook-Pro.dhcp.thefacebook.com>
 <196d941b-39cb-4526-1763-e480ba326a98@fb.com>
In-Reply-To: <196d941b-39cb-4526-1763-e480ba326a98@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Shaohua Li <shli@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kernel-team@fb.com" <Kernel-team@fb.com>, "Huang, Ying" <ying.huang@intel.com>



>-----Original Message-----
>From: Jens Axboe [mailto:axboe@fb.com]
>Sent: Thursday, May 04, 2017 2:29 PM
>To: Shaohua Li
>Cc: linux-mm@kvack.org; Andrew Morton; Kernel-team@fb.com; Chen, Tim C;
>Huang, Ying
>Subject: Re: [PATCH] swap: add block io poll in swapin path
>
>On 05/04/2017 03:27 PM, Shaohua Li wrote:
>> On Thu, May 04, 2017 at 02:53:59PM -0600, Jens Axboe wrote:
>>> On 05/04/2017 02:42 PM, Shaohua Li wrote:
>>>> For fast flash disk, async IO could introduce overhead because of
>>>> context switch. block-mq now supports IO poll, which improves
>>>> performance and latency a lot. swapin is a good place to use this
>>>> technique, because the task is waitting for the swapin page to
>>>> continue execution.
>>>
>>> Nitfy!
>>>
>>>> In my virtual machine, directly read 4k data from a NVMe with iopoll
>>>> is about 60% better than that without poll. With iopoll support in
>>>> swapin patch, my microbenchmark (a task does random memory write) is
>>>> about 10% ~ 25% faster. CPU utilization increases a lot though, 2x
>>>> and even 3x CPU utilization. This will depend on disk speed though.
>>>> While iopoll in swapin isn't intended for all usage cases, it's a
>>>> win for latency sensistive workloads with high speed swap disk.
>>>> block layer has knob to control poll in runtime. If poll isn't
>>>> enabled in block layer, there should be no noticeable change in swapin=
.
>>>
>>> Did you try with hybrid polling enabled? We should be able to achieve
>>> most of the latency win at much less CPU cost with that.
>>
>> Hybrid poll is much slower than classic in my test, I tried different se=
ttings.
>> maybe because this is a vm though.
>
>It's probably a vm issue, I bet the timed sleep are just too slow to be us=
eful in a
>vm.
>

The speedup is quite nice.
The high CPU utilization is somewhat of a concern.   But this is directly
proportional to the poll time or latency of the drive's response.  The late=
st generation of
SSD drive's latency is a factor of 7 or more compared to the previous one, =
so the poll time=20
could go down quite a bit, depending on what drive you were using in your t=
est.
What is the latency and the kind of drive you're using?

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
