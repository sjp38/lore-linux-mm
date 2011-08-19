Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF2866B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:00:32 -0400 (EDT)
Received: by vxj3 with SMTP id 3so3243085vxj.14
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:00:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110819060803.GA7887@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
	<20110818094824.GA25752@localhost>
	<1313669702.6607.24.camel@sauron>
	<20110818131343.GA17473@localhost>
	<CAFPAmTShNRykOEbUfRan_2uAAbBoRHE0RhOh4DrbWKq7a4-Z9Q@mail.gmail.com>
	<20110819023406.GA12732@localhost>
	<CAFPAmTSzYg5n150_ykv-Vvc4QVbz14Oxn_Mm+EqxzbUL3c39tg@mail.gmail.com>
	<20110819052839.GB28266@localhost>
	<20110819060803.GA7887@localhost>
Date: Fri, 19 Aug 2011 12:30:30 +0530
Message-ID: <CAFPAmTQU_rHwFi8KRdTU6BjMFhvq0HKNfufQ762i1KQEHVPk8g@mail.gmail.com>
Subject: Re: [PATCH] writeback: Per-block device bdi->dirty_writeback_interval
 and bdi->dirty_expire_interval.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Hi Wu,

Yes. I think I do understand your approach.

Your aim is to always retain the per BDI timeout value.

You want to check for threshholds by mathematically adjusting the
background time too
into your over_bground_thresh() formula so that your understanding
holds true always and also
affects the page dirtying scenario I mentioned.
This definitely helps and refines this scenario in terms of flushing
out of the dirty pages.

Doubts:
i)   Your entire implementation seems to be dependent on someone
calling balance_dirty_pages()
     directly or indirectly. This function will call the
bdi_start_background_writeback() which wakes
     up the flusher thread.
     What about those page dirtying code paths which might not call
balance_dirty_pages ?
     Those paths then depend on the BDI thread periodically writing it
to disk and then we are again
     dependent on the writeback interval.
     Can we assume that the kernel will reliably call
balance_dirty_pages() whenever the pages
     are dirtied ? If that was true, then we would not need bdi
periodic writeback threads ever.

ii)  Even after your rigorous checking, the bdi_writeback_thread()
will still do a schedule_timeout()
     with the global value. Will your current solution then handle
Artem's disk removal scenario ?
     Else, you start using your value in the schedule_timeout() call
in the bdi_writeback_thread()
     function, which brings us back to the interval phenomenon I was
talking about.

Does this patch really help the user control exact time when the write
BIO is transferred from the
MM to the Block layer assuming balance_dirty_pages() is not called ?

Please correct me if I am wrong.

Thanks,
Kautuk.

On Fri, Aug 19, 2011 at 11:38 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> Kautuk,
>
> Here is a quick demo for bdi->dirty_background_time. Totally untested.
>
> Thanks,
> Fengguang
>
> ---
> =A0fs/fs-writeback.c =A0 =A0 =A0 =A0 =A0 | =A0 16 +++++++++++-----
> =A0include/linux/backing-dev.h | =A0 =A01 +
> =A0include/linux/writeback.h =A0 | =A0 =A01 +
> =A0mm/backing-dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 23 +++++++++++++++++++++=
++
> =A0mm/page-writeback.c =A0 =A0 =A0 =A0 | =A0 =A03 ++-
> =A05 files changed, 38 insertions(+), 6 deletions(-)
>
> --- linux-next.orig/fs/fs-writeback.c =A0 2011-08-19 13:59:41.000000000 +=
0800
> +++ linux-next/fs/fs-writeback.c =A0 =A0 =A0 =A02011-08-19 14:00:36.00000=
0000 +0800
> @@ -653,14 +653,20 @@ long writeback_inodes_wb(struct bdi_writ
> =A0 =A0 =A0 =A0return nr_pages - work.nr_pages;
> =A0}
>
> -static inline bool over_bground_thresh(void)
> +bool over_bground_thresh(struct backing_dev_info *bdi)
> =A0{
> =A0 =A0 =A0 =A0unsigned long background_thresh, dirty_thresh;
>
> =A0 =A0 =A0 =A0global_dirty_limits(&background_thresh, &dirty_thresh);
>
> - =A0 =A0 =A0 return (global_page_state(NR_FILE_DIRTY) +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_page_state(NR_UNSTABLE_NFS) > backgr=
ound_thresh);
> + =A0 =A0 =A0 if (global_page_state(NR_FILE_DIRTY) +
> + =A0 =A0 =A0 =A0 =A0 global_page_state(NR_UNSTABLE_NFS) > background_thr=
esh)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> +
> + =A0 =A0 =A0 background_thresh =3D bdi->avg_write_bandwidth *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (u64)bdi->dirty_background_time / 1000;
> +
> + =A0 =A0 =A0 return bdi_stat(bdi, BDI_RECLAIMABLE) > background_thresh;
> =A0}
>
> =A0/*
> @@ -722,7 +728,7 @@ static long wb_writeback(struct bdi_writ
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * For background writeout, stop when we a=
re below the
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * background dirty threshold
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (work->for_background && !over_bground_t=
hresh())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (work->for_background && !over_bground_t=
hresh(wb->bdi))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (work->for_kupdate) {
> @@ -806,7 +812,7 @@ static unsigned long get_nr_dirty_pages(
>
> =A0static long wb_check_background_flush(struct bdi_writeback *wb)
> =A0{
> - =A0 =A0 =A0 if (over_bground_thresh()) {
> + =A0 =A0 =A0 if (over_bground_thresh(wb->bdi)) {
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct wb_writeback_work work =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nr_pages =A0 =A0 =A0 =3D =
LONG_MAX,
> --- linux-next.orig/include/linux/backing-dev.h 2011-08-19 13:59:41.00000=
0000 +0800
> +++ linux-next/include/linux/backing-dev.h =A0 =A0 =A02011-08-19 14:00:07=
.000000000 +0800
> @@ -91,6 +91,7 @@ struct backing_dev_info {
>
> =A0 =A0 =A0 =A0unsigned int min_ratio;
> =A0 =A0 =A0 =A0unsigned int max_ratio, max_prop_frac;
> + =A0 =A0 =A0 unsigned int dirty_background_time;
>
> =A0 =A0 =A0 =A0struct bdi_writeback wb; =A0/* default writeback info for =
this bdi */
> =A0 =A0 =A0 =A0spinlock_t wb_lock; =A0 =A0 =A0 /* protects work_list */
> --- linux-next.orig/mm/backing-dev.c =A0 =A02011-08-19 13:59:41.000000000=
 +0800
