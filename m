Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 663026B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 21:45:44 -0500 (EST)
Date: Sun, 16 Dec 2012 13:45:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216024520.GH9806@dastard>
References: <20121215005448.GA7698@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121215005448.GA7698@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 15, 2012 at 12:54:48AM +0000, Eric Wong wrote:
> Applications streaming large files may want to reduce disk spinups and
> I/O latency by performing large amounts of readahead up front.
> Applications also tend to read files soon after opening them, so waiting
> on a slow fadvise may cause unpleasant latency when the application
> starts reading the file.
> 
> As a userspace hacker, I'm sometimes tempted to create a background
> thread in my app to run readahead().  However, I believe doing this
> in the kernel will make life easier for other userspace hackers.
> 
> Since fadvise makes no guarantees about when (or even if) readahead
> is performed, this change should not hurt existing applications.
> 
> "strace -T" timing on an uncached, one gigabyte file:
> 
>  Before: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <2.484832>
>   After: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <0.000061>

You've basically asked fadvise() to readahead the entire file if it
can. That means it is likely to issue enough readahead to fill the
IO queue, and that's where all the latency is coming from. If all
you are trying to do is reduce the latency of the first read, then
only readahead the initial range that you are going to need to read...

Also, Pushing readahead off to a workqueue potentially allows
someone to DOS the system because readahead won't ever get throttled
in the syscall context...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
