Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 58B1A6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 21:08:20 -0500 (EST)
Date: Wed, 4 Nov 2009 02:08:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
	high-order watermarks are being hit
Message-ID: <20091104020815.GH22046@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911032301.59662.elendil@planet.nl> <20091103220808.GF22046@csn.ul.ie> <200911040101.50194.elendil@planet.nl> <20091104011811.GG22046@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091104011811.GG22046@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 01:18:11AM +0000, Mel Gorman wrote:
> > From vmstat for .31.1:
> > kswapd_highorder_rewakeup 20
> > kswapd_slept_prematurely_fast 307
> > kswapd_slept_prematurely_slow 105
> > 
> 
> This is useful.
> 
> The high premature_fast shows that after kswapd apparently finishes its work,
> the high waterwater marks are being breached very quickly (the fast counter
> being positive). The "slow" counter is even worse. Your machine is getting
> from the high to low watermark quickly without kswapd noticing and processes
> depending on the atomics are not waiting long enough.
> 

Sorry, that should have been

 The premature_fast shows that after kswapd finishes its work, the low
 waterwater marks are being breached very quickly as kswapd is being rewoken
 up. The "slow" counter is slightly worse. Just after kswapd sleeps, the
 high watermark is being breached again.

Either counter being positive implies that kswapd is having to do too
much work while parallel allocators are chewing up the high-order pages
quickly. The effect of the patch should still be to delay the rate high-order
pages are consumed but it assumes there are enough high-order requests that
can go to sleep.

Mentioning sleep, I'm going to get some.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
