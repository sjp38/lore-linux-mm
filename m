Date: Thu, 13 Apr 2006 19:32:32 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture independent manner V2
In-Reply-To: <20060413095207.GA4047@skynet.ie>
References: <20060412232036.18862.84118.sendpatchset@skynet> <20060413095207.GA4047@skynet.ie>
Message-Id: <20060413191700.1146.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: davej@codemonkey.org.uk, tony.luck@intel.com, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ah, my willing patch is here. :-).
My system, which is Tiger4 with my numa emulation,
can boot up by this patch.

Thanks.


> On (13/04/06 00:20), Mel Gorman didst pronounce:
> > This is V2 of the patchset. They have been boot tested on x86, ppc64
> > and x86_64 but I still need to do a double check that zones are the
> > same size before and after the patch on all arches. IA64 passed a
> > basic compile-test. a driver program that fed in the values generated
> > by IA64 to add_active_range(), zone_present_pages_in_node() and
> > zone_absent_pages_in_node() seemed to generate expected values.
> 
> I didn't look at the test program output carefully enough! There was a
> double counting of some holes because of a missing "if" - obvious in the
> morning. Fix is this (applies on top of the debugging patch)
> 
> diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.17-rc1-zonesizing-v6/mm/mem_init.c linux-2.6.17-rc1-zonesizing-v7/mm/mem_init.c
> --- linux-2.6.17-rc1-zonesizing-v6/mm/mem_init.c	2006-04-13 10:30:50.000000000 +0100
> +++ linux-2.6.17-rc1-zonesizing-v7/mm/mem_init.c	2006-04-13 10:37:11.000000000 +0100
> @@ -761,9 +761,11 @@ unsigned long __init zone_absent_pages_i
>  		}
>  
>  		/* Update the hole size cound and move on */
> -		hole_pages += start_pfn - prev_end_pfn;
> -		printk("Hole found index %d: %lu -> %lu\n",
> -				i, prev_end_pfn, start_pfn);
> +		if (start_pfn > arch_zone_lowest_possible_pfn[zone_type]) {
> +			hole_pages += start_pfn - prev_end_pfn;
> +			printk("Hole found index %d: %lu -> %lu\n",
> +					i, prev_end_pfn, start_pfn);
> +		}
>  		prev_end_pfn = early_node_map[i].end_pfn;
>  	}
>  
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
