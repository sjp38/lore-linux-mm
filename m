Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA27gTtS017740
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 02:42:29 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA27gTbn118496
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 02:42:29 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA27gSxP016136
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 02:42:29 -0500
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <43680D8C.5080500@yahoo.com.au>
References: <20051030235440.6938a0e9.akpm@osdl.org>
	 <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au>
	 <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au>
	 <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au>
	 <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu>
	 <1130854224.14475.60.camel@localhost>  <20051101142959.GA9272@elte.hu>
	 <1130856555.14475.77.camel@localhost>  <43680D8C.5080500@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 02 Nov 2005 08:42:18 +0100
Message-Id: <1130917338.14475.133.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-02 at 11:51 +1100, Nick Piggin wrote:
> Look: if you have to guarantee memory can be shrunk, set aside a zone
> for it (that only fills with user reclaimable areas). This is better
> than the current frag patches because it will give you the 100%
> guarantee that you need (provided we have page migration to move mlocked
> pages).

With Mel's patches, you can easily add the same guarantee.  Look at the
code in  fallback_alloc() (patch 5/8).  It would be quite easy to modify
the fallback lists to disallow fallbacks into areas from which we would
like to remove memory.  That was left out for simplicity.  As you say,
they're quite complex as it is.  Would you be interested in seeing a
patch to provide those kinds of guarantees?

We've had a bit of experience with a hotpluggable zone approach  before.
Just like the current topic patches, you're right, that approach can
also provide strong guarantees.  However, the issue comes if the system
ever needs to move memory between such zones, such as if a user ever
decides that they'd prefer to break hotplug guarantees rather than OOM.

Do you think changing what a particular area of memory is being used for
would ever be needed?

One other thing, if we decide to take the zones approach, it would have
no other side benefits for the kernel.  It would be for hotplug only and
I don't think even the large page users would get much benefit.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
