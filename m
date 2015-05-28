Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id B2F3B6B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:18:43 -0400 (EDT)
Received: by qgf2 with SMTP id 2so20121175qgf.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:18:43 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id w126si3224795qkw.2.2015.05.28.11.18.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 28 May 2015 11:18:42 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 28 May 2015 12:18:41 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E03743E40047
	for <linux-mm@kvack.org>; Thu, 28 May 2015 12:18:38 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4SIGQMU29294670
	for <linux-mm@kvack.org>; Thu, 28 May 2015 11:16:26 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4SIIbYY001421
	for <linux-mm@kvack.org>; Thu, 28 May 2015 12:18:38 -0600
Date: Thu, 28 May 2015 11:18:35 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150528181835.GI5989@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
 <20150427154728.GA26980@gmail.com>
 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
 <553E6405.1060007@redhat.com>
 <alpine.DEB.2.11.1504271147020.29735@gentwo.org>
 <1430178843.16571.134.camel@kernel.crashing.org>
 <55535B6E.5090700@suse.cz>
 <1431560326.20218.94.camel@kernel.crashing.org>
 <55545124.7090804@suse.cz>
 <1431589879.4160.50.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431589879.4160.50.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org, laijs@cn.fujitsu.com

On Thu, May 14, 2015 at 05:51:19PM +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2015-05-14 at 09:39 +0200, Vlastimil Babka wrote:
> > On 05/14/2015 01:38 AM, Benjamin Herrenschmidt wrote:
> > > On Wed, 2015-05-13 at 16:10 +0200, Vlastimil Babka wrote:
> > >> Sorry for reviving oldish thread...
> > >
> > > Well, that's actually appreciated since this is constructive discussion
> > > of the kind I was hoping to trigger initially :-) I'll look at
> > 
> > I hoped so :)
> > 
> > > ZONE_MOVABLE, I wasn't aware of its existence.
> > >
> > > Don't we still have the problem that ZONEs must be somewhat contiguous
> > > chunks ? Ie, my "CAPI memory" will be interleaved in the physical
> > > address space somewhat.. This is due to the address space on some of
> > > those systems where you'll basically have something along the lines of:
> > >
> > > [ node 0 mem ] [ node 0 CAPI dev ] .... [ node 1 mem] [ node 1 CAPI dev] ...
> > 
> > Oh, I see. The VM code should cope with that, but some operations would 
> > be inefficiently looping over the holes in the CAPI zone by 2MB 
> > pageblock per iteration. This would include compaction scanning, which 
> > would suck if you need those large contiguous allocations as you said. 
> > Interleaving works better if it's done with a smaller granularity.
> > 
> > But I guess you could just represent the CAPI as multiple NUMA nodes, 
> > each with single ZONE_MOVABLE zone. Especially if "node 0 CAPI dev" and 
> > "node 1 CAPI dev" differs in other characteristics than just using a 
> > different range of PFNs... otherwise what's the point of this split anyway?
> 
> Correct, I think we want the CAPI devs to look like CPU-less NUMA nodes
> anyway. This is the right way to target an allocation at one of them and
> it conveys the distance properly, so it makes sense.
> 
> I'll add the ZONE_MOVABLE to the list of things to investigate on our
> side, thanks for the pointer !

Any thoughts on CONFIG_MOVABLE_NODE and the corresponding "movable_node"
boot parameter?  It looks like it is designed to make an entire NUMA
node's memory hotpluggable, which seems consistent with what we are
trying to do here.  This feature is currently x86_64-only, so would need
to be enabled on other architectures.

It looks like this is intended to be used by booting normally, but
keeping the CAPI nodes' memory offline, setting movable_node, then
onlining their memory.

Thoughts?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
