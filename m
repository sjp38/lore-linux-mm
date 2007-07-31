Date: Tue, 31 Jul 2007 16:49:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: make swappiness safer to use
Message-Id: <20070731164938.aad531b5.akpm@linux-foundation.org>
In-Reply-To: <46AFC676.4030907@mbligh.org>
References: <20070731215228.GU6910@v2.random>
	<20070731160943.30e9c13a.akpm@linux-foundation.org>
	<46AFC676.4030907@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 16:32:06 -0700
Martin Bligh <mbligh@mbligh.org> wrote:

> > Anyway, we can say more if we see the patch (or, more accurately, the
> > analysis which comes with that patch).
> 
> I must say, I don't see what's wrong with killing it and having it
> local. We're rotating the list all the time, IIRC ... so if we start
> off with only 1/2^12th of the list ... does it matter? we'll just
> crank it up higher fairly quickly. Not sure why we want to start
> with the same chunk size we did last time.

This scenario:

- a thread goes into shrink_active_list(), does scan, scan, scan, finding
  only mapped pages.

- eventually, we reach a sufficiently high priority to flip into
  reclaim-mapped mode.

- now, we quickly move SWAP_CLUSTER_MAX pages onto the inactive list, and
  we're done.

So we scanned a few thousand pages, then moved 32-odd down to the inactive
list.

Now, someone else comes in and does some reclaim.  It would be bad to scan
another few thousand pages and to then move 32-odd pages down to the
inactive list.  Think what that pattern looks like: lumps of 32-pages with a
few thousand pages between them getting deactivated.

To fix this, we attempt to start scanning out in the state which it was
originally in: ie, the state which this caller to shrink_active_list()
would have discovered for himself _anyway_.  After enough pages have been
pointlessly recirculated.


Can the current implemetnation make mistakes?  Sure.  But I'd suggest that
it will make far less than (thousands/32) mistakes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
