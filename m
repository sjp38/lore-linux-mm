Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 16C648D0040
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:58:38 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3JHwYQZ032700
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:58:34 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by hpaq1.eem.corp.google.com with ESMTP id p3JHwLqr015461
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:58:32 -0700
Received: by qwh5 with SMTP id 5so4212952qwh.34
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:58:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303235496-3060-2-git-send-email-yinghan@google.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
	<1303235496-3060-2-git-send-email-yinghan@google.com>
Date: Tue, 19 Apr 2011 10:58:32 -0700
Message-ID: <BANLkTinoz_+DW40fV23j1-PeTbHHEXcywA@mail.gmail.com>
Subject: Re: [PATCH 1/3] move scan_control definition to header file
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee09b39e104a14941cd
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

--000e0cd68ee09b39e104a14941cd
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 10:51 AM, Ying Han <yinghan@google.com> wrote:

> This patch moves the scan_control definition from vmscan to swap.h
> header file, which is needed later to pass the struct to shrinkers.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/swap.h |   61
> ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c          |   61
> --------------------------------------------------
>  2 files changed, 61 insertions(+), 61 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ed6ebe6..cb48fbd 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -16,6 +16,67 @@ struct notifier_block;
>
>  struct bio;
>
> +/*
> + * reclaim_mode determines how the inactive list is shrunk
> + * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
> + * RECLAIM_MODE_ASYNC:  Do not block
> + * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
> + * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference
> + *                     page from the LRU and reclaim all pages within a
> + *                     naturally aligned range
> + * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number
> of
> + *                     order-0 pages and then compact the zone
> + */
> +typedef unsigned __bitwise__ reclaim_mode_t;
> +#define RECLAIM_MODE_SINGLE            ((__force reclaim_mode_t)0x01u)
> +#define RECLAIM_MODE_ASYNC             ((__force reclaim_mode_t)0x02u)
> +#define RECLAIM_MODE_SYNC              ((__force reclaim_mode_t)0x04u)
> +#define RECLAIM_MODE_LUMPYRECLAIM      ((__force reclaim_mode_t)0x08u)
> +#define RECLAIM_MODE_COMPACTION                ((__force
> reclaim_mode_t)0x10u)
> +
> +struct scan_control {
> +       /* Incremented by the number of inactive pages that were scanned */
> +       unsigned long nr_scanned;
> +
> +       /* Number of pages freed so far during a call to shrink_zones() */
> +       unsigned long nr_reclaimed;
> +
> +       /* How many pages shrink_list() should reclaim */
> +       unsigned long nr_to_reclaim;
> +
> +       unsigned long hibernation_mode;
> +
> +       /* This context's GFP mask */
> +       gfp_t gfp_mask;
> +
> +       int may_writepage;
> +
> +       /* Can mapped pages be reclaimed? */
> +       int may_unmap;
> +
> +       /* Can pages be swapped as part of reclaim? */
> +       int may_swap;
> +
> +       int swappiness;
> +
> +       int order;
> +
> +       /*
> +        * Intend to reclaim enough continuous memory rather than reclaim
> +        * enough amount of memory. i.e, mode for high order allocation.
> +        */
> +       reclaim_mode_t reclaim_mode;
> +
> +       /* Which cgroup do we reclaim from */
> +       struct mem_cgroup *mem_cgroup;
> +
> +       /*
> +        * Nodemask of nodes allowed by the caller. If NULL, all nodes
> +        * are scanned.
> +        */
> +       nodemask_t      *nodemask;
> +};
> +
>  #define SWAP_FLAG_PREFER       0x8000  /* set if swap priority specified
> */
>  #define SWAP_FLAG_PRIO_MASK    0x7fff
>  #define SWAP_FLAG_PRIO_SHIFT   0
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 060e4c1..08b1ab5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -52,67 +52,6 @@
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/vmscan.h>
>
> -/*
> - * reclaim_mode determines how the inactive list is shrunk
> - * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
> - * RECLAIM_MODE_ASYNC:  Do not block
> - * RECLAIM_MODE_SYNC:   Allow blocking e.g. call wait_on_page_writeback
> - * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference
> - *                     page from the LRU and reclaim all pages within a
> - *                     naturally aligned range
> - * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number
> of
> - *                     order-0 pages and then compact the zone
> - */
> -typedef unsigned __bitwise__ reclaim_mode_t;
> -#define RECLAIM_MODE_SINGLE            ((__force reclaim_mode_t)0x01u)
> -#define RECLAIM_MODE_ASYNC             ((__force reclaim_mode_t)0x02u)
> -#define RECLAIM_MODE_SYNC              ((__force reclaim_mode_t)0x04u)
> -#define RECLAIM_MODE_LUMPYRECLAIM      ((__force reclaim_mode_t)0x08u)
> -#define RECLAIM_MODE_COMPACTION                ((__force
> reclaim_mode_t)0x10u)
> -
> -struct scan_control {
> -       /* Incremented by the number of inactive pages that were scanned */
> -       unsigned long nr_scanned;
> -
> -       /* Number of pages freed so far during a call to shrink_zones() */
> -       unsigned long nr_reclaimed;
> -
> -       /* How many pages shrink_list() should reclaim */
> -       unsigned long nr_to_reclaim;
> -
> -       unsigned long hibernation_mode;
> -
> -       /* This context's GFP mask */
> -       gfp_t gfp_mask;
> -
> -       int may_writepage;
> -
> -       /* Can mapped pages be reclaimed? */
> -       int may_unmap;
> -
> -       /* Can pages be swapped as part of reclaim? */
> -       int may_swap;
> -
> -       int swappiness;
> -
> -       int order;
> -
> -       /*
> -        * Intend to reclaim enough continuous memory rather than reclaim
> -        * enough amount of memory. i.e, mode for high order allocation.
> -        */
> -       reclaim_mode_t reclaim_mode;
> -
> -       /* Which cgroup do we reclaim from */
> -       struct mem_cgroup *mem_cgroup;
> -
> -       /*
> -        * Nodemask of nodes allowed by the caller. If NULL, all nodes
> -        * are scanned.
> -        */
> -       nodemask_t      *nodemask;
> -};
> -
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
>
>  #ifdef ARCH_HAS_PREFETCH
> --
> 1.7.3.1
>
>

