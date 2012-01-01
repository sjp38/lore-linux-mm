Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 4CB3C6B00AB
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 03:03:43 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so15620216vbb.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 00:03:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOtvUMdCJEcDBD2KJ0T=Fygnag4sXaDMziYaH1oyeoQ42iZjaQ@mail.gmail.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-6-git-send-email-gilad@benyossef.com>
	<20111223102810.GT3487@suse.de>
	<CAOtvUMd6+ZZVLp-FbbEwbq3UZLRvSRo+_MMYj1aCGT3gBhxMwg@mail.gmail.com>
	<20111230150421.GE15729@suse.de>
	<4EFDD7FA.9000903@tilera.com>
	<20111230160857.GH15729@suse.de>
	<CAOtvUMdCJEcDBD2KJ0T=Fygnag4sXaDMziYaH1oyeoQ42iZjaQ@mail.gmail.com>
Date: Sun, 1 Jan 2012 10:03:42 +0200
Message-ID: <CAOtvUMcbjhV3-ZTjvLqgP0BN19qyPfCQwbZER3TTwfd5mfZong@mail.gmail.com>
Subject: Re: [PATCH v4 5/5] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Fri, Dec 30, 2011 at 10:29 PM, Gilad Ben-Yossef <gilad@benyossef.com> wr=
ote:
> On Fri, Dec 30, 2011 at 6:08 PM, Mel Gorman <mgorman@suse.de> wrote:
>> On Fri, Dec 30, 2011 at 10:25:46AM -0500, Chris Metcalf wrote:
>
>>> Alternately, since we really don't want more than one cpu running the d=
rain
>>> code anyway, you could imagine using a static cpumask, along with a loc=
k to
>>> serialize attempts to drain all the pages. =A0(Locking here would be tr=
icky,
>>> since we need to run on_each_cpu with interrupts enabled, but there's
>>> probably some reasonable way to make it work.)
>>>
>>
>> Good suggestion, that would at least shut up my complaining
>> about allocation costs! A statically-declared mutex similar
>> to hugetlb_instantiation_mutex should do it. The context that
>> drain_all_pages is called from will have interrupts enabled.
>>
>> Serialising processes entering direct reclaim may result in some stalls
>> but overall I think the impact of that would be less than increasing
>> memory pressure when low on memory.
>>
>
> Chris, I like the idea :-)
>
> Actually, assuming for a second that on_each_cpu* and underlying code
> wont mind if the cpumask will change mid call (I know it does, just think=
ing out
> loud), you could say you don't even need the lock if you careful in how y=
ou
> set/unset the per cpu bits of the cpumask, since they track the same thin=
g...

I took a look and smp_call_function_many is actually fine with the
passed cpumask getting changed in mid call.

I think this means we can do away with a single global cpumask without
any locking and the cost becomes the allocation space for the single cpumas=
k and
the cache bouncing for concurrent updating of the cpumask if
drain_all_pages races
 against itself on other cpus.

I'll spin a patch based on this idea.

Happy new year :-)
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
