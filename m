Date: Fri, 18 Jun 2004 15:03:37 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-Id: <20040618150337.2b3db85b.akpm@osdl.org>
In-Reply-To: <40D358C5.9060003@colorfullife.com>
References: <40D08225.6060900@colorfullife.com>
	<20040616180208.GD6069@sgi.com>
	<40D09872.4090107@colorfullife.com>
	<20040617131031.GB8473@sgi.com>
	<20040617214035.01e38285.akpm@osdl.org>
	<20040618143332.GA11056@sgi.com>
	<20040618134045.2b7ce5c5.akpm@osdl.org>
	<40D358C5.9060003@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: sivanich@sgi.com, linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Manfred Spraul <manfred@colorfullife.com> wrote:
>
> I'll write something:
> - allow to disable the DMA kmalloc caches for archs that do not need them.
> - increase the timer frequency and scan only a few caches in each timer.
> - perhaps a quicker test for cache_reap to notice that nothing needs to 
> be done. Right now four tests are done (!flags & _NO_REAP, 
> ac->touched==0, ac->avail != 0, global timer not yet expired). It's 
> possible to skip some tests. e.g. move the _NO_REAP caches on a separate 
> list, replace the time_after(.next_reap,jiffies) with a separate timer.

Come to think of it, replacing the timer with schedule_delayed_work() and
doing it all via keventd should work OK.  Doing everything in a single pass
is the most CPU-efficient way of doing it, and as long as we're preemptible
and interruptible the latency issues will be solved.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
