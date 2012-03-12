Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id DD17C6B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 10:02:38 -0400 (EDT)
Date: Mon, 12 Mar 2012 15:02:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120312140229.GG5998@quack.suse.cz>
References: <20120302095910.GB1744@quack.suse.cz>
 <20120302103951.GA13378@localhost>
 <20120302115700.7d970497.akpm@linux-foundation.org>
 <20120303135558.GA9869@localhost>
 <1331135301.32316.29.camel@sauron.fi.intel.com>
 <20120309073113.GA5337@localhost>
 <20120309095135.GC21038@quack.suse.cz>
 <1331309451.29445.42.camel@sauron.fi.intel.com>
 <20120309211156.GA6262@quack.suse.cz>
 <1331555774.12037.9.camel@sauron.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331555774.12037.9.camel@sauron.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Adrian Hunter <adrian.hunter@intel.com>

On Mon 12-03-12 14:36:14, Artem Bityutskiy wrote:
> On Fri, 2012-03-09 at 22:11 +0100, Jan Kara wrote:
> > On Fri 09-03-12 18:10:51, Artem Bityutskiy wrote:
> > > On Fri, 2012-03-09 at 10:51 +0100, Jan Kara wrote:
> > > > > However I cannot find any ubifs functions to form the above loop, so
> > > > > ubifs should be safe for now.
> > > >   Yeah, me neither but I also failed to find a place where
> > > > ubifs_evict_inode() truncates inode space when deleting the inode... Artem?
> > > 
> > > We do call 'truncate_inode_pages()':
> > > 
> > > static void ubifs_evict_inode(struct inode *inode)
> > > {
> > > 	...
> > > 
> > >         truncate_inode_pages(&inode->i_data, 0);
> > > 
> > >         ...
> > > }
> >   Well, but that just removes pages from page cache. You should somewhere
> > also free allocated blocks and free the inode... And I'm sure you do,
> > otherwise you would pretty quickly notice that file deletion does not work
> > :) Just I could not find which function does it.
> 
> ubifs_evict_inode() -> ubifs_jnl_delete_inode() ->
> ubifs_tnc_remove_ino()
> 
> Basically, deletion in UBIFS is about writing a so-called "deletion
> inode" to the journal and then removing all the data nodes of the
> truncated inode from the TNC (in-memory cache of the FS index, which is
> just a huge B-tree, like in reiser4 which inspired me long time ago, and
> like in btrfs).
> 
> The second part of the overall deletion job will be when we commit - the
> updated version of the FS index will be written to the flash media.
  Oh, I see. This is what I was missing. And I presume you always make sure
to have enough space for new FS index so it cannot deadlock when trying to
push out dirty pages.

> If we get a power cut before the commit, the journal reply will see the
> deletion inode and will clean-up the index. The deletion inode is never
> erased before the commit.
> 
> Basically, this design is dictated by the fact that we do not have a
> cheap way of doing in-place updates.
> 
> This is a short version of the story. Here are some docs as well:
> http://www.linux-mtd.infradead.org/doc/ubifs.html#L_documentation
  I see. Thanks.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
