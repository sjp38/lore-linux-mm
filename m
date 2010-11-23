Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B528F6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:50:14 -0500 (EST)
Received: by qyk10 with SMTP id 10so1621267qyk.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:50:13 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: [RFC PATCH] fadvise support in rsync
Date: Tue, 23 Nov 2010 09:49:49 -0500
Message-Id: <1290523792-6170-1-git-send-email-bgamari.foss@gmail.com>
In-Reply-To: <20101122103756.E236.A69D9226@jp.fujitsu.com>
References: <20101122103756.E236.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, rsync@lists.samba.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>


Warning for kernel folks: I'm not much of an mm person; let me know if I got
anything horribly wrong.

Many folks use rsync in their nightly backup jobs. In these applications, speed
is of minimal concern and should be sacrificed in order to minimize the effect
of rsync on the rest of the machine. When rsync is working on a large directory
it can quickly fill the page cache with written data, displacing the rest of
the system's working set. The solution for this is to inform the kernel that
our written pages will no longer be needed and should be expelled to disk. The
POSIX interface for this, posix_fadvise, has existed for some time, but there
has been no useable implementation in any of the major operating systems.

Attempts have been made in the past[1] to use the fadvise interface, but kernel
limitations have made this quite messy. In particular, the kernel supports
FADV_DONTNEED as a single-shot hint; i.e. if the page is clean when the hint is
given it will be freed, otherwise the hint is ignored. For this reason it is
necessary to fdatasync() against dirtied pages before giving the hint. This,
however, requires that rsync do some accounting, calling fdatasync() and
fadvise() only after giving the kernel an opportunity to flush the data itself.

Moreover, fadvise(DONTNEED) frees pages regardless of whether the hinting
process is the only referrer. For this reason, the previous fadvise patch also
used mincore to identify which pages are needed by other processes. Altogether,
this makes using fadvise very expensive from a complexity standpoint. This is
very unfortunately since the interface could be quite usable with a few minor
changes.

I recently asked about this on the LKML[2], where Minchan Kim was nice enough
to put together a patch improving support for the FADV_DONTNEED hint. His patch
adds invalidated flagged pages to the inactive list. This obviates the need for
fdatasync() since the page will be reclaimed by the kernel in the standard
inactive reclaim path. Moreover, by adding hinted pages to the head of the
inactive list, other processes are given ample time to call the pages back to
the active list, eliminating the need for the previous mincore() hack.

Here is my attempt at adding fadvise support to rsync (against v3.0.7). I do
this in both the sender (hinting after match_sums()) and the receiver (hinting
after receive_data()). In principle we could get better granularity if this was
hooked up within match_sums() (or even the map_ptr() interface) and the receive
loop in receive_data(), but I wanted to keep things simple at first (any
comments on these ideas?) . At the moment is for little more than testing.
Considering the potential negative effects of using FADV_DONTNEED on older
kernels, it is likely we will want this functionality off by default with a
command line flag to enable.

Cheers,

- Ben


[1] http://insights.oetiker.ch/linux/fadvise.html
[2] http://lkml.org/lkml/2010/11/21/59

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
