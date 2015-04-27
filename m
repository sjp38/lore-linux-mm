Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f48.google.com (mail-vn0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA276B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 19:54:17 -0400 (EDT)
Received: by vnbg62 with SMTP id g62so14207754vnb.7
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 16:54:17 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id si1si28230183vdc.42.2015.04.27.16.54.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 16:54:16 -0700 (PDT)
Message-ID: <1430178843.16571.134.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 28 Apr 2015 09:54:03 +1000
In-Reply-To: <alpine.DEB.2.11.1504271147020.29735@gentwo.org>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>, Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, 2015-04-27 at 11:48 -0500, Christoph Lameter wrote:
> On Mon, 27 Apr 2015, Rik van Riel wrote:
> 
> > Why would we want to avoid the sane approach that makes this thing
> > work with the fewest required changes to core code?
> 
> Becaus new ZONEs are a pretty invasive change to the memory management and
> because there are  other ways to handle references to device specific
> memory.

ZONEs is just one option we put on the table.

I think we can mostly agree on the fundamentals that a good model of
such a co-processor is a NUMA node, possibly with a higher distance
than other nodes (but even that can be debated).

That gives us a lot of the basics we need such as struct page, ability
to use existing migration infrastructure, and is actually a reasonably
representation at high level as well.

The question is how do we additionally get the random stuff we don't
care about out of the way. The large distance will not help that much
under memory pressure for example.

Covering the entire device memory with a CMA goes a long way toward that
goal. It will avoid your ordinary kernel allocations.

It also provides just what we need to be able to do large contiguous
"explicit" allocations for use by workloads that don't want the
transparent migration and by the driver for the device which might also
need such special allocations for its own internal management data
structures. 

We still have the risk of pages in the CMA being pinned by something
like gup however, that's where the ZONE idea comes in, to ensure the
various kernel allocators will *never* allocate in that zone unless
explicitly specified, but that could possibly implemented differently.

Maybe a concept of "exclusive" NUMA node, where allocations never
fallback to that node unless explicitly asked to go there.

Of course that would have an impact on memory pressure calculations,
nothign comes completely for free, but at this stage, this is the goal
of this thread, ie, to swap ideas around and see what's most likely to
work in the long run before we even start implementing something.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
