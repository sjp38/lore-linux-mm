Date: Sat, 19 Mar 2005 22:58:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Patch] cpusets policy kill no swap
Message-Id: <20050319225855.475e4167.akpm@osdl.org>
In-Reply-To: <20050320014847.16310.53697.sendpatchset@sam.engr.sgi.com>
References: <20050320014847.16310.53697.sendpatchset@sam.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: mort@sgi.com, linux-mm@kvack.org, emery@sgi.com, bron@sgi.com, Simon.Derr@bull.net, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> wrote:
>
> This mechanisms differs from a general purpose out-of-memory
>  killer in various ways, including:
> 
>   * An oom-killer tries to score the bad buy, to avoid shooting
>     the innocent little task that just happened to ask for one
>     page too many.
>   * The policy_kill_no_swap hook kills the current requester.
>   * It takes severe memory pressure to wake up an oom-killer.
>   * The policy_kill_no_swap hook triggers on the slightest
>     pressure that exceeds readily free memory.
>   * The oom-killer can be useful on a general purpose system.
>   * The policy_kill_no_swap hook is only useful for carefully
>     tuned apps running on dedicated nodes on large systems.
> 

There are a lot of reasons why we would wake kswapd apart from starting
swapout.  Such as to reclaim clean pagecache or some dcache+icache.

>  In short - simple enough, but quite specialized.

Way too specialised, I suspect.  Is it not possible to have a little
userspace daemon which monitors the long-running applications's rss and
whacks it if the rss gets too large?

The patch you have simply kills the process when all the eligible zones
reach their upper watermark.  Again, we can probably determine that state
from userspace right now.  If not, it would be simple enough to add the
required info to /proc somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
