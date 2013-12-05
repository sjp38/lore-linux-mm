Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D51156B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 05:26:50 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so24335738pdi.19
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 02:26:50 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id hb3si57547458pac.239.2013.12.05.02.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 02:26:49 -0800 (PST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3BC723EE0BB
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 19:26:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B84A45DEB7
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 19:26:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 128AC45DD77
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 19:26:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01C02E08002
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 19:26:47 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A68F41DB8038
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 19:26:46 +0900 (JST)
Message-ID: <52A054A0.6060108@jp.fujitsu.com>
Date: Thu, 5 Dec 2013 19:25:36 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, x86: Skip NUMA_NO_NODE while parsing SLIT
References: <1386191348-4696-1-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1386191348-4696-1-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, hpa@zytor.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

(2013/12/05 6:09), Toshi Kani wrote:
> When ACPI SLIT table has an I/O locality (i.e. a locality unique
> to an I/O device), numa_set_distance() emits the warning message
> below.
> 
>   NUMA: Warning: node ids are out of bound, from=-1 to=-1 distance=10
> 
> acpi_numa_slit_init() calls numa_set_distance() with pxm_to_node(),
> which assumes that all localities have been parsed with SRAT previously.
> SRAT does not list I/O localities, where as SLIT lists all localities

> including I/Os.  Hence, pxm_to_node() returns NUMA_NO_NODE (-1) for
> an I/O locality.  I/O localities are not supported and are ignored
> today, but emitting such warning message leads unnecessary confusion.

In this case, the warning message should not be shown. But if SLIT table
is really broken, the message should be shown. Your patch seems to not care
for second case.

Thanks,
Yasuaki Ishimatsu


> 
> Change acpi_numa_slit_init() to avoid calling numa_set_distance()
> with NUMA_NO_NODE.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>   arch/x86/mm/srat.c |   10 ++++++++--
>   1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
> index 266ca91..29a2ced 100644
> --- a/arch/x86/mm/srat.c
> +++ b/arch/x86/mm/srat.c
> @@ -47,10 +47,16 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
>   {
>   	int i, j;
>   
> -	for (i = 0; i < slit->locality_count; i++)
> -		for (j = 0; j < slit->locality_count; j++)
> +	for (i = 0; i < slit->locality_count; i++) {
> +		if (pxm_to_node(i) == NUMA_NO_NODE)
> +			continue;
> +		for (j = 0; j < slit->locality_count; j++) {
> +			if (pxm_to_node(j) == NUMA_NO_NODE)
> +				continue;
>   			numa_set_distance(pxm_to_node(i), pxm_to_node(j),
>   				slit->entry[slit->locality_count * i + j]);
> +		}
> +	}
>   }
>   
>   /* Callback for Proximity Domain -> x2APIC mapping */
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
