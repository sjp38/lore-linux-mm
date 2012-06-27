Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 4C9266B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 02:16:27 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1313621pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 23:16:26 -0700 (PDT)
Date: Tue, 26 Jun 2012 23:16:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/12] memory-hogplug : check memory offline in
 offline_pages
In-Reply-To: <4FEA9DB1.7010303@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206262313440.32567@chino.kir.corp.google.com>
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9DB1.7010303@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On Wed, 27 Jun 2012, Yasuaki Ishimatsu wrote:

> Index: linux-3.5-rc4/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-26 13:28:16.743211538 +0900
> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:38.264940468 +0900
> @@ -887,6 +887,11 @@ static int __ref offline_pages(unsigned
> 
>  	lock_memory_hotplug();
> 
> +	if (memory_is_offline(start_pfn, end_pfn)) {
> +		ret = 0;
> +		goto out;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;

Are there additional prerequisites for this patch?  Otherwise it changes 
the return value of offline_memory() which will now call 
acpi_memory_powerdown_device() in the acpi memhotplug case when disabling.  
Is that a problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
