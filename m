Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6216B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 12:26:14 -0500 (EST)
Date: Tue, 2 Mar 2010 17:26:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Memory management woes - order 1 allocation failures
Message-ID: <20100302172606.GA11355@csn.ul.ie>
References: <alpine.DEB.2.00.1002261042020.7719@router.home> <84144f021002260917q61f7c255rf994425f3a613819@mail.gmail.com> <20100301103546.DD86.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100301103546.DD86.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 10:42:50AM +0900, KOSAKI Motohiro wrote:
> > AFAICT, even in the worst case, the latter call-site is well below 4K.
> > I have no idea of the tty one.
> 
> afaik, tty_buffer_request_room() try to expand its buffer size for efficiency. but Its failure
> doesn't cause any user visible failure. probably we can mark it as NOWARN.
> 
> In worst case, maximum tty buffer size is 64K, it can make allocation failure easily.
>
> Alan, Can you please tell us your mention?
> 

(Added Greg as current tty maintainer)

For reasons that are not particularly clear to me, tty_buffer_alloc() is
called far more frequently in 2.6.33 than in 2.6.24. I instrumented the
function to print out the size of the buffers allocated, booted under
qemu and would just "cat /bin/ls" to see what buffers were allocated.
2.6.33 allocates loads, including high-order allocations. 2.6.24
appeared to allocate once and keep silent.

While there have been snags recently with respect to high-order
allocation failures in recent kernels, this might be one of the cases
where it's due to subsystems requesting high-order allocations more.

Anyone familiar with tty that might make a guess as to why it allocates
more aggressively?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
