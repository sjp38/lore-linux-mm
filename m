Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B28D46B00E8
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 19:37:44 -0500 (EST)
Date: Tue, 6 Mar 2012 16:37:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-Id: <20120306163742.b71bf57b.akpm@linux-foundation.org>
In-Reply-To: <20120303132555.GA6312@localhost>
References: <20120228140022.614718843@intel.com>
	<20120228144747.198713792@intel.com>
	<20120228160403.9c9fa4dc.akpm@linux-foundation.org>
	<20120301110404.GC4385@quack.suse.cz>
	<20120301114151.GA19049@localhost>
	<20120301114634.957da8d2.akpm@linux-foundation.org>
	<20120303132555.GA6312@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 3 Mar 2012 21:25:55 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> > > get_page() looks the perfect solution to verify if the struct inode
> > > pointer (w/o igrab) is still live and valid.
> > > 
> > > [...upon rethinking...] Oh but still we need to lock some page to pin
> > > the inode during the writeout. Then there is the dilemma: if the page
> > > is locked, we effectively keep it from being written out...
> > 
> > No, all you need to do is to structure the code so that after the page
> > gets unlocked, the kernel thread does not touch the address_space.  So
> > the processing within the kthread is along the lines of
> > 
> > writearound(locked_page)
> > {
> > 	write some pages preceding locked_page;	/* touches address_space */
> 
> It seems the above line will lead to ABBA deadlock.
> 
> At least btrfs will lock a number of pages in lock_delalloc_pages().

Well, this code locks multiple pages too.  I forget what I did about
that - probably trylock.  Dirty pages aren't locked for very long.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
