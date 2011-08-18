Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 18187900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 07:28:58 -0400 (EDT)
Received: by vwm42 with SMTP id 42so1944926vwm.14
        for <linux-mm@kvack.org>; Thu, 18 Aug 2011 04:28:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110818094824.GA25752@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
	<20110818094824.GA25752@localhost>
Date: Thu, 18 Aug 2011 16:58:55 +0530
Message-ID: <CAFPAmTQ3jN8RF5-7E92AoGAGMz5H0GrPxkgJ0O6u_MViGC6KnQ@mail.gmail.com>
Subject: Re: [PATCH] writeback: Per-block device bdi->dirty_writeback_interval
 and bdi->dirty_expire_interval.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi Wu,

Thanks for responding.

Please find my comments inline in your email below.

On Thu, Aug 18, 2011 at 3:18 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Hi Kautuk,
>
> Add CC to fsdevel and Mel and KOSAKI.
>
> When submitting patches you can find the relevant mailing list and
> developers to CC with this command under the kernel source tree:
>
> =A0 =A0 =A0 =A0scripts/get_maintainer.pl YOUR-PATCH-FILE
>
> On Thu, Aug 11, 2011 at 05:50:56PM +0530, Kautuk Consul wrote:
>> Hi,
>>
>> Currently the /proc/sys/vm/dirty_writeback_centisecs and
>> /proc/sys/vm/dirty_expire_centisecs values are
>> global to the system.
>> All the BDI flush-* threads are controlled by these central values.
>
> Yes.
>
>> However, the user/admin might want to set different writeback speeds
>> for different block devices based on
>> their page write-back performance.
>
> How can the above two sysctl values impact "writeback speeds"?
> In particular, what's the "speed" you mean?
>

By writeback speed, I meant writeback interval, i.e. the maximum
interval after which the BDI
thread for a particular block device can wake up and try to sync pages
with disk.


>> For example, the user might want to write-back pages in smaller
>> intervals to a block device which has a
>> faster known writeback speed.
>
> That's not a complete rational. What does the user ultimately want by
> setting a smaller interval? What would be the problems to the other
> slow devices if the user does so by simply setting a small value
> _globally_?
>

I think that the user might want to set a smaller interval for faster block
devices so that the dirty pages are synced with that block device/disk soon=
er.
This will unset the dirty bit of the page-cache pages sooner, which
will increase the
possibility of those pages getting reclaimed quickly in high memory
usage scenarios.
For a system that writes to disk very frequently and runs a lot of
memory intensive user-mode
applications, this might be crucial for their performance as they
would possibly have to sleep
comparitively lesser during page allocation.
For example, an server handling a database needs frequent disk access
as well as
anonymous memory. In such a case it would be nice to keep the
write-back interval for a USB pen
drive BDI thread as more than that of a SATA/SCSI disk.

> We need strong use cases for doing such user interface changes.
> Would you detail the problem and the pains that can only (or best)
> be addressed by this patch?
>

Overall, I think that ever since there have been different BDI threads
for different block devices,
it seems quite rational to provide the user an option to set different
writeback intervals to different
block devices due to the reasons/examples I have mentioned above.

I do not fully theoretically understand the way your patches are
controlling the dirty rate and estimating
the future bandwidth.
But, when I looked through them I did not see any place where the
writeback interval for a BDI was being
changed.
So, I felt that my patch was more like an additional feature for the
user rather than a conflict with your
writeback patches.

