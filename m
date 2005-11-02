Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA29X8eH015986
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 04:33:08 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA29X6Xg525988
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 02:33:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA29X51b003277
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 02:33:05 -0700
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <436880B8.1050207@yahoo.com.au>
References: <4366C559.5090504@yahoo.com.au>
	 <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au>
	 <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu>
	 <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu>
	 <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu>
	 <1130858580.14475.98.camel@localhost> <20051102084946.GA3930@elte.hu>
	 <436880B8.1050207@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 02 Nov 2005 10:32:49 +0100
Message-Id: <1130923969.15627.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-02 at 20:02 +1100, Nick Piggin wrote:
> I agree. Especially considering that all this memory hotplug usage for
> hypervisors etc. is a relatively new thing with few of our userbase
> actually using it. I think a simple zones solution is the right way to
> go for now.

I agree enough on concept that I think we can go implement at least a
demonstration of how easy it is to perform.

There are a couple of implementation details that will require some
changes to the current zone model, however.  Perhaps you have some
suggestions on those.

In which zone do we place hot-added RAM?  I don't think answer can
simply be the HOTPLUGGABLE zone.  If you start with sufficiently small
of a machine, you'll degrade into the same horrible HIGHMEM behavior
that a 64GB ia32 machine has today, despite your architecture.  Think of
a machine that starts out with a size of 256MB and grows to 1TB.

So, if you have to add to NORMAL/DMA on the fly, how do you handle a
case where the new NORMAL/DMA ram is physically above
HIGHMEM/HOTPLUGGABLE?  Is there any other course than to make a zone
required to be able to span other zones, and be noncontiguous?  Would
that represent too much of a change to the current model?

>From where do we perform reclaim when we run out of a particular zone?
Getting reclaim rates of the HIGHMEM and NORMAL zones balanced has been
hard, and I worry that we never got it quite.  Introducing yet another
zone makes this harder.

Should we allow allocations for NORMAL to fall back into HOTPLUGGABLE in
any case?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
