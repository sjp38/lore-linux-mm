Date: Tue, 26 Jul 2005 14:21:24 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Memory pressure handling with iSCSI
Message-Id: <20050726142124.44aa0176.akpm@osdl.org>
In-Reply-To: <1122410256.6433.43.camel@dyn9047017102.beaverton.ibm.com>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	<20050726111110.6b9db241.akpm@osdl.org>
	<1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	<20050726193138.GA32324@kevlar.burdell.org>
	<1122410256.6433.43.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: sonny@burdell.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> > You probably covered this, but just to make sure, if you're on a
> > pentium4 machine, I usually boot w/ "idle=poll" to see proper idle
> > reporting because otherwise the chip will throttle itself back and
> > idle time will be skewed -- at least on oprofile.
> > 
> 
> My machine is AMD64.

I'd expect the problem to which Sonny refers will occur on many
architectures.

IIRC, the problem is that many (or all) of the counters which oprofile uses
are turned off when the CPU does a halt.  So the profiler ends up thinking
that zero time is spent in the idle handler.  The net effect is that if
your workload spends 90% of its time idle then all the other profiler hits
are exaggerated by a factor of ten.  Making the CPU busywait in idle()
fixes this.

But you're using the old /proc/profile profiler which uses a free-running
timer which doesn't get stopped by halt, so it is unaffected by this.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
