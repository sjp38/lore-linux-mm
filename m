Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D34D6B0062
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 21:00:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH20jjH011972
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 11:00:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6427545DE4D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 11:00:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 39CAA45DE60
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 11:00:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 108DC1DB8041
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 11:00:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CFCC1DB803E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 11:00:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <Pine.LNX.4.64.0911152217030.29917@sister.anvils>
References: <20091113143930.33BF.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0911152217030.29917@sister.anvils>
Message-Id: <20091117103620.3DC4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 17 Nov 2009 11:00:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 13 Nov 2009, KOSAKI Motohiro wrote:
> > if so, following additional patch makes more consistent?
> > ----------------------------------
> > From 3fd3bc58dc6505af73ecf92c981609ecf8b6ac40 Mon Sep 17 00:00:00 2001
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Date: Fri, 13 Nov 2009 16:52:03 +0900
> > Subject: [PATCH] [RFC] mm: non linear mapping page don't mark as PG_mlo=
cked
> >=20
> > Now, try_to_unmap_file() lost the capability to treat VM_NONLINEAR.
>=20
> Now?
> Genuine try_to_unmap_file() deals with VM_NONLINEAR (including VM_LOCKED)
> much as it always did, I think.  But try_to_munlock() on a VM_NONLINEAR
> has not being doing anything useful, I assume ever since it was added,
> but haven't checked the history.
>=20
> But so what?  try_to_munlock() has those down_read_trylock()s which make
> it never quite reliable.  In the VM_NONLINEAR case it has simply been
> giving up rather more easily.

I catched your point, maybe. thanks, correct me. I agree your lazy=20
discovery method.

So, Can we add more kindly comment? (see below)



> > Then, mlock() shouldn't mark the page of non linear mapping as
> > PG_mlocked. Otherwise the page continue to drinker walk between
> > evictable and unevictable lru.
>=20
> I do like your phrase "drinker walk".  But is it really worse than
> the lazy discovery of the page being locked, which is how I thought
> this stuff was originally supposed to work anyway.  I presume cases
> were found in which the counts got so far out that it was a problem?
>=20
> I liked the lazy discovery much better than trying to keep count;
> can we just accept that VM_NONLINEAR may leave the counts further
> away from exactitude?
>=20
> I don't think this patch makes things more consistent, really.
> It does make sys_remap_file_pages on an mlocked area inconsistent
> with mlock on a sys_remap_file_pages area, doesn't it?

you are right.



=46rom 7332f765dbaa1fbfe48cf8d53b20048f7f8105e0 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 17 Nov 2009 10:46:51 +0900
Subject: comment adding to mlocking in try_to_unmap_one

Current code doesn't tell us why we don't bother to nonlinear kindly.
This patch added small adding explanation.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 81a168c..c631407 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1061,7 +1061,11 @@ static int try_to_unmap_file(struct page *page, enum=
 ttu_flags flags)
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
=20
-	/* We don't bother to try to find the munlocked page in nonlinears */
+	/*
+	 * We don't bother to try to find the munlocked page in nonlinears.
+	 * It's costly. Instead, later, page reclaim logic may call
+	 * try_to_unmap(TTU_MUNLOCK) and recover PG_mlocked lazily.
+	 */
 	if (MLOCK_PAGES && TTU_ACTION(flags) =3D=3D TTU_MUNLOCK)
 		goto out;
=20
--=20
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
