Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [ofa-general] Re: Demand paging for memory regions
Date: Fri, 15 Feb 2008 13:09:39 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77030E25BA@nekter>
In-Reply-To: <Pine.LNX.4.64.0802141836070.4898@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>  <ada3arzxgkz.fsf_-_@cisco.com>  <47B2174E.5000708@opengridcomputing.com>  <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>  <adazlu5vlub.fsf@cisco.com>  <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>  <47B45994.7010805@opengridcomputing.com>  <Pine.LNX.4.64.0802141137140.500@schroedinger.engr.sgi.com>  <469958e00802141217i3a3d16a1k1232d69b8ba54471@mail.gmail.com>  <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com> <469958e00802141443g33448abcs3efa6d6c4aec2b56@mail.gmail.com> <Pine.LNX.4.64.0802141445570.3298@schroedinger.engr.sgi.com> <78C9135A3D2ECE4B8162EBDCE82CAD77030E2456@nekter> <Pine.LNX.4.64.0802141836070.4898@schroedinger.engr.sgi.com>
From: "Caitlin Bestler" <Caitlin.Bestler@neterion.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Christoph Lameter asked:
> 
> What does it mean that the "application layer has to be determine what
> pages are registered"? The application does not know which of its
pages
> are currently in memory. It can only force these pages to stay in
> memory if their are mlocked.
> 

An application that advertises an RDMA accessible buffer
to a remote peer *does* have to know that its pages *are*
currently in memory.

The application does *not* need for the virtual-to-physical
mapping of those pages to be frozen for the lifespan of the
Memory Region. But it is issuing an invitation to its peer
to perform direct writes to the advertised buffer. When the
peer decides to exercise that invitation the pages have to
be there.

An analogy: when you write a check for $100 you do not have
to identify the serial numbers of ten $10 bills, but you are
expected to have the funds in your account.

Issuing a buffer advertisement for memory you do not have
is the network equivalent of writing a check that you do
not have funds for.

Now, just as your bank may offer overdraft protection, an
RDMA device could merely report a page fault rather than
tearing down the connection itself. But that does not grant
permission for applications to advertise buffer space that
they do not have committed, it  merely helps recovery from
a programming fault.

A suspend/resume interface between the Virtual Memory Manager
and the RDMA layer allows pages to be re-arranged at the 
convenience of the Virtual Memory Manager without breaking
the application layer peer-to-peer contract. The current
interfaces that pin exact pages are really the equivalent
of having to tell the bank that when Joe cashes this $100
check that you should give him *these* ten $10 bills. It
works, but it adds too much overhead and is very inflexible.
So there are a lot of good reasons to evolve this interface
to better deal with these issues. Other areas of possible
evolution include allowing growing or trimming of Memory
Regions without invalidating their advertised handles.

But the more fundamental issue is recognizing that applications
that use direct interfaces need to know that buffers that they
enable truly have committed resources. They need a way to
ask for twenty *real* pages, not twenty pages of address
space. And they need to do it in a way that allows memory
to be rearranged or even migrated with them to a new host.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
