Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 286C56B01AC
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 01:30:17 -0400 (EDT)
Received: by pzk30 with SMTP id 30so2469912pzk.12
        for <linux-mm@kvack.org>; Sat, 27 Mar 2010 22:30:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BAB6646.7040302@cn.fujitsu.com>
References: <4B94CD2D.8070401@cn.fujitsu.com>
	 <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com>
	 <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop>
	 <4B98C6DE.3060602@cn.fujitsu.com> <20100311110317.GL5812@laptop>
	 <4BAB6646.7040302@cn.fujitsu.com>
Date: Sun, 28 Mar 2010 13:30:13 +0800
Message-ID: <cf18f8341003272230l7739c182s40191cde5c8bf4de@mail.gmail.com>
Subject: Re: [PATCH] [PATCH -mmotm] cpuset,mm: use seqlock to protect
	task->mempolicy and mems_allowed (v2) (was: Re: [PATCH V2 4/4] cpuset,mm:
	update task's mems_allowed lazily)
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 9:33 PM, Miao Xie <miaox@cn.fujitsu.com> wrote:
> on 2010-3-11 19:03, Nick Piggin wrote:
>>> Ok, I try to make a new patch by using seqlock.
>>
>> Well... I do think seqlocks would be a bit simpler because they don't
>> require this checking and synchronizing of this patch.
> Hi, Nick Piggin
>
> I have made a new patch which uses seqlock to protect mems_allowed and me=
mpolicy.
> please review it.
>
> Subject: [PATCH] [PATCH -mmotm] cpuset,mm: use seqlock to protect task->m=
empolicy and mems_allowed (v2)
>
> Before applying this patch, cpuset updates task->mems_allowed by setting =
all
> new bits in the nodemask first, and clearing all old unallowed bits later=
.
> But in the way, the allocator can see an empty nodemask, though it is inf=
requent.
>
> The problem is following:
> The size of nodemask_t is greater than the size of long integer, so loadi=
ng
> and storing of nodemask_t are not atomic operations. If task->mems_allowe=
d
> don't intersect with new_mask, such as the first word of the mask is empt=
y
> and only the first word of new_mask is not empty. When the allocator
> loads a word of the mask before
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0current->mems_allowed |=3D new_mask;
>
> and then loads another word of the mask after
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0current->mems_allowed =3D new_mask;
>
> the allocator gets an empty nodemask.
>
> Besides that, if the size of nodemask_t is less than the size of long int=
eger,
> there is another problem. when the kernel allocater invokes the following=
 function,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zoneref *next_zones_zonelist(struct zon=
eref *z,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0enum zone_type highest_zoneidx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0nodemask_t *nodes,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct zone **zone)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Find the next s=
uitable zone to use for the allocation.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Only filter bas=
ed on nodemask if it's set
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(nodes =
=3D=3D NULL))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0......
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0while (zonelist_zone_idx(z) > highest_zoneidx ||
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(z->zone =
&& !zref_in_nodemask(z, nodes)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0z++;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*zone =3D zonelist=
_zone(z);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return z;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> if we change nodemask between two calls of zref_in_nodemask(), such as
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Task1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Task2
> =C2=A0 =C2=A0 =C2=A0 =C2=A0zref_in_nodemask(z =3D node0's z, nodes =3D 1-=
2)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0zref_in_nodemask return 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodes =3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0zref_in_nodemask(z =3D node1's z, nodes =3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0zref_in_nodemask return 0
> z will overflow.
>
> when the kernel allocater accesses task->mempolicy, there is the same pro=
blem.
>
> The following method is used to fix these two problem.
> A seqlock is used to protect task's mempolicy and mems_allowed for config=
s where
> MAX_NUMNODES > BITS_PER_LONG, and when the kernel allocater accesses node=
mask,
> it locks the seqlock and gets the copy of nodemask, then it passes the co=
py of
> nodemask to the memory allocating function.
>
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
> ---
> =C2=A0include/linux/cpuset.h =C2=A0 =C2=A0| =C2=A0 79 +++++++++++++++++++=
++++-
> =C2=A0include/linux/init_task.h | =C2=A0 =C2=A08 +++
> =C2=A0include/linux/sched.h =C2=A0 =C2=A0 | =C2=A0 17 ++++-
> =C2=A0kernel/cpuset.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 97 ++++=
+++++++++++++++++++-------
> =C2=A0kernel/exit.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A04 +
> =C2=A0kernel/fork.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A04 +
> =C2=A0mm/hugetlb.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 22 ++++++-
> =C2=A0mm/mempolicy.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0144=
 ++++++++++++++++++++++++++++++++++-----------
> =C2=A0mm/slab.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
 =C2=A0 26 +++++++-
> =C2=A0mm/slub.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
 =C2=A0 12 ++++-
> =C2=A010 files changed, 341 insertions(+), 72 deletions(-)
>
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index a5740fc..e307f89 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -53,8 +53,8 @@ static inline int cpuset_zone_allowed_hardwall(struct z=
one *z, gfp_t gfp_mask)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return cpuset_node_allowed_hardwall(zone_to_ni=
d(z), gfp_mask);
> =C2=A0}
>
> -extern int cpuset_mems_allowed_intersects(const struct task_struct *tsk1=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const=
 struct task_struct *tsk2);
> +extern int cpuset_mems_allowed_intersects(struct task_struct *tsk1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struc=
t task_struct *tsk2);
>
> =C2=A0#define cpuset_memory_pressure_bump() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> @@ -90,9 +90,68 @@ extern void rebuild_sched_domains(void);
>
> =C2=A0extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>
> +# if MAX_NUMNODES > BITS_PER_LONG
> +/*
> + * Be used to protect task->mempolicy and mems_allowed when reading them=
 for
> + * page allocation.
> + *
> + * we don't care that the kernel page allocator allocate a page on a nod=
e in
> + * the old mems_allowed, which isn't a big deal, especially since it was
> + * previously allowed.
> + *
> + * We just worry whether the kernel page allocator gets an empty mems_al=
lowed
> + * or not. But
> + * =C2=A0 if MAX_NUMNODES <=3D BITS_PER_LONG, loading/storing task->mems=
_allowed are
> + * =C2=A0 atomic operations. So we needn't do anything to protect the lo=
ading of
> + * =C2=A0 task->mems_allowed in fastpaths.
> + *
> + * =C2=A0 if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_al=
lowed are
> + * =C2=A0 not atomic operations. So we use a seqlock to protect the load=
ing of
> + * =C2=A0 task->mems_allowed in fastpaths.
> + */
> +#define mems_fastpath_lock_irqsave(p, flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 ({ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_seqbegin_irqsave(=
&p->mems_seqlock, flags); =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 })
> +
> +#define mems_fastpath_unlock_irqrestore(p, seq, flags) =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 ({ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_seqretry_irqresto=
re(&p->mems_seqlock, seq, flags); \
> + =C2=A0 =C2=A0 =C2=A0 })
> +
> +#define mems_slowpath_lock_irqsave(p, flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 write_seqlock_irqsave(=
&p->mems_seqlock, flags); =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 } while (0)
> +
> +#define mems_slowpath_unlock_irqrestore(p, flags) =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 write_sequnlock_irqres=
tore(&p->mems_seqlock, flags); =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 } while (0)
> +# else
> +#define mems_fastpath_lock_irqsave(p, flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ({ (void)(flags); 0; })
> +
> +#define mems_fastpath_unlock_irqrestore(p, flags) =C2=A0 =C2=A0 =C2=A0({=
 (void)(flags); 0; })