--000e0cd68ee09b39e104a14941cd
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 10:51 AM, Ying H=
an <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
This patch moves the scan_control definition from vmscan to swap.h<br>
header file, which is needed later to pass the struct to shrinkers.<br>
<br>
Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@g=
oogle.com</a>&gt;<br>
---<br>
=A0include/linux/swap.h | =A0 61 ++++++++++++++++++++++++++++++++++++++++++=
++++++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0| =A0 61 --------------------------------=
------------------<br>
=A02 files changed, 61 insertions(+), 61 deletions(-)<br>
<br>
diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
index ed6ebe6..cb48fbd 100644<br>
--- a/include/linux/swap.h<br>
+++ b/include/linux/swap.h<br>
@@ -16,6 +16,67 @@ struct notifier_block;<br>
<br>
=A0struct bio;<br>
<br>
+/*<br>
+ * reclaim_mode determines how the inactive list is shrunk<br>
+ * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages<br>
+ * RECLAIM_MODE_ASYNC: =A0Do not block<br>
+ * RECLAIM_MODE_SYNC: =A0 Allow blocking e.g. call wait_on_page_writeback<=
br>
+ * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference=
<br>
+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page from the LRU and reclaim a=
ll pages within a<br>
+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 naturally aligned range<br>
+ * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number o=
f<br>
+ * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order-0 pages and then compact =
the zone<br>
+ */<br>
+typedef unsigned __bitwise__ reclaim_mode_t;<br>
+#define RECLAIM_MODE_SINGLE =A0 =A0 =A0 =A0 =A0 =A0((__force reclaim_mode_=
t)0x01u)<br>
+#define RECLAIM_MODE_ASYNC =A0 =A0 =A0 =A0 =A0 =A0 ((__force reclaim_mode_=
t)0x02u)<br>
+#define RECLAIM_MODE_SYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0((__force reclaim_mod=
e_t)0x04u)<br>
+#define RECLAIM_MODE_LUMPYRECLAIM =A0 =A0 =A0((__force reclaim_mode_t)0x08=
u)<br>
+#define RECLAIM_MODE_COMPACTION =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((__force r=
eclaim_mode_t)0x10u)<br>
+<br>
+struct scan_control {<br>
+ =A0 =A0 =A0 /* Incremented by the number of inactive pages that were scan=
ned */<br>
+ =A0 =A0 =A0 unsigned long nr_scanned;<br>
+<br>
+ =A0 =A0 =A0 /* Number of pages freed so far during a call to shrink_zones=
() */<br>
+ =A0 =A0 =A0 unsigned long nr_reclaimed;<br>
+<br>
+ =A0 =A0 =A0 /* How many pages shrink_list() should reclaim */<br>
+ =A0 =A0 =A0 unsigned long nr_to_reclaim;<br>
+<br>
+ =A0 =A0 =A0 unsigned long hibernation_mode;<br>
+<br>
+ =A0 =A0 =A0 /* This context&#39;s GFP mask */<br>
+ =A0 =A0 =A0 gfp_t gfp_mask;<br>
+<br>
+ =A0 =A0 =A0 int may_writepage;<br>
+<br>
+ =A0 =A0 =A0 /* Can mapped pages be reclaimed? */<br>
+ =A0 =A0 =A0 int may_unmap;<br>
+<br>
+ =A0 =A0 =A0 /* Can pages be swapped as part of reclaim? */<br>
+ =A0 =A0 =A0 int may_swap;<br>
+<br>
+ =A0 =A0 =A0 int swappiness;<br>
+<br>
+ =A0 =A0 =A0 int order;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Intend to reclaim enough continuous memory rather than r=
eclaim<br>
+ =A0 =A0 =A0 =A0* enough amount of memory. i.e, mode for high order alloca=
tion.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 reclaim_mode_t reclaim_mode;<br>
+<br>
+ =A0 =A0 =A0 /* Which cgroup do we reclaim from */<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem_cgroup;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Nodemask of nodes allowed by the caller. If NULL, all no=
des<br>
+ =A0 =A0 =A0 =A0* are scanned.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;<br>
+};<br>
+<br>
=A0#define SWAP_FLAG_PREFER =A0 =A0 =A0 0x8000 =A0/* set if swap priority s=
pecified */<br>
=A0#define SWAP_FLAG_PRIO_MASK =A0 =A00x7fff<br>
=A0#define SWAP_FLAG_PRIO_SHIFT =A0 0<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 060e4c1..08b1ab5 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -52,67 +52,6 @@<br>
=A0#define CREATE_TRACE_POINTS<br>
=A0#include &lt;trace/events/vmscan.h&gt;<br>
<br>
-/*<br>
- * reclaim_mode determines how the inactive list is shrunk<br>
- * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages<br>
- * RECLAIM_MODE_ASYNC: =A0Do not block<br>
- * RECLAIM_MODE_SYNC: =A0 Allow blocking e.g. call wait_on_page_writeback<=
br>
- * RECLAIM_MODE_LUMPYRECLAIM: For high-order allocations, take a reference=
<br>
- * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page from the LRU and reclaim a=
ll pages within a<br>
- * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 naturally aligned range<br>
- * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number o=
f<br>
- * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order-0 pages and then compact =
the zone<br>
- */<br>
-typedef unsigned __bitwise__ reclaim_mode_t;<br>
-#define RECLAIM_MODE_SINGLE =A0 =A0 =A0 =A0 =A0 =A0((__force reclaim_mode_=
t)0x01u)<br>
-#define RECLAIM_MODE_ASYNC =A0 =A0 =A0 =A0 =A0 =A0 ((__force reclaim_mode_=
t)0x02u)<br>
-#define RECLAIM_MODE_SYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0((__force reclaim_mod=
e_t)0x04u)<br>
-#define RECLAIM_MODE_LUMPYRECLAIM =A0 =A0 =A0((__force reclaim_mode_t)0x08=
u)<br>
-#define RECLAIM_MODE_COMPACTION =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((__force r=
eclaim_mode_t)0x10u)<br>
-<br>
-struct scan_control {<br>
- =A0 =A0 =A0 /* Incremented by the number of inactive pages that were scan=
ned */<br>
- =A0 =A0 =A0 unsigned long nr_scanned;<br>
-<br>
- =A0 =A0 =A0 /* Number of pages freed so far during a call to shrink_zones=
() */<br>
- =A0 =A0 =A0 unsigned long nr_reclaimed;<br>
-<br>
- =A0 =A0 =A0 /* How many pages shrink_list() should reclaim */<br>
- =A0 =A0 =A0 unsigned long nr_to_reclaim;<br>
-<br>
- =A0 =A0 =A0 unsigned long hibernation_mode;<br>
-<br>
- =A0 =A0 =A0 /* This context&#39;s GFP mask */<br>
- =A0 =A0 =A0 gfp_t gfp_mask;<br>
-<br>
- =A0 =A0 =A0 int may_writepage;<br>
-<br>
- =A0 =A0 =A0 /* Can mapped pages be reclaimed? */<br>
- =A0 =A0 =A0 int may_unmap;<br>
-<br>
- =A0 =A0 =A0 /* Can pages be swapped as part of reclaim? */<br>
- =A0 =A0 =A0 int may_swap;<br>
-<br>
- =A0 =A0 =A0 int swappiness;<br>
-<br>
- =A0 =A0 =A0 int order;<br>
-<br>
- =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0* Intend to reclaim enough continuous memory rather than r=
eclaim<br>
- =A0 =A0 =A0 =A0* enough amount of memory. i.e, mode for high order alloca=
tion.<br>
- =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 reclaim_mode_t reclaim_mode;<br>
-<br>
- =A0 =A0 =A0 /* Which cgroup do we reclaim from */<br>
- =A0 =A0 =A0 struct mem_cgroup *mem_cgroup;<br>
-<br>
- =A0 =A0 =A0 /*<br>
- =A0 =A0 =A0 =A0* Nodemask of nodes allowed by the caller. If NULL, all no=
des<br>
- =A0 =A0 =A0 =A0* are scanned.<br>
- =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;<br>
-};<br>
-<br>
=A0#define lru_to_page(_head) (list_entry((_head)-&gt;prev, struct page, lr=
u))<br>
<br>
=A0#ifdef ARCH_HAS_PREFETCH<br>
<font color=3D"#888888">--<br>
1.7.3.1<br>
<br>
</font></blockquote></div><br>

--000e0cd68ee09b39e104a14941cd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
