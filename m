Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 036EF6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:33:06 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p82so10313211pfd.1
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:33:05 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0084.outbound.protection.outlook.com. [104.47.42.84])
        by mx.google.com with ESMTPS id k27si1775901pgn.757.2018.01.30.02.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 02:33:04 -0800 (PST)
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <20180129163114.GH21609@dhcp22.suse.cz>
 <MWHPR1201MB01278542F6EE848ABD187BDBFDE40@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <20180130075553.GM21609@dhcp22.suse.cz>
 <9060281e-62dd-8775-2903-339ff836b436@amd.com>
 <20180130101823.GX21609@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <7d5ce7ab-d16d-36bc-7953-e1da2db350bf@amd.com>
Date: Tue, 30 Jan 2018 11:32:49 +0100
MIME-Version: 1.0
In-Reply-To: <20180130101823.GX21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "He, Roger" <Hongbo.He@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Am 30.01.2018 um 11:18 schrieb Michal Hocko:
> On Tue 30-01-18 10:00:07, Christian KA?nig wrote:
>> Am 30.01.2018 um 08:55 schrieb Michal Hocko:
>>> On Tue 30-01-18 02:56:51, He, Roger wrote:
>>>> Hi Michal:
>>>>
>>>> We need a API to tell TTM module the system totally has how many swap
>>>> cache.  Then TTM module can use it to restrict how many the swap cache
>>>> it can use to prevent triggering OOM.  For Now we set the threshold of
>>>> swap size TTM used as 1/2 * total size and leave the rest for others
>>>> use.
>>> Why do you so much memory? Are you going to use TB of memory on large
>>> systems? What about memory hotplug when the memory is added/released?
>> For graphics and compute applications on GPUs it isn't unusual to use large
>> amounts of system memory.
>>
>> Our standard policy in TTM is to allow 50% of system memory to be pinned for
>> use with GPUs (the hardware can't do page faults).
>>
>> When that limit is exceeded (or the shrinker callbacks tell us to make room)
>> we wait for any GPU work to finish and copy buffer content into a shmem
>> file.
>>
>> This copy into a shmem file can easily trigger the OOM killer if there isn't
>> any swap space left and that is something we want to avoid.
>>
>> So what we want to do is to apply this 50% rule to swap space as well and
>> deny allocation of buffer objects when it is exceeded.
> How does that help when the rest of the system might eat swap?

Well it doesn't, but that is not the problem here.

When an application keeps calling malloc() it sooner or later is 
confronted with an OOM killer.

But when it keeps for example allocating OpenGL textures the expectation 
is that this sooner or later starts to fail because we run out of memory 
and not trigger the OOM killer.

So what we do is to allow the application to use all of video memory + a 
certain amount of system memory + swap space as last resort fallback 
(e.g. when you Alt+Tab from your full screen game back to your browser).

The problem we try to solve is that we haven't limited the use of swap 
space somehow.

>>>> But get_nr_swap_pages is the only API we can accessed from other
>>>> module now.  It can't cover the case of the dynamic swap size
>>>> increment.  I mean: user can use "swapon" to enable new swap file or
>>>> swap disk dynamically or "swapoff" to disable swap space.
>>> Exactly. Your scaling configuration based on get_nr_swap_pages or the
>>> available memory simply sounds wrong.
>> Why? That is pretty much exactly what we are doing with buffer objects and
>> system memory for years.
> Could you be more specific? What kind of buffer objects you have in
> mind?

Those are GEM buffer objects which user space uses for things like 
OpenGL textures, OpenCL matrix, Vulkan surfaces, video codec surfaces 
etc etc...

Regards,
Christian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
