Date: Sat, 9 Jun 2007 16:05:52 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the TIF_MEMDIE task to exit
Message-ID: <20070609140552.GA7130@v2.random>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random> <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com> <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 08, 2007 at 08:01:58PM -0700, Christoph Lameter wrote:
> On Sat, 9 Jun 2007, Andrea Arcangeli wrote:
> 
> > I'm sorry to inform you that the oom killing in current mainline has
> > always been a global event not a per-node one, regardless of the fixes
> > I just posted.
> 
> Wrong. The oom killling is a local event if we are in a constrained 
> allocation. The allocating task is killed not a random task. That call to 
> kill the allocating task should not set any global flags.

I just showed the global flag that is being checked. TIF_MEMDIE
affects the whole system, not just your node-constrained allocating
task. If your local constrained task fails to exit because it's
running in the nfs path that loops forever even if NULL is returned
from alloc_pages, it will deadlock the whole system if later a regular
oom happens (alloc_pages isn't guaranteed to be called by a page fault
where we know do_exit will guaranteed to be called if a sigkill is
pending). This is just an example.

Amittedly my fixes made things worse for your "local" oom killing, but
your code was only apparently "local" because TIF_MEMDIE is a _global_
flag in the mainline kernel. So again, I'm very willing to improve the
local oom killing, so that it will really become a local event for the
first time ever. Infact with my fixes applied the whole system will
stop waiting for the TIF_MEMDIE flag to go away, so it'll be much
easier to really make the global oom killing independent from the
local one. I didn't look into the details of the local oom killing yet
(exactly because it wasn't so local in the first place) but it may be
enough to set VM_is_OOM only for tasks that are not being locally
killed and then those new changes will automatically prevent
TIF_MEMDIE being set on a local-oom to affect the global-oom event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
