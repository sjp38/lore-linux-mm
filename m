Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E7B1C6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 03:28:50 -0500 (EST)
Received: by vcge1 with SMTP id e1so414727vcg.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 00:28:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326265449_1658@mail4.comsite.net>
References: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
	<1326265449_1658@mail4.comsite.net>
Date: Wed, 11 Jan 2012 10:28:49 +0200
Message-ID: <CAOtvUMf6v5iqdLaf6qocfso-HwEdJbHNt_SbY_7vWz6-1gA73g@mail.gmail.com>
Subject: Re: [PATCH v6 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milton Miller <miltonm@bga.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

On Wed, Jan 11, 2012 at 9:04 AM, Milton Miller <miltonm@bga.com> wrote:
>
> Hi Gilad. =A0 A few minor corrections for several of the patch logs, but =
some
> meater discussions on several of the patches.
>
> Overall I like the series and hope you see it through.


Hi Milton. Thanks so much for the detailed review.

As you've no doubt noticed,=A0English is=A0not my mother=A0tongue (as oppos=
ed to
=A0C),=A0so a special=A0thank you for the patch logs review :-)


>
> <SNIP>



>
> > +void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *)=
,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *info, bool wait)
> > +{
> > + =A0 =A0 int cpu =3D get_cpu();
> > +
> > + =A0 =A0 smp_call_function_many(mask, func, info, wait);
> > + =A0 =A0 if (cpumask_test_cpu(cpu, mask)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 local_irq_disable();
> > + =A0 =A0 =A0 =A0 =A0 =A0 func(info);
> > + =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
> > + =A0 =A0 }
> > + =A0 =A0 put_cpu();
> > +}
> > +EXPORT_SYMBOL(on_each_cpu_mask);
>
> It should be less code if we rewrite on_each_cpu as the one liner
> on_each_cpu_mask(cpu_online_mask). =A0I think the trade off of less
> code is worth the cost of the added test of cpu being in online_mask.
>
> That could be a seperate patch, but will be easier to read the result
> if on_each_cpu_mask is placed above on_each_cpu in this one.


Yes, it does look cleaner and I agree that the extra test is not a big
price to pay for simplee code.

However, to do that, on_each_cpu return value need to go away and
all caller needs to be adjusted. I=A0figured=A0this is out of scope for thi=
s
patch set.

I did send out a=A0separate patch set to do the needed work =A0(see:
https://lkml.org/lkml/2012/1/8/48) and I suggest that after both of
them go in, I'll send a patch to do exactly what you suggested.

Thanks!
Gilad
--
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
