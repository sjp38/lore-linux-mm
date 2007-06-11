Date: Mon, 11 Jun 2007 09:07:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070609143852.GB7130@v2.random>
Message-ID: <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random>
 <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
 <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
 <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jun 2007, Andrea Arcangeli wrote:

> On a side note about the current way you select the task to kill if a
> constrained alloc failure triggers, I think it would have been better
> if you simply extended the oom-selector by filtering tasks in function
> of the current->mems_allowed. Now I agree the current badness is quite

Filtering tasks is a very expensive operation on huge systems. We have had 
cases where it took an hour or so for the OOM to complete. OOM usually 
occurs under heavy processing loads which makes the taking of global locks 
quite expensive.

> bad, now with rss instead of the virtual space, it works a bit better
> at least, but the whole point is that if you integrate the cpuset task
> filtering in the oom-selector algorithm, then once we fix the badness
> algorithm to actually do something more meaningful than to check
> static values, you'll get the better algorithm working for your
> local-oom killing too. This if you really care about the huge-numa
> niche to get node-partitioning working really like if this was a
> virtualized environment. If you just have kill something to release
> memory, killing the current task is always the safest choice
> obviously, so as your customers are ok with it I'm certainly fine with
> the current approach too.

The "kill-the-current-process" approach is most effective in hitting the 
process that is allocating the most. And as far as I can tell its easiest 
to understand for our customer.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
