Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DC61D6B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 00:17:58 -0500 (EST)
Date: Sun, 16 Dec 2012 05:17:57 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216051757.GA6746@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121216024520.GH9806@dastard>
 <20121216030442.GA28172@dcvr.yhbt.net>
 <20121216033601.GJ9806@dastard>
 <20121216035953.GA30689@dcvr.yhbt.net>
 <20121216042636.GL9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216042636.GL9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dave Chinner <david@fromorbit.com> wrote:
> On Sun, Dec 16, 2012 at 03:59:53AM +0000, Eric Wong wrote:
> > I want the first read() to happen sooner than it would under current
> > fadvise. 
> 
> You're not listening.  You do not need the kernel to be modified to
> avoid the latency of issuing 1GB of readahead on a file.
> 
> You don't need to do readahead before the first read. Nor do you do
> need to wait for 1GB of readhead to be issued before you do the
> first read.
> 
> You could do readahead *concurrently* with the first read, so the
> first read only blocks until the readahead of the first part of the
> file completes.  i.e. just do readahead() in a background thread and
> don't wait for it to complete before doing the first read.

What you describe with concurrent readahead() is _exactly_ what my test
program (in other email) does with the RA environment variable set.

I know I do not _need_ fadvise + background WILLNEED support in the
kernel.

But I think the kernel can make life easier and allow us to avoid doing
background threads or writing our own (inferior) caching in userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
