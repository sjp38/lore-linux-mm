Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C63116B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 10:36:44 -0500 (EST)
Message-ID: <4CEBDF44.9060101@draigBrady.com>
Date: Tue, 23 Nov 2010 15:35:32 +0000
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] fadvise support in rsync
References: <20101122103756.E236.A69D9226@jp.fujitsu.com> <1290523792-6170-1-git-send-email-bgamari.foss@gmail.com>
In-Reply-To: <1290523792-6170-1-git-send-email-bgamari.foss@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, rsync@lists.samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On 23/11/10 14:49, Ben Gamari wrote:
> Warning for kernel folks: I'm not much of an mm person; let me know if I got
> anything horribly wrong.
> 
> Many folks use rsync in their nightly backup jobs. In these applications, speed
> is of minimal concern and should be sacrificed in order to minimize the effect
> of rsync on the rest of the machine. When rsync is working on a large directory
> it can quickly fill the page cache with written data, displacing the rest of
> the system's working set. The solution for this is to inform the kernel that
> our written pages will no longer be needed and should be expelled to disk. The
> POSIX interface for this, posix_fadvise, has existed for some time, but there
> has been no useable implementation in any of the major operating systems.
> 
> Attempts have been made in the past[1] to use the fadvise interface, but kernel
> limitations have made this quite messy. In particular, the kernel supports
> FADV_DONTNEED as a single-shot hint; i.e. if the page is clean when the hint is
> given it will be freed, otherwise the hint is ignored. For this reason it is
> necessary to fdatasync() against dirtied pages before giving the hint. This,
> however, requires that rsync do some accounting, calling fdatasync() and
> fadvise() only after giving the kernel an opportunity to flush the data itself.
> 
> Moreover, fadvise(DONTNEED) frees pages regardless of whether the hinting
> process is the only referrer. For this reason, the previous fadvise patch also
> used mincore to identify which pages are needed by other processes. Altogether,
> this makes using fadvise very expensive from a complexity standpoint. This is
> very unfortunately since the interface could be quite usable with a few minor
> changes.

Thanks for the easy to understand summary,
and for working through a solution.

> I recently asked about this on the LKML[2], where Minchan Kim was nice enough
> to put together a patch improving support for the FADV_DONTNEED hint. His patch
> adds invalidated flagged pages to the inactive list. This obviates the need for
> fdatasync() since the page will be reclaimed by the kernel in the standard
> inactive reclaim path. Moreover, by adding hinted pages to the head of the
> inactive list, other processes are given ample time to call the pages back to
> the active list, eliminating the need for the previous mincore() hack.
> 
> Here is my attempt at adding fadvise support to rsync (against v3.0.7). I do
> this in both the sender (hinting after match_sums()) and the receiver (hinting
> after receive_data()).

So for the moment you still thrash the cache when
backing up large files. Fair enough.

> In principle we could get better granularity if this was
> hooked up within match_sums() (or even the map_ptr() interface) and the receive
> loop in receive_data(), but I wanted to keep things simple at first (any
> comments on these ideas?) .

I implemented finer grained fadvise(DONTNEED) in dvd-vr1
and noted that I had to be careful not to invalidate
read ahead data from the cache. I.E. I had to specify
the specific range I had processed.

> At the moment is for little more than testing.
> Considering the potential negative effects of using FADV_DONTNEED on older
> kernels, it is likely we will want this functionality off by default with a
> command line flag to enable.

The downside being, files opened by other apps may be dropped?
Well if you're thrashing the cache anyway I'd just enable by
default and get the good behavior on new kernels.

cheers,
Padraig.

[1] http://www.pixelbeat.org/programs/dvd-vr/dvd-vr-0.9.7.tar.gz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