> +
> +#define mems_slowpath_lock_irqsave(p, flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_lock(p); =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (void)(flags); =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 } while (0)
> +
> +#define mems_slowpath_unlock_irqrestore(p, flags) =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_unlock(p); =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (void)(flags); =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 } while (0)
> +# endif
> +
> =C2=A0static inline void set_mems_allowed(nodemask_t nodemask)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(current, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0current->mems_allowed =3D nodemask;
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(current, flags);
> =C2=A0}
>
> =C2=A0#else /* !CONFIG_CPUSETS */
> @@ -144,8 +203,8 @@ static inline int cpuset_zone_allowed_hardwall(struct=
 zone *z, gfp_t gfp_mask)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0}
>
> -static inline int cpuset_mems_allowed_intersects(const struct task_struc=
t *tsk1,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0const struct task_struct *tsk2)
> +static inline int cpuset_mems_allowed_intersects(struct task_struct *tsk=
1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *tsk2)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0}
> @@ -193,6 +252,18 @@ static inline void set_mems_allowed(nodemask_t nodem=
ask)
> =C2=A0{
> =C2=A0}
>
> +#define mems_fastpath_lock_irqsave(p, flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 ({ (void)(flags); 0; })
> +
> +#define mems_fastpath_unlock_irqrestore(p, seq, flags) =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 ({ (void)(flags); 0; })
> +
> +#define mems_slowpath_lock_irqsave(p, flags) =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 do { (void)(flags); } while (0)
> +
> +#define mems_slowpath_unlock_irqrestore(p, flags) =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 do { (void)(flags); } while (0)
> +
> =C2=A0#endif /* !CONFIG_CPUSETS */
>
> =C2=A0#endif /* _LINUX_CPUSET_H */
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index 1ed6797..0394e20 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -102,6 +102,13 @@ extern struct cred init_cred;
> =C2=A0# define INIT_PERF_EVENTS(tsk)
> =C2=A0#endif
>
> +#if defined(CONFIG_CPUSETS) && MAX_NUMNODES > BITS_PER_LONG
> +# define INIT_MEM_SEQLOCK(tsk) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 \
> + =C2=A0 =C2=A0 =C2=A0 .mems_seqlock =C2=A0 =3D __SEQLOCK_UNLOCKED(tsk.me=
ms_seqlock),
> +#else
> +# define INIT_MEM_SEQLOCK(tsk)
> +#endif
> +
> =C2=A0/*
> =C2=A0* =C2=A0INIT_TASK is used to set up the first task table, touch at
> =C2=A0* your own risk!. Base=3D0, limit=3D0x1fffff (=3D2MB)
> @@ -171,6 +178,7 @@ extern struct cred init_cred;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_FTRACE_GRAPH =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_TRACE_RECURSION =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_TASK_RCU_PREEMPT(tsk) =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 INIT_MEM_SEQLOCK(tsk) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> =C2=A0}
>
>
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 84b8c22..1cf5fd3 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1356,8 +1356,9 @@ struct task_struct {
> =C2=A0/* Thread group tracking */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 parent_exec_id;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 self_exec_id;
> -/* Protection of (de-)allocation: mm, files, fs, tty, keyrings, mems_all=
owed,
> - * mempolicy */
> +/* Protection of (de-)allocation: mm, files, fs, tty, keyrings.
> + * if MAX_NUMNODES <=3D BITS_PER_LONG,it will protect mems_allowed and m=
empolicy.
> + * Or we use other seqlock - mems_seqlock to protect them. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t alloc_lock;
>
> =C2=A0#ifdef CONFIG_GENERIC_HARDIRQS
> @@ -1425,7 +1426,13 @@ struct task_struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cputime_t acct_timexpd; /* stime + utime since=
 last update */
