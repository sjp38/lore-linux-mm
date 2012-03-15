Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 147696B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 13:41:34 -0400 (EDT)
Date: Thu, 15 Mar 2012 18:41:28 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
Message-ID: <20120315174128.GS6329@redhat.com>
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
 <20120315171627.GB22255@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120315171627.GB22255@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>

On Thu, Mar 15, 2012 at 01:16:28PM -0400, Dave Jones wrote:
> On Thu, Mar 15, 2012 at 03:44:31PM +0100, Andrea Arcangeli wrote:
> 
>  > At some point prior to the panic, a "bad pmd ..." message similar to the
>  > following is logged on the console:
>  > 
>  >   mm/memory.c:145: bad pmd ffff8800376e1f98(80000000314000e7).
> 
> Hmm, I wonder if this could explain some of the many bad page state bug
> reports we've seen in Fedora recently.  (See my recent mail to linux-mm)

Yes.

https://bugzilla.redhat.com/show_bug.cgi?id=747738
https://bugzilla.redhat.com/show_bug.cgi?id=766676

as found by Ulrich.

>  > Reported-by: Ulrich Obergfell <uobergfe@redhat.com>
>  > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Should probably go to stable too ? How far back does this bug go ?

This goes back to 2.6.38 (included). After it gets a bit more of
testing and reviews it'll be ok for stable yes.

The fact MADV_DONTNEED zaps ptes with the mmap_sem in read mode
frankly escaped me. Then there was some other hiccup in readonly walks
that only hold the mmap_sem in read mode.

memcg walk_page_range especially should be careful because whenever
somebody does walk_page_range with the mmap_sem in read mode, the
result is undefined, so those walks should be ok with the fact they're
not accurate, if they need accuracy and full synchrony with the VM
status they must take the mmap_sem in write mode before doing the
walk_page_range (but that's not related to this race condition, it's
just something I noticed and I wasn't sure if it was safe so I'm
mentioning it here).

For those paths walking pagetables with the mmap_sem hold for reading,
MADV_DONTNEED can run simultaneously with other regular page faults,
with transhuge page faults, with get_user_pages_fast secondary MMU
faults all together.

A pmd that is none can become regular, huge under the code that
process it. A pmd that is huge can become none (because of
MADV_DONTNEED). So to fix this it's enough to proceed doing the leaf
level pte walk after checking the pmd is not none, and not huge in an
atomic way. In short the crux of the fix is to add a barrier() and
cache the pmd value in between the two checks so that we know a pmd is
really stable and we can do the leaf pte level walk safely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
