Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9596A900086
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 01:35:54 -0400 (EDT)
Received: by iyh42 with SMTP id 42so6738241iyh.14
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 22:35:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=h5DUL1k-31WDP3KfjmiNR8FTckQ@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-2-git-send-email-yinghan@google.com>
	<BANLkTikgoSt4VUY63J+G6mUJJDCL+NWH8Q@mail.gmail.com>
	<BANLkTi=h5DUL1k-31WDP3KfjmiNR8FTckQ@mail.gmail.com>
Date: Tue, 19 Apr 2011 14:35:52 +0900
Message-ID: <BANLkTikDxjBEbQ1KbFzS3MOHa4P4forN3Q@mail.gmail.com>
Subject: Re: [PATCH V5 01/10] Add kswapd descriptor
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, Apr 19, 2011 at 3:09 AM, Ying Han <yinghan@google.com> wrote:
>
>
> On Sun, Apr 17, 2011 at 5:57 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>>
>> Hi Ying,
>>
>> I have some comments and nitpick about coding style.
>
> Hi Minchan, thank you for your comments and reviews.
>>
>> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
>> > There is a kswapd kernel thread for each numa node. We will add a
>> > different
>> > kswapd for each memcg. The kswapd is sleeping in the wait queue headed
>> > at
>>
>> Why?
>>
>> Easily, many kernel developers raise an eyebrow to increase kernel threa=
d.
>> So you should justify why we need new kernel thread, why we can't
>> handle it with workqueue.
>>
>> Maybe you explained it and I didn't know it. If it is, sorry.
>> But at least, the patch description included _why_ is much mergeable
>> to maintainers and helpful to review the code to reviewers.
>
> Here are the replies i posted on earlier version regarding on workqueue.
> "
> I did some study on=C2=A0workqueue=C2=A0after posting V2. There was a
> comment=C2=A0suggesting=C2=A0workqueue=C2=A0instead of per-memcg kswapd t=
hread, since it
> will cut the number of kernel threads being created in host with lots of
> cgroups. Each kernel thread allocates about 8K of stack and 8M in total w=
/
> thousand of cgroups.
> The current=C2=A0workqueue=C2=A0model merged in 2.6.36 kernel is called "=
concurrency
> managed workqueu(cmwq)", which is intended to provide flexible concurrenc=
y
> without wasting resources. I studied a bit and here it is:
>
> 1. The=C2=A0workqueue=C2=A0is complicated and we need to be very careful =
of=C2=A0work=C2=A0items
> in the=C2=A0workqueue. We've experienced in one workitem stucks and the r=
est of
> the=C2=A0work=C2=A0item won't proceed. For example in dirty page writebac=
k, =C2=A0one
> heavily writer cgroup could starve the other cgroups from flushing dirty
> pages to the same disk. In the kswapd case, I can image we might have
> similar scenario.
>
> 2. How to prioritize the workitems is another problem. The order of addin=
g
> the workitems in the=C2=A0queue=C2=A0reflects the order of cgroups being =
reclaimed. We
> don't have that restriction currently but relying on the cpu scheduler to
> put kswapd on the right cpu-core to run. We "might" introduce priority la=
ter
> for reclaim and how are we gonna deal with that.
>
> 3. Based on what i observed, not many callers has migrated to the cmwq an=
d I
> don't have much data of how good it is.
> Back to the current model, on machine with thousands of cgroups which it
> will take 8M total for thousand of kswapd threads (8K stack for each
> thread). =C2=A0We are running system with fakenuma which each numa node h=
as a
> kswapd. So far we haven't noticed issue caused by "lots of"=C2=A0kswapd t=
hreads.
> Also, there shouldn't be any performance overhead for kernel thread if it=
 is
> not running.
>
> Based on the complexity of=C2=A0workqueue=C2=A0and the benefit it provide=
s, I would
> like to stick to the current model first. After we get the basic stuff in
> and other=C2=A0targeting=C2=A0reclaim improvement, we can come back to th=
is. What do
> you think?

Thanks for the good summary. I should study cmwq, too but I don't mean
we have to use only workqueue.

The problem of memcg-kswapd flooding is the lock, schedule overhead,
pid consumption as well as memory consumption and it is not good at
keeping the kswapd busy.
I don't think we have to keep the number of kswapd as much as memcg.

We can just keep memcg-kswapd min/max pool like old pdflush.
As memcg wmark pressure is high and memcg-kswapd is busy, new
memcg-kswapd will pop up to handle it.
As memcg wmark pressure is low and memcg-kswapd is idle, old
memcg-kswapd will be exited.

