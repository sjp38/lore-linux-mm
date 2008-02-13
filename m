Date: Wed, 13 Feb 2008 12:51:44 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080213195144.GE31435@obsidianresearch.com>
References: <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com> <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com> <20080213012638.GD31435@obsidianresearch.com> <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com> <20080213032533.GC32047@obsidianresearch.com> <Pine.LNX.4.64.0802131039160.18472@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802131039160.18472@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Roland Dreier <rdreier@cisco.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2008 at 10:51:58AM -0800, Christoph Lameter wrote:
> On Tue, 12 Feb 2008, Jason Gunthorpe wrote:
> 
> > But this isn't how IB or iwarp work at all. What you describe is a
> > significant change to the general RDMA operation and requires changes to
> > both sides of the connection and the wire protocol.
> 
> Yes it may require a separate connection between both sides where a 
> kind of VM notification protocol is established to tear these things down and 
> set them up again. That is if there is nothing in the RDMA protocol that
> allows a notification to the other side that the mapping is being down 
> down.

Well, yes, you could build this thing you are describing on top of the
RDMA protocol and get some support from some of the hardware - but it
is a new set of protocols and they would need to be implemented in
several places. It is not transparent to userspace and it is not
compatible with existing implementations.

Unfortunately it really has little to do with the drivers - changes,
for instance, need to be made to support this in the user space MPI
libraries. The RDMA ops do not pass through the kernel, userspace
talks directly to the hardware which complicates building any sort of
abstraction.

That is where I think you run into trouble, if you ask the MPI people
to add code to their critical path to support swapping they probably
will not be too interested. At a minimum to support your idea you need
to check on every RDMA if the remote page is mapped... Plus the
overheads Christian was talking about in the OOB channel(s).

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
