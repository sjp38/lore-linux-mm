Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8FD7F6B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 16:15:15 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Thu, 15 Oct 2009 22:15:09 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910142034.58826.elendil@planet.nl> <20091014235636.GF5027@csn.ul.ie>
In-Reply-To: <20091014235636.GF5027@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910152215.13011.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 15 October 2009, Mel Gorman wrote:
> After a lot more eyeballing, the best next candidate within mm is the
> following patch. Should be tested on it's own and in combination with
> the wakeup-kswapd patch sent before.
>
> From 4e8b5217f51a00caee527e4e8d8e46fe9f82b482 Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mel@csn.ul.ie>
> Date: Thu, 15 Oct 2009 00:17:05 +0100
> Subject: [PATCH] page allocator: Direct reclaim should always obey
> watermarks
>
> ALLOC_NO_WATERMARKS should be cleared when trying to allocate from the
> free-lists after a direct reclaim.

I've tested the two patches together and this seems like a definite
improvement. I still get SKB errors on the first test, but the desktop
freezes are a lot shorter and the total time needed to load the 3rd gitk
goes down from ~2:15 to ~1:15. The counter in gitk of the number of
loaded commits goes up visibly faster and with fewer halts.

This is on top of current mainline with the RX_LOW_WATERMARK in iwlagn
at it's current value (8).

Here are the allocation failures for 2 consecutive tests. Note that the
first test still shows quite a lot of failures, but the second test hardly
had any at all (I still had music skips though).

[  232.845116] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  232.845116] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  232.873009] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  232.884545] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  240.121577] __ratelimit: 26 callbacks suppressed
[  240.121634] __ratelimit: 6 callbacks suppressed
[  240.124006] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 6 free buffers remaining.
[  304.335767] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  304.335767] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  304.374729] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.
[  309.446481] __ratelimit: 5 callbacks suppressed
[  309.450197] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 free buffers remaining.

[  525.912934] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 5 free buffers remaining.
[  525.953939] iwlagn 0000:10:00.0: Failed to allocate SKB buffer with GFP_ATOMIC. Only 7 free buffers remaining.
[  536.058171] __ratelimit: 1 callbacks suppressed

Thanks,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
