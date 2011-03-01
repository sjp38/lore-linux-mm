Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CFEB68D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 16:14:25 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p21LEL6b001244
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 13:14:21 -0800
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by kpbe16.cbf.corp.google.com with ESMTP id p21LEIFk008168
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 13:14:19 -0800
Received: by qwj8 with SMTP id 8so4361353qwj.13
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 13:14:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110227163815.GC3226@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-5-git-send-email-gthelen@google.com> <20110227163815.GC3226@barrios-desktop>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 1 Mar 2011 13:13:58 -0800
Message-ID: <AANLkTi=bo1H1+DxrgPjTRH7+kk9T6=BMO3mAC78=-1uG@mail.gmail.com>
Subject: Re: [PATCH v5 4/9] writeback: create dirty_info structure
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Sun, Feb 27, 2011 at 8:38 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Feb 25, 2011 at 01:35:55PM -0800, Greg Thelen wrote:
>> Bundle dirty limits and dirty memory usage metrics into a dirty_info
>> structure to simplify interfaces of routines that need all.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>
>> ---
>> Changelog since v4:
>> - Within new dirty_info structure, replaced nr_reclaimable with nr_file_=
dirty
>> =A0 and nr_unstable_nfs to give callers finer grain dirty usage informat=
ion.
>> - Added new dirty_info_reclaimable() function.
>> - Made more use of dirty_info structure in throttle_vm_writeout().
>>
>> Changelog since v3:
>> - This is a new patch in v4.
>>
>> =A0fs/fs-writeback.c =A0 =A0 =A0 =A0 | =A0 =A07 ++---
>> =A0include/linux/writeback.h | =A0 15 ++++++++++++-
>> =A0mm/backing-dev.c =A0 =A0 =A0 =A0 =A0| =A0 18 +++++++++------
>> =A0mm/page-writeback.c =A0 =A0 =A0 | =A0 50 ++++++++++++++++++++++------=
----------------
>> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 +++-
>> =A05 files changed, 57 insertions(+), 39 deletions(-)
>>
>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>> index 59c6e49..d75e4da 100644
>> --- a/fs/fs-writeback.c
>> +++ b/fs/fs-writeback.c
>> @@ -595,12 +595,11 @@ static void __writeback_inodes_sb(struct super_blo=
ck *sb,
>>
>> =A0static inline bool over_bground_thresh(void)
>> =A0{
>> - =A0 =A0 unsigned long background_thresh, dirty_thresh;
>> + =A0 =A0 struct dirty_info info;
>>
>> - =A0 =A0 global_dirty_limits(&background_thresh, &dirty_thresh);
>> + =A0 =A0 global_dirty_info(&info);
>>
>> - =A0 =A0 return (global_page_state(NR_FILE_DIRTY) +
>> - =A0 =A0 =A0 =A0 =A0 =A0 global_page_state(NR_UNSTABLE_NFS) > backgroun=
d_thresh);
>> + =A0 =A0 return dirty_info_reclaimable(&info) > info.background_thresh;
>> =A0}
>
> Get unnecessary nr_writeback.
>
>>
>> =A0/*
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index 0ead399..a06fb38 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -84,6 +84,19 @@ static inline void inode_sync_wait(struct inode *inod=
e)
>> =A0/*
>> =A0 * mm/page-writeback.c
>> =A0 */
>> +struct dirty_info {
>> + =A0 =A0 unsigned long dirty_thresh;
>> + =A0 =A0 unsigned long background_thresh;
>> + =A0 =A0 unsigned long nr_file_dirty;
>> + =A0 =A0 unsigned long nr_writeback;
>> + =A0 =A0 unsigned long nr_unstable_nfs;
>> +};
>> +
>> +static inline unsigned long dirty_info_reclaimable(struct dirty_info *i=
nfo)
>> +{
>> + =A0 =A0 return info->nr_file_dirty + info->nr_unstable_nfs;
>> +}
>> +
>> =A0#ifdef CONFIG_BLOCK
>> =A0void laptop_io_completion(struct backing_dev_info *info);
>> =A0void laptop_sync_completion(void);
>> @@ -124,7 +137,7 @@ struct ctl_table;
>> =A0int dirty_writeback_centisecs_handler(struct ctl_table *, int,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
void __user *, size_t *, loff_t *);
>>
>> -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdi=
rty);
>> +void global_dirty_info(struct dirty_info *info);
>> =A0unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long=
 dirty);
