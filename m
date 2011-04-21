Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E01498D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:41:59 -0400 (EDT)
Date: Thu, 21 Apr 2011 18:41:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110421164154.GC4476@quack.suse.cz>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
 <20110420152211.GC4991@quack.suse.cz>
 <20110421033325.GA13764@localhost>
 <20110421043940.GC22423@infradead.org>
 <20110421060556.GA24232@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421060556.GA24232@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu 21-04-11 14:05:56, Wu Fengguang wrote:
> On Thu, Apr 21, 2011 at 12:39:40PM +0800, Christoph Hellwig wrote:
> > On Thu, Apr 21, 2011 at 11:33:25AM +0800, Wu Fengguang wrote:
> > > I collected the writeback_single_inode() traces (patch attached for
> > > your reference) each for several test runs, and find much more
> > > I_DIRTY_PAGES after patchset. Dave, do you know why there are so many
> > > I_DIRTY_PAGES (or radix tag) remained after the XFS ->writepages() call,
> > > even for small files?
> > 
> > What is your defintion of a small file?  As soon as it has multiple
> > extents or holes there's absolutely no way to clean it with a single
> > writepage call.
> 
> It's writing a kernel source tree to XFS. You can find in the below
> trace that it often leaves more dirty pages behind (indicated by the
> I_DIRTY_PAGES flag) after writing as less as 1 page (indicated by the
> wrote=1 field).
  As Dave said, it's probably just a race since XFS redirties the inode on
IO completion. So I think the inodes are just small so they have only a few
dirty pages so you don't have much to write and they are written and
redirtied before you check the I_DIRTY flags. You could use radix tree
dirty tag to verify whether there are really dirty pages or not...

  BTW a quick check of kernel tree shows the following distribution of
sizes (in KB):
  Count KB  Cumulative Percent
    257 0   0.9%
  13309 4   45%
   5553 8   63%
   2997 12  73%
   1879 16  80%
   1275 20  83%
    987 24  87%
    685 28  89%
    540 32  91%
    387 36  ...
    309 40
    264 44
    249 48
    170 52
    143 56
    144 60
    132 64
    100 68
    ...
Total 30155

And the distribution of your 'wrote=xxx' roughly corresponds to this...

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
