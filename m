Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2A1F6B026D
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:58:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 33so927559wrs.3
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:58:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w79sor1199311wrb.45.2018.01.19.01.58.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 01:58:26 -0800 (PST)
Reply-To: christian.koenig@amd.com
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net> <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
 <a3f6dc22-fce2-4371-462a-a4898249cf61@daenzer.net>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <11153f4f-8b9a-5780-6087-bc1e85459584@gmail.com>
Date: Fri, 19 Jan 2018 10:58:24 +0100
MIME-Version: 1.0
In-Reply-To: <a3f6dc22-fce2-4371-462a-a4898249cf61@daenzer.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Michal Hocko <mhocko@kernel.org>, Eric Anholt <eric@anholt.net>
Cc: Andrey Grodzovsky <andrey.grodzovsky@amd.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, linux-mm@kvack.org

Am 19.01.2018 um 10:32 schrieb Michel DA?nzer:
> On 2018-01-19 09:39 AM, Christian KA?nig wrote:
>> Am 19.01.2018 um 09:20 schrieb Michal Hocko:
>>> On Thu 18-01-18 12:01:32, Eric Anholt wrote:
>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>
>>>>> On Thu 18-01-18 18:00:06, Michal Hocko wrote:
>>>>>> On Thu 18-01-18 11:47:48, Andrey Grodzovsky wrote:
>>>>>>> Hi, this series is a revised version of an RFC sent by Christian
>>>>>>> KA?nig
>>>>>>> a few years ago. The original RFC can be found at
>>>>>>> https://lists.freedesktop.org/archives/dri-devel/2015-September/089778.html
>>>>>>>
>>>>>>>
>>>>>>> This is the same idea and I've just adressed his concern from the
>>>>>>> original RFC
>>>>>>> and switched to a callback into file_ops instead of a new member
>>>>>>> in struct file.
>>>>>> Please add the full description to the cover letter and do not make
>>>>>> people hunt links.
>>>>>>
>>>>>> Here is the origin cover letter text
>>>>>> : I'm currently working on the issue that when device drivers
>>>>>> allocate memory on
>>>>>> : behalf of an application the OOM killer usually doesn't knew
>>>>>> about that unless
>>>>>> : the application also get this memory mapped into their address
>>>>>> space.
>>>>>> :
>>>>>> : This is especially annoying for graphics drivers where a lot of
>>>>>> the VRAM
>>>>>> : usually isn't CPU accessible and so doesn't make sense to map
>>>>>> into the
>>>>>> : address space of the process using it.
>>>>>> :
>>>>>> : The problem now is that when an application starts to use a lot
>>>>>> of VRAM those
>>>>>> : buffers objects sooner or later get swapped out to system memory,
>>>>>> but when we
>>>>>> : now run into an out of memory situation the OOM killer obviously
>>>>>> doesn't knew
>>>>>> : anything about that memory and so usually kills the wrong process.
>>>>> OK, but how do you attribute that memory to a particular OOM killable
>>>>> entity? And how do you actually enforce that those resources get freed
>>>>> on the oom killer action?
>>>>>
>>>>>> : The following set of patches tries to address this problem by
>>>>>> introducing a per
>>>>>> : file OOM badness score, which device drivers can use to give the
>>>>>> OOM killer a
>>>>>> : hint how many resources are bound to a file descriptor so that it
>>>>>> can make
>>>>>> : better decisions which process to kill.
>>>>> But files are not killable, they can be shared... In other words this
>>>>> doesn't help the oom killer to make an educated guess at all.
>>>> Maybe some more context would help the discussion?
>>>>
>>>> The struct file in patch 3 is the DRM fd.A  That's effectively "my
>>>> process's interface to talking to the GPU" not "a single GPU resource".
>>>> Once that file is closed, all of the process's private, idle GPU buffers
>>>> will be immediately freed (this will be most of their allocations), and
>>>> some will be freed once the GPU completes some work (this will be most
>>>> of the rest of their allocations).
>>>>
>>>> Some GEM BOs won't be freed just by closing the fd, if they've been
>>>> shared between processes.A  Those are usually about 8-24MB total in a
>>>> process, rather than the GBs that modern apps use (or that our testcases
>>>> like to allocate and thus trigger oomkilling of the test harness instead
>>>> of the offending testcase...)
>>>>
>>>> Even if we just had the private+idle buffers being accounted in OOM
>>>> badness, that would be a huge step forward in system reliability.
>>> OK, in that case I would propose a different approach. We already
>>> have rss_stat. So why do not we simply add a new counter there
>>> MM_KERNELPAGES and consider those in oom_badness? The rule would be
>>> that such a memory is bound to the process life time. I guess we will
>>> find more users for this later.
>> I already tried that and the problem with that approach is that some
>> buffers are not created by the application which actually uses them.
>>
>> For example X/Wayland is creating and handing out render buffers to
>> application which want to use OpenGL.
>>
>> So the result is when you always account the application who created the
>> buffer the OOM killer will certainly reap X/Wayland first. And that is
>> exactly what we want to avoid here.
> FWIW, what you describe is true with DRI2, but not with DRI3 or Wayland
> anymore. With DRI3 and Wayland, buffers are allocated by the clients and
> then shared with the X / Wayland server.

Good point, when I initially looked at that problem DRI3 wasn't widely 
used yet.

> Also, in all cases, the amount of memory allocated for buffers shared
> between DRI/Wayland clients and the server should be relatively small
> compared to the amount of memory allocated for buffers used only locally
> in the client, particularly for clients which create significant memory
> pressure.

That is unfortunately only partially true. When you have a single 
runaway application which tries to allocate everything it would indeed 
work as you described.

But when I tested this a few years ago with X based desktop the 
applications which actually used most of the memory where Firefox and 
Thunderbird. Unfortunately they never got accounted for that.

Now, on my current Wayland based desktop it actually doesn't look much 
better. Taking a look at radeon_gem_info/amdgpu_gem_info the majority of 
all memory was allocated either by gnome-shell or Xwayland.

Regards,
Christian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
