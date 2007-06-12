Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C3UrjP027498
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:30:53 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C3UrPD251792
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:30:53 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C3UrKp023568
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:30:53 -0600
Date: Mon, 11 Jun 2007 20:30:50 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612033050.GR3798@us.ibm.com>
References: <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com> <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com> <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com> <20070612031718.GP3798@us.ibm.com> <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [20:19:24 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > Ahh did not see that. Can you not call simply into interleave() from 
> > > mempolicy.c? It will get you the counter that you need.
> > 
> > You just told me that mempolicy.c is built conditionally on NUMA.
> > alloc_fresh_huge_page() is not, it only depeonds on CONFIG_HUGETLB_PAGE!
> 
> Well you just need to have the appropriate fallbacks defined in
> mempolicy.h

Ok, I understand that.

> > The only interleave functions I see in mempolicy.c are:
> > 
> > interleave_nodes(), which takes a mempolicy, which I don't have in
> > hugetlb.c
> > 
> > interleave_nid(), which also takes a mempolicy
> > 
> > I guess I could try and use huge_zonelist(), but I don't see the point?
> 
> Export a function for the interleave functionality so that we do not
> have to replicate the same thing in various locations in the kernel.

But I don't understand this at all.

This is *not* generically available, unless every caller has its own
private static variable. I don't know how to do that in C.

You're asking me to complicate patches that work just fine right now.
Well, excluding a hasty patch that I didn't compile-test. All I'm trying
to do is ask for some guidance.

What we have here is:

alloc_fresh_huge_page() should return 1 after a successful allocation of
a huge page on a different node, in a round-robin fashion, on every
invocation; or 0, if no huge page could be allocated.

I don't see how to make that generic in a simple way. It relies on an
interator that is private to the function, not to any structure. And
this is really a one-time allocation right now (hugepages).

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
