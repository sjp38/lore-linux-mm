Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 63D136B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 14:07:56 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p97I7iqW014935
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 11:07:45 -0700
Received: from qadb15 (qadb15.prod.google.com [10.224.32.79])
	by wpaz33.hot.corp.google.com with ESMTP id p97I50vY026801
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 11:07:44 -0700
Received: by qadb15 with SMTP id b15so6776476qad.5
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 11:07:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111007152801.GA18460@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
	<20110928150242.GB16159@infradead.org>
	<20111007152801.GA18460@localhost>
Date: Fri, 7 Oct 2011 11:07:41 -0700
Message-ID: <CAO81RMbKAnTp1AtNGfFDv_ZoKFvD8xhuPcwcC3Q9pVjykWcRMQ@mail.gmail.com>
Subject: Re: [PATCH 1/2 v2] writeback: Add a 'reason' to wb_writeback_work
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Fengguang:

On Fri, Oct 7, 2011 at 8:28 AM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
>
> On Wed, Sep 28, 2011 at 11:02:42PM +0800, Christoph Hellwig wrote:
> > Did we get to any conclusion on this series? =A0I think having these
> > additional reasons in the tracepoints and the additional statistics
> > would be extremely useful for us who have to deal with writeback
> > issues frequently.
>
> I think we've reached reasonable agreements on the first patch, which
> has been split into two ones by Curt:
>
> 1/2 writeback: send work item to queue_io, move_expired_inodes
> 2/2 writeback: Add a 'reason' to wb_writeback_work
>
> I further incorporated some suggested changes by Jan and get the below
> updated patch 2/2, with changes
>
> - replace the tracing symbol array with wb_reason_name[]
> - remove the balance_dirty_pages reason (no longer exists)
> - rename @stat to @reason in the function declarations
> - rename "FS_free_space" to "fs_free_space"
>
> If no objections, I can push the two patches to linux-next tomorrow.

No objections on my part.  Thanks for wrapping this up!
Curt

