Date: Sun, 14 Nov 2004 19:27:14 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041114182714.GF13733@dualathlon.random>
References: <20041111112922.GA15948@logos.cnet> <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org> <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <480430000.1100456191@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480430000.1100456191@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Chris Ross <chris@tebibyte.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2004 at 10:16:32AM -0800, Martin J. Bligh wrote:
> Heh, I wasn't really worried about the code size at all ... I was just 
> pointing out that 1 page was a trivial amount to be worried about, in
> terms of when we start reclaim.

Ok, my point is that the code size will be smaller and simpler without
message passing, the locking will be a lot simpler since there will be
no locking at all (all info is in the local stack, no need to send local
info to a global kswapd). Plus kswapd when fails the paging is no
different from task context failing the paging, since kswapd will be
racing against all task context, like all task context races against
each other and kswapd too.

About the 1 page trivial amount, I missed/forgot where this 1 page
trivial amount comes from. There's not at all any 1 page trivial amount
of difference between doing oom kill in kswapd based on information
passed from the page_alloc.c task-context, or doing it in the
page_alloc.c task-context directly. Obviously if it was only 1
off-by-one issue it couldn't make any difference, the watermarks are big
enough not having to care about 1 page more or less. Perhaps I wasn't
very clear in explaning why it's better to do the oom killing in
page_alloc.c (where we've the task local information to know if the
allocation is just going to fail) instead of vmscan.c.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
