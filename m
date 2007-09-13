Date: Wed, 12 Sep 2007 18:16:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16 of 24] avoid some lock operation in vm fast path
Message-Id: <20070912181636.8e807295.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0709121746240.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random>
	<b343d1056f356d60de86.1187786943@v2.random>
	<20070912055952.bd5c99d6.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0709121746240.4489@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 17:49:23 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 12 Sep 2007, Andrew Morton wrote:
> 
> > OK, but we'd normally do this via some little wrapper functions which are
> > empty-if-not-numa.
> 
> The only leftover function on reclaim_in_progress is to insure that 
> zone_reclaim() does not run concurrently. Maybe that can be accomplished 
> in a different way?

We could replace all_unreclaimable with `unsigned long flags' and do bitops
on it.

> On the other hand: Maybe we would like to limit concurrent reclaim even 
> for direct reclaim. We have some livelock issues because of zone lock 
> contention on large boxes that may perhaps improve if we would simply let 
> one processor do its freeing job.

There might be problems if the task which has the lock is using GFP_NOIO
and the one which failed to get the lock could have used GFP_KERNEL.


We should be able to directly decrease lock contention in there by chewing
on larger hunks: make scan_control.swap_cluster_max larger.  Did anyone try
that?

I guess we should stop calling that thing swap_cluster_max, really. 
swap_cluster_max is amount-of-stuff-to-write-to-swap for IO clustering. 
That's unrelated to amount-of-stuff-to-batch-in-page-reclaim for lock
contention reduction.  My fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
