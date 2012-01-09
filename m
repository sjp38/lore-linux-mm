Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 919C46B0069
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 11:47:37 -0500 (EST)
Received: by eekc41 with SMTP id c41so2696958eek.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 08:47:35 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v6 7/8] mm: only IPI CPUs to drain local pages if they
 exist
References: <y> <1326040026-7285-8-git-send-email-gilad@benyossef.com>
 <alpine.DEB.2.00.1201091034390.31395@router.home>
Date: Mon, 09 Jan 2012 17:47:30 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7tsxgu33l0zgt@mpn-glaptop>
In-Reply-To: <alpine.DEB.2.00.1201091034390.31395@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal
 Nazarewicz <mina86@mina86.org>

On Mon, 09 Jan 2012 17:35:26 +0100, Christoph Lameter <cl@linux.com> wro=
te:

> On Sun, 8 Jan 2012, Gilad Ben-Yossef wrote:
>
>> @@ -67,6 +67,14 @@ DEFINE_PER_CPU(int, numa_node);
>>  EXPORT_PER_CPU_SYMBOL(numa_node);
>>  #endif
>>
>> +/*
>> + * A global cpumask of CPUs with per-cpu pages that gets
>> + * recomputed on each drain. We use a global cpumask
>> + * here to avoid allocation on direct reclaim code path
>> + * for CONFIG_CPUMASK_OFFSTACK=3Dy
>> + */
>> +static cpumask_var_t cpus_with_pcps;
>
> Move the static definition into drain_all_pages()?

This is initialised in setup_per_cpu_pageset() so it needs to be file sc=
oped.

>> +
>>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
>>  /*
>>   * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly=
.
>> @@ -1097,7 +1105,19 @@ void drain_local_pages(void *arg)
>>   */
>>  void drain_all_pages(void)
>>  {
>> -	on_each_cpu(drain_local_pages, NULL, 1);
>> +	int cpu;
>> +	struct per_cpu_pageset *pcp;
>> +	struct zone *zone;
>> +
>> +	for_each_online_cpu(cpu)
>> +		for_each_populated_zone(zone) {
>> +			pcp =3D per_cpu_ptr(zone->pageset, cpu);
>> +			if (pcp->pcp.count)
>> +				cpumask_set_cpu(cpu, cpus_with_pcps);
>> +			else
>> +				cpumask_clear_cpu(cpu, cpus_with_pcps);
>> +		}
>> +	on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
>>  }
>>
>>  #ifdef CONFIG_HIBERNATION
>> @@ -3601,6 +3621,10 @@ static void setup_zone_pageset(struct zone *zo=
ne)
>>  void __init setup_per_cpu_pageset(void)
>>  {
>>  	struct zone *zone;
>> +	int ret;
>> +
>> +	ret =3D zalloc_cpumask_var(&cpus_with_pcps, GFP_KERNEL);
>> +	BUG_ON(!ret);
>>
>>  	for_each_populated_zone(zone)
>>  		setup_zone_pageset(zone);
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stoptheme=
ter.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>


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
