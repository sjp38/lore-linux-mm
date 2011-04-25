Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 12F148D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:35:56 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3PHZl8j030047
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:35:48 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by hpaq1.eem.corp.google.com with ESMTP id p3PHZeUP020988
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:35:41 -0700
Received: by qwc23 with SMTP id 23so1508361qwc.31
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:35:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425183426.6a791ec9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183426.6a791ec9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 10:35:39 -0700
Message-ID: <BANLkTinLbssMOgmak+pUmhZpfuqveEDTLA@mail.gmail.com>
Subject: Re: [PATCH 4/7] memcg fix scan ratio with small memcg.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bcda1a6b04a1c1a28e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

--000e0ce008bcda1a6b04a1c1a28e
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 2:34 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> At memcg memory reclaim, get_scan_count() may returns [0, 0, 0, 0]
> and no scan was not issued at the reclaim priority.
>
> The reason is because memory cgroup may not be enough big to have
> the number of pages, which is greater than 1 << priority.
>
> Because priority affects many routines in vmscan.c, it's better
> to scan memory even if usage >> priority < 0.
> From another point of view, if memcg's zone doesn't have enough memory
> which
> meets priority, it should be skipped. So, this patch creates a temporal
> priority
> in get_scan_count() and scan some amount of pages even when
> usage is small. By this, memcg's reclaim goes smoother without
> having too high priority, which will cause unnecessary congestion_wait(),
> etc.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    6 ++++++
>  mm/memcontrol.c            |    5 +++++
>  mm/vmscan.c                |   11 +++++++++++
>  3 files changed, 22 insertions(+)
>
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -152,6 +152,7 @@ unsigned long mem_cgroup_soft_limit_recl
>                                                gfp_t gfp_mask,
>                                                unsigned long
> *total_scanned);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> +u64 mem_cgroup_get_usage(struct mem_cgroup *mem);
>
>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item
> idx);
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -357,6 +358,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro
>        return 0;
>  }
>
> +static inline u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
> +{
> +       return 0;
> +}
> +
>

should be  mem_cgroup_get_usage()


 static inline void mem_cgroup_split_huge_fixup(struct page *head,
>                                                struct page *tail)
>  {
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -1483,6 +1483,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro
>        return min(limit, memsw);
>  }
>
> +u64 mem_cgroup_get_usage(struct mem_cgroup *memcg)
> +{
> +       return res_counter_read_u64(&memcg->res, RES_USAGE);
> +}
> +
>  /*
>  * Visit the first child (need not be the first child as per the ordering
>  * of the cgroup list, since we track last_scanned_child) of @mem and use
> Index: memcg/mm/vmscan.c
> ===================================================================
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -1762,6 +1762,17 @@ static void get_scan_count(struct zone *
>                        denominator = 1;
>                        goto out;
>                }
> +       } else {
> +               u64 usage;
> +               /*
> +                * When memcg is enough small, anon+file >> priority
> +                * can be 0 and we'll do no scan. Adjust it to proper
> +                * value against its usage. If this zone's usage is enough
> +                * small, scan will ignore this zone until priority goes
> down.
> +                */
> +               for (usage = mem_cgroup_get_usage(sc->mem_cgroup) >>
> PAGE_SHIFT;
> +                    priority && ((usage >> priority) < SWAP_CLUSTER_MAX);
> +                    priority--);
>        }
>

--Ying

>
>        /*
>
>

--000e0ce008bcda1a6b04a1c1a28e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 2:34 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<br>
At memcg memory reclaim, get_scan_count() may returns [0, 0, 0, 0]<br>
and no scan was not issued at the reclaim priority.<br>
<br>
The reason is because memory cgroup may not be enough big to have<br>
the number of pages, which is greater than 1 &lt;&lt; priority.<br>
<br>
Because priority affects many routines in vmscan.c, it&#39;s better<br>
to scan memory even if usage &gt;&gt; priority &lt; 0.<br>
>From another point of view, if memcg&#39;s zone doesn&#39;t have enough mem=
ory which<br>
meets priority, it should be skipped. So, this patch creates a temporal pri=
ority<br>
in get_scan_count() and scan some amount of pages even when<br>
usage is small. By this, memcg&#39;s reclaim goes smoother without<br>
having too high priority, which will cause unnecessary congestion_wait(), e=
tc.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A06 ++++++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 +++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +++++++++++<br>
=A03 files changed, 22 insertions(+)<br>
<br>
Index: memcg/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/memcontrol.h<br>
+++ memcg/include/linux/memcontrol.h<br>
@@ -152,6 +152,7 @@ unsigned long mem_cgroup_soft_limit_recl<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned long *total_scanned);<br>
=A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);<br>
+u64 mem_cgroup_get_usage(struct mem_cgroup *mem);<br>
<br>
=A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item =
idx);<br>
=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE<br>
@@ -357,6 +358,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
<br>
+static inline u64 mem_cgroup_get_limit(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br></blockquote><div><br></div><div>should be =A0mem_cgroup_get_usage()=
=A0</div><div><br></div><div><br></div><meta http-equiv=3D"content-type" co=
ntent=3D"text/html; charset=3Dutf-8"><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

=A0static inline void mem_cgroup_split_huge_fixup(struct page *head,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0struct page *tail)<br>
=A0{<br>
Index: memcg/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/memcontrol.c<br>
+++ memcg/mm/memcontrol.c<br>
@@ -1483,6 +1483,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro<br>
 =A0 =A0 =A0 =A0return min(limit, memsw);<br>
=A0}<br>
<br>
+u64 mem_cgroup_get_usage(struct mem_cgroup *memcg)<br>
+{<br>
+ =A0 =A0 =A0 return res_counter_read_u64(&amp;memcg-&gt;res, RES_USAGE);<b=
r>
+}<br>
+<br>
=A0/*<br>
 =A0* Visit the first child (need not be the first child as per the orderin=
g<br>
 =A0* of the cgroup list, since we track last_scanned_child) of @mem and us=
e<br>
Index: memcg/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/vmscan.c<br>
+++ memcg/mm/vmscan.c<br>
@@ -1762,6 +1762,17 @@ static void get_scan_count(struct zone *<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0denominator =3D 1;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 usage;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* When memcg is enough small, anon+file &g=
t;&gt; priority<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can be 0 and we&#39;ll do no scan. Adjus=
t it to proper<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* value against its usage. If this zone&#3=
9;s usage is enough<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* small, scan will ignore this zone until =
priority goes down.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (usage =3D mem_cgroup_get_usage(sc-&gt;me=
m_cgroup) &gt;&gt; PAGE_SHIFT;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priority &amp;&amp; ((usage &gt;&g=
t; priority) &lt; SWAP_CLUSTER_MAX);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priority--);<br>
 =A0 =A0 =A0 =A0}<br></blockquote><div><br></div><div>--Ying=A0</div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex;">
<br>
 =A0 =A0 =A0 =A0/*<br>
<br>
</blockquote></div><br>

--000e0ce008bcda1a6b04a1c1a28e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
