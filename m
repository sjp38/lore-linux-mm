Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F39138D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 08:02:24 -0400 (EDT)
Date: Tue, 19 Apr 2011 16:02:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] writeback: moving expire targets for
 background/kupdate works
Message-ID: <20110419080220.GA7056@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419063823.GD23985@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419063823.GD23985@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 19, 2011 at 02:38:23PM +0800, Dave Chinner wrote:
> On Tue, Apr 19, 2011 at 11:00:03AM +0800, Wu Fengguang wrote:
> > 
> > Andrew,
> > 
> > This aims to reduce possible pageout() calls by making the flusher
> > concentrate a bit more on old/expired dirty inodes.
> 
> In what situation is this a problem? Can you demonstrate how you
> trigger it? And then how much improvement does this patchset make?

As Mel put it, "it makes sense to write old pages first to reduce the
chances page reclaim is initiating IO."

In last year's LSF, Rik presented the situation with a graph:

LRU head                                 [*] dirty page
[                          *              *      * *  *  * * * * * *]

Ideally, most dirty pages should lie close to the LRU tail instead of
LRU head. That requires the flusher thread to sync old/expired inodes
first (as there are obvious correlations between inode age and page
age), and to give fair opportunities to newly expired inodes rather
than sticking with some large eldest inodes (as larger inodes have
weaker correlations in the inode<=>page ages).

This patchset helps the flusher to meet both the above requirements.

The measurable improvements will depend a lot on the workload.  Mel
once did some tests and observed it to help (but as large as his
forward flush patches ;)

https://lkml.org/lkml/2010/7/28/124

> > Patches 04, 05 have been updated since last post, please review.
> > The concerns from last review have been addressed.
> > 
> > It runs fine on simple workloads over ext3/4, xfs, btrfs and NFS.
> 
> But it starts propagating new differences between background and
> kupdate style writeback. We've been trying to reduce the number of
> permutations of writeback behaviour, so it seems to me to be wrong
> to further increase the behavioural differences. Indeed, why do we
> need "for kupdate" style writeback and "background" writeback
> anymore - can' we just use background style writeback for both?

This patchset actually brings the background work semantic/behavior
closer to the kupdate work.

The two type of works have different termination rules: one is the 30s
dirty expire time, another is the background_thresh in number of dirty
pages. So they have to be treated differently when selecting the inodes
to sync.

This "if" could possibly be eliminated later, but should be done
carefully in an independent patch, preferably after this patchset is
confirmed to work reliably in upstream.

-       if (wbc->for_kupdate || wbc->for_background) {
                expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
                older_than_this = jiffies - expire_interval;
-       }

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