> +++ linux-next/mm/backing-dev.c 2011-08-19 14:03:15.000000000 +0800
> @@ -225,12 +225,33 @@ static ssize_t max_ratio_store(struct de
> =A0}
> =A0BDI_SHOW(max_ratio, bdi->max_ratio)
>
> +static ssize_t dirty_background_time_store(struct device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_attribute *attr, const char *=
buf, size_t count)
> +{
> + =A0 =A0 =A0 struct backing_dev_info *bdi =3D dev_get_drvdata(dev);
> + =A0 =A0 =A0 char *end;
> + =A0 =A0 =A0 unsigned int ms;
> + =A0 =A0 =A0 ssize_t ret =3D -EINVAL;
> +
> + =A0 =A0 =A0 ms =3D simple_strtoul(buf, &end, 10);
> + =A0 =A0 =A0 if (*buf && (end[0] =3D=3D '\0' || (end[0] =3D=3D '\n' && e=
nd[1] =3D=3D '\0'))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_background_time =3D ms;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D count;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (over_bground_thresh(bdi))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_start_background_writeb=
ack(bdi);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return ret;
> +}
> +BDI_SHOW(dirty_background_time, bdi->dirty_background_time)
> +
> =A0#define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
>
> =A0static struct device_attribute bdi_dev_attrs[] =3D {
> =A0 =A0 =A0 =A0__ATTR_RW(read_ahead_kb),
> =A0 =A0 =A0 =A0__ATTR_RW(min_ratio),
> =A0 =A0 =A0 =A0__ATTR_RW(max_ratio),
> + =A0 =A0 =A0 __ATTR_RW(dirty_background_time),
> =A0 =A0 =A0 =A0__ATTR_NULL,
> =A0};
>
> @@ -657,6 +678,8 @@ int bdi_init(struct backing_dev_info *bd
> =A0 =A0 =A0 =A0bdi->min_ratio =3D 0;
> =A0 =A0 =A0 =A0bdi->max_ratio =3D 100;
> =A0 =A0 =A0 =A0bdi->max_prop_frac =3D PROP_FRAC_BASE;
> + =A0 =A0 =A0 bdi->dirty_background_time =3D 10000;
> +
> =A0 =A0 =A0 =A0spin_lock_init(&bdi->wb_lock);
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&bdi->bdi_list);
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&bdi->work_list);
> --- linux-next.orig/mm/page-writeback.c 2011-08-19 14:00:07.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =A0 =A0 =A02011-08-19 14:00:07.0000000=
00 +0800
> @@ -1163,7 +1163,8 @@ pause:
> =A0 =A0 =A0 =A0if (laptop_mode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 if (nr_reclaimable > background_thresh)
> + =A0 =A0 =A0 if (nr_reclaimable > background_thresh ||
> + =A0 =A0 =A0 =A0 =A0 over_bground_thresh(bdi))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_start_background_writeback(bdi);
> =A0}
>
> --- linux-next.orig/include/linux/writeback.h =A0 2011-08-19 14:00:41.000=
000000 +0800
> +++ linux-next/include/linux/writeback.h =A0 =A0 =A0 =A02011-08-19 14:01:=
19.000000000 +0800
> @@ -132,6 +132,7 @@ extern int block_dump;
> =A0extern int laptop_mode;
>
> =A0extern unsigned long determine_dirtyable_memory(void);
> +extern bool over_bground_thresh(struct backing_dev_info *bdi);
>
> =A0extern int dirty_background_ratio_handler(struct ctl_table *table, int=
 write,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void __user *buffer, size_t *lenp,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
