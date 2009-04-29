Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B00296B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 12:07:45 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so688269yxh.26
        for <linux-mm@kvack.org>; Wed, 29 Apr 2009 09:07:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090429114708.66114c03@cuia.bos.redhat.com>
References: <20090428044426.GA5035@eskimo.com>
	 <20090428192907.556f3a34@bree.surriel.com>
	 <1240987349.4512.18.camel@laptop>
	 <20090429114708.66114c03@cuia.bos.redhat.com>
Date: Thu, 30 Apr 2009 01:07:51 +0900
Message-ID: <2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Looks good than previous version. but I have one question.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eac9577..4471dcb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1489,6 +1489,18 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr[l] =3D scan;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* When the system is doing streaming IO, memory pressure=
 here
> + =A0 =A0 =A0 =A0* ensures that active file pages get deactivated, until =
more
> + =A0 =A0 =A0 =A0* than half of the file pages are on the inactive list.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Once we get to that situation, protect the system's wo=
rking
> + =A0 =A0 =A0 =A0* set from being evicted by disabling active file page a=
ging.
> + =A0 =A0 =A0 =A0* The logic in get_scan_ratio protects anonymous pages.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (nr[LRU_INACTIVE_FILE] > nr[LRU_ACTIVE_FILE])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr[LRU_ACTIVE_FILE] =3D 0;
> +
> =A0 =A0 =A0 =A0while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0nr[LRU_INACTIVE_FILE]) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_evictable_lru(l) {

we handle active_anon vs inactive_anon ratio by shrink_list().
Why do you insert this logic insert shrink_zone() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
