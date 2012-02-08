Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id F381C6B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:30:58 -0500 (EST)
Received: by eekc13 with SMTP id c13so132544eek.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 01:30:57 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v8 4/8] smp: add func to IPI cpus based on parameter func
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
 <1328449722-15959-3-git-send-email-gilad@benyossef.com>
Date: Wed, 08 Feb 2012 10:30:51 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9csppvv3l0zgt@mpn-glaptop>
In-Reply-To: <1328449722-15959-3-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Kosaki
 Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Milton Miller <miltonm@bga.com>

On Sun, 05 Feb 2012 14:48:38 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:

> Add the on_each_cpu_cond() function that wraps on_each_cpu_mask()
> and calculates the cpumask of cpus to IPI by calling a function suppli=
ed
> as a parameter in order to determine whether to IPI each specific cpu.=

>
> The function works around allocation failure of cpumask variable in
> CONFIG_CPUMASK_OFFSTACK=3Dy by itereating over cpus sending an IPI a
> time via smp_call_function_single().
>
> The function is useful since it allows to seperate the specific
> code that decided in each case whether to IPI a specific cpu for
> a specific request from the common boilerplate code of handling
> creating the mask, handling failures etc.
>
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: Russell King <linux@arm.linux.org.uk>
> CC: linux-mm@kvack.org
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Sasha Levin <levinsasha928@gmail.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Alexander Viro <viro@zeniv.linux.org.uk>
> CC: linux-fsdevel@vger.kernel.org
> CC: Avi Kivity <avi@redhat.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Milton Miller <miltonm@bga.com>
> ---
>  include/linux/smp.h |   24 ++++++++++++++++++++
>  kernel/smp.c        |   60 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++
>  2 files changed, 84 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/smp.h b/include/linux/smp.h
> index d0adb78..da4d034 100644
> --- a/include/linux/smp.h
> +++ b/include/linux/smp.h
> @@ -153,6 +162,21 @@ static inline int up_smp_call_function(smp_call_f=
unc_t func, void *info)
>  			local_irq_enable();		\
>  		}					\
>  	} while (0)
> +/*
> + * Preemption is disabled here to make sure the
> + * cond_func is called under the same condtions in UP
> + * and SMP.
> + */
> +#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
> +	do {						\

How about:

		void *__info =3D (info);

as to avoid double execution.

> +		preempt_disable();			\
> +		if (cond_func(0, info)) {		\
> +			local_irq_disable();		\
> +			(func)(info);			\
> +			local_irq_enable();		\
> +		}					\
> +		preempt_enable();			\
> +	} while (0)
> static inline void smp_send_reschedule(int cpu) { }
>  #define num_booting_cpus()			1

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
