Date: Tue, 26 Jun 2007 22:37:43 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-ID: <20070626203743.GG7059@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random> <46814829.8090808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46814829.8090808@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2007 at 01:08:57PM -0400, Rik van Riel wrote:
> Both the normal kernel and your kernel fall over once memory
> pressure gets big enough, but they explode differently and
> at different points.

Ok, at some point it's normal they start trashing. What is strange is
that it seems patch 01 requires the VM to do more work and in turn
more memory to be free. The only explanation I could have is that the
race has the side effect of in average reducing the amount of vm
activity for each task instead of increasing it (this in turn reduces
thrashing and free memory level requirements before the workload
halts).

Even if it may have a positive effect in practice, I still think the
current racy behavior (randomly overstimating and randomly
understimating the amount of work each task has to do depending of who
adds and read the zone values first) isn't good.

Perhaps if you change the DEF_PRIORITY you'll get closer to the
current mainline but without any race. You can try to halve it and see
what happens. If the initial passes fails, it'll start swapping and
performance will go down quick. So perhaps once we fix the race we've
to decrease DEF_PRIORITY to get the same vm-tune.

It'd also be interesting to see what we get between 3000 and 4000.

Where exactly we get to the halting point (4300 vs 5105) isn't
crucial, otherwise one can win by simply decreasing min_free_kbytes as
well, which clearly shows "when" we hang isn't the real interest. OTOH
I agree the difference between 4300 and 5105 seems way too big but if
this was between 5000 and 5105 I wouldn't worry too much (5000 instead
of 5105 would result in more memory to be free at the oom point which
isn't a net-negative). Hope the benchmark is repeatable.  This week
I've been working on another project but I'll shortly try to install
AIM and reproduce and see what happens by decreasing
DEF_PRIORITY. Thanks for the testing!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
