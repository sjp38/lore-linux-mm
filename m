Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 33E526B01EB
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 10:12:37 -0400 (EDT)
Date: Tue, 22 Jun 2010 22:12:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: your mail
Message-ID: <20100622141228.GA12025@localhost>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
 <20100622025941.GA6147@localhost>
 <20100622135457.GD3338@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622135457.GD3338@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 09:54:58PM +0800, Jan Kara wrote:
> On Tue 22-06-10 10:59:41, Wu Fengguang wrote:
> > > - use tagging also for WB_SYNC_NONE writeback - there's problem with an
> > >   interaction with wbc->nr_to_write. If we tag all dirty pages, we can
> > >   spend too much time tagging when we write only a few pages in the end
> > >   because of nr_to_write. If we tag only say nr_to_write pages, we may
> > >   not have enough pages tagged because some pages are written out by
> > >   someone else and so we would have to restart and tagging would become
> > 
> > This could be addressed by ignoring nr_to_write for the WB_SYNC_NONE
> > writeback triggered by sync(). write_cache_pages() already ignored
> > nr_to_write for WB_SYNC_ALL.
>   We could do that but frankly, I'm not very fond of adding more special
> cases to writeback code than strictly necessary...

So do me. However for this case we only need to broaden the special case test:

                        if (nr_to_write > 0) {
                                nr_to_write--;
                                if (nr_to_write == 0 &&
-                                   wbc->sync_mode == WB_SYNC_NONE) {
+                                   !wbc->for_sync) {

> > >   essentially useless. So my option is - switch to tagging for WB_SYNC_NONE
> > >   writeback if we can get rid of nr_to_write. But that's a story for
> > >   a different patch set.
> > 
> > Besides introducing overheads, it will be a policy change in which the
> > system loses control to somehow "throttle" writeback of huge files.
>   Yes, but if we guarantee we cannot livelock on a single file, do we care?
> Memory management does not care because it's getting rid of dirty pages
> which is what it wants. User might care but actually writing out files in
> the order they were dirtied (i.e., the order user written them) is quite
> natural so it's not a "surprising" behavior. And I don't think we can
> assume that data in those small files are more valuable than data in the
> large file and thus should be written earlier...

It could be a surprising behavior when, there is a 4GB dirty file and
100 small dirty files. The user may expect the 100 small dirty files
be synced to disk after 30s. However without nr_to_write, they could
be delayed by the 4GB file for 40 more seconds. Now if something goes
wrong in between and the small dirty files happen to include some
.c/.tex/.txt/... files. 

Small files are more likely your precious documents that are typed in
word-by-word and perhaps the most important data you want to protect.
Naturally you'll want them enjoy more priority than large files.

>   With the overhead you are right that tagging is more expensive than
> checking nr_to_write limit...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
