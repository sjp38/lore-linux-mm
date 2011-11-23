Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6B46B009B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:47:43 -0500 (EST)
Received: by ggnq1 with SMTP id q1so1413957ggn.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:47:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111122210018.GF9581@n2100.arm.linux.org.uk>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-3-git-send-email-gilad@benyossef.com>
	<20111122210018.GF9581@n2100.arm.linux.org.uk>
Date: Wed, 23 Nov 2011 08:47:40 +0200
Message-ID: <CAOtvUMcus07UY1keOor2=k=iDocKA0GoqYeOQ5r5p6vQ7efwCA@mail.gmail.com>
Subject: Re: [PATCH v4 2/5] arm: Move arm over to generic on_each_cpu_mask
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>

Hi,

On Tue, Nov 22, 2011 at 11:00 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Nov 22, 2011 at 01:08:45PM +0200, Gilad Ben-Yossef wrote:
>> -static void on_each_cpu_mask(void (*func)(void *), void *info, int wait=
,
>> - =A0 =A0 const struct cpumask *mask)
>> -{
>> - =A0 =A0 preempt_disable();
>> -
>> - =A0 =A0 smp_call_function_many(mask, func, info, wait);
>> - =A0 =A0 if (cpumask_test_cpu(smp_processor_id(), mask))
>> - =A0 =A0 =A0 =A0 =A0 =A0 func(info);
>> -
>> - =A0 =A0 preempt_enable();
>> -}
>
> What hasn't been said in the descriptions (I couldn't find it) is that
> there's a semantic change between the new generic version and this versio=
n -
> that is, we run the function with IRQs disabled on the local CPU, whereas
> the version above runs it with IRQs potentially enabled.
>
> Luckily, for TLB flushing this is probably not a problem, but it's
> something that should've been pointed out in the patch description.

Thank you for the review!

You are very right that I should have mentioned it in the description.
My apologies for missing that bit.

My reasoning for why the change is OK is that the function passed is
ready to run with interrupt disabled because this is how it will be
called on all the other CPUs through the IPI handler so it is safe.
This is also how the generic  on_each_cpu() handles it.

Have I missed something? if not will you like me to update the patch
description and re-send?

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