> =C2=A0#endif
> =C2=A0#ifdef CONFIG_CPUSETS
> - =C2=A0 =C2=A0 =C2=A0 nodemask_t mems_allowed; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Protected by alloc_lock */
> +# if MAX_NUMNODES > BITS_PER_LONG
> + =C2=A0 =C2=A0 =C2=A0 /* Protection of mems_allowed, and mempolicy */
> + =C2=A0 =C2=A0 =C2=A0 seqlock_t mems_seqlock;
> +# endif
> + =C2=A0 =C2=A0 =C2=A0 /* if MAX_NUMNODES <=3D BITS_PER_LONG, Protected b=
y alloc_lock;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* else Protected by mems_seqlock */
> + =C2=A0 =C2=A0 =C2=A0 nodemask_t mems_allowed;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int cpuset_mem_spread_rotor;
> =C2=A0#endif
> =C2=A0#ifdef CONFIG_CGROUPS
> @@ -1448,7 +1455,9 @@ struct task_struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head perf_event_list;
> =C2=A0#endif
> =C2=A0#ifdef CONFIG_NUMA
> - =C2=A0 =C2=A0 =C2=A0 struct mempolicy *mempolicy; =C2=A0 =C2=A0/* Prote=
cted by alloc_lock */
> + =C2=A0 =C2=A0 =C2=A0 /* if MAX_NUMNODES <=3D BITS_PER_LONG, Protected b=
y alloc_lock;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* else Protected by mems_seqlock */
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy *mempolicy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0short il_next;
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_t fs_excl; =C2=A0 =C2=A0 =C2=A0 /* hold=
ing fs exclusive resources */
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index d109467..52e6f51 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -198,12 +198,13 @@ static struct cpuset top_cpuset =3D {
> =C2=A0* from one of the callbacks into the cpuset code from within
> =C2=A0* __alloc_pages().
> =C2=A0*
> - * If a task is only holding callback_mutex, then it has read-only
> - * access to cpusets.
> + * If a task is only holding callback_mutex or cgroup_mutext, then it ha=
s
> + * read-only access to cpusets.
> =C2=A0*
> =C2=A0* Now, the task_struct fields mems_allowed and mempolicy may be cha=
nged
> - * by other task, we use alloc_lock in the task_struct fields to protect
> - * them.
> + * by other task, we use alloc_lock(if MAX_NUMNODES <=3D BITS_PER_LONG) =
or
> + * mems_seqlock(if MAX_NUMNODES > BITS_PER_LONG) in the task_struct fiel=
ds
> + * to protect them.
> =C2=A0*
> =C2=A0* The cpuset_common_file_read() handlers only hold callback_mutex a=
cross
> =C2=A0* small pieces of code, such as when reading out possibly multi-wor=
d
> @@ -920,6 +921,10 @@ static int update_cpumask(struct cpuset *cs, struct =
cpuset *trialcs,
> =C2=A0* =C2=A0 =C2=A0call to guarantee_online_mems(), as we know no one i=
s changing
> =C2=A0* =C2=A0 =C2=A0our task's cpuset.
> =C2=A0*
> + * =C2=A0 =C2=A0As the above comment said, no one can change current tas=
k's mems_allowed
> + * =C2=A0 =C2=A0except itself. so we needn't hold lock to protect task's=
 mems_allowed
> + * =C2=A0 =C2=A0during this call.
> + *
> =C2=A0* =C2=A0 =C2=A0While the mm_struct we are migrating is typically fr=
om some
> =C2=A0* =C2=A0 =C2=A0other task, the task_struct mems_allowed that we are=
 hacking
> =C2=A0* =C2=A0 =C2=A0is for our current task, which must allocate new pag=
es for that
> @@ -947,15 +952,13 @@ static void cpuset_migrate_mm(struct mm_struct *mm,=
 const nodemask_t *from,
> =C2=A0* we structure updates as setting all new allowed nodes, then clear=
ing newly
> =C2=A0* disallowed ones.
> =C2=A0*
> - * Called with task's alloc_lock held
> + * Called with mems_slowpath_lock held
> =C2=A0*/
> =C2=A0static void cpuset_change_task_nodemask(struct task_struct *tsk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodemask_=
t *newmems)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 nodes_or(tsk->mems_allowed, tsk->mems_allowed, *ne=
wmems);
> - =C2=A0 =C2=A0 =C2=A0 mpol_rebind_task(tsk, &tsk->mems_allowed);
> - =C2=A0 =C2=A0 =C2=A0 mpol_rebind_task(tsk, newmems);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tsk->mems_allowed =3D *newmems;
> + =C2=A0 =C2=A0 =C2=A0 mpol_rebind_task(tsk, newmems);
> =C2=A0}
>
> =C2=A0/*
> @@ -970,6 +973,7 @@ static void cpuset_change_nodemask(struct task_struct=
 *p,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cpuset *cs;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int migrate;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const nodemask_t *oldmem =3D scan->data;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NODEMASK_ALLOC(nodemask_t, newmems, GFP_KERNEL=
);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!newmems)
> @@ -978,9 +982,9 @@ static void cpuset_change_nodemask(struct task_struct=
 *p,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cs =3D cgroup_cs(scan->cg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0guarantee_online_mems(cs, newmems);
>
> - =C2=A0 =C2=A0 =C2=A0 task_lock(p);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(p, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cpuset_change_task_nodemask(p, newmems);
> - =C2=A0 =C2=A0 =C2=A0 task_unlock(p);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(p, flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NODEMASK_FREE(newmems);
>
> @@ -1375,6 +1379,7 @@ static int cpuset_can_attach(struct cgroup_subsys *=
ss, struct cgroup *cont,
> =C2=A0static void cpuset_attach_task(struct task_struct *tsk, nodemask_t =
*to,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct cpuset *cs)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * can_attach beforehand should guarantee that=
 this doesn't fail.
> @@ -1383,9 +1388,10 @@ static void cpuset_attach_task(struct task_struct =
*tsk, nodemask_t *to,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D set_cpus_allowed_ptr(tsk, cpus_attach)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON_ONCE(err);
>
> - =C2=A0 =C2=A0 =C2=A0 task_lock(tsk);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(tsk, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cpuset_change_task_nodemask(tsk, to);
> - =C2=A0 =C2=A0 =C2=A0 task_unlock(tsk);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(tsk, flags);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cpuset_update_task_spread_flag(cs, tsk);
>
> =C2=A0}
> @@ -2233,7 +2239,15 @@ nodemask_t cpuset_mems_allowed(struct task_struct =
*tsk)
> =C2=A0*/
> =C2=A0int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return nodes_intersects(*nodemask, current->mems_a=
llowed);
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags, seq;
> + =C2=A0 =C2=A0 =C2=A0 int retval;
> +
> + =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 seq =3D mems_fastpath_=
lock_irqsave(current, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 retval =3D nodes_inter=
sects(*nodemask, current->mems_allowed);
> + =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath_unlock_irqrestore(current, =
seq, flags));
> +
> + =C2=A0 =C2=A0 =C2=A0 return retval;
> =C2=A0}
>
> =C2=A0/*
> @@ -2314,11 +2328,18 @@ int __cpuset_node_allowed_softwall(int node, gfp_=
t gfp_mask)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct cpuset *cs; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* current cpuset ancestors */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int allowed; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* is allocation in zone z allowed? *=
/
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags, seq;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (in_interrupt() || (gfp_mask & __GFP_THISNO=
DE))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
> - =C2=A0 =C2=A0 =C2=A0 if (node_isset(node, current->mems_allowed))
> +
> + =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 seq =3D mems_fastpath_=
lock_irqsave(current, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 allowed =3D node_isset=
(node, current->mems_allowed);
> + =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath_unlock_irqrestore(current, =
seq, flags));
> +
> + =C2=A0 =C2=A0 =C2=A0 if (allowed)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Allow tasks that have access to memory rese=
rves because they have
> @@ -2369,9 +2390,18 @@ int __cpuset_node_allowed_softwall(int node, gfp_t=
 gfp_mask)
> =C2=A0*/
> =C2=A0int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 int allowed;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags, seq;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (in_interrupt() || (gfp_mask & __GFP_THISNO=
DE))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> - =C2=A0 =C2=A0 =C2=A0 if (node_isset(node, current->mems_allowed))
> +
> + =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 seq =3D mems_fastpath_=
lock_irqsave(current, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 allowed =3D node_isset=
(node, current->mems_allowed);
> + =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath_unlock_irqrestore(current, =
seq, flags));
> +
> + =C2=A0 =C2=A0 =C2=A0 if (allowed)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Allow tasks that have access to memory rese=
rves because they have
> @@ -2438,11 +2468,16 @@ void cpuset_unlock(void)
> =C2=A0int cpuset_mem_spread_node(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int node;
> -
> - =C2=A0 =C2=A0 =C2=A0 node =3D next_node(current->cpuset_mem_spread_roto=
r, current->mems_allowed);
> - =C2=A0 =C2=A0 =C2=A0 if (node =3D=3D MAX_NUMNODES)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 node =3D first_node(cu=
rrent->mems_allowed);
> - =C2=A0 =C2=A0 =C2=A0 current->cpuset_mem_spread_rotor =3D node;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags, seq;
> +
> + =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 seq =3D mems_fastpath_=
lock_irqsave(current, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 node =3D next_node(cur=
rent->cpuset_mem_spread_rotor,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 current->mem=
s_allowed);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (node =3D=3D MAX_NU=
MNODES)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 node =3D first_node(current->mems_allowed);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 current->cpuset_mem_sp=
read_rotor =3D node;
> + =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath_unlock_irqrestore(current, =
seq, flags));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return node;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
> @@ -2458,10 +2493,26 @@ EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
> =C2=A0* to the other.
> =C2=A0**/
>
> -int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct task_struct *t=
sk2)
> +int cpuset_mems_allowed_intersects(struct task_struct *tsk1,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *tsk2)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return nodes_intersects(tsk1->mems_allowed, tsk2->=
mems_allowed);
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags1, flags2;
> + =C2=A0 =C2=A0 =C2=A0 int retval;
> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *tsk;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (tsk1 > tsk2) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tsk =3D tsk1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tsk1 =3D tsk2;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tsk2 =3D tsk;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(tsk1, flags1);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(tsk2, flags2);
> + =C2=A0 =C2=A0 =C2=A0 retval =3D nodes_intersects(tsk1->mems_allowed, ts=
k2->mems_allowed);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(tsk2, flags2);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(tsk1, flags1);
> +
> + =C2=A0 =C2=A0 =C2=A0 return retval;
> =C2=A0}
>
> =C2=A0/**
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 7b012a0..cbf045d 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -16,6 +16,7 @@
> =C2=A0#include <linux/key.h>
> =C2=A0#include <linux/security.h>
> =C2=A0#include <linux/cpu.h>
> +#include <linux/cpuset.h>
> =C2=A0#include <linux/acct.h>
> =C2=A0#include <linux/tsacct_kern.h>
> =C2=A0#include <linux/file.h>
> @@ -649,6 +650,7 @@ static void exit_mm(struct task_struct * tsk)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D tsk->mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct core_state *core_state;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm_release(tsk, mm);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mm)
> @@ -694,8 +696,10 @@ static void exit_mm(struct task_struct * tsk)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We don't want this task to be frozen premat=
urely */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0clear_freeze_flag(tsk);
> =C2=A0#ifdef CONFIG_NUMA
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(tsk, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_put(tsk->mempolicy);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tsk->mempolicy =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(tsk, flags);
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(tsk);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm_update_next_owner(mm);
> diff --git a/kernel/fork.c b/kernel/fork.c
> index fe73f8d..591346a 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -32,6 +32,7 @@
> =C2=A0#include <linux/capability.h>
> =C2=A0#include <linux/cpu.h>
> =C2=A0#include <linux/cgroup.h>
> +#include <linux/cpuset.h>
> =C2=A0#include <linux/security.h>
> =C2=A0#include <linux/hugetlb.h>
> =C2=A0#include <linux/swap.h>
> @@ -1075,6 +1076,9 @@ static struct task_struct *copy_process(unsigned lo=
ng clone_flags,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p->io_context =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p->audit_context =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cgroup_fork(p);
> +#if defined(CONFIG_CPUSETS) && MAX_NUMNODES > BITS_PER_LONG
> + =C2=A0 =C2=A0 =C2=A0 seqlock_init(&p->mems_seqlock);
> +#endif
> =C2=A0#ifdef CONFIG_NUMA
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p->mempolicy =3D mpol_dup(p->mempolicy);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (IS_ERR(p->mempolicy)) {
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3a5aeb3..b40cc52 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -465,6 +465,8 @@ static struct page *dequeue_huge_page_vma(struct hsta=
te *h,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *mpol;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nodemask_t *nodemask;
> + =C2=A0 =C2=A0 =C2=A0 nodemask_t tmp_mask;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long seq, irqflag;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zonelist *zonelist =3D huge_zonelist(vm=
a, address,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0htlb_allo=
c_mask, &mpol, &nodemask);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;
> @@ -483,6 +485,15 @@ static struct page *dequeue_huge_page_vma(struct hst=
ate *h,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (avoid_reserve && h->free_huge_pages - h->r=
esv_huge_pages =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
> + =C2=A0 =C2=A0 =C2=A0 if (mpol =3D=3D current->mempolicy && nodemask) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, irqflag);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmp_mask =3D *nodemask;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
eq, irqflag));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nodemask =3D &tmp_mask=
;
> + =C2=A0 =C2=A0 =C2=A0 }
> +

Maybe you can define these to a macro or inline function, I saw
serveral similar places  :-)

> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_zone_zonelist_nodemask(zone, z, zonel=
ist,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0MAX_NR_ZONES - 1, nodemask) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nid =3D zone_to_ni=
d(zone);
> @@ -1835,10 +1846,15 @@ __setup("default_hugepagesz=3D", hugetlb_default_=
setup);
> =C2=A0static unsigned int cpuset_mems_nr(unsigned int *array)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int node;
> - =C2=A0 =C2=A0 =C2=A0 unsigned int nr =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 unsigned int nr;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags, seq;
>
> - =C2=A0 =C2=A0 =C2=A0 for_each_node_mask(node, cpuset_current_mems_allow=
ed)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr +=3D array[node];
> + =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 seq =3D mems_fastpath_=
lock_irqsave(current, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for_each_node_mask(nod=
e, cpuset_current_mems_allowed)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr +=3D array[node];
> + =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath_unlock_irqrestore(current, =
seq, flags));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return nr;
> =C2=A0}
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index dd3f5c5..49abf11 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -187,8 +187,10 @@ static int mpol_new_bind(struct mempolicy *pol, cons=
t nodemask_t *nodes)
> =C2=A0* parameter with respect to the policy mode and flags. =C2=A0But, w=
e need to
> =C2=A0* handle an empty nodemask with MPOL_PREFERRED here.
> =C2=A0*
> - * Must be called holding task's alloc_lock to protect task's mems_allow=
ed
> - * and mempolicy. =C2=A0May also be called holding the mmap_semaphore fo=
r write.
> + * Must be called using
> + * =C2=A0 =C2=A0 mems_slowpath_lock_irqsave()/mems_slowpath_unlock_irqre=
store()
> + * to protect task's mems_allowed and mempolicy. =C2=A0May also be calle=
d holding
> + * the mmap_semaphore for write.
> =C2=A0*/
> =C2=A0static int mpol_set_nodemask(struct mempolicy *pol,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 con=
st nodemask_t *nodes, struct nodemask_scratch *nsc)
> @@ -344,9 +346,10 @@ static void mpol_rebind_policy(struct mempolicy *pol=
,
> =C2=A0* Wrapper for mpol_rebind_policy() that just requires task
> =C2=A0* pointer, and updates task mempolicy.
> =C2=A0*
> - * Called with task's alloc_lock held.
> + * Using
> + * =C2=A0 =C2=A0 mems_slowpath_lock_irqsave()/mems_slowpath_unlock_irqre=
store()
> + * to protect it.
> =C2=A0*/
> -
> =C2=A0void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *ne=
w)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_rebind_policy(tsk->mempolicy, new);
> @@ -644,6 +647,7 @@ static long do_set_mempolicy(unsigned short mode, uns=
igned short flags,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *new, *old;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D current->mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NODEMASK_SCRATCH(scratch);
> + =C2=A0 =C2=A0 =C2=A0 unsigned long irqflags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!scratch)
> @@ -662,10 +666,10 @@ static long do_set_mempolicy(unsigned short mode, u=
nsigned short flags,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0down_write(&mm->mm=
ap_sem);
> - =C2=A0 =C2=A0 =C2=A0 task_lock(current);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D mpol_set_nodemask(new, nodes, scratch)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_unlock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_i=
rqrestore(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0up_write(&mm->mmap_sem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_put(new);
> @@ -677,7 +681,7 @@ static long do_set_mempolicy(unsigned short mode, uns=
igned short flags,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (new && new->mode =3D=3D MPOL_INTERLEAVE &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodes_weight(new->v.nodes))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0current->il_next =
=3D first_node(new->v.nodes);
> - =C2=A0 =C2=A0 =C2=A0 task_unlock(current);
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(current, irqflags)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&mm->mmap=
_sem);
>
> @@ -691,7 +695,9 @@ out:
> =C2=A0/*
> =C2=A0* Return nodemask for policy for get_mempolicy() query
> =C2=A0*
> - * Called with task's alloc_lock held
> + * Must be called using mems_slowpath_lock_irqsave()/
> + * mems_slowpath_unlock_irqrestore() to
> + * protect it.
> =C2=A0*/
> =C2=A0static void get_policy_nodemask(struct mempolicy *p, nodemask_t *no=
des)
> =C2=A0{
> @@ -736,6 +742,7 @@ static long do_get_mempolicy(int *policy, nodemask_t =
*nmask,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D current->mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *pol =3D current->mempolicy;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long irqflags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags &
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0~(unsigned long)(M=
POL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
> @@ -745,9 +752,10 @@ static long do_get_mempolicy(int *policy, nodemask_t=
 *nmask,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags & (MPOL_=
F_NODE|MPOL_F_ADDR))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*policy =3D 0; =C2=
=A0 =C2=A0/* just so it's initialized */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_lock(current);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irq=
save(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*nmask =C2=A0=3D c=
puset_current_mems_allowed;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_unlock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_i=
rqrestore(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -803,13 +811,13 @@ static long do_get_mempolicy(int *policy, nodemask_=
t *nmask,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nmask) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irq=
save(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mpol_store_use=
r_nodemask(pol)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*nmask =3D pol->w.user_nodemask;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_lock(current);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0get_policy_nodemask(pol, nmask);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_unlock(current);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_i=
rqrestore(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0out:
> @@ -1008,6 +1016,7 @@ static long do_mbind(unsigned long start, unsigned =
long len,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long end;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long irqflags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LIST_HEAD(pagelist);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags & ~(unsigned long)(MPOL_MF_STRICT |
> @@ -1055,9 +1064,9 @@ static long do_mbind(unsigned long start, unsigned =
long len,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NODEMASK_SCRATCH(s=
cratch);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (scratch) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0down_write(&mm->mmap_sem);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_lock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mems_slowpath_lock_irqsave(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0err =3D mpol_set_nodemask(new, nmask, scratch);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_unlock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mems_slowpath_unlock_irqrestore(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_write(&mm->mmap_sem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> @@ -1408,8 +1417,10 @@ static struct mempolicy *get_vma_policy(struct tas=
k_struct *task,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (vma->vm=
_policy)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pol =3D vma->vm_policy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pol)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pol =3D &default_p=
olicy;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return pol;
> =C2=A0}
>
> @@ -1475,7 +1486,7 @@ static unsigned interleave_nodes(struct mempolicy *=
policy)
> =C2=A0* next slab entry.
> =C2=A0* @policy must be protected by freeing by the caller. =C2=A0If @pol=
icy is
> =C2=A0* the current task's mempolicy, this protection is implicit, as onl=
y the
> - * task can change it's policy. =C2=A0The system default policy requires=
 no
> + * task can free it's policy. =C2=A0The system default policy requires n=
o
> =C2=A0* such protection.
> =C2=A0*/
> =C2=A0unsigned slab_node(struct mempolicy *policy)
> @@ -1574,16 +1585,33 @@ struct zonelist *huge_zonelist(struct vm_area_str=
uct *vma, unsigned long addr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodemask_t **nodemask)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zonelist *zl;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy policy;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy *pol;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long seq, irqflag;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*mpol =3D get_vma_policy(current, vma, addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*nodemask =3D NULL; =C2=A0 =C2=A0 =C2=A0 /* as=
sume !MPOL_BIND */
>
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely((*mpol)->mode =3D=3D MPOL_INTERLEAVE)=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zl =3D node_zonelist(i=
nterleave_nid(*mpol, vma, addr,
> + =C2=A0 =C2=A0 =C2=A0 pol =3D *mpol;
> + =C2=A0 =C2=A0 =C2=A0 if (pol =3D=3D current->mempolicy) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* get_vma_policy=
() doesn't return NULL, so we needn't worry
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* whether pol is=
 NULL or not.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, irqflag);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 policy =3D *pol;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
eq, irqflag));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pol =3D &policy;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(pol->mode =3D=3D MPOL_INTERLEAVE)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zl =3D node_zonelist(i=
nterleave_nid(pol, vma, addr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0huge_page_shift(hstate_vma(vma))), gf=
p_flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zl =3D policy_zonelist=
(gfp_flags, *mpol);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((*mpol)->mode =3D=
=3D MPOL_BIND)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zl =3D policy_zonelist=
(gfp_flags, pol);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pol->mode =3D=3D M=
POL_BIND)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*nodemask =3D &(*mpol)->v.nodes;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return zl;
> @@ -1609,11 +1637,14 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *mempolicy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long irqflags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(mask && current->mempolicy))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;
>
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irqsave(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mempolicy =3D current->mempolicy;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (mempolicy->mode) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case MPOL_PREFERRED:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mempolicy->fla=
gs & MPOL_F_LOCAL)
> @@ -1633,6 +1664,8 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_irqrestore(current, irqflags)=
;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;
> =C2=A0}
> =C2=A0#endif
> @@ -1722,7 +1755,22 @@ struct page *
> =C2=A0alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long=
 addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *pol =3D get_vma_policy(curre=
nt, vma, addr);
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy policy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zonelist *zl;
> + =C2=A0 =C2=A0 =C2=A0 struct page *page;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long seq, iflags;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (pol =3D=3D current->mempolicy) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* get_vma_policy=
() doesn't return NULL, so we needn't worry
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* whether pol is=
 NULL or not.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, iflags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 policy =3D *pol;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current, seq, iflags));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pol =3D &policy;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(pol->mode =3D=3D MPOL_INTERLEAVE)=
) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned nid;
> @@ -1736,15 +1784,16 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *=
vma, unsigned long addr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * slow path: ref =
counted shared policy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page =3D =
=C2=A0__alloc_pages_nodemask(gfp, 0,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 zl, policy_nodemask(gfp, pol));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D =C2=A0__alloc=
_pages_nodemask(gfp, 0, zl,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 policy_nodem=
ask(gfp, pol));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__mpol_put(pol);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * fast path: =C2=A0default or task policy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 return __alloc_pages_nodemask(gfp, 0, zl, policy_n=
odemask(gfp, pol));
> + =C2=A0 =C2=A0 =C2=A0 page =3D __alloc_pages_nodemask(gfp, 0, zl, policy=
_nodemask(gfp, pol));
> + =C2=A0 =C2=A0 =C2=A0 return page;
> =C2=A0}
>
> =C2=A0/**
> @@ -1761,26 +1810,37 @@ alloc_page_vma(gfp_t gfp, struct vm_area_struct *=
vma, unsigned long addr)
> =C2=A0* =C2=A0 =C2=A0 Allocate a page from the kernel page pool. =C2=A0Wh=
en not in
> =C2=A0* =C2=A0 =C2=A0 interrupt context and apply the current process NUM=
A policy.
> =C2=A0* =C2=A0 =C2=A0 Returns NULL when no page can be allocated.
> - *
> - * =C2=A0 =C2=A0 Don't call cpuset_update_task_memory_state() unless
> - * =C2=A0 =C2=A0 1) it's ok to take cpuset_sem (can WAIT), and
> - * =C2=A0 =C2=A0 2) allocating for current task (not interrupt).
> =C2=A0*/
> =C2=A0struct page *alloc_pages_current(gfp_t gfp, unsigned order)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *pol =3D current->mempolicy;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy policy;
> + =C2=A0 =C2=A0 =C2=A0 struct page *page;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long seq, irqflags;
> +
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pol || in_interrupt() || (gfp & __GFP_THI=
SNODE))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pol =3D &default_p=
olicy;
> -
> + =C2=A0 =C2=A0 =C2=A0 else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, irqflags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 policy =3D *pol;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
eq, irqflags));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pol =3D &policy;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * No reference counting needed for current->m=
empolicy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * nor system default_policy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pol->mode =3D=3D MPOL_INTERLEAVE)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return alloc_page_inte=
rleave(gfp, order, interleave_nodes(pol));
> - =C2=A0 =C2=A0 =C2=A0 return __alloc_pages_nodemask(gfp, order,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 policy_zonelist(gfp, pol), policy_nodemask(gfp, pol));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D alloc_page_in=
terleave(gfp, order, interleave_nodes(pol));
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D =C2=A0__alloc=
_pages_nodemask(gfp, order,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 policy_zonel=
ist(gfp, pol),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 policy_nodem=
ask(gfp, pol));
> +
> + =C2=A0 =C2=A0 =C2=A0 return page;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(alloc_pages_current);
>
> @@ -2026,6 +2086,7 @@ restart:
> =C2=A0*/
> =C2=A0void mpol_shared_policy_init(struct shared_policy *sp, struct mempo=
licy *mpol)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 unsigned long irqflags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sp->root =3D RB_ROOT; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 /* empty tree =3D=3D default mempolicy */
> @@ -2043,9 +2104,9 @@ void mpol_shared_policy_init(struct shared_policy *=
sp, struct mempolicy *mpol)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (IS_ERR(new))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto put_free; /* no valid nodemask intersection */
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_lock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_lock_irq=
save(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D mpol_set_n=
odemask(new, &mpol->w.user_nodemask, scratch);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_unlock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mems_slowpath_unlock_i=
rqrestore(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_put(mpol); /*=
 drop our ref on sb mpol */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto put_free;
> @@ -2200,6 +2261,7 @@ int mpol_parse_str(char *str, struct mempolicy **mp=
ol, int no_context)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nodemask_t nodes;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char *nodelist =3D strchr(str, ':');
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char *flags =3D strchr(str, '=3D');
> + =C2=A0 =C2=A0 =C2=A0 unsigned long irqflags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err =3D 1;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nodelist) {
> @@ -2291,9 +2353,9 @@ int mpol_parse_str(char *str, struct mempolicy **mp=
ol, int no_context)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NODEMASK_SCRATCH(s=
cratch);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (scratch) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_lock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mems_slowpath_lock_irqsave(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D mpol_set_nodemask(new, &nodes, scratch);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_unlock(current);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mems_slowpath_unlock_irqrestore(current, irqflags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D -ENOMEM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NODEMASK_SCRATCH_F=
REE(scratch);
> @@ -2487,8 +2549,10 @@ int show_numa_map(struct seq_file *m, void *v)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct file *file =3D vma->vm_file;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D vma->vm_mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mempolicy *pol;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy policy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int n;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char buffer[50];
> + =C2=A0 =C2=A0 =C2=A0 unsigned long iflags, seq;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> @@ -2498,6 +2562,18 @@ int show_numa_map(struct seq_file *m, void *v)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pol =3D get_vma_policy(priv->task, vma, vma->v=
m_start);
> + =C2=A0 =C2=A0 =C2=A0 if (pol =3D=3D current->mempolicy) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* get_vma_policy=
() doesn't return NULL, so we needn't worry
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* whether pol is=
 NULL or not.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, iflags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 policy =3D *pol;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current, seq, iflags));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pol =3D &policy;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_to_str(buffer, sizeof(buffer), pol, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mpol_cond_put(pol);
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 09f1572..b8f5acb 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3282,14 +3282,24 @@ static inline void *____cache_alloc(struct kmem_c=
ache *cachep, gfp_t flags)
> =C2=A0static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t =
flags)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid_alloc, nid_here;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long lflags, seq;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy mpol;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (in_interrupt() || (flags & __GFP_THISNODE)=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nid_alloc =3D nid_here =3D numa_node_id();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (cpuset_do_slab_mem_spread() && (cachep->fl=
ags & SLAB_MEM_SPREAD))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nid_alloc =3D cpus=
et_mem_spread_node();
> - =C2=A0 =C2=A0 =C2=A0 else if (current->mempolicy)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nid_alloc =3D slab_nod=
e(current->mempolicy);
> + =C2=A0 =C2=A0 =C2=A0 else if (current->mempolicy) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, lflags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mpol =3D *(current->mempolicy);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current, seq, lflags));
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nid_alloc =3D slab_nod=
e(&mpol);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nid_alloc !=3D nid_here)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ____cache_a=
lloc_node(cachep, flags, nid_alloc);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> @@ -3312,11 +3322,21 @@ static void *fallback_alloc(struct kmem_cache *ca=
che, gfp_t flags)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0enum zone_type high_zoneidx =3D gfp_zone(flags=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0void *obj =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long lflags, seq;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy mpol;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags & __GFP_THISNODE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
> - =C2=A0 =C2=A0 =C2=A0 zonelist =3D node_zonelist(slab_node(current->memp=
olicy), flags);
> + =C2=A0 =C2=A0 =C2=A0 if (current->mempolicy) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, lflags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mpol =3D *(current->mempolicy);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current, seq, lflags));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zonelist =3D node_zone=
list(slab_node(&mpol), flags);
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zonelist =3D node_zone=
list(slab_node(NULL), flags);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_flags =3D flags & (GFP_CONSTRAINT_MASK|G=
FP_RECLAIM_MASK);
>
> =C2=A0retry:
> diff --git a/mm/slub.c b/mm/slub.c
> index b364844..436c521 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1345,6 +1345,8 @@ static struct page *get_any_partial(struct kmem_cac=
he *s, gfp_t flags)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0enum zone_type high_zoneidx =3D gfp_zone(flags=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long lflags, seq;
> + =C2=A0 =C2=A0 =C2=A0 struct mempolicy mpol;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * The defrag ratio allows a configuration of =
the tradeoffs between
> @@ -1368,7 +1370,15 @@ static struct page *get_any_partial(struct kmem_ca=
che *s, gfp_t flags)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0get_cycles() % 1024 > s->remote_node_defrag_ratio)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
> - =C2=A0 =C2=A0 =C2=A0 zonelist =3D node_zonelist(slab_node(current->memp=
olicy), flags);
> + =C2=A0 =C2=A0 =C2=A0 if (current->mempolicy) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 seq =3D mems_fastpath_lock_irqsave(current, lflags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mpol =3D *(current->mempolicy);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (mems_fastpath=
_unlock_irqrestore(current, seq, lflags));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zonelist =3D node_zone=
list(slab_node(&mpol), flags);
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zonelist =3D node_zone=
list(slab_node(NULL), flags);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_zone_zonelist(zone, z, zonelist, high=
_zoneidx) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct kmem_cache_=
node *n;
>
> --
> 1.6.5.2
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
