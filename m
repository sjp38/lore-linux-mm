Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E38F6B01E1
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 09:55:24 -0400 (EDT)
Date: Tue, 22 Jun 2010 15:54:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: your mail
Message-ID: <20100622135457.GD3338@quack.suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
 <20100622025941.GA6147@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622025941.GA6147@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue 22-06-10 10:59:41, Wu Fengguang wrote:
> > - use tagging also for WB_SYNC_NONE writeback - there's problem with an
> >   interaction with wbc->nr_to_write. If we tag all dirty pages, we can
> >   spend too much time tagging when we write only a few pages in the end
> >   because of nr_to_write. If we tag only say nr_to_write pages, we may
> >   not have enough pages tagged because some pages are written out by
> >   someone else and so we would have to restart and tagging would become
> 
> This could be addressed by ignoring nr_to_write for the WB_SYNC_NONE
> writeback triggered by sync(). write_cache_pages() already ignored
> nr_to_write for WB_SYNC_ALL.
  We could do that but frankly, I'm not very fond of adding more special
cases to writeback code than strictly necessary...

> >   essentially useless. So my option is - switch to tagging for WB_SYNC_NONE
> >   writeback if we can get rid of nr_to_write. But that's a story for
> >   a different patch set.
> 
> Besides introducing overheads, it will be a policy change in which the
> system loses control to somehow "throttle" writeback of huge files.
  Yes, but if we guarantee we cannot livelock on a single file, do we care?
Memory management does not care because it's getting rid of dirty pages
which is what it wants. User might care but actually writing out files in
the order they were dirtied (i.e., the order user written them) is quite
natural so it's not a "surprising" behavior. And I don't think we can
assume that data in those small files are more valuable than data in the
large file and thus should be written earlier...
  With the overhead you are right that tagging is more expensive than
checking nr_to_write limit...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
