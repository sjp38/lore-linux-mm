Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [ofa-general] Re: Demand paging for memory regions
Date: Thu, 14 Feb 2008 20:26:51 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77030E2456@nekter>
In-Reply-To: <Pine.LNX.4.64.0802141445570.3298@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>  <ada3arzxgkz.fsf_-_@cisco.com>  <47B2174E.5000708@opengridcomputing.com>  <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>  <adazlu5vlub.fsf@cisco.com>  <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>  <47B45994.7010805@opengridcomputing.com>  <Pine.LNX.4.64.0802141137140.500@schroedinger.engr.sgi.com>  <469958e00802141217i3a3d16a1k1232d69b8ba54471@mail.gmail.com>  <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com> <469958e00802141443g33448abcs3efa6d6c4aec2b56@mail.gmail.com> <Pine.LNX.4.64.0802141445570.3298@schroedinger.engr.sgi.com>
From: "Caitlin Bestler" <Caitlin.Bestler@neterion.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>


> -----Original Message-----
> From: Christoph Lameter [mailto:clameter@sgi.com]
> Sent: Thursday, February 14, 2008 2:49 PM
> To: Caitlin Bestler
> Cc: linux-kernel@vger.kernel.org; avi@qumranet.com;
linux-mm@kvack.org;
> general@lists.openfabrics.org; kvm-devel@lists.sourceforge.net
> Subject: Re: [ofa-general] Re: Demand paging for memory regions
> 
> On Thu, 14 Feb 2008, Caitlin Bestler wrote:
> 
> > I have no problem with that, as long as the application layer is
> responsible for
> > tearing down and re-establishing the connections. The RDMA/transport
> layers
> > are incapable of tearing down and re-establishing a connection
> transparently
> > because connections need to be approved above the RDMA layer.
> 
> I am not that familiar with the RDMA layers but it seems that RDMA has
> a library that does device driver like things right? So the logic
would
> best fit in there I guess.
> 
> If you combine mlock with the mmu notifier then you can actually
> guarantee that a certain memory range will not be swapped out. The
> notifier will then only be called if the memory range will need to be
> moved for page migration, memory unplug etc etc. There may be a limit
> on
> the percentage of memory that you can mlock in the future. This may be
> done to guarantee that the VM still has memory to work with.
> 

The problem is that with existing APIs, or even slightly modified APIs,
the RDMA layer will not be able to figure out which connections need to
be "interrupted" in order to deal with what memory suspensions.

Further, because any request for a new connection will be handled by
the remote *application layer* peer there is no way for the two RDMA
layers to agree to covertly tear down and re-establish the connection.
Nor really should there be, connections should be approved by OS layer
networking controls. RDMA should not be able to tell the network stack,
"trust me, you don't have to check if this connection is legitimate".

Another example, if you terminate a connection pending receive
operations
complete *to the user* in a Completion Queue. Those completions are NOT
seen by the RDMA layer, and especially not by the Connection Manager. It
has absolutely no way to repost them transparently to the same
connection
when the connection is re-established.

Even worse, some portions of a receive operation might have been placed
in the receive buffer and acknowledged to the remote peer. But there is
no mechanism to report this fact in the CQE. A receive operation that is
aborted is aborted. There is no concept of partial success. Therefore
you
cannot covertly terminate a connection mid-operation and covertly
re-establish
it later. Data will be lost, it will no longer be a reliable connection,
and
therefore it needs to be torn down anyway.

The RDMA layers also cannot tell the other side not to transmit. Flow
control is the responsibility of the application layer, not RDMA.

What the RDMA layer could do is this: once you tell it to suspend a
given
memory region it can either tell you that it doesn't know how to do that
or it can instruct the device to stop processing a set of connections
that will ceases all access for a given Memory Region. When you resume
it can guarantee that it is no longer using any cached older mappings
for the memory region (assuming it was capable of doing the suspend),
and then because RDMA connections are reliable everything will recover
unless the connection timed-out. The chance that it will time-out is
probably low, but the chance that the underlying connection will be in
slow start or equivalent is much higher.

So any solution that requires the upper layers to suspend operations
for a brief bit will require explicit interaction with those layers.
No RDMA layer can perform the sleight of hand tricks that you seem
to want it to perform.

AT the RDMA layer the best you could get is very brief suspensions
for the purpose of *re-arranging* memory, not of reducing the amount
of registered memory. If you need to reduce the amount of registered
memory then you have to talk to the application. Discussions on making
it easier for the application to trim a memory region dynamically might
be in order, but you will not work around the fact that the application
layer needs to determine what pages are registered. And they would
really
prefer just to be told how much memory they can have up front, they can
figure out how to deal with that amount of memory on their own.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