>
> Thanks,
> Fengguang
> ---
> Subject: writeback: Add a 'reason' to wb_writeback_work
> Date: Fri Oct 07 21:54:10 CST 2011
>
> From: Curt Wohlgemuth <curtw@google.com>
>
> This creates a new 'reason' field in a wb_writeback_work
> structure, which unambiguously identifies who initiates
> writeback activity. =A0A 'wb_reason' enumeration has been
> added to writeback.h, to enumerate the possible reasons.
>
> The 'writeback_work_class' and tracepoint event class and
> 'writeback_queue_io' tracepoints are updated to include the
> symbolic 'reason' in all trace events.
>
> And the 'writeback_inodes_sbXXX' family of routines has had
> a wb_stats parameter added to them, so callers can specify
> why writeback is being started.
>
> Acked-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Curt Wohlgemuth <curtw@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>
> Changes since v2:
>
> =A0 - enum wb_stats renamed enum wb_reason
> =A0 - All WB_STAT_xxx enum constants now named WB_REASON_xxx
> =A0 - All 'reason' strings in tracepoints match the WB_REASON name
> =A0 - The change to send 'work' to queue_io, move_expired_inodes, and
> =A0 =A0 trace_writeback_queue_io are in a separate commit
>
> =A0fs/btrfs/extent-tree.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
> =A0fs/buffer.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 -
> =A0fs/ext4/inode.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 -
> =A0fs/fs-writeback.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 49 ++++++++++++=
+++++++++--------
> =A0fs/quota/quota.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 -
> =A0fs/sync.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0fs/ubifs/budget.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 -
> =A0include/linux/backing-dev.h =A0 =A0 =A0| =A0 =A03 +
> =A0include/linux/writeback.h =A0 =A0 =A0 =A0| =A0 32 +++++++++++++++---
> =A0include/trace/events/writeback.h | =A0 14 +++++---
> =A0mm/backing-dev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
> =A0mm/page-writeback.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +
> =A013 files changed, 88 insertions(+), 34 deletions(-)
>
> --- linux-next.orig/fs/btrfs/extent-tree.c =A0 =A0 =A02011-10-07 22:23:35=
.000000000 +0800
> +++ linux-next/fs/btrfs/extent-tree.c =A0 2011-10-07 22:24:47.000000000 +=
0800
> @@ -3340,7 +3340,8 @@ static int shrink_delalloc(struct btrfs_
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0smp_mb();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_pages =3D min_t(unsigned long, nr_pages=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root->fs_info->delalloc_bytes=
 >> PAGE_CACHE_SHIFT);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb_nr_if_idle(root->fs_inf=
o->sb, nr_pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb_nr_if_idle(root->fs_inf=
o->sb, nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 WB_REASON_FS_FREE_SPACE);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&space_info->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (reserved > space_info->bytes_reserved)
> --- linux-next.orig/fs/buffer.c 2011-10-07 22:23:35.000000000 +0800
> +++ linux-next/fs/buffer.c =A0 =A0 =A02011-10-07 22:24:47.000000000 +0800
> @@ -285,7 +285,7 @@ static void free_more_memory(void)
> =A0 =A0 =A0 =A0struct zone *zone;
> =A0 =A0 =A0 =A0int nid;
>
> - =A0 =A0 =A0 wakeup_flusher_threads(1024);
> + =A0 =A0 =A0 wakeup_flusher_threads(1024, WB_REASON_FREE_MORE_MEM);
> =A0 =A0 =A0 =A0yield();
>
> =A0 =A0 =A0 =A0for_each_online_node(nid) {
> --- linux-next.orig/fs/ext4/inode.c =A0 =A0 2011-10-07 22:23:35.000000000=
 +0800
> +++ linux-next/fs/ext4/inode.c =A02011-10-07 22:24:47.000000000 +0800
> @@ -2241,7 +2241,7 @@ static int ext4_nonda_switch(struct supe
> =A0 =A0 =A0 =A0 * start pushing delalloc when 1/2 of free blocks are dirt=
y.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (free_blocks < 2 * dirty_blocks)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb_if_idle(sb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb_if_idle(sb, WB_REASON_F=
S_FREE_SPACE);
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
> --- linux-next.orig/fs/fs-writeback.c =A0 2011-10-07 22:23:35.000000000 +=
0800
> +++ linux-next/fs/fs-writeback.c =A0 =A0 =A0 =A02011-10-07 22:24:47.00000=
0000 +0800
> @@ -41,11 +41,23 @@ struct wb_writeback_work {
> =A0 =A0 =A0 =A0unsigned int for_kupdate:1;
> =A0 =A0 =A0 =A0unsigned int range_cyclic:1;
> =A0 =A0 =A0 =A0unsigned int for_background:1;
> + =A0 =A0 =A0 enum wb_reason reason; =A0 =A0 =A0 =A0 =A0/* why was writeb=
ack initiated? */
>
> =A0 =A0 =A0 =A0struct list_head list; =A0 =A0 =A0 =A0 =A0/* pending work =
list */
> =A0 =A0 =A0 =A0struct completion *done; =A0 =A0 =A0 =A0/* set if the call=
er waits */
> =A0};
>
> +const char *wb_reason_name[] =3D {
> + =A0 =A0 =A0 [WB_REASON_BACKGROUND] =A0 =A0 =A0 =A0 =A0=3D "background",
> + =A0 =A0 =A0 [WB_REASON_TRY_TO_FREE_PAGES] =A0 =3D "try_to_free_pages",
> + =A0 =A0 =A0 [WB_REASON_SYNC] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D "sync",
> + =A0 =A0 =A0 [WB_REASON_PERIODIC] =A0 =A0 =A0 =A0 =A0 =A0=3D "periodic",
> + =A0 =A0 =A0 [WB_REASON_LAPTOP_TIMER] =A0 =A0 =A0 =A0=3D "laptop_timer",
> + =A0 =A0 =A0 [WB_REASON_FREE_MORE_MEM] =A0 =A0 =A0 =3D "free_more_memory=
",
> + =A0 =A0 =A0 [WB_REASON_FS_FREE_SPACE] =A0 =A0 =A0 =3D "fs_free_space",
> + =A0 =A0 =A0 [WB_REASON_FORKER_THREAD] =A0 =A0 =A0 =3D "forker_thread"
> +};
> +
> =A0/*
> =A0* Include the creation of the trace points after defining the
> =A0* wb_writeback_work structure so that the definition remains local to =
this
> @@ -115,7 +127,7 @@ static void bdi_queue_work(struct backin
>
> =A0static void
> =A0__bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool range_cyclic)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool range_cyclic, enum wb_reas=
on reason)
> =A0{
> =A0 =A0 =A0 =A0struct wb_writeback_work *work;
>
> @@ -135,6 +147,7 @@ __bdi_start_writeback(struct backing_dev
> =A0 =A0 =A0 =A0work->sync_mode =3D WB_SYNC_NONE;
> =A0 =A0 =A0 =A0work->nr_pages =A0=3D nr_pages;
> =A0 =A0 =A0 =A0work->range_cyclic =3D range_cyclic;
> + =A0 =A0 =A0 work->reason =A0 =A0=3D reason;
>
> =A0 =A0 =A0 =A0bdi_queue_work(bdi, work);
> =A0}
> @@ -150,9 +163,10 @@ __bdi_start_writeback(struct backing_dev
> =A0* =A0 completion. Caller need not hold sb s_umount semaphore.
> =A0*
> =A0*/
> -void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages)
> +void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_reason reason)
> =A0{
> - =A0 =A0 =A0 __bdi_start_writeback(bdi, nr_pages, true);
> + =A0 =A0 =A0 __bdi_start_writeback(bdi, nr_pages, true, reason);
> =A0}
>
> =A0/**
> @@ -641,12 +655,14 @@ static long __writeback_inodes_wb(struct
> =A0 =A0 =A0 =A0return wrote;
> =A0}
>
> -long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages)
> +long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_rea=
son reason)
> =A0{
> =A0 =A0 =A0 =A0struct wb_writeback_work work =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_pages =A0 =A0 =A0 =3D nr_pages,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.sync_mode =A0 =A0 =A0=3D WB_SYNC_NONE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.range_cyclic =A0 =3D 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reason =A0 =A0 =A0 =A0 =3D reason,
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0spin_lock(&wb->list_lock);
> @@ -825,6 +841,7 @@ static long wb_check_background_flush(st
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.sync_mode =A0 =A0 =A0=3D =
WB_SYNC_NONE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.for_background =3D 1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.range_cyclic =A0 =3D 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reason =A0 =A0 =A0 =A0 =3D=
 WB_REASON_BACKGROUND,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return wb_writeback(wb, &work);
> @@ -858,6 +875,7 @@ static long wb_check_old_data_flush(stru
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.sync_mode =A0 =A0 =A0=3D =
WB_SYNC_NONE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.for_kupdate =A0 =A0=3D 1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.range_cyclic =A0 =3D 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reason =A0 =A0 =A0 =A0 =3D=
 WB_REASON_PERIODIC,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return wb_writeback(wb, &work);
> @@ -976,7 +994,7 @@ int bdi_writeback_thread(void *data)
> =A0* Start writeback of `nr_pages' pages. =A0If `nr_pages' is zero, write=
 back
> =A0* the whole world.
> =A0*/
> -void wakeup_flusher_threads(long nr_pages)
> +void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
> =A0{
> =A0 =A0 =A0 =A0struct backing_dev_info *bdi;
>
> @@ -989,7 +1007,7 @@ void wakeup_flusher_threads(long nr_page
> =A0 =A0 =A0 =A0list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!bdi_has_dirty_io(bdi))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __bdi_start_writeback(bdi, nr_pages, false)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __bdi_start_writeback(bdi, nr_pages, false,=
 reason);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0}
> @@ -1210,7 +1228,9 @@ static void wait_sb_inodes(struct super_
> =A0* on how many (if any) will be written, and this function does not wai=
t
> =A0* for IO completion of submitted IO.
> =A0*/
> -void writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr)
> +void writeback_inodes_sb_nr(struct super_block *sb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_reason reas=
on)
> =A0{
> =A0 =A0 =A0 =A0DECLARE_COMPLETION_ONSTACK(done);
> =A0 =A0 =A0 =A0struct wb_writeback_work work =3D {
> @@ -1219,6 +1239,7 @@ void writeback_inodes_sb_nr(struct super
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.tagged_writepages =A0 =A0 =A0=3D 1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.done =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=3D &done,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_pages =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D =
nr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reason =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 reason,
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0WARN_ON(!rwsem_is_locked(&sb->s_umount));
> @@ -1235,9 +1256,9 @@ EXPORT_SYMBOL(writeback_inodes_sb_nr);
> =A0* on how many (if any) will be written, and this function does not wai=
t
> =A0* for IO completion of submitted IO.
> =A0*/
> -void writeback_inodes_sb(struct super_block *sb)
> +void writeback_inodes_sb(struct super_block *sb, enum wb_reason reason)
> =A0{
> - =A0 =A0 =A0 return writeback_inodes_sb_nr(sb, get_nr_dirty_pages());
> + =A0 =A0 =A0 return writeback_inodes_sb_nr(sb, get_nr_dirty_pages(), rea=
son);
> =A0}
> =A0EXPORT_SYMBOL(writeback_inodes_sb);
>
> @@ -1248,11 +1269,11 @@ EXPORT_SYMBOL(writeback_inodes_sb);
> =A0* Invoke writeback_inodes_sb if no writeback is currently underway.
> =A0* Returns 1 if writeback was started, 0 if not.
> =A0*/
> -int writeback_inodes_sb_if_idle(struct super_block *sb)
> +int writeback_inodes_sb_if_idle(struct super_block *sb, enum wb_reason r=
eason)
> =A0{
> =A0 =A0 =A0 =A0if (!writeback_in_progress(sb->s_bdi)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0down_read(&sb->s_umount);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb(sb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb(sb, reason);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up_read(&sb->s_umount);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0} else
> @@ -1269,11 +1290,12 @@ EXPORT_SYMBOL(writeback_inodes_sb_if_idl
> =A0* Returns 1 if writeback was started, 0 if not.
> =A0*/
> =A0int writeback_inodes_sb_nr_if_idle(struct super_block *sb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long nr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long nr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum=
 wb_reason reason)
> =A0{
> =A0 =A0 =A0 =A0if (!writeback_in_progress(sb->s_bdi)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0down_read(&sb->s_umount);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb_nr(sb, nr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb_nr(sb, nr, reason);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up_read(&sb->s_umount);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0} else
> @@ -1297,6 +1319,7 @@ void sync_inodes_sb(struct super_block *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_pages =A0 =A0 =A0 =3D LONG_MAX,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.range_cyclic =A0 =3D 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.done =A0 =A0 =A0 =A0 =A0 =3D &done,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reason =A0 =A0 =A0 =A0 =3D WB_REASON_SYNC,
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0WARN_ON(!rwsem_is_locked(&sb->s_umount));
> --- linux-next.orig/fs/quota/quota.c =A0 =A02011-10-07 22:23:35.000000000=
 +0800
> +++ linux-next/fs/quota/quota.c 2011-10-07 22:24:47.000000000 +0800
> @@ -286,7 +286,7 @@ static int do_quotactl(struct super_bloc
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* caller already holds s_umount */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sb->s_flags & MS_RDONLY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EROFS;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb(sb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb(sb, WB_REASON_SYNC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> --- linux-next.orig/fs/sync.c =A0 2011-10-07 22:23:35.000000000 +0800
> +++ linux-next/fs/sync.c =A0 =A0 =A0 =A02011-10-07 22:24:47.000000000 +08=
00
> @@ -43,7 +43,7 @@ static int __sync_filesystem(struct supe
> =A0 =A0 =A0 =A0if (wait)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sync_inodes_sb(sb);
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb(sb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_inodes_sb(sb, WB_REASON_SYNC);
>
> =A0 =A0 =A0 =A0if (sb->s_op->sync_fs)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sb->s_op->sync_fs(sb, wait);
> @@ -98,7 +98,7 @@ static void sync_filesystems(int wait)
> =A0*/
> =A0SYSCALL_DEFINE0(sync)
> =A0{
> - =A0 =A0 =A0 wakeup_flusher_threads(0);
> + =A0 =A0 =A0 wakeup_flusher_threads(0, WB_REASON_SYNC);
> =A0 =A0 =A0 =A0sync_filesystems(0);
> =A0 =A0 =A0 =A0sync_filesystems(1);
> =A0 =A0 =A0 =A0if (unlikely(laptop_mode))
> --- linux-next.orig/fs/ubifs/budget.c =A0 2011-10-07 22:23:35.000000000 +=
0800
> +++ linux-next/fs/ubifs/budget.c =A0 =A0 =A0 =A02011-10-07 22:24:47.00000=
0000 +0800
> @@ -63,7 +63,7 @@
> =A0static void shrink_liability(struct ubifs_info *c, int nr_to_write)
> =A0{
> =A0 =A0 =A0 =A0down_read(&c->vfs_sb->s_umount);
> - =A0 =A0 =A0 writeback_inodes_sb(c->vfs_sb);
> + =A0 =A0 =A0 writeback_inodes_sb(c->vfs_sb, WB_REASON_FS_FREE_SPACE);
> =A0 =A0 =A0 =A0up_read(&c->vfs_sb->s_umount);
> =A0}
>
> --- linux-next.orig/include/linux/backing-dev.h 2011-10-07 22:23:35.00000=
0000 +0800
> +++ linux-next/include/linux/backing-dev.h =A0 =A0 =A02011-10-07 22:24:47=
.000000000 +0800
> @@ -118,7 +118,8 @@ int bdi_register(struct backing_dev_info
> =A0int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
> =A0void bdi_unregister(struct backing_dev_info *bdi);
> =A0int bdi_setup_and_register(struct backing_dev_info *, char *, unsigned=
 int);
> -void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages);
> +void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_reason reason);
> =A0void bdi_start_background_writeback(struct backing_dev_info *bdi);
> =A0int bdi_writeback_thread(void *data);
> =A0int bdi_has_dirty_io(struct backing_dev_info *bdi);
> --- linux-next.orig/include/linux/writeback.h =A0 2011-10-07 22:23:35.000=
000000 +0800
> +++ linux-next/include/linux/writeback.h =A0 =A0 =A0 =A02011-10-07 22:24:=
47.000000000 +0800
> @@ -39,6 +39,23 @@ enum writeback_sync_modes {
> =A0};
>
> =A0/*
> + * why some writeback work was initiated
> + */
> +enum wb_reason {
> + =A0 =A0 =A0 WB_REASON_BACKGROUND,
> + =A0 =A0 =A0 WB_REASON_TRY_TO_FREE_PAGES,
> + =A0 =A0 =A0 WB_REASON_SYNC,
> + =A0 =A0 =A0 WB_REASON_PERIODIC,
> + =A0 =A0 =A0 WB_REASON_LAPTOP_TIMER,
> + =A0 =A0 =A0 WB_REASON_FREE_MORE_MEM,
> + =A0 =A0 =A0 WB_REASON_FS_FREE_SPACE,
> + =A0 =A0 =A0 WB_REASON_FORKER_THREAD,
> +
> + =A0 =A0 =A0 WB_REASON_MAX,
> +};
> +extern const char *wb_reason_name[];
> +
> +/*
> =A0* A control structure which tells the writeback code what to do. =A0Th=
ese are
> =A0* always on the stack, and hence need no locking. =A0They are always i=
nitialised
> =A0* in a manner such that unspecified fields are set to zero.
> @@ -69,14 +86,17 @@ struct writeback_control {
> =A0*/
> =A0struct bdi_writeback;
> =A0int inode_wait(void *);
> -void writeback_inodes_sb(struct super_block *);
> -void writeback_inodes_sb_nr(struct super_block *, unsigned long nr);
> -int writeback_inodes_sb_if_idle(struct super_block *);
> -int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long n=
r);
> +void writeback_inodes_sb(struct super_block *, enum wb_reason reason);
> +void writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_reason reason);
> +int writeback_inodes_sb_if_idle(struct super_block *, enum wb_reason rea=
son);
> +int writeback_inodes_sb_nr_if_idle(struct super_block *, unsigned long n=
r,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_reason reason);
> =A0void sync_inodes_sb(struct super_block *);
> -long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages);
> +long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum wb_rea=
son reason);
> =A0long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
> -void wakeup_flusher_threads(long nr_pages);
> +void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
>
> =A0/* writeback.h requires fs.h; it, too, is not included from here. */
> =A0static inline void wait_on_inode(struct inode *inode)
> --- linux-next.orig/include/trace/events/writeback.h =A0 =A02011-10-07 22=
:23:35.000000000 +0800
> +++ linux-next/include/trace/events/writeback.h 2011-10-07 22:24:47.00000=
0000 +0800
> @@ -34,6 +34,7 @@ DECLARE_EVENT_CLASS(writeback_work_class
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, for_kupdate)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, range_cyclic)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, for_background)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(int, reason)
> =A0 =A0 =A0 =A0),
> =A0 =A0 =A0 =A0TP_fast_assign(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strncpy(__entry->name, dev_name(bdi->dev),=
 32);
> @@ -43,16 +44,18 @@ DECLARE_EVENT_CLASS(writeback_work_class
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->for_kupdate =3D work->for_kupdate=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->range_cyclic =3D work->range_cycl=
ic;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->for_background =3D work->for_back=
ground;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->reason =3D work->reason;
> =A0 =A0 =A0 =A0),
> =A0 =A0 =A0 =A0TP_printk("bdi %s: sb_dev %d:%d nr_pages=3D%ld sync_mode=
=3D%d "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "kupdate=3D%d range_cyclic=3D%d backgro=
und=3D%d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "kupdate=3D%d range_cyclic=3D%d backgro=
und=3D%d reason=3D%s",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MAJOR(__entry->sb_dev), MINOR(__entry-=
>sb_dev),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_pages,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->sync_mode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->for_kupdate,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->range_cyclic,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->for_background
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->for_background,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wb_reason_name[__entry->reason]
> =A0 =A0 =A0 =A0)
> =A0);
> =A0#define DEFINE_WRITEBACK_WORK_EVENT(name) \
> @@ -165,6 +168,7 @@ TRACE_EVENT(writeback_queue_io,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(unsigned long, =A0older)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(long, =A0 =A0 =A0 =A0 =A0 age)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, =A0 =A0 =A0 =A0 =A0 =A0moved)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(int, =A0 =A0 =A0 =A0 =A0 =A0reason)
> =A0 =A0 =A0 =A0),
> =A0 =A0 =A0 =A0TP_fast_assign(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *older_than_this =3D work->o=
lder_than_this;
> @@ -173,12 +177,14 @@ TRACE_EVENT(writeback_queue_io,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->age =A0 =A0=3D older_than_this ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(jiffi=
es - *older_than_this) * 1000 / HZ : -1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->moved =A0=3D moved;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->reason =3D work->reason;
> =A0 =A0 =A0 =A0),
> - =A0 =A0 =A0 TP_printk("bdi %s: older=3D%lu age=3D%ld enqueue=3D%d",
> + =A0 =A0 =A0 TP_printk("bdi %s: older=3D%lu age=3D%ld enqueue=3D%d reaso=
n=3D%s",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->older, /* older_than_this in jiff=
ies */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->age, =A0 /* older_than_this in re=
lative milliseconds */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->moved)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->moved,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wb_reason_name[__entry->reason])
> =A0);
>
> =A0TRACE_EVENT(global_dirty_state,
> --- linux-next.orig/mm/backing-dev.c =A0 =A02011-10-07 22:23:35.000000000=
 +0800
> +++ linux-next/mm/backing-dev.c 2011-10-07 22:24:47.000000000 +0800
> @@ -476,7 +476,8 @@ static int bdi_forker_thread(void *ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * the bdi=
 from the thread. Hopefully 1024 is
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * large e=
nough for efficient IO.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_i=
nodes_wb(&bdi->wb, 1024);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeback_i=
nodes_wb(&bdi->wb, 1024,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WB_REASON_FORKER_THREAD);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * The spi=
nlock makes sure we do not lose
> --- linux-next.orig/mm/page-writeback.c 2011-10-07 22:23:35.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =A0 =A0 =A02011-10-07 22:24:47.0000000=
00 +0800
> @@ -1304,7 +1304,8 @@ void laptop_mode_timer_fn(unsigned long
> =A0 =A0 =A0 =A0 * threshold
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (bdi_has_dirty_io(&q->backing_dev_info))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_start_writeback(&q->backing_dev_info, n=
r_pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_start_writeback(&q->backing_dev_info, n=
r_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 WB_REASON_LAPTOP_TIMER);
> =A0}
>
> =A0/*
> --- linux-next.orig/mm/vmscan.c 2011-10-07 22:23:35.000000000 +0800
> +++ linux-next/mm/vmscan.c =A0 =A0 =A02011-10-07 22:24:47.000000000 +0800
> @@ -2181,7 +2181,8 @@ static unsigned long do_try_to_free_page
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0writeback_threshold =3D sc->nr_to_reclaim =
+ sc->nr_to_reclaim / 2;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (total_scanned > writeback_threshold) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_flusher_threads(lapt=
op_mode ? 0 : total_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_flusher_threads(lapt=
op_mode ? 0 : total_scanned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 WB_REASON_TRY_TO_FREE_PAGES);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->may_writepage =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