> "
> KAMEZAWA's reply:
> "
> Okay, fair enough. kthread_run() will win.
>
> Then, I have another request. I'd like to kswapd-for-memcg to some cpu
> cgroup to limit cpu usage.
>
> - Could you show thread ID somewhere ? and
> =C2=A0confirm we can put it to some cpu cgroup ?
> =C2=A0(creating a auto cpu cgroup for memcg kswapd is a choice, I think.)
> "
>>
>> > kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
>> > information of node or memcg and it allows the global and per-memcg
>> > background
>> > reclaim to share common reclaim algorithms.
>> >
>> > This patch adds the kswapd descriptor and moves the per-node kswapd to
>> > use the
>> > new structure.
>> >
>> > changelog v5..v4:
>> > 1. add comment on kswapds_spinlock
>> > 2. remove the kswapds_spinlock. we don't need it here since the kswapd
>> > and pgdat
>> > have 1:1 mapping.
>> >
>> > changelog v3..v2:
>> > 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later
>> > patch.
>> > 2. rename thr in kswapd_run to something else.
>> >
>> > changelog v2..v1:
>> > 1. dynamic allocate kswapd descriptor and initialize the wait_queue_he=
ad
>> > of pgdat
>> > at kswapd_run.
>> > 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup
>> > kswapd
>> > descriptor.
>> >
>> > Signed-off-by: Ying Han <yinghan@google.com>
>> > ---
>> > =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A03 +-
>> > =C2=A0include/linux/swap.h =C2=A0 | =C2=A0 =C2=A07 ++++
>> > =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 -
>> > =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 89
>> > +++++++++++++++++++++++++++++++++++------------
>> > =C2=A04 files changed, 74 insertions(+), 26 deletions(-)
>> >
>> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> > index 628f07b..6cba7d2 100644
>> > --- a/include/linux/mmzone.h
>> > +++ b/include/linux/mmzone.h
>> > @@ -640,8 +640,7 @@ typedef struct pglist_data {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long node_spanned_pages; /* total =
size of physical page
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 range, including holes */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int node_id;
>> > - =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t kswapd_wait;
>> > - =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd;
>> > + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *kswapd_wait;
>>
>> Personally, I prefer kswapd not kswapd_wait.
>> It's more readable and straightforward.
>
> hmm. I would like to keep as it is for this version, and improve it after
> the basic stuff are in. Hope that works for you?

No problem.

>>
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int kswapd_max_order;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0enum zone_type classzone_idx;
>> > =C2=A0} pg_data_t;
>> > diff --git a/include/linux/swap.h b/include/linux/swap.h
>> > index ed6ebe6..f43d406 100644
>> > --- a/include/linux/swap.h
>> > +++ b/include/linux/swap.h
>> > @@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return current->flags & PF_KSWAPD;
>> > =C2=A0}
>> >
>> > +struct kswapd {
>> > + =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd_task;
>> > + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t kswapd_wait;
>> > + =C2=A0 =C2=A0 =C2=A0 pg_data_t *kswapd_pgdat;
>> > +};
>> > +
>> > +int kswapd(void *p);
>> > =C2=A0/*
>> > =C2=A0* MAX_SWAPFILES defines the maximum number of swaptypes: things =
which
>> > can
>> > =C2=A0* be swapped to. =C2=A0The swap type and the offset into that sw=
ap type are
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index 6e1b52a..6340865 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -4205,7 +4205,6 @@ static void __paginginit
>> > free_area_init_core(struct pglist_data *pgdat,
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat_resize_init(pgdat);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat->nr_zones =3D 0;
>> > - =C2=A0 =C2=A0 =C2=A0 init_waitqueue_head(&pgdat->kswapd_wait);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat->kswapd_max_order =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat_page_cgroup_init(pgdat);
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 060e4c1..61fb96e 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2242,12 +2242,13 @@ static bool pgdat_balanced(pg_data_t *pgdat,
>> > unsigned long balanced_pages,
>> > =C2=A0}
>> >
>> > =C2=A0/* is kswapd sleeping prematurely? */
>> > -static bool sleeping_prematurely(pg_data_t *pgdat, int order, long
>> > remaining,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int clas=
szone_idx)
>> > +static int sleeping_prematurely(struct kswapd *kswapd, int order,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 long remaining, int classzone_idx)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long balanced =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0bool all_zones_ok =3D true;
>> > + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D kswapd->kswapd_pgdat;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If a direct reclaimer woke kswapd within=
 HZ/10, it's premature
>> > */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (remaining)
>> > @@ -2570,28 +2571,31 @@ out:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return order;
>> > =C2=A0}
>> >
>> > -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int
>> > classzone_idx)
>> > +static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int classzone_idx)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0long remaining =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0DEFINE_WAIT(wait);
>> > + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D kswapd_p->kswapd_pgdat;
>> > + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *wait_h =3D &kswapd_p->kswapd=
_wait;
>>
>> kswapd_p? p means pointer?
>
> yes,
>>
>> wait_h? h means header?
>
> =C2=A0yes,
>>
>> Hmm.. Of course, it's trivial and we can understand easily in such
>> context but we don't have been used such words so it's rather awkward
>> to me.
>>
>> How about kswapd instead of kswapd_p, kswapd_wait instead of wait_h?
>
> that sounds ok for me for the change. however i would like to make the
> change as sperate patch after the basic stuff are in. Is that ok?

Sure. It's not critical to merge the series. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
