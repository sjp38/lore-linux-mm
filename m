Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D2C9E6B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 21:50:59 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p581othZ012376
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:50:55 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by wpaz29.hot.corp.google.com with ESMTP id p581ostG016949
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:50:54 -0700
Received: by qwf7 with SMTP id 7so19488qwf.38
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 18:50:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110608090132.ef9ccb91.kamezawa.hiroyu@jp.fujitsu.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-11-git-send-email-gthelen@google.com> <20110607175056.83619c5f.kamezawa.hiroyu@jp.fujitsu.com>
 <xr93tyc1ws4n.fsf@gthelen.mtv.corp.google.com> <20110608090132.ef9ccb91.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 7 Jun 2011 18:50:34 -0700
Message-ID: <BANLkTinfZf=JP55=SNthKKecnMQygkz9Wg@mail.gmail.com>
Subject: Re: [PATCH v8 10/12] memcg: create support routines for page-writeback
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Tue, Jun 7, 2011 at 5:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 07 Jun 2011 08:58:16 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>>
>> > On Fri, =A03 Jun 2011 09:12:16 -0700
>> > Greg Thelen <gthelen@google.com> wrote:
>> >
>> >> Introduce memcg routines to assist in per-memcg dirty page management=
:
>> >>
>> >> - mem_cgroup_balance_dirty_pages() walks a memcg hierarchy comparing
>> >> =A0 dirty memory usage against memcg foreground and background thresh=
olds.
>> >> =A0 If an over-background-threshold memcg is found, then per-memcg
>> >> =A0 background writeback is queued. =A0Per-memcg writeback differs fr=
om
>> >> =A0 classic, non-memcg, per bdi writeback by setting the new
>> >> =A0 writeback_control.for_cgroup bit.
>> >>
>> >> =A0 If an over-foreground-threshold memcg is found, then foreground
>> >> =A0 writeout occurs. =A0When performing foreground writeout, first co=
nsider
>> >> =A0 inodes exclusive to the memcg. =A0If unable to make enough progre=
ss,
>> >> =A0 then consider inodes shared between memcg. =A0Such cross-memcg in=
ode
>> >> =A0 sharing likely to be rare in situations that use per-cgroup memor=
y
>> >> =A0 isolation. =A0The approach tries to handle the common (non-shared=
)
>> >> =A0 case well without punishing well behaved (non-sharing) cgroups.
>> >> =A0 As a last resort writeback shared inodes.
>> >>
>> >> =A0 This routine is used by balance_dirty_pages() in a later change.
>> >>
>> >> - mem_cgroup_hierarchical_dirty_info() returns the dirty memory usage
>> >> =A0 and limits of the memcg closest to (or over) its dirty limit. =A0=
This
>> >> =A0 will be used by throttle_vm_writeout() in a latter change.
>> >>
>> >> Signed-off-by: Greg Thelen <gthelen@google.com>
>> >> ---
>> >> Changelog since v7:
>> >> - Add more detail to commit description.
>> >>
>> >> - Declare the new writeback_control for_cgroup bit in this change, th=
e
>> >> =A0 first patch that uses the new field is first used. =A0In -v7 the =
field
>> >> =A0 was declared in a separate patch.
>> >>
>> >> =A0include/linux/memcontrol.h =A0 =A0 =A0 =A0| =A0 18 +++++
>> >> =A0include/linux/writeback.h =A0 =A0 =A0 =A0 | =A0 =A01 +
>> >> =A0include/trace/events/memcontrol.h | =A0 83 ++++++++++++++++++++
>> >> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0150 +++++=
++++++++++++++++++++++++++++++++
>> >> =A04 files changed, 252 insertions(+), 0 deletions(-)
>> >>
>> >> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> >> index 3d72e09..0d0363e 100644
>> >> --- a/include/linux/memcontrol.h
>> >> +++ b/include/linux/memcontrol.h
>> >> @@ -167,6 +167,11 @@ bool should_writeback_mem_cgroup_inode(struct in=
ode *inode,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s=
truct writeback_control *wbc);
>> >> =A0bool mem_cgroups_over_bground_dirty_thresh(void);
>> >> =A0void mem_cgroup_writeback_done(void);
>> >> +bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_=
mem,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct mem_cgroup *mem,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct dirty_info *info);
>> >> +void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned=
 long write_chunk);
