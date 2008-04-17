Date: Thu, 17 Apr 2008 09:19:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080417091930.cbac6286.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080416113642.8ffd5684.akpm@linux-foundation.org>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080416200036.2ea9b5c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20080416113642.8ffd5684.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, npiggin@suse.de, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008 11:36:42 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > To set a page as Uptodate, all buffers must be uptodate.
> > 
> > But *all* buffers to this page is not necessary to be uptodate, here. 
> > Then, the page can be not-up-to-date after commit-write.
> > 
> > At page offlining, all buffers on the page seems to be marked as Uptodate
> > (by printk) but the page itself isn't. This seems strange.
> > 
> > But I don't found who set Uptodate to the buffers. 
> > And why page isn't up-to-date while all buffers are marked as up-to-date.
> 
> That would imply that someone brought a buffer uptodate and didn't mark the
> page uptodate.  That can happen if a read reads the buffer from disk or
> memsets all of it.  Or if a write memsets all of it, or does
> copy_from_user() into all of it.
> 
ok, I'll pay attention to codes for read.

> > still chasing.
> 
> umm..
> 
> If you had some code which does
> 
> 	pread(fd, buf, 1, 0);
> 	pread(fd, buf, 1, 4096);
> 	pread(fd, buf, 1, 8192);
> 	pread(fd, buf, 1, 12288);
> 
> then I'd expect that each read would read a single buffer so we end up with
> four uptodate buffers, but nobody brings the entire page uptodate.
> 
> readahead will hide this most of the time by reading entire pages, but if
> for some reason readahead has collapsed the window to zero then it could
> happen.
> 
> I'd expect that you could reproduce this by disabling readahead with
> fadvise(POSIX_FADV_RANDOM) and then issuing the above four reads.
> 
Thank you for advice. I'll try.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
