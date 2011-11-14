Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0D66B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 08:57:15 -0500 (EST)
Received: by ywp17 with SMTP id 17so3551998ywp.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 05:57:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBCkHe14gXBh3GyYyTM8dvvUam_Har5BpUU1WuG9Spd-3g@mail.gmail.com>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
	<1321179449-6675-5-git-send-email-gilad@benyossef.com>
	<CAJd=RBC0eTkjF8CSKXv-SK5Zef1G+9x-FUYRBXKmVg6Gbno5gw@mail.gmail.com>
	<CAOtvUMe+Um-t3k=VC2Kz4hnOdKYszn9_OG8fa2tp8qK=FLpz0Q@mail.gmail.com>
	<CAJd=RBCkHe14gXBh3GyYyTM8dvvUam_Har5BpUU1WuG9Spd-3g@mail.gmail.com>
Date: Mon, 14 Nov 2011 15:57:13 +0200
Message-ID: <CAOtvUMf1COVDUv6MCsPAt806kcRfzSmeUqOZR_XWy-6dx=ZqcA@mail.gmail.com>
Subject: Re: [PATCH v3 4/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Nov 14, 2011 at 3:19 PM, Hillf Danton <dhillf@gmail.com> wrote:
> On Sun, Nov 13, 2011 at 10:57 PM, Gilad Ben-Yossef <gilad@benyossef.com> =
wrote:
...
>>> Perhaps, the technique of local_cpu_mask defined in kernel/sched_rt.c
>>> could be used to replace the above atomic allocation.
>>>
>>
>> Thank you for taking the time to review my patch :-)
>>
>> That is indeed the direction I went with inthe previous iteration of
>> this patch, with the small change that because of observing that the
>> allocation will only actually occurs for CPUMASK_OFFSTACK=3Dy which by
>> definition are systems with lots and lots of CPUs and, it is actually
>> better to allocate the cpumask per kmem_cache rather then per CPU,
>> since on system where it matters we are bound to have more CPUs (e.g.
>> 4096) then kmem_caches (~160). See
>> https://lkml.org/lkml/2011/10/23/151.
>>
>> I then went a head and further=A0optimized=A0the code to only=A0incur=A0=
the
>> memory overhead of allocating those cpumasks for CPUMASK_OFFSTACK=3Dy
>> systems. See https://lkml.org/lkml/2011/10/23/152.
>>
>> As you can see from the discussion that=A0evolved, there seems to be an
>> agreement that the code complexity overhead involved is simply not
>> worth it for what is, unlike sched_rt, a rather esoteric case and one
>> where allocation failure is easily dealt with.
>>
> Even with the introduced overhead of allocation, IPIs could not go down
> as much as we wish, right?
>

My apologies, but I don't think I follow you through -

If processor A needs processor B to do something, an IPI is the right
thing to do. Let's call them useful IPIs.

What I am trying to tackle is the places where processor B doesn't
really have anything to
do and processor A is simply blindly sending IPIs to the whole system.
I call them useless IPIs.

I don't see a reason why *useless* IPIs can go to zero, or very close
to that. Useful IPIs are fine :-)

Thanks,
Gilad
--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
