From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Date: Sat, 11 Aug 2007 03:04:54 +0200
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie> <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708110304.55433.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 10 August 2007 21:02, Christoph Lameter wrote:
> On Fri, 10 Aug 2007, Andi Kleen wrote:
> > > x86_64 does not support ZONE_HIGHMEM.
> >
> > I also plan to eliminate ZONE_DMA soon (and replace all its users
> > with a new allocator that sits outside the normal fallback lists)
>
> Hallelujah. You are my hero! x86_64 will switch off CONFIG_ZONE_DMA?

Yes. i386 too actually.

The DMA zone will be still there, but only reachable with special functions.

This is fine because the default zone protection heuristics keep DMA 
near always free from !GFP_DMA allocations anyways -- so it doesn't make much 
difference if it's totally unreachable. swiotlb will also use the same pool.

Also all callers are going to pass masks around so it's always clear
what address range they really need. Actually a lot of them
pass still 16MB simply because it is hard to find out what masks
old undocumented hardware really needs. But this could change.

This also means the DMA support in sl[a-z]b is not needed anymore.

I went through near all GFP_DMA users and found they're usually
happy enough with pages. If someone comes up who really needs
lots of subobjects the right way for them would be likely extending
the pci pool allocator for this case. But I haven't found a need for this yet.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
