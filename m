Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2C5C900138
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 03:28:27 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p7T7SOun013282
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:28:24 -0700
Received: from qyk4 (qyk4.prod.google.com [10.241.83.132])
	by hpaq14.eem.corp.google.com with ESMTP id p7T7S8Dd028561
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:28:23 -0700
Received: by qyk4 with SMTP id 4so1644680qyk.13
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:28:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110720003653.GA667@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
	<CALWz4iwDGD8xoUbzi=9Sy7C-njcYqmka_25rQL8RhkN_ArLgDw@mail.gmail.com>
	<20110720003653.GA667@cmpxchg.org>
Date: Mon, 29 Aug 2011 00:28:22 -0700
Message-ID: <CALWz4iy-EXmRrwPGW=d=0iHGVvKfB1yQEQBb2QYGmPCKHZtE=g@mail.gmail.com>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Tue, Jul 19, 2011 at 5:36 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Jul 19, 2011 at 03:47:43PM -0700, Ying Han wrote:
>> On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org>wr=
ote:
>>
>> > Once the per-memcg lru lists are exclusive, the unevictable page
>> > rescue scanner can no longer work on the global zone lru lists.
>> >
>> > This converts it to go through all memcgs and scan their respective
>> > unevictable lists instead.
>> >
>> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> > ---
>> > =A0include/linux/memcontrol.h | =A0 =A02 +
>> > =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +++++++++
>> > =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 53
>> > +++++++++++++++++++++++++++----------------
>> > =A03 files changed, 46 insertions(+), 20 deletions(-)
>> >
>> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> > index cb02c00..56c1def 100644
>> > --- a/include/linux/memcontrol.h
>> > +++ b/include/linux/memcontrol.h
>> > @@ -60,6 +60,8 @@ extern void mem_cgroup_cancel_charge_swapin(struct
>> > mem_cgroup *ptr);
>> >
>> > =A0extern int mem_cgroup_cache_charge(struct page *page, struct mm_str=
uct
>> > *mm,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0gfp_t gfp_mask);
>> > +struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup =
*,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
enum lru_list);
>> >
>>
>> Did we miss a #ifdef case for this function? I got compile error by
>> disabling memcg.
>
> I assume it's because the call to it is not optimized away properly in
> the disabled case. =A0I'll have it fixed in the next round, thanks for
> letting me know.
>

Hi Johannes:

This is the change for the hierarchy_walk() sent on the other patch,
also including a fix. Please consider to fold in your patch:

Fix the hierarchy_walk() in the unevictable page rescue scanner

the patch including changes
1. adjust the change in hierarchy_walk() which needs to hold the reference =
to
the first mem_cgroup.
2. add stop_hierarchy_walk() at the end which is missed on the original pat=
ch.

Signed-off-by: Ying Han <yinghan@google.com>

Change-Id: I72fb5d351faf0f111c8c99edd90b6cfee6281d3f
---
 mm/memcontrol.c |    3 +++
 mm/vmscan.c     |    7 ++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9bcd429..426092b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1514,6 +1514,9 @@ void mem_cgroup_stop_hierarchy_walk(struct
mem_cgroup *target,
 >------>------->------->-------    struct mem_cgroup *first,
 >------>------->------->-------    struct mem_cgroup *mem)
 {
+>------if (!target)
+>------>-------target =3D root_mem_cgroup;
+
 >------if (mem && mem !=3D target)
 >------>-------css_put(&mem->css);
=B7
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 290998e..fd9593b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4110,9 +4110,9 @@ static struct page *lru_tailpage(struct zone
*zone, struct mem_cgroup *mem,
 #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size=
 */
 static void scan_zone_unevictable_pages(struct zone *zone)
 {
->------struct mem_cgroup *first, *mem =3D NULL;
+>------struct mem_cgroup *first, *mem;
=B7
->------first =3D mem =3D mem_cgroup_hierarchy_walk(NULL, mem);
+>------first =3D mem =3D mem_cgroup_hierarchy_walk(NULL, NULL, NULL);
 >------do {
 >------>-------unsigned long nr_to_scan;
=B7
@@ -4139,8 +4139,9 @@ static void scan_zone_unevictable_pages(struct zone *=
zone)
 >------>------->-------spin_unlock_irq(&zone->lru_lock);
 >------>------->-------nr_to_scan -=3D batch_size;
 >------>-------}
->------>-------mem =3D mem_cgroup_hierarchy_walk(NULL, mem);
+>------>-------mem =3D mem_cgroup_hierarchy_walk(NULL, first, mem);
 >------} while (mem !=3D first);
+>------mem_cgroup_stop_hierarchy_walk(NULL, first, mem);
 }

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
