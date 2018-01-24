Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77403800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 05:27:20 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o79so1044640lff.0
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 02:27:20 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id 26si787484lfp.43.2018.01.24.02.27.17
        for <linux-mm@kvack.org>;
        Wed, 24 Jan 2018 02:27:18 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
 <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
Date: Wed, 24 Jan 2018 11:27:15 +0100
MIME-Version: 1.0
In-Reply-To: <20180124092847.GI1526@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Christian.Koenig@amd.com, linux-mm@kvack.org, amd-gfx@lists.freedesktop.org, Roman Gushchin <guro@fb.com>

On 2018-01-24 10:28 AM, Michal Hocko wrote:
> On Tue 23-01-18 17:39:19, Michel DA?nzer wrote:
>> On 2018-01-23 04:36 PM, Michal Hocko wrote:
>>> On Tue 23-01-18 15:27:00, Roman Gushchin wrote:
>>>> On Thu, Jan 18, 2018 at 06:00:06PM +0100, Michal Hocko wrote:
>>>>> On Thu 18-01-18 11:47:48, Andrey Grodzovsky wrote:
>>>>>> Hi, this series is a revised version of an RFC sent by Christian KA?nig
>>>>>> a few years ago. The original RFC can be found at 
>>>>>> https://urldefense.proofpoint.com/v2/url?u=https-3A__lists.freedesktop.org_archives_dri-2Ddevel_2015-2DSeptember_089778.html&d=DwIDAw&c=5VD0RTtNlTh3ycd41b3MUw&r=jJYgtDM7QT-W-Fz_d29HYQ&m=R-JIQjy8rqmH5qD581_VYL0Q7cpWSITKOnBCE-3LI8U&s=QZGqKpKuJ2BtioFGSy8_721owcWJ0J6c6d4jywOwN4w&
>>>>> Here is the origin cover letter text
>>>>> : I'm currently working on the issue that when device drivers allocate memory on
>>>>> : behalf of an application the OOM killer usually doesn't knew about that unless
>>>>> : the application also get this memory mapped into their address space.
>>>>> : 
>>>>> : This is especially annoying for graphics drivers where a lot of the VRAM
>>>>> : usually isn't CPU accessible and so doesn't make sense to map into the
>>>>> : address space of the process using it.
>>>>> : 
>>>>> : The problem now is that when an application starts to use a lot of VRAM those
>>>>> : buffers objects sooner or later get swapped out to system memory, but when we
>>>>> : now run into an out of memory situation the OOM killer obviously doesn't knew
>>>>> : anything about that memory and so usually kills the wrong process.
>>>>> : 
>>>>> : The following set of patches tries to address this problem by introducing a per
>>>>> : file OOM badness score, which device drivers can use to give the OOM killer a
>>>>> : hint how many resources are bound to a file descriptor so that it can make
>>>>> : better decisions which process to kill.
>>>>> : 
>>>>> : So question at every one: What do you think about this approach?
>>>>> : 
>>>>> : My biggest concern right now is the patches are messing with a core kernel
>>>>> : structure (adding a field to struct file). Any better idea? I'm considering
>>>>> : to put a callback into file_ops instead.
>>>>
>>>> Hello!
>>>>
>>>> I wonder if groupoom (aka cgroup-aware OOM killer) can work for you?
>>>
>>> I do not think so. The problem is that the allocating context is not
>>> identical with the end consumer.
>>
>> That's actually not really true. Even in cases where a BO is shared with
>> a different process, it is still used at least occasionally in the
>> process which allocated it as well. Otherwise there would be no point in
>> sharing it between processes.
> 
> OK, but somebody has to be made responsible. Otherwise you are just
> killing a process which doesn't really release any memory.
>  
>> There should be no problem if the memory of a shared BO is accounted for
>> in each process sharing it. It might be nice to scale each process'
>> "debt" by 1 / (number of processes sharing it) if possible, but in the
>> worst case accounting it fully in each process should be fine.
> 
> So how exactly then helps to kill one of those processes? The memory
> stays pinned behind or do I still misunderstand?

Fundamentally, the memory is only released once all references to the
BOs are dropped. That's true no matter how the memory is accounted for
between the processes referencing the BO.


In practice, this should be fine:

1. The amount of memory used for shared BOs is normally small compared
to the amount of memory used for non-shared BOs (and other things). So
regardless of how shared BOs are accounted for, the OOM killer should
first target the process which is responsible for more memory overall.

2. If the OOM killer kills a process which is sharing BOs with another
process, this should result in the other process dropping its references
to the BOs as well, at which point the memory is released.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
