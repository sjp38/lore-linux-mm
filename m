Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 651936B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:33:17 -0500 (EST)
Received: by eekc13 with SMTP id c13so133329eek.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 01:33:15 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v8 7/8] mm: only IPI CPUs to drain local pages if they
 exist
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
 <1328449722-15959-6-git-send-email-gilad@benyossef.com>
Date: Wed, 08 Feb 2012 10:33:13 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9cstne43l0zgt@mpn-glaptop>
In-Reply-To: <1328449722-15959-6-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, Russell
 King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander
 Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Milton Miller <miltonm@bga.com>

On Sun, 05 Feb 2012 14:48:41 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d2186ec..3ff5aff 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1161,11 +1161,46 @@ void drain_local_pages(void *arg)
>  }
> /*
> - * Spill all the per-cpu pages from all CPUs back into the buddy allo=
cator
> + * Spill all the per-cpu pages from all CPUs back into the buddy allo=
cator.
> + *
> + * Note that this code is protected against sending an IPI to an offl=
ine
> + * CPU but does not guarantee sending an IPI to newly hotplugged CPUs=
:
> + * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs =
but
> + * nothing keeps CPUs from showing up after we populated the cpumask =
and
> + * before the call to on_each_cpu_mask().
>   */
>  void drain_all_pages(void)
>  {
> -	on_each_cpu(drain_local_pages, NULL, 1);
> +	int cpu;
> +	struct per_cpu_pageset *pcp;
> +	struct zone *zone;
> +
> +	/* Allocate in the BSS so we wont require allocation in
> +	 * direct reclaim path for CONFIG_CPUMASK_OFFSTACK=3Dy
> +	 */

If you are going to send next iteration, this comment should have
=E2=80=9C/*=E2=80=9D on its own line just like comment below.

> +	static cpumask_t cpus_with_pcps;
> +
> +	/*
> +	 * We don't care about racing with CPU hotplug event
> +	 * as offline notification will cause the notified
> +	 * cpu to drain that CPU pcps and on_each_cpu_mask
> +	 * disables preemption as part of its processing
> +	 */
> +	for_each_online_cpu(cpu) {
> +		bool has_pcps =3D false;
> +		for_each_populated_zone(zone) {
> +			pcp =3D per_cpu_ptr(zone->pageset, cpu);
> +			if (pcp->pcp.count) {
> +				has_pcps =3D true;
> +				break;
> +			}
> +		}
> +		if (has_pcps)
> +			cpumask_set_cpu(cpu, &cpus_with_pcps);
> +		else
> +			cpumask_clear_cpu(cpu, &cpus_with_pcps);
> +	}
> +	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
>  }
> #ifdef CONFIG_HIBERNATION


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