> Thanks,
> Fengguang
>
>> This patch creates 3 new counters (in centisecs) for all the BDI
>> threads that were controlled centrally by these
>> 2 counters:
>> i) =A0 /sys/block/<block_dev>/bdi/dirty_writeback_interval,
>> ii) =A0/sys/block/<block_dev>/bdi/dirty_expire_interval,
>> iii) /proc/sys/vm/sync_supers_centisecs.
>>
>> Although these new counters can be tuned individually, I have taken
>> care that they be centrally reset by changes
>> to the /proc/sys/vm/dirty_expire_centisecs and
>> /proc/sys/vm/dirty_writeback_centisecs so that the earlier
>> functionality is not broken by distributions using these central values.
>> After resetting all values centrally, these values can be tuned
>> individually without altering the central values.
>>
>> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
>> ---
>>
>> diff -uprN a/fs/fs-writeback.c b/fs/fs-writeback.c
>> --- a/fs/fs-writeback.c =A0 =A0 =A0 2011-08-05 10:29:21.000000000 +0530
>> +++ b/fs/fs-writeback.c =A0 =A0 =A0 2011-08-09 09:15:37.093041675 +0530
>> @@ -638,8 +638,8 @@ static inline bool over_bground_thresh(v
>> =A0 * just walks the superblock inode list, writing back any inodes whic=
h are
>> =A0 * older than a specific point in time.
>> =A0 *
>> - * Try to run once per dirty_writeback_interval. =A0But if a writeback =
event
>> - * takes longer than a dirty_writeback_interval interval, then leave a
>> + * Try to run once per bdi->dirty_writeback_interval. =A0But if a write=
back event
>> + * takes longer than a bdi->dirty_writeback_interval interval, then lea=
ve a
>> =A0 * one-second gap.
>> =A0 *
>> =A0 * older_than_this takes precedence over nr_to_write. =A0So we'll onl=
y write back
>> @@ -663,7 +663,7 @@ static long wb_writeback(struct bdi_writ
>> =A0 =A0 =A0 if (wbc.for_kupdate) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wbc.older_than_this =3D &oldest_jif;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 oldest_jif =3D jiffies -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs_to_jiffi=
es(dirty_expire_interval * 10);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs_to_jiffi=
es(wb->bdi->dirty_expire_interval * 10);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 if (!wbc.range_cyclic) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wbc.range_start =3D 0;
>> @@ -811,15 +811,16 @@ static long wb_check_old_data_flush(stru
>> =A0{
>> =A0 =A0 =A0 unsigned long expired;
>> =A0 =A0 =A0 long nr_pages;
>> + =A0 =A0 struct backing_dev_info *bdi =3D wb->bdi;
>>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* When set to zero, disable periodic writeback
>> =A0 =A0 =A0 =A0*/
>> - =A0 =A0 if (!dirty_writeback_interval)
>> + =A0 =A0 if (!bdi->dirty_writeback_interval)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> =A0 =A0 =A0 expired =3D wb->last_old_flush +
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs_to_jiffies(dirty_writeba=
ck_interval * 10);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs_to_jiffies(bdi->dirty_wr=
iteback_interval * 10);
>> =A0 =A0 =A0 if (time_before(jiffies, expired))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> @@ -923,8 +924,8 @@ int bdi_writeback_thread(void *data)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (wb_has_dirty_io(wb) && dirty_writeback_int=
erval)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_timeout(msecs_to_jiff=
ies(dirty_writeback_interval * 10));
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (wb_has_dirty_io(wb) && bdi->dirty_writebac=
k_interval)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_timeout(msecs_to_jiff=
ies(bdi->dirty_writeback_interval * 10));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We have nothing to do, =
so can go sleep without any
>> diff -uprN a/include/linux/backing-dev.h b/include/linux/backing-dev.h
>> --- a/include/linux/backing-dev.h =A0 =A0 2011-08-05 10:29:21.000000000 =
+0530
>> +++ b/include/linux/backing-dev.h =A0 =A0 2011-08-09 09:15:37.094041619 =
+0530
>> @@ -76,6 +76,8 @@ struct backing_dev_info {
>>
>> =A0 =A0 =A0 unsigned int min_ratio;
>> =A0 =A0 =A0 unsigned int max_ratio, max_prop_frac;
>> + =A0 =A0 unsigned int dirty_writeback_interval;
>> + =A0 =A0 unsigned int dirty_expire_interval;
>>
>> =A0 =A0 =A0 struct bdi_writeback wb; =A0/* default writeback info for th=
is bdi */
>> =A0 =A0 =A0 spinlock_t wb_lock; =A0 =A0 =A0 /* protects work_list */
>> @@ -333,4 +335,5 @@ static inline int bdi_sched_wait(void *w
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> +extern unsigned int shortest_dirty_writeback_interval;
>> =A0#endif =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* _LINUX_BACKING_DEV_H */
>> diff -uprN a/include/linux/writeback.h b/include/linux/writeback.h
>> --- a/include/linux/writeback.h =A0 =A0 =A0 2011-08-05 10:29:21.00000000=
0 +0530
>> +++ b/include/linux/writeback.h =A0 =A0 =A0 2011-08-09 10:09:23.58126826=
0 +0530
>> @@ -100,6 +100,7 @@ extern unsigned long dirty_background_by
>> =A0extern int vm_dirty_ratio;
>> =A0extern unsigned long vm_dirty_bytes;
>> =A0extern unsigned int dirty_writeback_interval;
>> +extern unsigned int sync_supers_interval;
>> =A0extern unsigned int dirty_expire_interval;
>> =A0extern int vm_highmem_is_dirtyable;
>> =A0extern int block_dump;
>> @@ -123,6 +124,10 @@ extern int dirty_bytes_handler(struct ct
>> =A0struct ctl_table;
>> =A0int dirty_writeback_centisecs_handler(struct ctl_table *, int,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
void __user *, size_t *, loff_t *);
>> +int sync_supers_centisecs_handler(struct ctl_table *, int,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vo=
id __user *, size_t *, loff_t *);
>> +int dirty_expire_centisecs_handler(struct ctl_table *, int,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vo=
id __user *, size_t *, loff_t *);
>>
>> =A0void global_dirty_limits(unsigned long *pbackground, unsigned long *p=
dirty);
>> =A0unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
>> diff -uprN a/kernel/sysctl.c b/kernel/sysctl.c
>> --- a/kernel/sysctl.c 2011-08-05 10:29:21.000000000 +0530
>> +++ b/kernel/sysctl.c 2011-08-09 12:39:43.453087554 +0530
>> @@ -1076,12 +1076,19 @@ static struct ctl_table vm_table[] =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D dirty_writeback_centis=
ecs_handler,
>> =A0 =A0 =A0 },
>> + =A0 =A0{
>> + =A0 =A0 =A0 =A0.procname =A0 =3D "sync_supers_centisecs",
>> + =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =3D &sync_supers_interval,
>> + =A0 =A0 =A0 =A0.maxlen =A0 =A0 =3D sizeof(sync_supers_interval),
>> + =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =3D 0644,
>> + =A0 =A0 =A0 =A0.proc_handler =A0 =3D sync_supers_centisecs_handler,
>> + =A0 =A0},
>> =A0 =A0 =A0 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "dirty_expire_cent=
isecs",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &dirty_expire_=
interval,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(dirty_exp=
ire_interval),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_dointvec_minmax,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D dirty_expire_centisecs_h=
andler,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .extra1 =A0 =A0 =A0 =A0 =3D &zero,
>> =A0 =A0 =A0 },
>> =A0 =A0 =A0 {
>> diff -uprN a/mm/backing-dev.c b/mm/backing-dev.c
>> --- a/mm/backing-dev.c =A0 =A0 =A0 =A02011-08-05 10:29:21.000000000 +053=
0
>> +++ b/mm/backing-dev.c =A0 =A0 =A0 =A02011-08-09 12:08:06.287079027 +053=
0
>> @@ -39,6 +39,10 @@ DEFINE_SPINLOCK(bdi_lock);
>> =A0LIST_HEAD(bdi_list);
>> =A0LIST_HEAD(bdi_pending_list);
>>
>> +/* Same value as the dirty_writeback_interval as this is what our
>> + * initial shortest_dirty_writeback_interval. */
>> +unsigned int shortest_dirty_writeback_interval =3D 5 * 100;
>> +
>> =A0static struct task_struct *sync_supers_tsk;
>> =A0static struct timer_list sync_supers_timer;
>>
>> @@ -204,12 +208,50 @@ static ssize_t max_ratio_store(struct de
>> =A0}
>> =A0BDI_SHOW(max_ratio, bdi->max_ratio)
>>
>> +static ssize_t dirty_writeback_interval_store(struct device *dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct device_attribute *attr, const char *buf=
, size_t count)
>> +{
>> + =A0 =A0 struct backing_dev_info *bdi =3D dev_get_drvdata(dev);
>> + =A0 =A0 char *end;
>> + =A0 =A0 unsigned int interval;
>> + =A0 =A0 ssize_t ret =3D -EINVAL;
>> +
>> + =A0 =A0 interval =3D simple_strtoul(buf, &end, 10);
>> + =A0 =A0 if (*buf && (end[0] =3D=3D '\0' || (end[0] =3D=3D '\n' && end[=
1] =3D=3D '\0'))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_writeback_interval =3D interval;
>> + =A0 =A0 =A0 =A0 =A0 =A0 shortest_dirty_writeback_interval =3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 min(shortest_dirty_writeback_interval,interval);
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D count;
>> + =A0 =A0 }
>> + =A0 =A0 return ret;
>> +}
>> +BDI_SHOW(dirty_writeback_interval, bdi->dirty_writeback_interval)
>> +
>> +static ssize_t dirty_expire_interval_store (struct device *dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct device_attribute *attr, const char *buf=
, size_t count)
>> +{
>> + =A0 =A0 struct backing_dev_info *bdi =3D dev_get_drvdata(dev);
>> + =A0 =A0 char *end;
>> + =A0 =A0 unsigned int interval;
>> + =A0 =A0 ssize_t ret =3D -EINVAL;
>> +
>> + =A0 =A0 interval =3D simple_strtoul(buf, &end, 10);
>> + =A0 =A0 if (*buf && (end[0] =3D=3D '\0' || (end[0] =3D=3D '\n' && end[=
1] =3D=3D '\0'))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_expire_interval =3D interval;
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D count;
>> + =A0 =A0 }
>> + =A0 =A0 return ret;
>> +}
>> +BDI_SHOW(dirty_expire_interval, bdi->dirty_expire_interval)
>> +
>> =A0#define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
>>
>> =A0static struct device_attribute bdi_dev_attrs[] =3D {
>> =A0 =A0 =A0 __ATTR_RW(read_ahead_kb),
>> =A0 =A0 =A0 __ATTR_RW(min_ratio),
>> =A0 =A0 =A0 __ATTR_RW(max_ratio),
>> + =A0 =A0 __ATTR_RW(dirty_writeback_interval),
>> + =A0 =A0 __ATTR_RW(dirty_expire_interval),
>> =A0 =A0 =A0 __ATTR_NULL,
>> =A0};
>>
>> @@ -291,7 +333,7 @@ void bdi_arm_supers_timer(void)
>> =A0 =A0 =A0 if (!dirty_writeback_interval)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> - =A0 =A0 next =3D msecs_to_jiffies(dirty_writeback_interval * 10) + jif=
fies;
>> + =A0 =A0 next =3D msecs_to_jiffies(sync_supers_interval* 10) + jiffies;
>> =A0 =A0 =A0 mod_timer(&sync_supers_timer, round_jiffies_up(next));
>> =A0}
>>
>> @@ -336,7 +378,7 @@ void bdi_wakeup_thread_delayed(struct ba
>> =A0{
>> =A0 =A0 =A0 unsigned long timeout;
>>
>> - =A0 =A0 timeout =3D msecs_to_jiffies(dirty_writeback_interval * 10);
>> + =A0 =A0 timeout =3D msecs_to_jiffies(bdi->dirty_writeback_interval * 1=
0);
>> =A0 =A0 =A0 mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
>> =A0}
>>
>> @@ -348,7 +390,19 @@ static unsigned long bdi_longest_inactiv
>> =A0{
>> =A0 =A0 =A0 unsigned long interval;
>>
>> - =A0 =A0 interval =3D msecs_to_jiffies(dirty_writeback_interval * 10);
>> + =A0 =A0 interval =3D msecs_to_jiffies(shortest_dirty_writeback_interva=
l * 10);
>> + =A0 =A0 return max(5UL * 60 * HZ, interval);
>> +}
>> +
>> +/*
>> + * Calculate the longest interval (jiffies) this bdi thread is allowed =
to be
>> + * inactive.
>> + */
>> +static unsigned long bdi_longest_inactive_this(struct backing_dev_info =
*bdi)
>> +{
>> + =A0 =A0 unsigned long interval;
>> +
>> + =A0 =A0 interval =3D msecs_to_jiffies(bdi->dirty_writeback_interval * =
10);
>> =A0 =A0 =A0 return max(5UL * 60 * HZ, interval);
>> =A0}
>>
>> @@ -422,7 +476,7 @@ static int bdi_forker_thread(void *ptr)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bdi->wb.task && !have_di=
rty_io &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 time_after(jiffies, =
bdi->wb.last_active +
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 bdi_longest_inactive())) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 bdi_longest_inactive_this(bdi))) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task =3D bdi=
->wb.task;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi->wb.task=
 =3D NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(=
&bdi->wb_lock);
>> @@ -469,7 +523,7 @@ static int bdi_forker_thread(void *ptr)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case NO_ACTION:
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!wb_has_dirty_io(me) || !d=
irty_writeback_interval)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!wb_has_dirty_io(me) || !m=
e->bdi->dirty_writeback_interval)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* There a=
re no dirty data. The only thing we
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* should =
now care about is checking for
>> @@ -479,7 +533,7 @@ static int bdi_forker_thread(void *ptr)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_tim=
eout(bdi_longest_inactive());
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_timeo=
ut(msecs_to_jiffies(dirty_writeback_interval * 10));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_timeo=
ut(msecs_to_jiffies(me->bdi->dirty_writeback_interval * 10));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Back to the main loop */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> @@ -641,6 +695,8 @@ int bdi_init(struct backing_dev_info *bd
>> =A0 =A0 =A0 bdi->min_ratio =3D 0;
>> =A0 =A0 =A0 bdi->max_ratio =3D 100;
>> =A0 =A0 =A0 bdi->max_prop_frac =3D PROP_FRAC_BASE;
>> + =A0 =A0 bdi->dirty_writeback_interval =3D dirty_writeback_interval;
>> + =A0 =A0 bdi->dirty_expire_interval =3D dirty_expire_interval;
>> =A0 =A0 =A0 spin_lock_init(&bdi->wb_lock);
>> =A0 =A0 =A0 INIT_LIST_HEAD(&bdi->bdi_list);
>> =A0 =A0 =A0 INIT_LIST_HEAD(&bdi->work_list);
>> diff -uprN a/mm/page-writeback.c b/mm/page-writeback.c
>> --- a/mm/page-writeback.c =A0 =A0 2011-08-05 10:29:21.000000000 +0530
>> +++ b/mm/page-writeback.c =A0 =A0 2011-08-09 13:09:37.985919961 +0530
>> @@ -92,6 +92,11 @@ unsigned long vm_dirty_bytes;
>> =A0unsigned int dirty_writeback_interval =3D 5 * 100; /* centiseconds */
>>
>> =A0/*
>> + * The interval between sync_supers thread writebacks
>> + */
>> +unsigned int sync_supers_interval =3D 5 * 100; /* centiseconds */
>> +
>> +/*
>> =A0 * The longest time for which data is allowed to remain dirty
>> =A0 */
>> =A0unsigned int dirty_expire_interval =3D 30 * 100; /* centiseconds */
>> @@ -686,8 +691,60 @@ void throttle_vm_writeout(gfp_t gfp_mask
>> =A0int dirty_writeback_centisecs_handler(ctl_table *table, int write,
>> =A0 =A0 =A0 void __user *buffer, size_t *length, loff_t *ppos)
>> =A0{
>> + =A0 =A0 struct backing_dev_info *bdi;
>> +
>> + =A0 =A0 proc_dointvec(table, write, buffer, length, ppos);
>> +
>> + =A0 =A0 if (write) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Traverse all the BDIs registered to the BDI=
 list and reset their
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* bdi->dirty_writeback_interval to this val=
ue. */
>> + =A0 =A0 =A0 =A0 spin_lock_bh(&bdi_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry(bdi, &bdi_list, bdi_list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_writeback_interval =
=3D dirty_writeback_interval;
>> + =A0 =A0 =A0 =A0 spin_unlock_bh(&bdi_lock);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 sync_supers_interval =3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shortest_dirty_writeback_inter=
val =3D dirty_writeback_interval;
>> +
>> + =A0 =A0 }
>> +
>> + =A0 =A0 bdi_arm_supers_timer();
>> +
>> + =A0 =A0 return 0;
>> +}
>> +
>> +/*
>> + * sysctl handler for /proc/sys/vm/sync_supers_centisecs
>> + */
>> +int sync_supers_centisecs_handler(ctl_table *table, int write,
>> + =A0 =A0 void __user *buffer, size_t *length, loff_t *ppos)
>> +{
>> =A0 =A0 =A0 proc_dointvec(table, write, buffer, length, ppos);
>> +
>> =A0 =A0 =A0 bdi_arm_supers_timer();
>> +
>> + =A0 =A0 return 0;
>> +}
>> +
>> +/*
>> + * sysctl handler for /proc/sys/vm/dirty_expire_centisecs
>> + */
>> +int dirty_expire_centisecs_handler(ctl_table *table, int write,
>> + =A0 =A0 void __user *buffer, size_t *length, loff_t *ppos)
>> +{
>> + =A0 =A0 struct backing_dev_info *bdi;
>> +
>> + =A0 =A0 proc_dointvec_minmax(table, write, buffer, length, ppos);
>> +
>> + =A0 =A0 if (write) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Traverse all the BDIs registered to the BDI=
 list and reset their
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* bdi->dirty_expire_interval to this value.=
 */
>> + =A0 =A0 =A0 =A0 spin_lock_bh(&bdi_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry(bdi, &bdi_list, bdi_list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_expire_interval =3D=
 dirty_expire_interval;
>> + =A0 =A0 =A0 =A0 spin_unlock_bh(&bdi_lock);
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 return 0;
>> =A0}
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
