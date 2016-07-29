Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id F16046B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 14:08:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so115347588pac.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:08:56 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id g2si19467561pfa.278.2016.07.29.11.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 11:08:56 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id iw10so33206516pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:08:56 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] mm: move swap-in anonymous page into active list
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1469811331.13905.10.camel@redhat.com>
Date: Fri, 29 Jul 2016 11:08:53 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <39F87A25-801A-48A8-A042-A64861A0229B@gmail.com>
References: <1469762740-17860-1-git-send-email-minchan@kernel.org> <1469811331.13905.10.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

Rik van Riel <riel@redhat.com> wrote:

> On Fri, 2016-07-29 at 12:25 +0900, Minchan Kim wrote:
>> Every swap-in anonymous page starts from inactive lru list's head.
>> It should be activated unconditionally when VM decide to reclaim
>> because page table entry for the page always usually has marked
>> accessed bit. Thus, their window size for getting a new referece
>> is 2 * NR_inactive + NR_active while others is NR_active + NR_active.
>>=20
>> It's not fair that it has more chance to be referenced compared
>> to other newly allocated page which starts from active lru list's
>> head.
>>=20
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>=20
> Acked-by: Rik van Riel <riel@redhat.com>
>=20
> The reason newly read in swap cache pages start on the
> inactive list is that we do some amount of read-around,
> and do not know which pages will get used.
>=20
> However, immediately activating the ones that DO get
> used, like your patch does, is the right thing to do.

Can it cause the swap clusters to lose spatial locality?

For instance, if a process writes sequentially to memory multiple times,
and if pages are swapped out, in and back out. In such case, doesn=E2=80=99=
t it
increase the probability that the swap cluster will hold irrelevant data =
and
make swap prefetch less efficient?

Regards,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
