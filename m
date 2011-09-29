Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BD3E79000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 08:50:23 -0400 (EDT)
Received: by yxi19 with SMTP id 19so736970yxi.14
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 05:50:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317290085-3804-1-git-send-email-minchan.kim@gmail.com>
References: <20110928081452.GC23535@redhat.com> <1317290085-3804-1-git-send-email-minchan.kim@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 29 Sep 2011 21:50:02 +0900
Message-ID: <CAHGf_=rH4QThPidf9TD_d1qt3QJ-_mAJnH+XmP+ZJ0pOjpOTTQ@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: add barrier to prevent evictable page in
 unevictable list
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

2011/9/29 Minchan Kim <minchan.kim@gmail.com>:
> When racing between putback_lru_page and shmem_lock with lock=3D0 happens=
,
> progrom execution order is as follows, but clear_bit in processor #1
> could be reordered right before spin_unlock of processor #1.
> Then, the page would be stranded on the unevictable list.
>
> spin_lock
> SetPageLRU
> spin_unlock
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_bit(=
AS_UNEVICTABLE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if PageLRU=
()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0if !test_bit(AS_UNEVICTABLE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0move evictable list
> smp_mb
> if !test_bit(AS_UNEVICTABLE)
> =A0 =A0 =A0 =A0move evictable list
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unloc=
k
>
> But, pagevec_lookup in scan_mapping_unevictable_pages has rcu_read_[un]lo=
ck so
> it could protect reordering before reaching test_bit(AS_UNEVICTABLE) on p=
rocessor #1
> so this problem never happens. But it's a unexpected side effect and we s=
hould
> solve this problem properly.
>
> This patch adds a barrier after mapping_clear_unevictable.
>
> side-note: I didn't meet this problem but just found during review.
>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: Johannes Weiner <jweiner@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

  Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
