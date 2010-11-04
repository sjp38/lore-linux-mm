Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBFB26B00C5
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 12:05:56 -0400 (EDT)
Message-ID: <E1PE2Jp-00031X-Tx@approx.mit.edu>
Subject: Re: 2.6.36 io bring the system to its knees
In-Reply-To: Your message of "Tue, 02 Nov 2010 09:12:39 EDT."
             <20101102131239.GA8680@think>
Date: Thu, 4 Nov 2010 12:05:41 -0400
From: Sanjoy Mahajan <sanjoy@olin.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter.Zijl@MIT.EDU
List-ID: <linux-mm.kvack.org>

> So this sounds like the backup is just thrashing your cache.

I think it's more than that.  Starting an rxvt shouldn't take 8 seconds,
even with a cold cache.  Actually, it does take a while, so you do have
a point.  I just did

  echo 3 > /proc/sys/vm/drop_caches

and then started rxvt.  That takes about 3 seconds (which seems long,
but I don't know wherein that slowness lies), of which maybe 0.25
seconds is loading and running 'date':

$ time rxvt -e date
real	0m2.782s
user	0m0.148s
sys	0m0.032s

The 8-second delay during the rsync must have at least two causes: (1)
the cache is wiped out, and (2) the rxvt binary cannot be paged in
quickly because the disk is doing lots of other I/O.  

Can the system someknow that paging in the rxvt binary and shared
libraries is interactive I/O, because it was started by an interactive
process, and therefore should take priority over the rsync?

> Does rsync have the option to do an fadvise DONTNEED?

I couldn't find one.  It would be good to have a solution that is
independent of the backup app.  (The 'locate' cron job does a similar
thrashing of the interactive response.)

-Sanjoy

`Until lions have their historians, tales of the hunt shall always
 glorify the hunters.'  --African Proverb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
