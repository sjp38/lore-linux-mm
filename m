Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6791B6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 02:02:31 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB872RAn030478
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Dec 2010 16:02:27 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6371745DEE2
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:02:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D99845DEDD
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:02:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 249E8E08001
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:02:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3B21DB803E
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:02:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [merged] mm-mempolicyc-add-rcu-read-lock-to-protect-pid-structure.patch removed from -mm tree
In-Reply-To: <201012071948.oB7Jm78B004585@imap1.linux-foundation.org>
References: <201012071948.oB7Jm78B004585@imap1.linux-foundation.org>
Message-Id: <20101208160009.173F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed,  8 Dec 2010 16:02:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, zengzm.kernel@gmail.com, cl@linux-foundation.org, paulmck@us.ibm.com, mm-commits@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>=20
> The patch titled
>      mm/mempolicy.c: add rcu read lock to protect pid structure
> has been removed from the -mm tree.  Its filename was
>      mm-mempolicyc-add-rcu-read-lock-to-protect-pid-structure.patch
>=20
> This patch was dropped because it was merged into mainline or a subsystem=
 tree
>=20
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmot=
m/
>=20
> ------------------------------------------------------
> Subject: mm/mempolicy.c: add rcu read lock to protect pid structure
> From: Zeng Zhaoming <zengzm.kernel@gmail.com>
>=20
> find_task_by_vpid() should be protected by rcu_read_lock(), to prevent
> free_pid() reclaiming pid.
>=20
> Signed-off-by: Zeng Zhaoming <zengzm.kernel@gmail.com>
> Cc: "Paul E. McKenney" <paulmck@us.ibm.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>


Andrew, please consider pick following patch too.



=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 9de9f70f74e55d92b5e9057e22fc629405f63295 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 16 Dec 2010 17:49:23 +0900
Subject: [PATCH] mempolicy: remove tasklist_lock from migrate_pages

Today, tasklist_lock in migrate_pages doesn't protect anything.=20
rcu_read_lock() provide enough protection from pid hash walk.

Reported-by: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 11ff260..9064945 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1308,16 +1308,13 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned=
 long, maxnode,
=20
 	/* Find the mm_struct */
 	rcu_read_lock();
-	read_lock(&tasklist_lock);
 	task =3D pid ? find_task_by_vpid(pid) : current;
 	if (!task) {
-		read_unlock(&tasklist_lock);
 		rcu_read_unlock();
 		err =3D -ESRCH;
 		goto out;
 	}
 	mm =3D get_task_mm(task);
-	read_unlock(&tasklist_lock);
 	rcu_read_unlock();
=20
 	err =3D -EINVAL;
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
