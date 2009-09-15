Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EDD9B6B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 22:56:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8F2uWe2006088
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Sep 2009 11:56:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DFDA45DE6F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:56:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEC9345DE6E
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:56:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEC311DB8037
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:56:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F30F1DB8041
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:56:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Isolated(anon) and Isolated(file)
In-Reply-To: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
References: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
Message-Id: <20090915114742.DB79.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 15 Sep 2009 11:56:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> Hi KOSAKI-san,
>=20
> May I question the addition of Isolated(anon) and Isolated(file)
> lines to /proc/meminfo?  I get irritated by all such "0 kB" lines!
>=20
> I see their appropriateness and usefulness in the Alt-Sysrq-M-style
> info which accompanies an OOM; and I see that those statistics help
> you to identify and fix bugs of having too many pages isolated.
>=20
> But IMHO they're too transient to be appropriate in /proc/meminfo:
> by the time the "cat /proc/meminfo" is done, the situation is very
> different (or should be once the bugs are fixed).
>=20
> Almost all its numbers are transient, of course, but these seem
> so much so that I think /proc/meminfo is better off without them
> (compressing more info into fewer lines).
>=20
> Perhaps I'm in the minority: if others care, what do they think?

I think Alt-Sysrq-M isn't useful in this case. because, if heavy memory
pressure occur, the administrator can't input "echo > /proc/sysrq-trigger"
to his terminal.
In the otherhand, many system get /proc/meminfo per every second. then,
the administrator can see last got statistics.

However, I halfly agree with you. Isolated field is transient value.
In almost case, it display 0kB. it is a bit annoy.

Fortunately, now /proc/vmstat and /sys/device/system/node/meminfo also
can display isolated value.
(As far as I rememberd, it was implemented by Wu's request)
We can use it. IOW, we can remove isolated field from /proc/meminfo.


How about following patch?


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D CUT HERE =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 7aa6fa2b76ff5d063b8bfa4a3af38c39b9396fd5 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 15 Sep 2009 10:16:51 +0900
Subject: [PATCH] Kill Isolated field in /proc/meminfo

Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
It is only increased at heavy memory pressure case.

So, if the system haven't get memory pressure, this field isn't useful.
And now, we have two alternative way, /sys/device/system/node/node{n}/memin=
fo
and /prov/vmstat. Then, it can be removed.

Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/meminfo.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 7d46c2e..c7bff4f 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -65,8 +65,6 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
 		"Unevictable:    %8lu kB\n"
-		"Isolated(anon): %8lu kB\n"
-		"Isolated(file): %8lu kB\n"
 		"Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -116,8 +114,6 @@ static int meminfo_proc_show(struct seq_file *m, void *=
v)
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_UNEVICTABLE]),
-		K(global_page_state(NR_ISOLATED_ANON)),
-		K(global_page_state(NR_ISOLATED_FILE)),
 		K(global_page_state(NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
--=20
1.6.2.5




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
