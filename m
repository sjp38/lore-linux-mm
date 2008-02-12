Date: Tue, 12 Feb 2008 16:23:29 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080212232329.GC31435@obsidianresearch.com>
References: <20080209012446.GB7051@v2.random> <Pine.LNX.4.64.0802081725200.5445@schroedinger.engr.sgi.com> <20080209015659.GC7051@v2.random> <Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com> <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <adazlu5vlub.fsf@cisco.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland Dreier <rdreier@cisco.com>
Cc: Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2008 at 02:41:48PM -0800, Roland Dreier wrote:
>  > > Chelsio's T3 HW doesn't support this.
> 
>  > Not so far I guess but it could be equipped with these features right? 
> 
> I don't know anything about the T3 internals, but it's not clear that
> you could do this without a new chip design in general.  Lot's of RDMA
> devices were designed expecting that when a packet arrives, the HW can
> look up the bus address for a given memory region/offset and place
> the

Well, certainly today the memfree IB devices store the page tables in
host memory so they are already designed to hang onto packets during
the page lookup over PCIE, adding in faulting makes this time
larger.

But this is not a good thing at all, IB's congestion model is based on
the notion that end ports can always accept packets without making
input contigent on output. If you take a software interrupt to fill in
the page pointer then you could potentially deadlock on the
fabric. For example using this mechanism to allow swap-in of RDMA target
pages and then putting the storage over IB would be deadlock
prone. Even without deadlock slowing down the input path will cause
network congestion and poor performance for other nodes. It is not a
desirable thing to do..

I expect that iwarp running over flow controlled ethernet has similar
kinds of problems for similar reasons..

In general the best I think you can hope for with RDMA hardware is
page migration using some atomic operations with the adaptor and a cpu
page copy with retry sort of scheme - but is pure page migration
interesting at all?

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
