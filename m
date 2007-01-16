Date: Tue, 16 Jan 2007 14:18:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/8] Cpuset aware writeback
In-Reply-To: <200701170901.58757.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0701161416060.3545@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
 <200701170901.58757.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jan 2007, Andi Kleen wrote:

> > Secondly we modify the dirty limit calculation to be based
> > on the acctive cpuset.
> 
> The global dirty limit definitely seems to be a problem
> in several cases, but my feeling is that the cpuset is the wrong unit
> to keep track of it. Most likely it should be more fine grained.

We already have zone reclaim that can take care of smaller units but why 
would we start writeback if only one zone is full of dirty pages and there
are lots of other zones (nodes) that are free?

> > If we are in a cpuset then we select only inodes for writeback
> > that have pages on the nodes of the cpuset.
> 
> Is there any indication this change helps on smaller systems
> or is it purely a large system optimization?

The bigger the system the larger the problem because the ratio of dirty
pages is calculated is currently based on the percentage of dirty pages
in the system as a whole. The less percentage of a system a cpuset 
contains the less effective the dirty_ratio and background_dirty_ratio 
become.

> > B. We add a new counter NR_UNRECLAIMABLE that is subtracted
> >    from the available pages in a node. This allows us to
> >    accurately calculate the dirty ratio even if large portions
> >    of the node have been allocated for huge pages or for
> >    slab pages.
> 
> That sounds like a useful change by itself.

I can separate that one out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
