Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 0A5606B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 17:09:40 -0400 (EDT)
Date: Fri, 5 Oct 2012 14:09:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: memory-hotplug : suppres
 "Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"
 warning
Message-Id: <20121005140938.e3e1e196.akpm@linux-foundation.org>
In-Reply-To: <506D1F1D.9000301@jp.fujitsu.com>
References: <506D1F1D.9000301@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On Thu, 4 Oct 2012 14:31:09 +0900
Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

> When our x86 box calls __remove_pages(), release_mem_region() shows
> many warnings. And x86 box cannot unregister iomem_resource.
> 
> "Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"
> 
> release_mem_region() has been changed as called in each PAGES_PER_SECTION
> chunk since applying a patch(de7f0cba96786c). Because powerpc registers
> iomem_resource in each PAGES_PER_SECTION chunk. But when I hot add memory
> on x86 box, iomem_resource is register in each _CRS not PAGES_PER_SECTION
> chunk. So x86 box unregisters iomem_resource.
> 
> The patch fixes the problem.
> 
> --- linux-3.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-04 14:22:59.833520792 +0900
> +++ linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-04 14:23:05.150521411 +0900
> @@ -77,7 +77,8 @@ static int pseries_remove_memblock(unsig
>  {
>  	unsigned long start, start_pfn;
>  	struct zone *zone;
> -	int ret;
> +	int i, ret;
> +	int sections_to_remove;
>  
>  	start_pfn = base >> PAGE_SHIFT;
>  
> @@ -97,9 +98,13 @@ static int pseries_remove_memblock(unsig
>  	 * to sysfs "state" file and we can't remove sysfs entries
>  	 * while writing to it. So we have to defer it to here.
>  	 */
> -	ret = __remove_pages(zone, start_pfn, memblock_size >> PAGE_SHIFT);
> -	if (ret)
> -		return ret;
> +	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
> +	for (i = 0; i < sections_to_remove; i++) {
> +		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
> +		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
> +		if (ret)
> +			return ret;
> +	}

It is inappropriate that `i' have a signed 32-bit type.  I doubt if
there's any possibility of an overflow bug here, but using a consistent
and well-chosen type would eliminate all doubt.

Note that __remove_pages() does use an unsigned long for this, although
it stupidly calls that variable "i", despite the C programmers'
expectation that a variable called "i" has type "int".

The same applies to `sections_to_remove', but __remove_pages() went and
decided to use an `int' for that variable.  Sigh.

Anyway, please have a think, and see if we can come up with the best
and most accurate choice of types and identifiers in this code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
