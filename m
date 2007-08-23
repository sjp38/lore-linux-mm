From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18125.23918.550443.628936@gargle.gargle.HOWL>
Date: Thu, 23 Aug 2007 14:11:58 +0400
Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if
	PF_MEMALLOC is set
In-Reply-To: <1187861208.6114.342.camel@twins>
References: <20070814153021.446917377@sgi.com>
	<20070814153501.305923060@sgi.com>
	<20070818071035.GA4667@ucw.cz>
	<Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
	<1187641056.5337.32.camel@lappy>
	<Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
	<1187644449.5337.48.camel@lappy>
	<20070821003922.GD8414@wotan.suse.de>
	<1187705235.6114.247.camel@twins>
	<20070823033826.GE18788@wotan.suse.de>
	<1187861208.6114.342.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra writes:

[...]

 > My idea is to extend kswapd, run cpus_per_node instances of kswapd per
 > node for each of GFP_KERNEL, GFP_NOFS, GFP_NOIO. (basically 3 kswapds
 > per cpu)
 > 
 > whenever we would hit direct reclaim, add ourselves to a special
 > waitqueue corresponding to the type of GFP and kick all the
 > corresponding kswapds.

There are two standard objections to this:

    - direct reclaim was introduced to reduce memory allocation latency,
      and going to scheduler kills this. But more importantly,

    - it might so happen that _all_ per-cpu kswapd instances are
      blocked, e.g., waiting for IO on indirect blocks, or queue
      congestion. In that case whole system stops waiting for IO to
      complete. In the direct reclaim case, other threads can continue
      zone scanning.

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