>>
>> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> index 027100d..17a06ab 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -66,8 +66,7 @@ static int bdi_debug_stats_show(struct seq_file *m, vo=
id *v)
>> =A0{
>> =A0 =A0 =A0 struct backing_dev_info *bdi =3D m->private;
>> =A0 =A0 =A0 struct bdi_writeback *wb =3D &bdi->wb;
>> - =A0 =A0 unsigned long background_thresh;
>> - =A0 =A0 unsigned long dirty_thresh;
>> + =A0 =A0 struct dirty_info dirty_info;
>> =A0 =A0 =A0 unsigned long bdi_thresh;
>> =A0 =A0 =A0 unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
>> =A0 =A0 =A0 struct inode *inode;
>> @@ -82,8 +81,8 @@ static int bdi_debug_stats_show(struct seq_file *m, vo=
id *v)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_more_io++;
>> =A0 =A0 =A0 spin_unlock(&inode_lock);
>>
>> - =A0 =A0 global_dirty_limits(&background_thresh, &dirty_thresh);
>> - =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi, dirty_thresh);
>> + =A0 =A0 global_dirty_info(&dirty_info);
>> + =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi, dirty_info.dirty_thresh);
>>
>> =A0#define K(x) ((x) << (PAGE_SHIFT - 10))
>> =A0 =A0 =A0 seq_printf(m,
>> @@ -99,9 +98,14 @@ static int bdi_debug_stats_show(struct seq_file *m, v=
oid *v)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"state: =A0 =A0 =A0 =A0 =A0 =A0%8lx\n=
",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) K(bdi_stat(bdi, BDI_W=
RITEBACK)),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) K(bdi_stat(bdi, BDI_R=
ECLAIMABLE)),
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(bdi_thresh), K(dirty_thresh),
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(background_thresh), nr_dirty, nr_io, =
nr_more_io,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!list_empty(&bdi->bdi_list), bdi->state=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(bdi_thresh),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(dirty_info.dirty_thresh),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0K(dirty_info.background_thresh),
>
> Get unnecessary nr_file_dirty, nr_writeback, nr_unstable_nfs.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_dirty,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_io,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_more_io,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!list_empty(&bdi->bdi_list),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi->state);
>> =A0#undef K
>>
>> =A0 =A0 =A0 return 0;
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 4408e54..00424b9 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -398,7 +398,7 @@ unsigned long determine_dirtyable_memory(void)
>> =A0}
>>
>> =A0/*
>> - * global_dirty_limits - background-writeback and dirty-throttling thre=
sholds
>> + * global_dirty_info - return dirty thresholds and usage metrics
>> =A0 *
>> =A0 * Calculate the dirty thresholds based on sysctl parameters
>> =A0 * - vm.dirty_background_ratio =A0or =A0vm.dirty_background_bytes
>> @@ -406,7 +406,7 @@ unsigned long determine_dirtyable_memory(void)
>> =A0 * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. n=
fsd) and
>> =A0 * real-time tasks.
>> =A0 */
>> -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdi=
rty)
>> +void global_dirty_info(struct dirty_info *info)
>> =A0{
>> =A0 =A0 =A0 unsigned long background;
>> =A0 =A0 =A0 unsigned long dirty;
>> @@ -426,6 +426,10 @@ void global_dirty_limits(unsigned long *pbackground=
, unsigned long *pdirty)
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 background =3D (dirty_background_ratio * ava=
ilable_memory) / 100;
>>
>> + =A0 =A0 info->nr_file_dirty =3D global_page_state(NR_FILE_DIRTY);
>> + =A0 =A0 info->nr_writeback =3D global_page_state(NR_WRITEBACK);
>> + =A0 =A0 info->nr_unstable_nfs =3D global_page_state(NR_UNSTABLE_NFS);
>> +
>> =A0 =A0 =A0 if (background >=3D dirty)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 background =3D dirty / 2;
>> =A0 =A0 =A0 tsk =3D current;
>> @@ -433,8 +437,8 @@ void global_dirty_limits(unsigned long *pbackground,=
 unsigned long *pdirty)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 background +=3D background / 4;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dirty +=3D dirty / 4;
>> =A0 =A0 =A0 }
>> - =A0 =A0 *pbackground =3D background;
>> - =A0 =A0 *pdirty =3D dirty;
>> + =A0 =A0 info->background_thresh =3D background;
>> + =A0 =A0 info->dirty_thresh =3D dirty;
>> =A0}
>>
>> =A0/*
>> @@ -478,12 +482,9 @@ unsigned long bdi_dirty_limit(struct backing_dev_in=
fo *bdi, unsigned long dirty)
>> =A0static void balance_dirty_pages(struct address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lon=
g write_chunk)
>> =A0{
>> - =A0 =A0 unsigned long nr_reclaimable;
>> + =A0 =A0 struct dirty_info sys_info;
>> =A0 =A0 =A0 long bdi_nr_reclaimable;
>> - =A0 =A0 unsigned long nr_writeback;
>> =A0 =A0 =A0 long bdi_nr_writeback;
>> - =A0 =A0 unsigned long background_thresh;
>> - =A0 =A0 unsigned long dirty_thresh;
>> =A0 =A0 =A0 unsigned long bdi_thresh;
>> =A0 =A0 =A0 unsigned long pages_written =3D 0;
>> =A0 =A0 =A0 unsigned long pause =3D 1;
>> @@ -498,22 +499,19 @@ static void balance_dirty_pages(struct address_spa=
ce *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .range_cyclic =A0 =3D 1,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimable =3D global_page_state(NR_FILE_D=
IRTY) +
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 global_page_state(NR_UNSTABLE_NFS);
>> - =A0 =A0 =A0 =A0 =A0 =A0 nr_writeback =3D global_page_state(NR_WRITEBAC=
K);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_limits(&background_thresh, &dirty=
_thresh);
>> + =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_info(&sys_info);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Throttle it only when the background wr=
iteback cannot
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* catch-up. This avoids (excessively) sma=
ll writeouts
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* when the bdi limits are ramping up.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimable + nr_writeback <=3D
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (background_th=
resh + dirty_thresh) / 2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (dirty_info_reclaimable(&sys_info) + sys_in=
fo.nr_writeback <=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (sys_info.back=
ground_thresh +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_info.di=
rty_thresh) / 2)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi, dirty_thre=
sh);
>> + =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi, sys_info.d=
irty_thresh);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D task_dirty_limit(current, bdi=
_thresh);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> @@ -542,7 +540,8 @@ static void balance_dirty_pages(struct address_space=
 *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dirty_exceeded =3D
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (bdi_nr_reclaimable + bdi_nr=
_writeback > bdi_thresh)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || (nr_reclaimable + nr_writeb=
ack > dirty_thresh);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || (dirty_info_reclaimable(&sy=
s_info) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_info.nr_writeba=
ck > sys_info.dirty_thresh);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!dirty_exceeded)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> @@ -595,7 +594,8 @@ static void balance_dirty_pages(struct address_space=
 *mapping,
>> =A0 =A0 =A0 =A0* background_thresh, to keep the amount of dirty memory l=
ow.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 if ((laptop_mode && pages_written) ||
>> - =A0 =A0 =A0 =A0 (!laptop_mode && (nr_reclaimable > background_thresh))=
)
>> + =A0 =A0 =A0 =A0 (!laptop_mode && (dirty_info_reclaimable(&sys_info) >
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sys_info.backgroun=
d_thresh)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_start_background_writeback(bdi);
>> =A0}
>>
>> @@ -655,21 +655,21 @@ EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>>
>> =A0void throttle_vm_writeout(gfp_t gfp_mask)
>> =A0{
>> - =A0 =A0 unsigned long background_thresh;
>> - =A0 =A0 unsigned long dirty_thresh;
>> + =A0 =A0 struct dirty_info sys_info;
>>
>> =A0 =A0 =A0 =A0 =A0for ( ; ; ) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_limits(&background_thresh, &dirty=
_thresh);
>> + =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_info(&sys_info);
>
> Get unnecessary nr_file_dirty.
>
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Boost the allowable dirty threshol=
d a bit for page
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * allocators so they don't get DoS'e=
d by heavy writers
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dirty_thresh +=3D dirty_thresh / 10; =
=A0 =A0 =A0/* wheeee... */
>> + =A0 =A0 =A0 =A0 =A0 =A0 sys_info.dirty_thresh +=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sys_info.dirty_thresh / 10; =
=A0 =A0 =A0/* wheeee... */
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (global_page_state(NR_UNSTABLE_NFS) =
+
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_page_state(NR_WRITEBACK=
) <=3D dirty_thresh)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (sys_info.nr_unstable_nfs +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sys_info.nr_writeback <=3D sys_info.di=
rty_thresh)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0congestion_wait(BLK_RW_ASYNC, HZ/10);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 0c3b504..ec95924 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -1044,6 +1044,7 @@ static void *vmstat_start(struct seq_file *m, loff=
_t *pos)
>> =A0{
>> =A0 =A0 =A0 unsigned long *v;
>> =A0 =A0 =A0 int i, stat_items_size;
>> + =A0 =A0 struct dirty_info dirty_info;
>>
>> =A0 =A0 =A0 if (*pos >=3D ARRAY_SIZE(vmstat_text))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> @@ -1062,8 +1063,9 @@ static void *vmstat_start(struct seq_file *m, loff=
_t *pos)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 v[i] =3D global_page_state(i);
>> =A0 =A0 =A0 v +=3D NR_VM_ZONE_STAT_ITEMS;
>>
>> - =A0 =A0 global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 v + NR_DIRTY_THRESHOLD=
);
>> + =A0 =A0 global_dirty_info(&dirty_info);
>> + =A0 =A0 v[NR_DIRTY_BG_THRESHOLD] =3D dirty_info.background_thresh;
>> + =A0 =A0 v[NR_DIRTY_THRESHOLD] =3D dirty_info.dirty_thresh;
>> =A0 =A0 =A0 v +=3D NR_VM_WRITEBACK_STAT_ITEMS;
>
> Get unnecessary nr_file_dirty, nr_writeback, nr_unstable_nfs.
>
> The code itself doesn't have a problem. but although it makes code simple=
,
> sometime it get unnecessary information in that context. The global_page_=
state never
> cheap operation and we have been tried to reduce overhead in page-writeba=
ck.
> (16c4042f, e50e3720).
>
> Fortunately this patch doesn't increase balance_dirty_pages's overhead an=
d
> things affected by this patch are not fast-path.
> So I think it doesn't have a problem.

I am doing a small restructure to address this feedback.  The plan is
to only use the new dirty_info structure for memcg limits and usage.
The global limits and usage variables and logic will not be changed.

> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
