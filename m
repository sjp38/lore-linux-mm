Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B1F26B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 06:36:27 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when high-order watermarks are being hit (data on latencies available)
Date: Thu, 12 Nov 2009 12:36:19 +0100
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911042157.25020.elendil@planet.nl> <20091105164832.GB25926@csn.ul.ie>
In-Reply-To: <20091105164832.GB25926@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200911121236.25197.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

First of all, sorry for not replying to this sooner. And my heartfelt 
appreciation for sticking with the issue. I wish I could do more to help 
resolve it instead of just reporting the problem.
I saw your blog post today and am looking forward to your results.

On Thursday 05 November 2009, Mel Gorman wrote:
> In the interest of getting something more empirical, I sat down from
> scratch with the view to recreating your case and I believe I was
> successful. I was able to reproduce your problem after a fashion and
> generate some figures - crucially including some latency figures.

I'm not sure if you have exactly reproduced what I'm seeing, mainly because 
I would have expected a clearer difference between .30 and .31 for the 
latency figures. There's also little difference in latency between .32-rc6 
with and without 8aa7e847 reverted.
So it looks as if latency is not a significant indicator of the effects of 
8aa7e847 in your test.

But if I look at your graphs for IO and writeback, then those *do* show a 
marked difference between .30 and .31. Those graphs also show a 
significant difference between .32-rc6 with and without 8aa7e847 reverted.
So that looks promising.

> Because of other reports, the slight improvements on latency and the
> removal of a possible live-lock situation, I think patches 1-3 and the
> accounting patch posted in this thread should go ahead. Patches 1,2
> bring allocator behaviour more in line with 2.6.30 and are a proper fix.
> Patch 3 makes a lot of sense when there are a lot of high-order atomics
> going on so that kswapd notices as fast as possible that it needs to do
> other work. The accounting patch monitors what's going on with patch 3.

Hmmm. What strikes me most about the latency graphs is how much worse it 
looks for .32 with your patches 1-3 applied than without. That seems to 
contradict what you say above.

The fact that all .32 latencies are worse that with either .30 or .31 is 
probably simply the result of the changes in the scheduler. It's one 
reason why I have tested most candidate patches against both .31 and .32.

As the latencies are not extreme in an absolute sense, I would say it does 
not need to indicate a problem. It just means you cannot easily compare 
latency figures for .30 and .31 with those for .32.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
