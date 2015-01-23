Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3234D6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 10:00:03 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id v8so6063323qal.7
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:00:03 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id z1si2269095qar.33.2015.01.23.07.00.01
        for <linux-mm@kvack.org>;
        Fri, 23 Jan 2015 07:00:02 -0800 (PST)
Message-ID: <54C261F0.9070606@arm.com>
Date: Fri, 23 Jan 2015 15:00:00 +0000
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
References: <54B01335.4060901@arm.com> <20150110085525.GD2110@esperanza> <54BCFDCF.9090603@arm.com> <20150121163955.GM4549@arm.com> <20150122134550.GA13876@phnom.home.cmpxchg.org>
In-Reply-To: <20150122134550.GA13876@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <Will.Deacon@arm.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 22/01/15 13:45, Johannes Weiner wrote:
> On Wed, Jan 21, 2015 at 04:39:55PM +0000, Will Deacon wrote:
>> On Mon, Jan 19, 2015 at 12:51:27PM +0000, Suzuki K. Poulose wrote:
>>> On 10/01/15 08:55, Vladimir Davydov wrote:
>>>> The problem is that the memory cgroup controller takes a css reference
>>>> per each charged page and does not reparent charged pages on css
>>>> offline, while cgroup_mount/cgroup_kill_sb expect all css references t=
o
>>>> offline cgroups to be gone soon, restarting the syscall if the ref cou=
nt
>>>> !=3D 0. As a result, if you create a memory cgroup, charge some page c=
ache
>>>> to it, and then remove it, unmount/mount will hang forever.
>>>>
>>>> May be, we should kill the ref counter to the memory controller root i=
n
>>>> cgroup_kill_sb only if there is no children at all, neither online nor
>>>> offline.
>>>>
>>>
>>> Still reproducible on 3.19-rc5 with the same setup.
>>
>> Yeah, I'm seeing the same failure on my setup too.
>>
>>>  From git bisect, the last good commit is :
>>>
>>> commit 8df0c2dcf61781d2efa8e6e5b06870f6c6785735
>>> Author: Pranith Kumar <bobby.prani@gmail.com>
>>> Date:   Wed Dec 10 15:42:28 2014 -0800
>>>
>>>       slab: replace smp_read_barrier_depends() with lockless_dereferenc=
e()
>>
>> So that points at 3e32cb2e0a12 ("mm: memcontrol: lockless page counters"=
)
>> as the offending commit.
>
> With b2052564e66d ("mm: memcontrol: continue cache reclaim from
> offlined groups"), page cache can pin an old css and its ancestors
> indefinitely, making that hang in a second mount() very likely.
>
> However, swap entries have also been doing that for quite a while now,
> and as Vladimir pointed out, the same is true for kernel memory.  This
> latest change just makes this existing bug easier to trigger.
>
> I think we have to update the lifetime rules to reflect reality here:
> memory and swap lifetime is indefinite, so once the memory controller
> is used, it has state that is independent from whether its mounted or
> not.  We can support an identical remount, but have to fail mounting
> with new parameters that would change the behavior of the controller.
>
> Suzuki, Will, could you give the following patch a shot?


>
> Tejun, would that route be acceptable to you?
>
> Thanks
>
> ---
>  From c5e88d02d185c52748df664aa30a2c5f8949b0f7 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 22 Jan 2015 08:16:31 -0500
> Subject: [patch] kernel: cgroup: prevent mount hang due to memory control=
ler
>   lifetime
>

>
> Don't offline the controller root as long as there are any children,
> dead or alive.  A remount will no longer wait for these old references
> to drain, it will simply mount the persistent controller state again.
>
> Reported-by: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
This one fixes the issue.

Tested-by : Suzuki K. Poulose <suzuki.poulose@arm.com>

Thanks
Suzuki



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
