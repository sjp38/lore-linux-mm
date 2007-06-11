Date: Mon, 11 Jun 2007 20:58:44 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the TIF_MEMDIE task to exit
Message-ID: <20070611185844.GO7443@v2.random>
References: <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com> <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random> <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com> <20070611165032.GJ7443@v2.random> <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com> <20070611175130.GL7443@v2.random> <Pine.LNX.4.64.0706111055140.17264@schroedinger.engr.sgi.com> <20070611182232.GN7443@v2.random> <Pine.LNX.4.64.0706111133020.18327@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111133020.18327@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2007 at 11:39:03AM -0700, Christoph Lameter wrote:
> These are big systems and it would take some time to reproduce these 

Sure I understand.

> issues. Thanks for your work. I'd really like to see improvements there. 

I appreciate and hope it already helps for your oom troubles too.

> If you take care of not worsening the local kill path then I am okay with 
> the rest.

The slight regression I introduced for the numa local oom path clearly
needed correction. Let me know if you still see problems after the
incremental patch I posted today of course. I think that should be
enough to correct the local-oom without altering the global-oom. I
tested it on non-numa and it still works fine.

> out_of_memory takes about 5-10 minutes each (according to one report). An 

Even 10 minutes is way beyond what I expected (but with the background
trashing of the mainline kernel, I can imagine it happening).

> OOM storm will then take the machine out for 4 hours. The on site SE can 
> likely tell you more details in the bugzilla.

Ok, then I think you really want to try my patchset for the oom storm
since at least that one should be gone. When the first oom starts, the
whole VM will stop, no other oom_kill will be called, and even if
they're on their way to call a spurious out_of_memory, the semaphore
trylock will put them back in S state immediately inside
try_to_free_pages. Especially in systems like yours where trashing
cachelines is practically forbidden, I suspect this could make a
substantial difference and perhaps then out_of_memory will return in
less than 10 minutes by the fact of practically running single
threaded.

> Another reporter had been waiting for 2 hours after an oom without any 
> messages indicating that a single OOM was processed.

This is the case I'm dealing with more commonly, normally the more
swap more more it takes, and that's expectable. It should have
improved too with the patchset.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
