Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id ACCFE6B00FA
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:12:54 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so471160lbj.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 12:12:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F9A359C.10107@jp.fujitsu.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A359C.10107@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 12:12:52 -0700
Message-ID: <CALWz4ixHGCqfWh1U+JyiJWTkGmCDtXQy1vbHRjrHaU_pOgGuBw@mail.gmail.com>
Subject: Re: [RFC][PATCH 5/9 v2] move charges to root at rmdir if
 use_hierarchy is unset
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On Thu, Apr 26, 2012 at 10:58 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Now, at removal of cgroup, ->pre_destroy() is called and move charges
> to the parent cgroup. A major reason of -EBUSY returned by ->pre_destroy(=
)
> is that the 'moving' hits parent's resource limitation. It happens only
> when use_hierarchy=3D0. This was a mistake of original design.(it's me...=
)

Nice patch, i can see how broken it is now with use_hierarchy=3D0...

nitpick on the documentation below:

>
> Considering use_hierarchy=3D0, all cgroups are treated as flat. So, no on=
e
> cannot justify moving charges to parent...parent and children are in
> flat configuration, not hierarchical.
>
> This patch modifes to move charges to root cgroup at rmdir/force_empty
> if use_hierarchy=3D=3D0. This will much simplify rmdir() and reduce error
> in ->pre_destroy.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 12 ++++++----
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 39 ++++++++++=
+++------------------------
> =A02 files changed, 21 insertions(+), 30 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index 54c338d..82ce1ef 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -393,14 +393,14 @@ cgroup might have some charge associated with it, e=
ven though all
> =A0tasks have migrated away from it. (because we charge against pages, no=
t
> =A0against tasks.)
>
> -Such charges are freed or moved to their parent. At moving, both of RSS
> -and CACHES are moved to parent.
> -rmdir() may return -EBUSY if freeing/moving fails. See 5.1 also.
> +Such charges are freed or moved to their parent if use_hierarchy=3D1.
> +if use_hierarchy=3D0, the charges will be moved to root cgroup.

It is more clear that we move the stats to root (if use_hierarchy=3D=3D0)
or parent (if use_hierarchy=3D=3D1), and no change on the charge except
uncharging from the child.

--Ying

>
> =A0Charges recorded in swap information is not updated at removal of cgro=
up.
> =A0Recorded information is discarded and a cgroup which uses swap (swapca=
che)
> =A0will be charged as a new owner of it.
>
> +About use_hierarchy, see Section 6.
>
> =A05. Misc. interfaces.
>
> @@ -413,13 +413,15 @@ will be charged as a new owner of it.
>
> =A0 Almost all pages tracked by this memory cgroup will be unmapped and f=
reed.
> =A0 Some pages cannot be freed because they are locked or in-use. Such pa=
ges are
> - =A0moved to parent and this cgroup will be empty. This may return -EBUS=
Y if
> - =A0VM is too busy to free/move all pages immediately.
> + =A0moved to parent(if use_hierarchy=3D=3D1) or root (if use_hierarchy=
=3D=3D0) and this
> + =A0cgroup will be empty.
>
> =A0 Typical use case of this interface is that calling this before rmdir(=
).
> =A0 Because rmdir() moves all pages to parent, some out-of-use page cache=
s can be
> =A0 moved to the parent. If you want to avoid that, force_empty will be u=
seful.
>
> + =A0About use_hierarchy, see Section 6.
> +
> =A05.2 stat file
>
> =A0memory.stat file includes following statistics
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ed53d64..62200f1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2695,32 +2695,23 @@ static int mem_cgroup_move_parent(struct page *pa=
ge,
> =A0 =A0 =A0 =A0nr_pages =3D hpage_nr_pages(page);
>
> =A0 =A0 =A0 =A0parent =3D mem_cgroup_from_cont(pcg);
> - =A0 =A0 =A0 if (!parent->use_hierarchy) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 gfp_mask, nr_pages, &parent, false);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto put_back;
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* if use_hierarchy=3D=3D0, move charges to root cgroup.
> + =A0 =A0 =A0 =A0* in root cgroup, we don't touch res_counter
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!parent->use_hierarchy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 parent =3D root_mem_cgroup;
>
> =A0 =A0 =A0 =A0if (nr_pages > 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags =3D compound_lock_irqsave(page);
>
> - =A0 =A0 =A0 if (parent->use_hierarchy) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_move_account(page, nr_pa=
ges,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 pc, child, parent, false);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_cancel_local_c=
harge(child, nr_pages);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_move_account(page, nr_pa=
ges,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 pc, child, parent, true);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_cancel_charge(=
parent, nr_pages);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 ret =3D mem_cgroup_move_account(page, nr_pages,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc, child, =
parent, false);
> + =A0 =A0 =A0 if (!ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_cancel_local_charge(child, nr_=
pages);
>
> =A0 =A0 =A0 =A0if (nr_pages > 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compound_unlock_irqrestore(page, flags);
> -put_back:
> =A0 =A0 =A0 =A0putback_lru_page(page);
> =A0put:
> =A0 =A0 =A0 =A0put_page(page);
> @@ -3338,12 +3329,10 @@ int mem_cgroup_move_hugetlb_parent(int idx, struc=
t cgroup *cgroup,
> =A0 =A0 =A0 =A0csize =3D PAGE_SIZE << compound_order(page);
> =A0 =A0 =A0 =A0/* If parent->use_hierarchy =3D=3D 0, we need to charge pa=
rent */
> =A0 =A0 =A0 =A0if (!parent->use_hierarchy) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_charge(&parent->hugepag=
e[idx],
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0csize, &fail_res);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EBUSY;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 parent =3D root_mem_cgroup;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* root has no limit */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_charge_nofail(&parent->hugepage=
[idx],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0csize, &=
fail_res);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0counter =3D &memcg->hugepage[idx];
> =A0 =A0 =A0 =A0res_counter_uncharge_until(counter, counter->parent, csize=
);
> --
> 1.7.4.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
