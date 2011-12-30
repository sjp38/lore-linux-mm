Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 310FF6B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 03:12:12 -0500 (EST)
Received: by yenq10 with SMTP id q10so9354497yen.14
        for <linux-mm@kvack.org>; Fri, 30 Dec 2011 00:12:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1325226961-4271-1-git-send-email-tm@tao.ma>
References: <1325226961-4271-1-git-send-email-tm@tao.ma>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 30 Dec 2011 03:11:49 -0500
Message-ID: <CAHGf_=qOGy3MQgiFyfeG82+gbDXTBT5KQjgR7JqMfQ7e7RSGpA@mail.gmail.com>
Subject: Re: [PATCH] mm: do not drain pagevecs for mlock
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

2011/12/30 Tao Ma <tm@tao.ma>:
> In our test of mlock, we have found some severe performance regression
> in it. Some more investigations show that mlocked is blocked heavily
> by lur_add_drain_all which calls schedule_on_each_cpu and flush the work
> queue which is very slower if we have several cpus.
>
> So we have tried 2 ways to solve it:
> 1. Add a per cpu counter for all the pagevecs so that we don't schedule
> =A0 and flush the lru_drain work if the cpu doesn't have any pagevecs(I
> =A0 have finished the codes already).
> 2. Remove the lru_add_drain_all.
>
> The first one has some problems since in our product system, all the cpus
> are busy, so I guess there is very little chance for a cpu to have 0 page=
vecs
> except that you run several consecutive mlocks.
>
> From the commit log which added this function(8891d6da), it seems that we
> don't have to call it. So the 2nd one seems to be both easy and workable =
and
> comes this patch.

Could you please show us your system environment and benchmark programs?
Usually lru_drain_** is very fast than mlock() body because it makes
plenty memset(page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
