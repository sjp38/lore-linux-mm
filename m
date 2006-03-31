Date: Fri, 31 Mar 2006 15:45:53 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-Id: <20060331154553.69f8eb1f.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Resent to correct linux-mm address)

Christoph Lameter <clameter@sgi.com> wrote:
>
> We experienced that concurrent slab shrinking on 2.6.16 can slow down a
>  system excessively due to lock contention.

How much?

Which lock(s)?

> Slab shrinking is a global
>  operation so it does not make sense for multiple slab shrink operations
>  to be ongoing at the same time.

That's how it used to be - it was a semaphore and we baled out if
down_trylock() failed.  If we're going to revert that change then I'd
prefer to just go back to doing it that way (only with a mutex).

The reason we made that change in 2.6.9:

  Use an rwsem to protect the shrinker list instead of a regular
  semaphore.  Modifications to the list are now done under the write lock,
  shrink_slab takes the read lock, and access to shrinker->nr becomes racy
  (which is no concurrent.

  Previously, having the slab scanner get preempted or scheduling while
  holding the semaphore would cause other tasks to skip putting pressure on
  the slab.

  Also, make shrink_icache_memory return -1 if it can't do anything in
  order to hold pressure on this cache and prevent useless looping in
  shrink_slab.

Note the lack of performance numbers?  How are we to judge which the
regression which your proposal introduces is outweighed by the (unmeasured)
gain it provides?

> The single shrinking task can perform the
>  shrinking for all nodes and processors in the system.

Probably.  But we _can_ sometimes do disk I/O while holding that lock, down
in the inode-releasing code, iirc.  Could get bad with a `-o sync' mounted
filesystem.

> Introduce an atomic
>  counter that works in the same was as in shrink_zone to limit concurrent
>  shrinking.

No, a simple mutex_trylock() should suffice.

>  Also calculate the time it took to do the shrinking and wait at least twice
>  that time before doing it again. If we are spending excessive time 
>  on slab shrinking then we need to pause for some time to insure that the 
>  system is capable of archiving other tasks.

No way, sorry.  I've had it with "gee let's do this, it might be better"
"optimisations" in that code.

We need a *lot* of testing results with varied workloads and varying
machine types before we can say that changes like this are of aggregate
benefit and do not introduce bad corner-case regressions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
