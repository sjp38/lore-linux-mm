Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 62A446B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 16:22:17 -0500 (EST)
Date: Thu, 1 Mar 2012 13:22:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-Id: <20120301132215.71246044.akpm@linux-foundation.org>
In-Reply-To: <20120301211551.GD13104@quack.suse.cz>
References: <20120228140022.614718843@intel.com>
	<20120228144747.198713792@intel.com>
	<20120228160403.9c9fa4dc.akpm@linux-foundation.org>
	<20120301110404.GC4385@quack.suse.cz>
	<20120301114201.d1dcacad.akpm@linux-foundation.org>
	<20120301211551.GD13104@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 1 Mar 2012 22:15:51 +0100
Jan Kara <jack@suse.cz> wrote:

> On Thu 01-03-12 11:42:01, Andrew Morton wrote:
> > On Thu, 1 Mar 2012 12:04:04 +0100
> > Jan Kara <jack@suse.cz> wrote:
> > 
> > > > iirc, the way I "grabbed" the page was to actually lock it, with
> > > > [try_]_lock_page().  And unlock it again way over within the writeback
> > > > thread.  I forget why I did it this way, rather than get_page() or
> > > > whatever.  Locking the page is a good way of preventing anyone else
> > > > from futzing with it.  It also pins the inode, which perhaps meant that
> > > > with careful management, I could avoid the igrab()/iput() horrors
> > > > discussed above.
> > >
> > >   I think using get_page() might be a good way to go.
> > 
> > get_page() doesn't pin the inode - truncate() will still detach it
> > from the address_space().
>   Yes, I know. And exactly because of that I'd like to use it. Flusher
> thread would lock the page from the work item, check whether it is still
> attached to the inode and if yes, it will proceed. Otherwise it will just
> discard the work item because we know the page has already been written out
> by someone else or truncated.

That would work OK.  The vmscanning process won't know that its
writeback effort failed, but it's hard to see how that could cause a
problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
