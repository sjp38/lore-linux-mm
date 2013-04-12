Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C93FB6B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 06:19:13 -0400 (EDT)
From: Tvrtko Ursulin <tvrtko.ursulin@onelan.co.uk>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Date: Fri, 12 Apr 2013 11:18:13 +0100
Message-ID: <7098047.RSyYY1KrfL@deuteros>
In-Reply-To: <20130412025708.GB7445@thunk.org>
References: <20130402142717.GH32241@suse.de> <20130411213335.GE9379@quack.suse.cz> <20130412025708.GB7445@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>


Hi all,

On Thursday 11 April 2013 22:57:08 Theodore Ts'o wrote:
> That's an interesting theory.  If the workload is one which is very
> heavy on reads and writes, that could explain the high latency.  That
> would explain why those of us who are using primarily SSD's are seeing
> the problems, because would be reads are nice and fast.
> 
> If that is the case, one possible solution that comes to mind would be
> to mark buffer_heads that contain metadata with a flag, so that the
> flusher thread can write them back at the same priority as reads.
> 
> The only problem I can see with this hypothesis is that if this is the
> explanation for what Mel and Jiri are seeing, it's something that
> would have been around for a long time, and would affect ext3 as well
> as ext4.  That isn't quite consistent, however, with Mel's observation
> that this is a probablem which has gotten worse in relatively
> recently.

Dropping in as a casual observer and having missed the start of the thread, 
risking that I will just muddle the water for you.

I had a similar problem for quite a while with ext4, at least that was my 
conclusion since the fix was to migrate one filesystem to xfs which fixed it 
for me. Time period when I observed this was between 3.5 and 3.7 kernels.

Situation was I had an ext4 filesystem (on top of LVM, which was on top of MD 
RAID 1, which was on top of two mechanical hard drives) which was dedicated to 
holding a large SVN check-out. Other filesystems were also ext4 on different 
logical volumes (but same spindles).

Symptoms were long stalls of everything (including window management!) on a 
relatively heavily loaded desktop (which was KDE). Stalls would last anything 
from five to maybe even 30 seconds. Not sure exactly but long enough that you 
think the system has actually crashed. I couldn't even switch away to a 
different virtual terminal during the stall, nothing.

Eventually I traced it down to kdesvn (subversion client) periodically 
refreshing (or something) it's metadata and hence generating some IO on that 
dedicated filesystem. That combined with some other desktop activity had an 
effect of stalling everything else. I thought it was very weird, but I suppose 
KDE and all the rest nowadays do to much IO in everything they do.

Following a hunch I reformatted that filesystem as XFS which fixed the 
problem.

I can't reproduce this now to run any tests so I know this is not very helpful 
now. But perhaps some of the info will be useful to someone.

Tvrtko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
