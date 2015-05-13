Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id E1D7A6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 19:38:58 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so29846792qgf.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 16:38:58 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 130si17657770qhv.73.2015.05.13.16.38.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 13 May 2015 16:38:57 -0700 (PDT)
Message-ID: <1431560326.20218.94.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 14 May 2015 09:38:46 +1000
In-Reply-To: <55535B6E.5090700@suse.cz>
References: <20150424150829.GA3840@gmail.com>
	 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
	 <20150424164325.GD3840@gmail.com>
	 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
	 <20150424171957.GE3840@gmail.com>
	 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
	 <20150424192859.GF3840@gmail.com>
	 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
	 <20150425114633.GI5561@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
	 <20150427154728.GA26980@gmail.com>
	 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
	 <553E6405.1060007@redhat.com>
	 <alpine.DEB.2.11.1504271147020.29735@gentwo.org>
	 <1430178843.16571.134.camel@kernel.crashing.org> <55535B6E.5090700@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 2015-05-13 at 16:10 +0200, Vlastimil Babka wrote:
> Sorry for reviving oldish thread...

Well, that's actually appreciated since this is constructive discussion
of the kind I was hoping to trigger initially :-) I'll look at
ZONE_MOVABLE, I wasn't aware of its existence.

Don't we still have the problem that ZONEs must be somewhat contiguous
chunks ? Ie, my "CAPI memory" will be interleaved in the physical
address space somewhat.. This is due to the address space on some of
those systems where you'll basically have something along the lines of:

[ node 0 mem ] [ node 0 CAPI dev ] .... [ node 1 mem] [ node 1 CAPI dev] ...

> On 04/28/2015 01:54 AM, Benjamin Herrenschmidt wrote:
> > On Mon, 2015-04-27 at 11:48 -0500, Christoph Lameter wrote:
> >> On Mon, 27 Apr 2015, Rik van Riel wrote:
> >>
> >>> Why would we want to avoid the sane approach that makes this thing
> >>> work with the fewest required changes to core code?
> >>
> >> Becaus new ZONEs are a pretty invasive change to the memory management and
> >> because there are  other ways to handle references to device specific
> >> memory.
> >
> > ZONEs is just one option we put on the table.
> >
> > I think we can mostly agree on the fundamentals that a good model of
> > such a co-processor is a NUMA node, possibly with a higher distance
> > than other nodes (but even that can be debated).
> >
> > That gives us a lot of the basics we need such as struct page, ability
> > to use existing migration infrastructure, and is actually a reasonably
> > representation at high level as well.
> >
> > The question is how do we additionally get the random stuff we don't
> > care about out of the way. The large distance will not help that much
> > under memory pressure for example.
> >
> > Covering the entire device memory with a CMA goes a long way toward that
> > goal. It will avoid your ordinary kernel allocations.
> 
> I think ZONE_MOVABLE should be sufficient for this. CMA is basically for 
> marking parts of zones as MOVABLE-only. You shouldn't need that for the 
> whole zone. Although it might happen that CMA will be a special zone one 
> day.
> 
> > It also provides just what we need to be able to do large contiguous
> > "explicit" allocations for use by workloads that don't want the
> > transparent migration and by the driver for the device which might also
> > need such special allocations for its own internal management data
> > structures.
> 
> Plain zone compaction + reclaim should work as well in a ZONE_MOVABLE 
> zone. CMA allocations might IIRC additionally migrate across zones, e.g. 
> from the device to system memory (unlike plain compaction), which might 
> be what you want, or not.
> 
> > We still have the risk of pages in the CMA being pinned by something
> > like gup however, that's where the ZONE idea comes in, to ensure the
> > various kernel allocators will *never* allocate in that zone unless
> > explicitly specified, but that could possibly implemented differently.
> 
> Kernel allocations should ignore the ZONE_MOVABLE zone as they are not 
> typically movable. Then it depends on how much control you want for 
> userspace allocations.
> 
> > Maybe a concept of "exclusive" NUMA node, where allocations never
> > fallback to that node unless explicitly asked to go there.
> 
> I guess that could be doable on the zonelist level, where the device 
> memory node/zone wouldn't be part of the "normal" zonelists, so memory 
> pressure calculations should be also fine. But sure there will be some 
> corner cases :)
> 
> > Of course that would have an impact on memory pressure calculations,
> > nothign comes completely for free, but at this stage, this is the goal
> > of this thread, ie, to swap ideas around and see what's most likely to
> > work in the long run before we even start implementing something.
> >
> > Cheers,
> > Ben.
> >
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
