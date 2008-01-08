Date: Tue, 8 Jan 2008 08:45:02 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
Message-ID: <20080108074502.GF22800@v2.random>
References: <504e981185254a12282d.1199326157@v2.random> <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0801071751320.13505@chino.kir.corp.google.com> <200801081425.31515.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200801081425.31515.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@cpushare.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 02:25:31PM +1100, Nick Piggin wrote:
> We already do that today in the case of regular page reclaim.

exactly. And we have to set TIF_MEMDIE on more than one task in case
we have a locking dependency like the ones I can trivially reproduce.

> The problem is the global reserve. Once you have a kernel that doesn't
> need this handwavy global reserve for forward progress, a lot of little
> problems go away.

Yep.

> It should be, but that task you OOM may be blocking on another one that
> is waiting for memory, for example.

Exactly.

> In practice, I think a task will not need a great deal of memory in order
> to finish what it is doing and exit; but it will be more likely to be in
> some oom deadlock. So neither solution is perfect, but I think this patch
> will solve more cases than it introduces.

Yes. The memory reserve being accessed by more than one TIF_MEMDIE
task is the least of the problems. Also consider the first task will
normally not even try to use the memory reserve at all, because if we
set TIF_MEMDIE on a second task, it's because the first task was
normally totally stuck on a lock and sleeping in D state the whole time.

> Why not just have a global frequency limit on OOM events. Then the panic
> has this delay factored in...

My current pathset uses 1min as max frequency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
