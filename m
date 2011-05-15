Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECD36B0011
	for <linux-mm@kvack.org>; Sun, 15 May 2011 15:56:25 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p4FJuLql003334
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:56:22 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by wpaz5.hot.corp.google.com with ESMTP id p4FJuKZl008830
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:56:20 -0700
Received: by qwb7 with SMTP id 7so2248738qwb.12
        for <linux-mm@kvack.org>; Sun, 15 May 2011 12:56:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513185612.84b466ec.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
 <1305276473-14780-11-git-send-email-gthelen@google.com> <20110513185612.84b466ec.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Sun, 15 May 2011 12:56:00 -0700
Message-ID: <BANLkTin6_CiP-Q8MyN=PKhpUhGhdmUQyEA@mail.gmail.com>
Subject: Re: [RFC][PATCH v7 10/14] memcg: dirty page accounting support routines
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, May 13, 2011 at 2:56 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 13 May 2011 01:47:49 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Added memcg dirty page accounting support routines. =A0These routines ar=
e
>> used by later changes to provide memcg aware writeback and dirty page
>> limiting. =A0A mem_cgroup_dirty_info() tracepoint is is also included to
>> allow for easier understanding of memcg writeback operation.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> with small nit..(see below)
>
>
>> ---
>> =A0include/linux/memcontrol.h =A0 =A0 =A0 =A0| =A0 =A09 +++
>> =A0include/trace/events/memcontrol.h | =A0 34 +++++++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0145 ++++++++=
+++++++++++++++++++++++++++++
>> =A03 files changed, 188 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index f1261e5..f06c2de 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -36,6 +36,15 @@ enum mem_cgroup_page_stat_item {
>> =A0 =A0 =A0 MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
>> =A0 =A0 =A0 MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
>> =A0 =A0 =A0 MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
>> + =A0 =A0 MEMCG_NR_DIRTYABLE_PAGES, /* # of pages that could be dirty */
>> +};
>> +
>> +struct dirty_info {
>> + =A0 =A0 unsigned long dirty_thresh;
>> + =A0 =A0 unsigned long background_thresh;
>> + =A0 =A0 unsigned long nr_file_dirty;
>> + =A0 =A0 unsigned long nr_writeback;
>> + =A0 =A0 unsigned long nr_unstable_nfs;
>> =A0};
>>
>> =A0extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_sca=
n,
>> diff --git a/include/trace/events/memcontrol.h b/include/trace/events/me=
mcontrol.h
>> index 781ef9fc..abf1306 100644
>> --- a/include/trace/events/memcontrol.h
>> +++ b/include/trace/events/memcontrol.h
>> @@ -26,6 +26,40 @@ TRACE_EVENT(mem_cgroup_mark_inode_dirty,
>> =A0 =A0 =A0 TP_printk("ino=3D%ld css_id=3D%d", __entry->ino, __entry->cs=
s_id)
>> =A0)
>>
>> +TRACE_EVENT(mem_cgroup_dirty_info,
>> + =A0 =A0 TP_PROTO(unsigned short css_id,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0struct dirty_info *dirty_info),
>> +
>> + =A0 =A0 TP_ARGS(css_id, dirty_info),
>> +
>> + =A0 =A0 TP_STRUCT__entry(
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned short, css_id)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, dirty_thresh)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, background_thresh)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, nr_file_dirty)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, nr_writeback)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, nr_unstable_nfs)
>> + =A0 =A0 =A0 =A0 =A0 =A0 ),
>> +
>> + =A0 =A0 TP_fast_assign(
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->css_id =3D css_id;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->dirty_thresh =3D dirty_info->dirty_th=
resh;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->background_thresh =3D dirty_info->bac=
kground_thresh;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_file_dirty =3D dirty_info->nr_file=
_dirty;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_writeback =3D dirty_info->nr_write=
back;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_unstable_nfs =3D dirty_info->nr_un=
stable_nfs;
>> + =A0 =A0 =A0 =A0 =A0 =A0 ),
>> +
>> + =A0 =A0 TP_printk("css_id=3D%d thresh=3D%ld bg_thresh=3D%ld dirty=3D%l=
d wb=3D%ld "
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "unstable_nfs=3D%ld",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->css_id,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->dirty_thresh,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->background_thresh,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_file_dirty,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_writeback,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_unstable_nfs)
>> +)
>> +
>> =A0#endif /* _TRACE_MEMCONTROL_H */
>>
>> =A0/* This part must be outside protection */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 248396c..75ef32c 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1328,6 +1328,11 @@ static unsigned int get_swappiness(struct mem_cgr=
oup *memcg)
>> =A0 =A0 =A0 return memcg->swappiness;
>> =A0}
>>
>> +static unsigned long dirty_info_reclaimable(struct dirty_info *info)
>> +{
>> + =A0 =A0 return info->nr_file_dirty + info->nr_unstable_nfs;
>> +}
>> +
>> =A0/*
>> =A0 * Return true if the current memory cgroup has local dirty memory se=
ttings.
>> =A0 * There is an allowed race between the current task migrating in-to/=
out-of the
>> @@ -1358,6 +1363,146 @@ static void mem_cgroup_dirty_param(struct vm_dir=
ty_param *param,
>> =A0 =A0 =A0 }
>> =A0}
>>
>> +static inline bool mem_cgroup_can_swap(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (!do_swap_account)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return nr_swap_pages > 0;
>> + =A0 =A0 return !mem->memsw_is_minimum &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 (res_counter_read_u64(&mem->memsw, RES_LIMIT) =
> 0);
>> +}
>> +
>> +static s64 mem_cgroup_local_page_stat(struct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 en=
um mem_cgroup_page_stat_item item)
>> +{
>> + =A0 =A0 s64 ret;
>> +
>> + =A0 =A0 switch (item) {
>> + =A0 =A0 case MEMCG_NR_FILE_DIRTY:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(mem, MEM_CGROUP_S=
TAT_FILE_DIRTY);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 case MEMCG_NR_FILE_WRITEBACK:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(mem, MEM_CGROUP_S=
TAT_FILE_WRITEBACK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 case MEMCG_NR_FILE_UNSTABLE_NFS:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 case MEMCG_NR_DIRTYABLE_PAGES:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(mem, LRU_ACTIVE_F=
ILE) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_read_stat(mem, LRU_=
INACTIVE_FILE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_can_swap(mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D mem_cgroup_read_stat(=
mem, LRU_ACTIVE_ANON) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rea=
d_stat(mem, LRU_INACTIVE_ANON);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 }
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/*
>> + * Return the number of additional pages that the @mem cgroup could all=
ocate.
>> + * If use_hierarchy is set, then this involves checking parent mem cgro=
ups to
>> + * find the cgroup with the smallest free space.
>> + */
>> +static unsigned long
>> +mem_cgroup_hierarchical_free_pages(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 u64 free;
>> + =A0 =A0 unsigned long min_free;
>> +
>> + =A0 =A0 min_free =3D global_page_state(NR_FREE_PAGES);
>> +
>> + =A0 =A0 while (mem) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 free =3D (res_counter_read_u64(&mem->res, RES_=
LIMIT) -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&mem->res=
, RES_USAGE)) >>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PAGE_SHIFT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 min_free =3D min((u64)min_free, free);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem =3D parent_mem_cgroup(mem);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return min_free;
>> +}
>> +
>> +/*
>> + * mem_cgroup_page_stat() - get memory cgroup file cache statistics
>> + * @mem: =A0 =A0 =A0 memory cgroup to query
>> + * @item: =A0 =A0 =A0memory statistic item exported to the kernel
>> + *
>> + * Return the accounted statistic value.
>> + */
>> +static unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 enum mem_cgroup_page_stat_item item)
>
> How about mem_cgroup_file_cache_stat() ?

