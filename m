Subject: Re: where to get ZONE_MOVABLE pathces?
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <02e801c8108c$4d7ca7a0$3708a8c0@arcapub.arca.com>
References: <20071011075743.GA4654@skynet.ie>
	 <01f601c80be8$39537c70$3708a8c0@arcapub.arca.com>
	 <20071011095622.GB4654@skynet.ie>
	 <040c01c80cab$02e6a4f0$3708a8c0@arcapub.arca.com>
	 <20071012101955.GA27254@skynet.ie>
	 <003601c80ee8$c6487ce0$3708a8c0@arcapub.arca.com>
	 <20071015092426.GA31490@skynet.ie>
	 <016401c80f21$bf0e6c30$3708a8c0@arcapub.arca.com>
	 <20071015130744.GA26741@skynet.ie>
	 <024a01c80fcd$ff785e50$3708a8c0@arcapub.arca.com>
	 <20071016125035.GA4294@skynet.ie>
	 <02e801c8108c$4d7ca7a0$3708a8c0@arcapub.arca.com>
Content-Type: text/plain
Date: Wed, 17 Oct 2007 11:04:21 +0100
Message-Id: <1192615461.5901.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jacky(GuangXiang  Lee)" <gxli@arca.com.cn>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-17 at 15:06 +0800, Jacky(GuangXiang Lee) wrote:

> Can I precisely make the RAM range of a specific DIMM to be a independent
> zone?

Technically, yes as nothing stops you. Again, look at what
mm/page_alloc.c#free_area_init_nodes() does to setup each of the zones
as they currently exist.

Also, to reiterate, using a zone is easiest for a prototype but it's
unlikely to be the final solution. You probably want to use page
migration and a page-allocation callback from your driver to move pages
you detect are read-only to flash.

> e.x., I have a machine with 2G RAM(in place of 2 DIMM socket , each socket
> is plugged with 1G RAM)
> then I divided in kernel startup:
>  ZONE_DMA: 0~16M
> ZONE_DMA32: 16M~1G
> ZONE_READONLY:1G~2G (supposing this is my new created zone)
> hence the third zone corresponds to a DIMM hardware.
> right?
> 

You cannot assume that PFN ranges correspond to DIMMs in the normal
case. However, in your specific case where you have a piece of flash
that you want to use as a DIMM, you know exactly what the PFN ranges
are.

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
