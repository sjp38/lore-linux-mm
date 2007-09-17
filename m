From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Date: Tue, 18 Sep 2007 03:12:31 +1000
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk> <200709170828.01098.nickpiggin@yahoo.com.au> <46EEB3AC.20205@redhat.com>
In-Reply-To: <46EEB3AC.20205@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709180312.31937.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Anton Altaparmakov <aia21@cam.ac.uk>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

On Tuesday 18 September 2007 03:04, Rik van Riel wrote:
> Nick Piggin wrote:
> > (Rik has a patch sitting in -mm I believe which would make this problem
> > even worse, by doing even less highmem scanning in response to lowmem
> > allocations).
>
> My patch should not make any difference here, since
> balance_pgdat() already scans the zones from high to
> low and sets an end_zone variable that determines the
> highest zone to scan.
>
> All my patch does is make sure that we do not try to
> reclaim excessive amounts of dma or low memory when
> a higher zone is full.

Sorry, yeah I had it the wrong way around. Your patch would not
increase the probability of this problem.

We could have some logic in there to scan highmem when buffer
heads are over limit. But that really kind of sucks in that it introduces
some arbitrary point where reclaim behaviour completely changes...
Adding a shrinker for buffer heads is the "logical" approach that we
take for other non-page caches. That also kind of sucks because we
normally don't want to do this out of band buffer reclaiming and just
have it work from page reclaim (it will introduce extra locking and list
scanning).

Maybe when the machine is near OOM, we can just change the scanning
to do all zones -- a change in scanning behaviour at that point is better
than oom kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
