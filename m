Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2EMInua284016
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 17:18:49 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2EMInPc123462
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 15:18:49 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2EMImdl011235
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 15:18:49 -0700
Subject: Re: [PATCH 0/4] sparsemem intro patches
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050314135021.639d1533.davem@davemloft.net>
References: <1110834883.19340.47.camel@localhost>
	 <20050314135021.639d1533.davem@davemloft.net>
Content-Type: text/plain
Date: Mon, 14 Mar 2005 14:18:31 -0800
Message-Id: <1110838711.19340.58.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-03-14 at 13:50 -0800, David S. Miller wrote:
> On Mon, 14 Mar 2005 13:14:43 -0800
> Dave Hansen <haveblue@us.ibm.com> wrote:
> 
> > Three of these are i386-only, but one of them reorganizes the macros
> > used to manage the space in page->flags, and will affect all platforms.
> > There are analogous patches to the i386 ones for ppc64, ia64, and
> > x86_64, but those will be submitted by the normal arch maintainers.
> 
> Sparc64 uses some of the upper page->flags bits to store D-cache
> flushing state.
> 
> Specifically, PG_arch_1 is used to set whether the page is scheduled
> for delayed D-cache flushing, and bits 24 and up say which CPU the
> CPU stores occurred on (and thus which CPU will get the cross-CPU
> message to flush it's D-cache should the deferred flush actually
> occur).
> 
> I imagine that since we don't support the domain stuff (yet) on sparc64,
> your patches won't break things, but it is something to be aware of.

Those bits are used today for page_zone() and page_to_nid().  I assume
that you don't support NUMA, but how do you get around the page_zone()
definition?  (a quick grep in asm-sparc64 didn't show anything obvious)

        static inline struct zone *page_zone(struct page *page)
        {
                return zone_table[page->flags >> NODEZONE_SHIFT];
        }
        
BTW, in theory, the new patch should allow page->flags to be better
managed by a variety of users, including special arch users.  An
architecture should be able to relatively easily add the necessary
pieces to reserve them.  We could even have a ARCH_RESERVED_BITS macro
or something.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
