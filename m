Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0433B900113
	for <linux-mm@kvack.org>; Sun,  1 May 2011 18:11:05 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p41MB27r019111
	for <linux-mm@kvack.org>; Sun, 1 May 2011 15:11:02 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by hpaq12.eem.corp.google.com with ESMTP id p41MAwbf023352
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 1 May 2011 15:11:01 -0700
Received: by qyk35 with SMTP id 35so1147107qyk.13
        for <linux-mm@kvack.org>; Sun, 01 May 2011 15:10:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c7a7b3ceafe4fdc4bc038774374504827c01481f.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
	<c7a7b3ceafe4fdc4bc038774374504827c01481f.1304261567.git.minchan.kim@gmail.com>
Date: Sun, 1 May 2011 15:10:58 -0700
Message-ID: <BANLkTi=c2tBcXJnFi-i4r1_ADiMFebmxMA@mail.gmail.com>
Subject: Re: [PATCH 1/2] Check PageUnevictable in lru_deactivate_fn
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

On Sun, May 1, 2011 at 8:03 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> The lru_deactivate_fn should not move page which in on unevictable lru
> into inactive list. Otherwise, we can meet BUG when we use isolate_lru_pa=
ges
> as __isolate_lru_page could return -EINVAL.
> It's really BUG and let's fix it.
>
> Reported-by: Ying Han <yinghan@google.com>
> Tested-by: Ying Han <yinghan@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =A0mm/swap.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index a83ec5a..2e9656d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -429,6 +429,9 @@ static void lru_deactivate_fn(struct page *page, void=
 *arg)
> =A0 =A0 =A0 =A0if (!PageLRU(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> + =A0 =A0 =A0 if (PageUnevictable(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> =A0 =A0 =A0 =A0/* Some processes are using the page */
> =A0 =A0 =A0 =A0if (page_mapped(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> --
> 1.7.1

Thanks Minchan for the fix, and i haven't been able to reproducing the
issue after applying the patch.

--Ying

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
