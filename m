Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1F32D6B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 07:43:51 -0400 (EDT)
Date: Wed, 29 Jul 2009 19:43:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090729114322.GA9335@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com> <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 12:15:48AM -0700, Martin Bligh wrote:
> On Tue, Jul 28, 2009 at 2:49 PM, Martin Bligh<mbligh@google.com> wrote:
> >> An interesting recent-ish change is "writeback: speed up writeback of
> >> big dirty files." A When I revert the change to __sync_single_inode the
> >> problem appears to go away and background writeout proceeds at disk
> >> speed. A Interestingly, that code is in the git commit [2], but not in
> >> the post to LKML. [3] A This is may not be the fix, but it makes this
> >> test behave better.
> >
> > I'm fairly sure this is not fixing the root cause - but putting it at the head
> > rather than the tail of the queue causes the error not to starve wb_kupdate
> > for nearly so long - as long as we keep the queue full, the bug is hidden.
> 
> OK, it seems this is the root cause - I wasn't clear why all the pages weren't
> being written back, and thought there was another bug. What happens is
> we go into write_cache_pages, and stuff the disk queue with as much as
> we can put into it, and then inevitably hit the congestion limit.
> 
> Then we back out to __sync_single_inode, who says "huh, you didn't manage
> to write your whole slice", and penalizes the poor blameless inode in question
> by putting it back into the penalty box for 30s.
> 
> This results in very lumpy I/O writeback at 5s intervals, and very
> poor throughput.

You are right, so let's fix the congestion case. Your analysis would
be perfect changelog :)

> Patch below is inline and probably text munged, but is for RFC only.
> I'll test it
> more thoroughly tomorrow. As for the comment about starving other writes,
> I believe requeue_io moves it from s_io to s_more_io which should at least
> allow some progress of other files.
> 
> --- linux-2.6.30/fs/fs-writeback.c.old  2009-07-29 00:08:29.000000000 -0700
> +++ linux-2.6.30/fs/fs-writeback.c      2009-07-29 00:11:28.000000000 -0700
> @@ -322,46 +322,11 @@ __sync_single_inode(struct inode *inode,
>                         /*
>                          * We didn't write back all the pages.  nfs_writepages()
>                          * sometimes bales out without doing anything. Redirty
[snip]
> -                               if (wbc->nr_to_write <= 0) {
> -                                       /*
> -                                        * slice used up: queue for next turn
> -                                        */
> -                                       requeue_io(inode);
> -                               } else {
> -                                       /*
> -                                        * somehow blocked: retry later
> -                                        */
> -                                       redirty_tail(inode);

Removing this line can be dangerous - we'll probably go into buzy
waiting (I have tried that long long ago).

Chad, can you try this small patch? Thank you.

Thanks,
Fengguang
---
 fs/fs-writeback.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- mm.orig/fs/fs-writeback.c
+++ mm/fs/fs-writeback.c
@@ -325,7 +325,8 @@ __sync_single_inode(struct inode *inode,
 				 * soon as the queue becomes uncongested.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-				if (wbc->nr_to_write <= 0) {
+				if (wbc->nr_to_write <= 0 ||
+				    wbc->encountered_congestion) {
 					/*
 					 * slice used up: queue for next turn
 					 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
