Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 56F9E6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 22:09:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8G29tPP010908
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Sep 2009 11:09:56 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C13EC2AEA82
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:09:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9944D1EF085
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:09:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 78647E1800F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:09:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2619AE18010
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:09:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Isolated(anon) and Isolated(file)
In-Reply-To: <Pine.LNX.4.64.0909160047480.4234@sister.anvils>
References: <20090915114742.DB79.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0909160047480.4234@sister.anvils>
Message-Id: <20090916091022.DB8C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 16 Sep 2009 11:09:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 15 Sep 2009, KOSAKI Motohiro wrote:
> > From 7aa6fa2b76ff5d063b8bfa4a3af38c39b9396fd5 Mon Sep 17 00:00:00 2001
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Date: Tue, 15 Sep 2009 10:16:51 +0900
> > Subject: [PATCH] Kill Isolated field in /proc/meminfo
> >=20
> > Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
> > It is only increased at heavy memory pressure case.
> >=20
> > So, if the system haven't get memory pressure, this field isn't useful.
> > And now, we have two alternative way, /sys/device/system/node/node{n}/m=
eminfo
> > and /prov/vmstat. Then, it can be removed.
> >=20
> > Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>=20
> Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
>=20
> I should be overjoyed that you agree to hide the Isolateds from my sight:
> thank you.  But in fact I'm a little depressed, now you've reminded me of
> almost-the-same-but-annoyingly-different /sys/devices/unmemorable/meminfo.
>=20
> Oh well, since I never see it (I'd need some nodes), I guess I don't
> even need to turn a blind eye to it; and it already contains other
> stuff I objected to in /proc/meminfo.
>=20
> I still think your Isolateds make most sense in the OOM display;
> and yes, they are there in /proc/vmstat, that's good too.

Hmm..
You touch different another problem. /proc/vmstat don't have sufficient
capability. Recently average #-of-cpus and numa rapidly become common.
Then, many administrator decide to run two or more each unrelated workload
on one machine and they are separated by cpuset.

However, /proc/vmstat don't have per-numa nor per-cpuset capability. then,
We lost a way of getting vm statistics.

<btw>
Another several user want per-memcgroup statistics. another user want anoth=
er.
Several month ago, Ingo proposed object based tracing framework and /proc/v=
mstat
replace with it. I like his idea. but flexibility statiscis decrease
system performnce a bit. My brain haven't got the answer.
</btw>


Anyway, we need to decide drop or not before merge the patch. unfortunately
current is merge window.
Then, I decide to drop /sys/devices/node/meminfo too at once. Perhaps I'll
resubmit the same patch after (Of cource, perhaps not), but We know field
adding is feature enhancement but field removing is regression.

Andrew, very sorry, could you please pick up following patch and it merge
my last patch? the patch description also be rewritten.


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
=46rom 094c314ba851171d8201f4446783341ea0d22141 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 16 Sep 2009 09:22:44 +0900
Subject: [PATCH] Kill Isolated field in /proc/meminfo fix

Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
It is only increased at heavy memory pressure case.

So, if the system haven't get memory pressure, this field isn't useful.
And now, we have an alternative way, (i.e. /prov/vmstat).
Then, it can be removed.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/base/node.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index f50621b..1fe5536 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -73,8 +73,6 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
-		       "Node %d Isolated(anon): %8lu kB\n"
-		       "Node %d Isolated(file): %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
@@ -108,8 +106,6 @@ static ssize_t node_read_meminfo(struct sys_device * de=
v,
 		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
-		       nid, K(node_page_state(nid, NR_ISOLATED_ANON)),
-		       nid, K(node_page_state(nid, NR_ISOLATED_FILE)),
 		       nid, K(node_page_state(nid, NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
--=20
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
