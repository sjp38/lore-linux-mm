Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C1FDA6B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:26:14 -0500 (EST)
Date: Tue, 27 Dec 2011 20:26:13 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] Makefiles: Disable unused-variable warning (was: Re:
 [PATCH 1/6] memcg: fix unused variable warning)
Message-ID: <20111227182613.GA21840@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
 <20111227135752.GK5344@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20111227135752.GK5344@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Marek <mmarek@suse.cz>, linux-kbuild@vger.kernel.org

On Tue, Dec 27, 2011 at 02:57:52PM +0100, Michal Hocko wrote:
> On Sat 24-12-11 05:00:14, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> >=20
> > mm/memcontrol.c: In function =E2=80=98memcg_check_events=E2=80=99:
> > mm/memcontrol.c:784:22: warning: unused variable =E2=80=98do_numainfo=
=E2=80=99 [-Wunused-variable]
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > ---
> >  mm/memcontrol.c |    7 ++++---
> >  1 files changed, 4 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index d643bd6..a5e92bd 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -781,14 +781,15 @@ static void memcg_check_events(struct mem_cgroup =
*memcg, struct page *page)
> >  	/* threshold event is triggered in finer grain than soft limit */
> >  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
> >  						MEM_CGROUP_TARGET_THRESH))) {
> > -		bool do_softlimit, do_numainfo;
> > +		bool do_softlimit;
> > =20
> > -		do_softlimit =3D mem_cgroup_event_ratelimit(memcg,
> > -						MEM_CGROUP_TARGET_SOFTLIMIT);
> >  #if MAX_NUMNODES > 1
> > +		bool do_numainfo;
> >  		do_numainfo =3D mem_cgroup_event_ratelimit(memcg,
> >  						MEM_CGROUP_TARGET_NUMAINFO);
> >  #endif
> > +		do_softlimit =3D mem_cgroup_event_ratelimit(memcg,
> > +						MEM_CGROUP_TARGET_SOFTLIMIT);
>=20
> I don't like this very much. Maybe we should get rid of both do_* and
> do it with flags? But maybe it is not worth the additional code at
> all...

Something like this (untested):

=3D=3D=3D=3D
=46rom f57e1a2e1aaaa167c75b963d5bf12fcbdd3331b8 Mon Sep 17 00:00:00 2001
=46rom: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Tue, 27 Dec 2011 20:17:13 +0200
Subject: [PATCH] memcg: cleanup memcg_check_events()

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   42 ++++++++++++++++++++++++------------------
 1 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d643bd6..40c2236 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -108,11 +108,12 @@ enum mem_cgroup_events_index {
  * than using jiffies etc. to handle periodic memcg event.
  */
 enum mem_cgroup_events_target {
-	MEM_CGROUP_TARGET_THRESH,
-	MEM_CGROUP_TARGET_SOFTLIMIT,
-	MEM_CGROUP_TARGET_NUMAINFO,
-	MEM_CGROUP_NTARGETS,
+	MEM_CGROUP_TARGET_THRESH	=3D BIT(1),
+	MEM_CGROUP_TARGET_SOFTLIMIT	=3D BIT(2),
+	MEM_CGROUP_TARGET_NUMAINFO	=3D BIT(3),
 };
+#define MEM_CGROUP_NTARGETS 3
+
 #define THRESHOLDS_EVENTS_TARGET (128)
 #define SOFTLIMIT_EVENTS_TARGET (1024)
 #define NUMAINFO_EVENTS_TARGET	(1024)
@@ -743,7 +744,7 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem=
_cgroup *memcg,
 	return total;
 }
=20
-static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
+static int mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 				       enum mem_cgroup_events_target target)
 {
 	unsigned long val, next;
@@ -766,9 +767,9 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgrou=
p *memcg,
 			break;
 		}
 		__this_cpu_write(memcg->stat->targets[target], next);
-		return true;
+		return target;
 	}
-	return false;
+	return 0;
 }
=20
 /*
@@ -777,29 +778,34 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgr=
oup *memcg,
  */
 static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 {
+	int flags;
+
 	preempt_disable();
-	/* threshold event is triggered in finer grain than soft limit */
-	if (unlikely(mem_cgroup_event_ratelimit(memcg,
-						MEM_CGROUP_TARGET_THRESH))) {
-		bool do_softlimit, do_numainfo;
+	flags =3D mem_cgroup_event_ratelimit(memcg, MEM_CGROUP_TARGET_THRESH);
=20
-		do_softlimit =3D mem_cgroup_event_ratelimit(memcg,
+	/*
+	 * Threshold event is triggered in finer grain than soft limit
+	 * and numainfo
+	 */
+	if (unlikely(flags)) {
+		flags |=3D mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_SOFTLIMIT);
 #if MAX_NUMNODES > 1
-		do_numainfo =3D mem_cgroup_event_ratelimit(memcg,
+		flags |=3D mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_NUMAINFO);
 #endif
-		preempt_enable();
+	}
+	preempt_enable();
=20
+	if (unlikely(flags)) {
 		mem_cgroup_threshold(memcg);
-		if (unlikely(do_softlimit))
+		if (unlikely(flags & MEM_CGROUP_TARGET_SOFTLIMIT))
 			mem_cgroup_update_tree(memcg, page);
 #if MAX_NUMNODES > 1
-		if (unlikely(do_numainfo))
+		if (unlikely(flags & MEM_CGROUP_TARGET_NUMAINFO))
 			atomic_inc(&memcg->numainfo_events);
 #endif
-	} else
-		preempt_enable();
+	}
 }
=20
 struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
--=20
1.7.7.3

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
