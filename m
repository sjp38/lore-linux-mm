Date: Sat, 6 Nov 2004 16:21:33 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /
    all_unreclaimable braindamage
In-Reply-To: <20041106152903.GA3851@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0411061609520.3592-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Andrea Arcangeli wrote:
> On Sat, Nov 06, 2004 at 09:47:56AM +0000, Hugh Dickins wrote:
> > Problematic, yes: don't overlook that GFP_REPEAT and GFP_NOFAIL _can_
> > fail, returning NULL: when the process is being OOM-killed (PF_MEMDIE).
> 
> that looks weird, why that? The oom killer must be robust against a task
> not going anyway regardless of this (task can be stuck in nfs or
> similar).

Oh, sure, it is, that's not the problem.

> If a fail path ever existed, __GFP_NOFAIL should not have been
> used in the first place. I don't see many valid excuses to use
> __GFP_NOFAIL if we can return NULL without the caller running into an
> infinite loop.

I took exception to the misleadingness of the name GFP_NOFAIL, and did
send Andrew a patch to remove it once upon a time, but he didn't bite.

Your view, that it's better to hang repeating indefinitely than ever
return a NULL when caller said not to, is probably the better view.

> btw, PF_MEMDIE has always been racy in the way it's being set, so it can
> corrupt the p->flags, but the race window is very small to trigger it
> (and even if it triggers, it probably wouldn't be fatal). That's why I
> don't use PF_MEMDIE in 2.4-aa.

I expect so, yes, the PF_ flags don't have proper locking.  Those
places which set or clear PF_MEMALLOC are more likely to hit races,
but last time I went there I don't think there was a real serious problem.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
