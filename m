Message-ID: <4513B69B.3050104@yahoo.com.au>
Date: Fri, 22 Sep 2006 20:10:35 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com> <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com> <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com> <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com> <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com> <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com> <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com> <20060917152723.5bb69b82.pj@sgi.com> <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com> <20060917192010.cc360ece.pj@sgi.com> <20060918093434.e66b8887.pj@sgi.com> <Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com> <Pine.LNX.4.63.0609211510130.17417@chino.corp.google.com>
In-Reply-To: <Pine.LNX.4.63.0609211510130.17417@chino.corp.google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c

You have a couple of problems with the page_alloc side. First of all,
__alloc_pages can be called from interrupt context and you don't
protect current->last_zonelist from that.

Secondly, you aren't checking wrapping the zone and checking skipped
ones so you may return NULL by mistake.

Also, if you are going into page reclaim, get_page_from_freelist is
designed to return NULL after at the first call from __alloc_pages,
so you end up having to go through all zones and check all their
watermarks anyway. If you use my pcp patch, this can be made to
happen much less frequently.

> @@ -34,6 +34,7 @@ #include <linux/cpu.h>
>  #include <linux/cpuset.h>
>  #include <linux/memory_hotplug.h>
>  #include <linux/nodemask.h>
> +#include <linux/numa.h>
>  #include <linux/vmalloc.h>
>  #include <linux/mempolicy.h>
>  #include <linux/stop_machine.h>
> @@ -870,6 +871,14 @@ get_page_from_freelist(gfp_t gfp_mask, u
>  	struct zone **z = zonelist->zones;
>  	struct page *page = NULL;
>  	int classzone_idx = zone_idx(*z);
> +	unsigned index = 0;
> +
> +	if (numa_emu_enabled) {
> +		if (zonelist == current->last_zonelist &&
> +		    (alloc_flags & __GFP_HARDWALL) && (alloc_flags & ALLOC_CPUSET))
> +			z += current->last_zone_used;
> +		current->last_zonelist = zonelist;
> +	}
>  
>  	/*
>  	 * Go through the zonelist once, looking for a zone with enough free.
> @@ -897,8 +906,11 @@ get_page_from_freelist(gfp_t gfp_mask, u
>  
>  		page = buffered_rmqueue(zonelist, *z, order, gfp_mask);
>  		if (page) {
> +			if (numa_emu_enabled)
> +				current->last_zone_used = index;
>  			break;
>  		}
> +		index++;
>  	} while (*(++z) != NULL);
>  	return page;
>  }

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
