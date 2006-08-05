Date: Fri, 4 Aug 2006 19:05:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: mempolicies: fix policy_zone check
In-Reply-To: <200608050349.49114.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0608041901260.6160@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
 <200608050349.49114.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Sat, 5 Aug 2006, Andi Kleen wrote:

> On Saturday 05 August 2006 01:54, Christoph Lameter wrote:
> 
> > So move the highest_zone() function from mm/page_alloc.c into
> > include/linux/gfp.h.  On the way we simplify the function and use the new
> > zone_type that was also introduced with the zone reduction patchset plus we
> > also specify the right type for the gfp flags parameter.
> 
> The function is a bit big to inline. Better keep it in page_alloc.c, but
> make it global.

Basically we have a maximum of 2 comparisons (no architecture 
supports 4 zones) in the function with a simple constant return.

Most modern processors can do that kind of thing inline without jumps and 
its just a few instructions (likely less than a function call). On most 
platforms that only support DMA and NORMAL we only have a single 
comparison.

Also having that function inline allows optimizations if the gfp flag is 
partially or fully known. If the compiler sees

gfp_zone(__GFP_HIGHMEM | blablabla) then it can substitute ZONE_HIGHMEM .
gfp_zone(GFP_USER) can be determined at compile time etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