The suggested rename is possible.  But for consistency I assume we
would also want to rename:
* mem_cgroup_local_page_stat()
* enum mem_cgroup_page_stat_item
* mem_cgroup_update_page_stat()
* mem_cgroup_move_account_page_stat()

I have a slight preference for leaving it as is,
mem_cgroup_page_stat(), to allow for future coverage of pages other
that just file cache pages.  But I do not feel very strongly.

>> +{
>> + =A0 =A0 struct mem_cgroup *iter;
>> + =A0 =A0 s64 value;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If we're looking for dirtyable pages we need to evaluate =
free pages
>> + =A0 =A0 =A0* depending on the limit and usage of the parents first of =
all.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (item =3D=3D MEMCG_NR_DIRTYABLE_PAGES)
>> + =A0 =A0 =A0 =A0 =A0 =A0 value =3D mem_cgroup_hierarchical_free_pages(m=
em);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 value =3D 0;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Recursively evaluate page statistics against all cgroup u=
nder
>> + =A0 =A0 =A0* hierarchy tree
>> + =A0 =A0 =A0*/
>> + =A0 =A0 for_each_mem_cgroup_tree(iter, mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 value +=3D mem_cgroup_local_page_stat(iter, it=
em);
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Summing of unlocked per-cpu counters is racy and may yiel=
d a slightly
>> + =A0 =A0 =A0* negative value. =A0Zero is the only sensible value in suc=
h cases.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (unlikely(value < 0))
>> + =A0 =A0 =A0 =A0 =A0 =A0 value =3D 0;
>> +
>> + =A0 =A0 return value;
>> +}
>
> seems very nice handling of hierarchy :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
