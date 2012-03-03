Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id C6C996B007E
	for <linux-mm@kvack.org>; Sat,  3 Mar 2012 11:38:07 -0500 (EST)
Received: by qcsu28 with SMTP id u28so1407296qcs.8
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 08:38:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F522910.1050402@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-5-git-send-email-ssouhlal@FreeBSD.org>
	<20120229150041.62c1feeb.kamezawa.hiroyu@jp.fujitsu.com>
	<CABCjUKBHjLHKUmW6_r0SOyw42WfV0zNO7Kd7FhhRQTT6jZdyeQ@mail.gmail.com>
	<20120301091044.1a62d42c.kamezawa.hiroyu@jp.fujitsu.com>
	<4F4EC1AB.8050506@parallels.com>
	<20120301150537.8996bbf6.kamezawa.hiroyu@jp.fujitsu.com>
	<4F522910.1050402@parallels.com>
Date: Sat, 3 Mar 2012 08:38:06 -0800
Message-ID: <CABCjUKBngJx0o5jnJk3FEjWUDA6aNTAiFENdEF+M7BwB85NaLg@mail.gmail.com>
Subject: Re: [PATCH 04/10] memcg: Introduce __GFP_NOACCOUNT.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Sat, Mar 3, 2012 at 6:22 AM, Glauber Costa <glommer@parallels.com> wrote=
:
> On 03/01/2012 03:05 AM, KAMEZAWA Hiroyuki wrote:
>>
>> On Wed, 29 Feb 2012 21:24:11 -0300
>> Glauber Costa<glommer@parallels.com> =A0wrote:
>>
>>> On 02/29/2012 09:10 PM, KAMEZAWA Hiroyuki wrote:
>>>>
>>>> On Wed, 29 Feb 2012 11:09:50 -0800
>>>> Suleiman Souhlal<suleiman@google.com> =A0 wrote:
>>>>
>>>>> On Tue, Feb 28, 2012 at 10:00 PM, KAMEZAWA Hiroyuki
>>>>> <kamezawa.hiroyu@jp.fujitsu.com> =A0 wrote:
>>>>>>
>>>>>> On Mon, 27 Feb 2012 14:58:47 -0800
>>>>>> Suleiman Souhlal<ssouhlal@FreeBSD.org> =A0 wrote:
>>>>>>
>>>>>>> This is used to indicate that we don't want an allocation to be
>>>>>>> accounted
>>>>>>> to the current cgroup.
>>>>>>>
>>>>>>> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
>>>>>>
>>>>>>
>>>>>> I don't like this.
>>>>>>
>>>>>> Please add
>>>>>>
>>>>>> ___GFP_ACCOUNT =A0"account this allocation to memcg"
>>>>>>
>>>>>> Or make this as slab's flag if this work is for slab allocation.
>>>>>
>>>>>
>>>>> We would like to account for all the slab allocations that happen in
>>>>> process context.
>>>>>
>>>>> Manually marking every single allocation or kmem_cache with a GFP fla=
g
>>>>> really doesn't seem like the right thing to do..
>>>>>
>>>>> Can you explain why you don't like this flag?
>>>>>
>>>>
>>>> For example, tcp buffer limiting has another logic for buffer size
>>>> controling.
>>>> _AND_, most of kernel pages are not reclaimable at all.
>>>> I think you should start from reclaimable caches as dcache, icache etc=
.
>>>>
>>>> If you want to use this wider, you can discuss
>>>>
>>>> + #define GFP_KERNEL =A0 =A0(.....| ___GFP_ACCOUNT)
>>>>
>>>> in future. I'd like to see small start because memory allocation failu=
re
>>>> is always terrible and make the system unstable. Even if you notify
>>>> "Ah, kernel memory allocation failed because of memory.limit? and
>>>> =A0 many unreclaimable memory usage. Please tweak the limitation or ki=
ll
>>>> tasks!!"
>>>>
>>>> The user can't do anything because he can't create any new task becaus=
e
>>>> of OOM.
>>>>
>>>> The system will be being unstable until an admin, who is not under any
>>>> limit,
>>>> tweaks something or reboot the system.
>>>>
>>>> Please do small start until you provide Eco-System to avoid a case tha=
t
>>>> the admin cannot login and what he can do was only reboot.
>>>>
>>> Having the root cgroup to be always unlimited should already take care
>>> of the most extreme cases, right?
>>>
>> If an admin can login into root cgroup ;)
>> Anyway, if someone have a container under cgroup via hosting service,
>> he can do noting if oom killer cannot recover his container. It can be
>> caused by kernel memory limit. And I'm not sure he can do shutdown becau=
se
>> he can't login.
>>
>
> To be fair, I think this may be unavoidable. Even if we are only dealing
> with reclaimable slabs, having reclaimable slabs doesn't mean they are
> always reclaimable. Unlike user memory, that we can swap at will (unless
> mlock'd, but that is a different issue), we can have so many objects lock=
ed,
> that reclaim is effectively impossible. And with the right pattern, that =
may
> not even need to be that many: all one needs to do, is figure out a way t=
o
> pin one object per slab page, and that's it: you'll never get rid of them=
.
>
> So although obviously being nice making sure we did everything we could t=
o
> recover from oom scenarios, once we start tracking kernel memory, this ma=
y
> not be possible. So the whole point for me, is guaranteeing that one
> container cannot destroy the others - which is the reality if one of them
> can go an grab all kmem =3Dp
>
> That said, I gave this an extra thought. GFP flags are in theory targeted=
 at
> a single allocation. So I think this is wrong. We either track or not a
> cache, not an allocation. Once we decided that a cache should be tracked,=
 it
> should be tracked and end of story.
>
> So how about using a SLAB flag instead?

The reason I had to make it a GFP flag in the first place is that
there are some allocations that we really do not want to track that
are in slabs we generally want accounted: We have to do some slab
allocations while we are in the slab accounting code (for the cache
name or when enqueuing a memcg kmem_cache to be created, both of which
are just regular kmallocs, I think).
Another possible example might be the skb data, which are just kmalloc
and are already accounted by your TCP accounting changes, so we might
not want to account them a second time.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
