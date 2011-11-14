Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BCC2A6B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 08:19:13 -0500 (EST)
Received: by wyg24 with SMTP id 24so7848824wyg.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 05:19:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOtvUMe+Um-t3k=VC2Kz4hnOdKYszn9_OG8fa2tp8qK=FLpz0Q@mail.gmail.com>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
	<1321179449-6675-5-git-send-email-gilad@benyossef.com>
	<CAJd=RBC0eTkjF8CSKXv-SK5Zef1G+9x-FUYRBXKmVg6Gbno5gw@mail.gmail.com>
	<CAOtvUMe+Um-t3k=VC2Kz4hnOdKYszn9_OG8fa2tp8qK=FLpz0Q@mail.gmail.com>
Date: Mon, 14 Nov 2011 21:19:11 +0800
Message-ID: <CAJd=RBCkHe14gXBh3GyYyTM8dvvUam_Har5BpUU1WuG9Spd-3g@mail.gmail.com>
Subject: Re: [PATCH v3 4/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Sun, Nov 13, 2011 at 10:57 PM, Gilad Ben-Yossef <gilad@benyossef.com> wr=
ote:
> On Sun, Nov 13, 2011 at 2:20 PM, Hillf Danton <dhillf@gmail.com> wrote:
>>
>> On Sun, Nov 13, 2011 at 6:17 PM, Gilad Ben-Yossef <gilad@benyossef.com> =
wrote:
>>
> ...
>>
>> > diff --git a/mm/slub.c b/mm/slub.c
>> > index 7d2a996..caf4b3a 100644
>> > --- a/mm/slub.c
>> > +++ b/mm/slub.c
>> > @@ -2006,7 +2006,20 @@ static void flush_cpu_slab(void *d)
>> >
>> > =C2=A0static void flush_all(struct kmem_cache *s)
>> > =C2=A0{
>> > - =C2=A0 =C2=A0 =C2=A0 on_each_cpu(flush_cpu_slab, s, 1);
>> > + =C2=A0 =C2=A0 =C2=A0 cpumask_var_t cpus;
>> > + =C2=A0 =C2=A0 =C2=A0 struct kmem_cache_cpu *c;
>> > + =C2=A0 =C2=A0 =C2=A0 int cpu;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC=
))) {
>>
>> Perhaps, the technique of local_cpu_mask defined in kernel/sched_rt.c
>> could be used to replace the above atomic allocation.
>>
>
> Thank you for taking the time to review my patch :-)
>
> That is indeed the direction I went with inthe previous iteration of
> this patch, with the small change that because of observing that the
> allocation will only actually occurs for CPUMASK_OFFSTACK=3Dy which by
> definition are systems with lots and lots of CPUs and, it is actually
> better to allocate the cpumask per kmem_cache rather then per CPU,
> since on system where it matters we are bound to have more CPUs (e.g.
> 4096) then kmem_caches (~160). See
> https://lkml.org/lkml/2011/10/23/151.
>
> I then went a head and further=C2=A0optimized=C2=A0the code to only=C2=A0=
incur=C2=A0the
> memory overhead of allocating those cpumasks for CPUMASK_OFFSTACK=3Dy
> systems. See https://lkml.org/lkml/2011/10/23/152.
>
> As you can see from the discussion that=C2=A0evolved, there seems to be a=
n
> agreement that the code complexity overhead involved is simply not
> worth it for what is, unlike sched_rt, a rather esoteric case and one
> where allocation failure is easily dealt with.
>
Even with the introduced overhead of allocation, IPIs could not go down
as much as we wish, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
