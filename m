Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 3B45D6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 03:08:17 -0500 (EST)
Received: by vbip1 with SMTP id p1so1301034vbi.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 00:08:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120208160344.88d187e5.akpm@linux-foundation.org>
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
	<1328449722-15959-3-git-send-email-gilad@benyossef.com>
	<op.v9csppvv3l0zgt@mpn-glaptop>
	<20120208160344.88d187e5.akpm@linux-foundation.org>
Date: Thu, 9 Feb 2012 10:08:16 +0200
Message-ID: <CAOtvUMebLNtMcrxuxRq_U5UbwNt-9mE0-0z7Zg79abRTbHE4MQ@mail.gmail.com>
Subject: Re: [PATCH v8 4/8] smp: add func to IPI cpus based on parameter func
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 9, 2012 at 2:03 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Wed, 08 Feb 2012 10:30:51 +0100
> "Michal Nazarewicz" <mina86@mina86.com> wrote:
>
>> > =A0 =A0 } while (0)
>> > +/*
>> > + * Preemption is disabled here to make sure the
>> > + * cond_func is called under the same condtions in UP
>> > + * and SMP.
>> > + */
>> > +#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
>> > + =A0 do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>>
>> How about:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *__info =3D (info);
>>
>> as to avoid double execution.
>
> Yup. =A0How does this look?
>
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: smp-add-func-to-ipi-cpus-based-on-parameter-func-update-fix
>
> - avoid double-evaluation of `info' (per Michal)
> - parenthesise evaluation of `cond_func'
>
> Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
> Cc: Gilad Ben-Yossef <gilad@benyossef.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
> =A0include/linux/smp.h | =A0 =A05 +++--
> =A01 file changed, 3 insertions(+), 2 deletions(-)
>
> --- a/include/linux/smp.h~smp-add-func-to-ipi-cpus-based-on-parameter-fun=
c-update-fix
> +++ a/include/linux/smp.h
> @@ -168,10 +168,11 @@ static inline int up_smp_call_function(s
> =A0*/
> =A0#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags)\
> =A0 =A0 =A0 =A0do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *__info =3D (info); =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0preempt_disable(); =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(0, info)) { =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((cond_func)(0, __info)) { =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable(); =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (func)(info); =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (func)(__info); =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_enable(); =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0preempt_enable(); =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> _
>

Right, I missed that. I hate macros.

As I was requested to correct some comments I'll send a re-spin.
I folded your patch into the original one (and kept the Signed-off-by,
I hope it's OK).

BTW -  I used a macro since I imitated the rest of the code in smp.h
but is there any
reason not to use an inline macro here?

Thanks!
Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