>> >>
>> >> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int=
 order,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0gfp_t gfp_mask,
>> >> @@ -383,6 +388,19 @@ static inline void mem_cgroup_writeback_done(voi=
d)
>> >> =A0{
>> >> =A0}
>> >>
>> >> +static inline void mem_cgroup_balance_dirty_pages(struct address_spa=
ce *mapping,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0unsigned long write_chunk)
>> >> +{
>> >> +}
>> >> +
>> >> +static inline bool
>> >> +mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup *mem,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dirt=
y_info *info)
>> >> +{
>> >> + =A0return false;
>> >> +}
>> >> +
>> >> =A0static inline
>> >> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int=
 order,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0gfp_t gfp_mask,
>> >> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> >> index 66ec339..4f5c0d2 100644
>> >> --- a/include/linux/writeback.h
>> >> +++ b/include/linux/writeback.h
>> >> @@ -47,6 +47,7 @@ struct writeback_control {
>> >> =A0 =A0unsigned for_reclaim:1; =A0 =A0 =A0 =A0 /* Invoked from the pa=
ge allocator */
>> >> =A0 =A0unsigned range_cyclic:1; =A0 =A0 =A0 =A0/* range_start is cycl=
ic */
>> >> =A0 =A0unsigned more_io:1; =A0 =A0 =A0 =A0 =A0 =A0 /* more io to be d=
ispatched */
>> >> + =A0unsigned for_cgroup:1; =A0 =A0 =A0 =A0 =A0/* enable cgroup write=
back */
>> >> =A0 =A0unsigned shared_inodes:1; =A0 =A0 =A0 /* write inodes spanning=
 cgroups */
>> >> =A0};
>> >>
>> >> diff --git a/include/trace/events/memcontrol.h b/include/trace/events=
/memcontrol.h
>> >> index 326a66b..b42dae1 100644
>> >> --- a/include/trace/events/memcontrol.h
>> >> +++ b/include/trace/events/memcontrol.h
>> >> @@ -109,6 +109,89 @@ TRACE_EVENT(mem_cgroups_over_bground_dirty_thres=
h,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->first_id)
>> >> =A0)
>> >>
>> >> +DECLARE_EVENT_CLASS(mem_cgroup_consider_writeback,
>> >> + =A0TP_PROTO(unsigned short css_id,
>> >> + =A0 =A0 =A0 =A0 =A0 struct backing_dev_info *bdi,
>> >> + =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimable,
>> >> + =A0 =A0 =A0 =A0 =A0 unsigned long thresh,
>> >> + =A0 =A0 =A0 =A0 =A0 bool over_limit),
>> >> +
>> >> + =A0TP_ARGS(css_id, bdi, nr_reclaimable, thresh, over_limit),
>> >> +
>> >> + =A0TP_STRUCT__entry(
>> >> + =A0 =A0 =A0 =A0 =A0__field(unsigned short, css_id)
>> >> + =A0 =A0 =A0 =A0 =A0__field(struct backing_dev_info *, bdi)
>> >> + =A0 =A0 =A0 =A0 =A0__field(unsigned long, nr_reclaimable)
>> >> + =A0 =A0 =A0 =A0 =A0__field(unsigned long, thresh)
>> >> + =A0 =A0 =A0 =A0 =A0__field(bool, over_limit)
>> >> + =A0),
>> >> +
>> >> + =A0TP_fast_assign(
>> >> + =A0 =A0 =A0 =A0 =A0__entry->css_id =3D css_id;
>> >> + =A0 =A0 =A0 =A0 =A0__entry->bdi =3D bdi;
>> >> + =A0 =A0 =A0 =A0 =A0__entry->nr_reclaimable =3D nr_reclaimable;
>> >> + =A0 =A0 =A0 =A0 =A0__entry->thresh =3D thresh;
>> >> + =A0 =A0 =A0 =A0 =A0__entry->over_limit =3D over_limit;
>> >> + =A0),
>> >> +
>> >> + =A0TP_printk("css_id=3D%d bdi=3D%p nr_reclaimable=3D%ld thresh=3D%l=
d "
>> >> + =A0 =A0 =A0 =A0 =A0 =A0"over_limit=3D%d", __entry->css_id, __entry-=
>bdi,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0__entry->nr_reclaimable, __entry->thresh, __=
entry->over_limit)
>> >> +)
>> >> +
>> >> +#define DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(name) \
>> >> +DEFINE_EVENT(mem_cgroup_consider_writeback, name, \
>> >> + =A0TP_PROTO(unsigned short id, \
>> >> + =A0 =A0 =A0 =A0 =A0 struct backing_dev_info *bdi, \
>> >> + =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimable, \
>> >> + =A0 =A0 =A0 =A0 =A0 unsigned long thresh, \
>> >> + =A0 =A0 =A0 =A0 =A0 bool over_limit), \
>> >> + =A0TP_ARGS(id, bdi, nr_reclaimable, thresh, over_limit) \
>> >> +)
>> >> +
>> >> +DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(mem_cgroup_consider_bg_wr=
iteback);
>> >> +DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(mem_cgroup_consider_fg_wr=
iteback);
>> >> +
>> >> +TRACE_EVENT(mem_cgroup_fg_writeback,
>> >> + =A0TP_PROTO(unsigned long write_chunk,
>> >> + =A0 =A0 =A0 =A0 =A0 struct writeback_control *wbc),
>> >> +
>> >> + =A0TP_ARGS(write_chunk, wbc),
>> >> +
>> >> + =A0TP_STRUCT__entry(
>> >> + =A0 =A0 =A0 =A0 =A0__field(unsigned long, write_chunk)
>> >> + =A0 =A0 =A0 =A0 =A0__field(long, wbc_to_write)
>> >> + =A0 =A0 =A0 =A0 =A0__field(bool, shared_inodes)
>> >> + =A0),
>> >> +
>> >> + =A0TP_fast_assign(
>> >> + =A0 =A0 =A0 =A0 =A0__entry->write_chunk =3D write_chunk;
>> >> + =A0 =A0 =A0 =A0 =A0__entry->wbc_to_write =3D wbc->nr_to_write;
>> >> + =A0 =A0 =A0 =A0 =A0__entry->shared_inodes =3D wbc->shared_inodes;
>> >> + =A0),
>> >> +
>> >> + =A0TP_printk("write_chunk=3D%ld nr_to_write=3D%ld shared_inodes=3D%=
d",
>> >> + =A0 =A0 =A0 =A0 =A0 =A0__entry->write_chunk,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0__entry->wbc_to_write,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0__entry->shared_inodes)
>> >> +)
>> >> +
>> >> +TRACE_EVENT(mem_cgroup_enable_shared_writeback,
>> >> + =A0TP_PROTO(unsigned short css_id),
>> >> +
>> >> + =A0TP_ARGS(css_id),
>> >> +
>> >> + =A0TP_STRUCT__entry(
>> >> + =A0 =A0 =A0 =A0 =A0__field(unsigned short, css_id)
>> >> + =A0 =A0 =A0 =A0 =A0),
>> >> +
>> >> + =A0TP_fast_assign(
>> >> + =A0 =A0 =A0 =A0 =A0__entry->css_id =3D css_id;
>> >> + =A0 =A0 =A0 =A0 =A0),
>> >> +
>> >> + =A0TP_printk("enabling shared writeback for memcg %d", __entry->css=
_id)
>> >> +)
>> >> +
>> >> =A0#endif /* _TRACE_MEMCONTROL_H */
>> >>
>> >> =A0/* This part must be outside protection */
>> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> >> index a5b1794..17cb888 100644
>> >> --- a/mm/memcontrol.c
>> >> +++ b/mm/memcontrol.c
>> >> @@ -1622,6 +1622,156 @@ void mem_cgroup_writeback_done(void)
>> >> =A0 =A0}
>> >> =A0}
>> >>
>> >> +/*
>> >> + * This routine must be called by processes which are generating dir=
ty pages.
>> >> + * It considers the dirty pages usage and thresholds of the current =
cgroup and
>> >> + * (depending if hierarchical accounting is enabled) ancestral memcg=
. =A0If any of
>> >> + * the considered memcg are over their background dirty limit, then =
background
>> >> + * writeback is queued. =A0If any are over the foreground dirty limi=
t then
>> >> + * throttle the dirtying task while writing dirty data. =A0The per-m=
emcg dirty
>> >> + * limits check by this routine are distinct from either the per-sys=
tem,
>> >> + * per-bdi, or per-task limits considered by balance_dirty_pages().
>> >> + */
>> >> +void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned=
 long write_chunk)
