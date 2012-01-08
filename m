Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 12C966B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:13:07 -0500 (EST)
Received: by vcge1 with SMTP id e1so2665127vcg.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:13:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F01B187.7060008@redhat.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-5-git-send-email-gilad@benyossef.com>
	<alpine.LFD.2.02.1111230822270.1773@tux.localdomain>
	<4F00547A.9090204@redhat.com>
	<CAOtvUMcCzK=tNkHudOrzxjdGkdkZPt02krO8QYRGjyXm+cvRSw@mail.gmail.com>
	<4F008ECA.5040703@redhat.com>
	<CAOtvUMfWKpXaR6Ph1ZN6g0QhgmZtbcf=hMSgtkD-1pLpkzSuNA@mail.gmail.com>
	<4F01B187.7060008@redhat.com>
Date: Sun, 8 Jan 2012 18:13:05 +0200
Message-ID: <CAOtvUMcnjfLxQW7iGKWbPJ=MVhBWdyAyeVJB0sCDb-phkXOx-g@mail.gmail.com>
Subject: Re: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, apkm@linux-foundation.org

On Mon, Jan 2, 2012 at 3:30 PM, Avi Kivity <avi@redhat.com> wrote:
> On 01/02/2012 01:59 PM, Gilad Ben-Yossef wrote:
>> On Sun, Jan 1, 2012 at 6:50 PM, Avi Kivity <avi@redhat.com> wrote:
>> > On 01/01/2012 06:12 PM, Gilad Ben-Yossef wrote:
>> >> >
>> >> > Since this seems to be a common pattern, how about:
>> >> >
>> >> > =A0 zalloc_cpumask_var_or_all_online_cpus(&cpus, GFTP_ATOMIC);
>> >> > =A0 ...
>> >> > =A0 free_cpumask_var(cpus);
>> >> >
>> >> > The long-named function at the top of the block either returns a ne=
wly
>> >> > allocated zeroed cpumask, or a static cpumask with all online cpus =
set.
>> >> > The code in the middle is only allowed to set bits in the cpumask
>> >> > (should be the common usage). =A0free_cpumask_var() needs to check =
whether
>> >> > the freed object is the static variable.
>> >>
>> >> Thanks for the feedback and advice! I totally agree the repeating
>> >> pattern needs abstracting.
>> >>
>> >> I ended up chosing to try a different abstraction though - basically =
a wrapper
>> >> on_each_cpu_cond that gets a predicate function to run per CPU to
>> >> build the mask
>> >> to send the IPI to. It seems cleaner to me not having to mess with
>> >> free_cpumask_var
>> >> and it abstracts more of the general pattern.
>> >>
>> >
>> > This converts the algorithm to O(NR_CPUS) from a potentially lower
>> > complexity algorithm. =A0Also, the existing algorithm may not like to =
be
>> > driven by cpu number. =A0Both are true for kvm.
>> >
>>
>> Right, I was only thinking on my own uses, which are O(NR_CPUS) by natur=
e.
>>
>> I wonder if it would be better to create a safe_cpumask_var type with
>> its own alloc function
>> free and and sset_cpu function but no clear_cpu function so that the
>> compiler will catch
>> cases of trying to clear bits off of such a cpumask?
>>
>> It seems safer and also makes handling the free function easier.
>>
>> Does that makes sense or am I over engineering it? :-)
>
> It makes sense. =A0Depends on the number of call sites, really. =A0If the=
re
> are several, consolidation helps, also makes it easier to further refacto=
r.

As Andrew pointed out code that usually calls just the CPU you wanted but
sometime (under memory pressure) might call other CPUs is a problem
waiting to happen, so I took his advice and re factored to use
smp_call_function_single to IPI each CPU individually in case of alloc fail=
ure.

I don't know if that applied to the KVM use case. I'm guessing it
probably doesn't
from what you wrote here.

Cheers,
Gilad

>
> --
> error compiling committee.c: too many arguments to function
>



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
