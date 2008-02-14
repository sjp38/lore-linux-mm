Date: Wed, 13 Feb 2008 17:01:03 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080214000103.GG31435@obsidianresearch.com>
References: <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com> <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com> <20080213012638.GD31435@obsidianresearch.com> <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com> <20080213040905.GQ29340@mv.qlogic.com> <20080213232308.GB7597@osc.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080213232308.GB7597@osc.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pete Wyckoff <pw@osc.edu>
Cc: Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2008 at 06:23:08PM -0500, Pete Wyckoff wrote:
> christian.bell@qlogic.com wrote on Tue, 12 Feb 2008 20:09 -0800:
> > One other area that has not been brought up yet (I think) is the
> > applicability of notifiers in letting users know when pinned memory
> > is reclaimed by the kernel.  This is useful when a lower-level
> > library employs lazy deregistration strategies on memory regions that
> > are subsequently released to the kernel via the application's use of
> > munmap or sbrk.  Ohio Supercomputing Center has work in this area but
> > a generalized approach in the kernel would certainly be welcome.
> 
> The whole need for memory registration is a giant pain.  There is no
> motivating application need for it---it is simply a hack around
> virtual memory and the lack of full VM support in current hardware.
> There are real hardware issues that interact poorly with virtual
> memory, as discussed previously in this thread.

Well, the registrations also exist to provide protection against
rouge/faulty remotes, but for the purposes of MPI that is probably not
important.

Here is a thought.. Some RDMA hardware can change the page tables on
the fly. What if the kernel had a mechanism to dynamically maintain a
full registration of the processes entire address space ('mlocked' but
able to be migrated)? MPI would never need to register a buffer, and
all the messy cases with munmap/sbrk/etc go away - the risk is that
other MPI nodes can randomly scribble all over the process :)

Christoph: It seemed to me you were first talking about
freeing/swapping/faulting RDMA'able pages - but would pure migration
as a special hardware supported case be useful like Catilan suggested?

Regards,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