>> >> +{
>> >> + =A0struct backing_dev_info *bdi =3D mapping->backing_dev_info;
>> >> + =A0struct mem_cgroup *mem;
>> >> + =A0struct mem_cgroup *ref_mem;
>> >> + =A0struct dirty_info info;
>> >> + =A0unsigned long nr_reclaimable;
>> >> + =A0unsigned long sys_available_mem;
>> >> + =A0unsigned long pause =3D 1;
>> >> + =A0unsigned short id;
>> >> + =A0bool over;
>> >> + =A0bool shared_inodes;
>> >> +
>> >> + =A0if (mem_cgroup_disabled())
>> >> + =A0 =A0 =A0 =A0 =A0return;
>> >> +
>> >> + =A0sys_available_mem =3D determine_dirtyable_memory();
>> >> +
>> >> + =A0/* reference the memcg so it is not deleted during this routine =
*/
>> >> + =A0rcu_read_lock();
>> >> + =A0mem =3D mem_cgroup_from_task(current);
>> >> + =A0if (mem && mem_cgroup_is_root(mem))
>> >> + =A0 =A0 =A0 =A0 =A0mem =3D NULL;
>> >> + =A0if (mem)
>> >> + =A0 =A0 =A0 =A0 =A0css_get(&mem->css);
>> >> + =A0rcu_read_unlock();
>> >> + =A0ref_mem =3D mem;
>> >> +
>> >> + =A0/* balance entire ancestry of current's mem. */
>> >> + =A0for (; mem_cgroup_has_dirty_limit(mem); mem =3D parent_mem_cgrou=
p(mem)) {
>> >> + =A0 =A0 =A0 =A0 =A0id =3D css_id(&mem->css);
>> >> +
>> >
>> > Hmm, this sounds natural...but...don't we need to restart checking fro=
m ref_mem's
>> > dirty_ratio once we find an ancestor is over dirty_ratio and we slept =
?
>> >
>> > Even if parent's dirty ratio comes to be clean state, children's may n=
ot.
>> > So, I think some "restart loop" jump after io_schedule_timeout().
>> >
>> > Thanks,
>> > -Kame
>>
>> I do not think that we need to restart, but maybe you have a case in
>> mind that I am not considering.
>>
>> Example hierarchy:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 root
>> =A0 =A0 =A0 =A0 =A0A =A0 =A0 =A0 =A0 =A0 =A0B
>> =A0 =A0 =A0A1 =A0 =A0 =A0A2
>> =A0 A11 A12 =A0A21 A22
>>
>> Assume that mem_cgroup_balance_dirty_pages(A11), so ref_mem=3DA11.
>>
>> We start at A11 and walk up towards the root. =A0If A11 is over limit,
>> then write A11 until under limit. =A0Next check A1, if over limit then
>> write A1,A11,A12. =A0Then check A. =A0If A is over A limit, then we invo=
ke
>> writeback on A* until A is under A limit. =A0Are you concerned that whil=
e
>> performing writeback on A* that other tasks may push A1 over the A1
>> limit? =A0Such other task writers would also be calling
>> mem_cgroup_balance_dirty_pages() later.
>>
>
> Hm, ok. Could you add comments to explain the algorithm ?
>
> Thanks,
> -Kame

No problem.  I will add comments to this routine in -v9 to clarify.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
