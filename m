Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ADD656B0083
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 19:52:54 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8HNqx8a024771
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 18 Sep 2009 08:53:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B776945DE79
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:52:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7980845DE6F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:52:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 237DDE18006
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:52:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5D4E18001
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:52:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] memcg: migrate charge of anon
In-Reply-To: <20090917135737.04c3b65f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112656.908b44fa.nishimura@mxp.nes.nec.co.jp> <20090917135737.04c3b65f.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090918085049.8E42.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 18 Sep 2009 08:52:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 17 Sep 2009 11:26:56 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>=20
> > This patch is the core part of this charge migration feature.
> > It adds functions to migrate charge of anonymous pages of the task.
> >=20
> > Implementation:
> > - define struct migrate_charge and a valuable of it(mc) to remember
> >   the target pages and other information.
> > - At can_attach(), isolate the target pages, call __mem_cgroup_try_char=
ge(),
> >   and move them to mc->list.
> > - Call mem_cgroup_move_account() at attach() about all pages on mc->lis=
t
> >   after necessary checks under page_cgroup lock, and put back them to L=
RU.
> > - Cancel charges about all pages remains on mc->list on failure or at t=
he end
> >   of charge migration, and put back them to LRU.
> >=20
> >=20
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>=20
> > ---
> >  mm/memcontrol.c |  196 +++++++++++++++++++++++++++++++++++++++++++++++=
+++++++-
> >  1 files changed, 195 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index a6b07f8..3a3f4ac 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -21,6 +21,8 @@
> >  #include <linux/memcontrol.h>
> >  #include <linux/cgroup.h>
> >  #include <linux/mm.h>
> > +#include <linux/migrate.h>
> > +#include <linux/hugetlb.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/smp.h>
> >  #include <linux/page-flags.h>
> > @@ -274,6 +276,18 @@ enum charge_type {
> >  #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
> >  #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
> > =20
> > +/*
> > + * Stuffs for migrating charge at task move.
> > + * mc and its members are protected by cgroup_lock
> > + */
> > +struct migrate_charge {
> > +	struct task_struct *tsk;
> > +	struct mem_cgroup *from;
> > +	struct mem_cgroup *to;
> > +	struct list_head list;
> > +};
> > +static struct migrate_charge *mc;
> > +
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> > @@ -2829,6 +2843,7 @@ static int mem_cgroup_swappiness_write(struct cgr=
oup *cgrp, struct cftype *cft,
> >  }
> > =20
> >  enum migrate_charge_type {
> > +	MIGRATE_CHARGE_ANON,
> >  	NR_MIGRATE_CHARGE_TYPE,
> >  };
> > =20
> > @@ -3184,10 +3199,164 @@ static int mem_cgroup_populate(struct cgroup_s=
ubsys *ss,
> >  	return ret;
> >  }
> > =20
> > +static int migrate_charge_prepare_pte_range(pmd_t *pmd,
> > +					unsigned long addr, unsigned long end,
> > +					struct mm_walk *walk)
> > +{
> > +	int ret =3D 0;
> > +	struct page *page, *tmp;
> > +	LIST_HEAD(list);
> > +	struct vm_area_struct *vma =3D walk->private;
> > +	pte_t *pte, ptent;
> > +	spinlock_t *ptl;
> > +	bool move_anon =3D (mc->to->migrate_charge & (1 << MIGRATE_CHARGE_ANO=
N));
> > +
> > +	lru_add_drain_all();
>=20
> plz call lru_add_drain_all() before taking mmap_sem().
> This waits for workqueue in synchronous manner.
> (I think KOSAKI-san is working for better pagevec drain function.)

FYI

I plan to submit following patch after merge window.
lru_add_drain_all_async() can be called in mmap_sem grabbed area.


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom d76f56718886b6dd7f77babddad45a33ccf668cd Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 17 Sep 2009 16:07:55 +0900
Subject: [PATCH 1/2] Implement lru_add_drain_all_async()

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/swap.h |    1 +
 mm/swap.c            |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4ec9001..1f5772a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -204,6 +204,7 @@ extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
+extern int lru_add_drain_all_async(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
=20
diff --git a/mm/swap.c b/mm/swap.c
index 308e57d..e16cd40 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -38,6 +38,7 @@ int page_cluster;
=20
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct work_struct, lru_drain_work);
=20
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -312,6 +313,24 @@ int lru_add_drain_all(void)
 }
=20
 /*
+ * Returns 0 for success
+ */
+int lru_add_drain_all_async(void)
+{
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct work_struct *work =3D &per_cpu(lru_drain_work, cpu);
+		schedule_work_on(cpu, work);
+	}
+	put_online_cpus();
+
+	return 0;
+}
+
+
+/*
  * Batched page_cache_release().  Decrement the reference count on all the
  * passed pages.  If it fell to zero then remove the page from the LRU and
  * free it.
@@ -497,6 +516,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 void __init swap_setup(void)
 {
 	unsigned long megs =3D totalram_pages >> (20 - PAGE_SHIFT);
+	int cpu;
=20
 #ifdef CONFIG_SWAP
 	bdi_init(swapper_space.backing_dev_info);
@@ -511,4 +531,8 @@ void __init swap_setup(void)
 	 * Right now other parts of the system means that we
 	 * _really_ don't want to cluster much more
 	 */
+
+	for_each_possible_cpu(cpu) {
+		INIT_WORK(&per_cpu(lru_drain_work, cpu), lru_add_drain_per_cpu);
+	}
 }
--=20
1.6.2.5





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
