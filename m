Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id F2FAC6B0092
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 02:36:14 -0500 (EST)
Date: Thu, 8 Mar 2012 23:31:13 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120309073113.GA5337@localhost>
References: <20120228144747.198713792@intel.com>
 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
 <20120301123640.GA30369@localhost>
 <20120301163837.GA13104@quack.suse.cz>
 <20120302044858.GA14802@localhost>
 <20120302095910.GB1744@quack.suse.cz>
 <20120302103951.GA13378@localhost>
 <20120302115700.7d970497.akpm@linux-foundation.org>
 <20120303135558.GA9869@localhost>
 <1331135301.32316.29.camel@sauron.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331135301.32316.29.camel@sauron.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Adrian Hunter <adrian.hunter@intel.com>

Artem,

On Wed, Mar 07, 2012 at 05:48:21PM +0200, Artem Bityutskiy wrote:
> On Sat, 2012-03-03 at 21:55 +0800, Fengguang Wu wrote:
> >   13   1125  /c/linux/fs/ubifs/file.c <<do_truncation>>   <===== deadlockable
> 
> Sorry, but could you please explain once again how the deadlock may
> happen?

Sorry I confused ubifs do_truncation() with the truncate_inode_pages()
that may be called from iput().

The once suspected deadlock scheme is when the flusher thread calls
the final iput:

        flusher thread
          iput_final
            <some ubifs function>
              ubifs_budget_space
                shrink_liability
                  writeback_inodes_sb
                    writeback_inodes_sb_nr
                      bdi_queue_work
                      wait_for_completion  => end up waiting for the flusher itself

However I cannot find any ubifs functions to form the above loop, so
ubifs should be safe for now.

> > It seems they are all safe except for ubifs. ubifs may actually
> > deadlock from the above do_truncation() caller. However it should be
> > fixable because the ubifs call for writeback_inodes_sb_nr() sounds
> > very brute force writeback and wait and there may well be better way
> > out.
> 
> I do not think this "fixable" - this is part of UBIFS design to force
> write-back when we are not sure we have enough space.
> 
> The problem is that we do not know how much space the dirty data in RAM
> will take on the flash media (after it is actually written-back) - e.g.,
> because we compress all the data (UBIFS performs on-the-flight
> compression). So we do pessimistic assumptions and allow dirtying more
> and more data as long as we know for sure that there is enough flash
> space on the media for the worst-case scenario (data are not
> compressible). This is what the UBIFS budgeting subsystem does.
> 
> Once the budgeting sub-system sees that we are not going to have enough
> flash space for the worst-case scenario, it starts forcing write-back to
> push some dirty data out to the flash media and update the budgeting
> numbers, and get more realistic picture.
> 
> So basically, before you can change _anything_ on UBIFS file-system, you
> need to budget for the space. Even when you truncate - because
> truncation is also about allocating more space for writing the updated
> inode and update the FS index. (Remember, all writes are out-of-place in
> UBIFS because we work with raw flash, not a block device).

Thanks for the detailed explanations!

Judging from the git log, ubifs starts with flushing NR_TO_WRITE=16
pages at one time commit 2acf80675800d ("UBIFS: simplify
make_free_space") and is later changed to flushing *the whole*
superblock by a writeback change ("writeback: get rid of
generic_sync_sb_inodes() export"). This could greatly increase the
wait time. I'd suggest to limit the write chunk size to about 125ms
as the below change:

--- linux.orig/fs/ubifs/budget.c	2012-03-08 23:16:01.661194026 -0800
+++ linux/fs/ubifs/budget.c	2012-03-08 23:16:02.477194003 -0800
@@ -63,7 +63,9 @@
 static void shrink_liability(struct ubifs_info *c, int nr_to_write)
 {
 	down_read(&c->vfs_sb->s_umount);
-	writeback_inodes_sb(c->vfs_sb, WB_REASON_FS_FREE_SPACE);
+	writeback_inodes_sb_nr(c->vfs_sb,
+			       c->bdi.avg_write_bandwidth / 8 + nr_to_write,
+			       WB_REASON_FS_FREE_SPACE);
 	up_read(&c->vfs_sb->s_umount);
 }
 
Here nr_to_write=16 merely serves as some minimal safeguard in case
bdi.avg_write_bandwidth drops to 0. Perhaps we can eliminate the
parameter and use the constant number directly.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
