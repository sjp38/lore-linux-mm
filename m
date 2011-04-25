Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC5F8D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 22:22:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3690E3EE0C0
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:21:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1390B45DE52
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:21:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB59B45DE4E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:21:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD3681DB8037
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:21:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F0351DB803B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:21:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan,memcg: memcg aware swap token
In-Reply-To: <BANLkTinB5tGAH=DE55HnE5krGxx1uoXgLA@mail.gmail.com>
References: <20110422174554.71F2.A69D9226@jp.fujitsu.com> <BANLkTinB5tGAH=DE55HnE5krGxx1uoXgLA@mail.gmail.com>
Message-Id: <20110425112333.2662.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 25 Apr 2011 11:21:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> > > > > +             sc.priority =3D priority;
> > > > > +             /* The swap token gets in the way of swapout... */
> > > > > +             if (!priority)
> > > > > +                     disable_swap_token();
> > > >
> > > > Why?
> > > >
> > > > disable swap token mean "Please devest swap preventation privilege =
from
> > > > owner task. Instead we endure swap storm and performance hit".
> > > > However I doublt memcg memory shortage is good situation to make sw=
ap
> > > > storm.
> > > >
> > >
> > > I am not sure about that either way. we probably can leave as it is a=
nd
> > make
> > > corresponding change if real problem is observed?
> >
> > Why?
> > This is not only memcg issue, but also can lead to global swap ping-pon=
g.
> >
> > But I give up. I have no time to persuade you.
> >
> > Thank you for pointing that out. I didn't pay much attention on the
> swap_token but just simply inherited
> it from the global logic. Now after reading a bit more, i think you were
> right about it.  It would be a bad
> idea to have memcg kswapds affecting much the global swap token being set.
>=20
> I will remove it from the next post.

The better approach is swap-token recognize memcg and behave clever? :)



=46rom 106c21d7f9cf8641592cbfe1416af66470af4f9a Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 10:57:54 +0900
Subject: [PATCH] vmscan,memcg: memcg aware swap token

Currently, memcg reclaim can disable swap token even if the swap token
mm doesn't belong in its memory cgroup. It's slightly riskly. If an
admin makes very small mem-cgroup and silly guy runs contenious heavy
memory pressure workloa, whole tasks in the system are going to lose
swap-token and then system may become unresponsive. That's bad.

This patch adds 'memcg' parameter into disable_swap_token(). and if
the parameter doesn't match swap-token, VM doesn't put swap-token.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 ++++++
 include/linux/swap.h       |   24 +++++++++++++++++-------
 mm/memcontrol.c            |    2 +-
 mm/thrash.c                |   17 +++++++++++++++++
 mm/vmscan.c                |    4 ++--
 5 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6a0cffd..df572af 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -84,6 +84,7 @@ int task_in_mem_cgroup(struct task_struct *task, const st=
ruct mem_cgroup *mem);
=20
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)=
;
=20
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *c=
group)
@@ -244,6 +245,11 @@ static inline struct mem_cgroup *try_get_mem_cgroup_fr=
om_page(struct page *page)
 	return NULL;
 }
=20
+static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_stru=
ct *mm)
+{
+	return NULL;
+}
+
 static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup =
*mem)
 {
 	return 1;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 384eb5f..ccea15d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -358,21 +358,31 @@ struct backing_dev_info;
 extern struct mm_struct *swap_token_mm;
 extern void grab_swap_token(struct mm_struct *);
 extern void __put_swap_token(struct mm_struct *);
+extern int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *m=
emcg);
=20
-static inline int has_swap_token(struct mm_struct *mm)
+static inline
+int has_swap_token(struct mm_struct *mm)
 {
-	return (mm =3D=3D swap_token_mm);
+	return has_swap_token_memcg(mm, NULL);
 }
=20
-static inline void put_swap_token(struct mm_struct *mm)
+static inline
+void put_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
 {
-	if (has_swap_token(mm))
+	if (has_swap_token_memcg(mm, memcg))
 		__put_swap_token(mm);
 }
=20
-static inline void disable_swap_token(void)
+static inline
+void put_swap_token(struct mm_struct *mm)
+{
+	return put_swap_token_memcg(mm, NULL);
+}
+
+static inline
+void disable_swap_token(struct mem_cgroup *memcg)
 {
-	put_swap_token(swap_token_mm);
+	put_swap_token_memcg(swap_token_mm, memcg);
 }
=20
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
@@ -500,7 +510,7 @@ static inline int has_swap_token(struct mm_struct *mm)
 	return 0;
 }
=20
-static inline void disable_swap_token(void)
+static inline void disable_swap_token(struct mem_cgroup *memcg)
 {
 }
=20
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c2776f1..5683c7a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -735,7 +735,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_str=
uct *p)
 				struct mem_cgroup, css);
 }
=20
-static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *mem =3D NULL;
=20
diff --git a/mm/thrash.c b/mm/thrash.c
index 2372d4e..f892a6e 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -21,6 +21,7 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/swap.h>
+#include <linux/memcontrol.h>
=20
 static DEFINE_SPINLOCK(swap_token_lock);
 struct mm_struct *swap_token_mm;
@@ -75,3 +76,19 @@ void __put_swap_token(struct mm_struct *mm)
 		swap_token_mm =3D NULL;
 	spin_unlock(&swap_token_lock);
 }
+
+int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
+{
+	if (memcg) {
+		struct mem_cgroup *swap_token_memcg;
+
+		/*
+		 * memcgroup reclaim can disable swap token only if token task
+		 * is in the same cgroup.
+		 */
+		swap_token_memcg =3D try_get_mem_cgroup_from_mm(swap_token_mm);
+		return ((mm =3D=3D swap_token_mm) && (memcg =3D=3D swap_token_memcg));
+	} else
+		return (mm =3D=3D swap_token_mm);
+}
+
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b3a569f..19e179b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2044,7 +2044,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,
 	for (priority =3D DEF_PRIORITY; priority >=3D 0; priority--) {
 		sc->nr_scanned =3D 0;
 		if (!priority)
-			disable_swap_token();
+			disable_swap_token(sc->mem_cgroup);
 		shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
@@ -2353,7 +2353,7 @@ loop_again:
=20
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
-			disable_swap_token();
+			disable_swap_token(NULL);
=20
 		all_zones_ok =3D 1;
 		balanced =3D 0;
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
