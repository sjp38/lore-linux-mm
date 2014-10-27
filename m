Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 30E936B007B
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:15:03 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id ge10so2189233lab.30
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:15:02 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id u2si20870242laa.120.2014.10.27.10.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 10:15:01 -0700 (PDT)
Received: by mail-lb0-f180.google.com with SMTP id z12so2704123lbi.11
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:15:00 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v4 2/4] mm/page_alloc: add freepage on isolate pageblock to correct buddy list
In-Reply-To: <1414051821-12769-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com> <1414051821-12769-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 27 Oct 2014 18:14:55 +0100
Message-ID: <xa1tlho1o2nk.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Oct 23 2014, Joonsoo Kim wrote:
> In free_pcppages_bulk(), we use cached migratetype of freepage
> to determine type of buddy list where freepage will be added.
> This information is stored when freepage is added to pcp list, so
> if isolation of pageblock of this freepage begins after storing,
> this cached information could be stale. In other words, it has
> original migratetype rather than MIGRATE_ISOLATE.
>
> There are two problems caused by this stale information. One is that
> we can't keep these freepages from being allocated. Although this
> pageblock is isolated, freepage will be added to normal buddy list
> so that it could be allocated without any restriction. And the other
> problem is incorrect freepage accounting. Freepages on isolate pageblock
> should not be counted for number of freepage.
>
> Following is the code snippet in free_pcppages_bulk().
>
> /* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> __free_one_page(page, page_to_pfn(page), zone, 0, mt);
> trace_mm_page_pcpu_drain(page, 0, mt);
> if (likely(!is_migrate_isolate_page(page))) {
> 	__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
> 	if (is_migrate_cma(mt))
> 		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
> }
>
> As you can see above snippet, current code already handle second problem,
> incorrect freepage accounting, by re-fetching pageblock migratetype
> through is_migrate_isolate_page(page). But, because this re-fetched
> information isn't used for __free_one_page(), first problem would not be
> solved. This patch try to solve this situation to re-fetch pageblock
> migratetype before __free_one_page() and to use it for __free_one_page().
>
> In addition to move up position of this re-fetch, this patch use
> optimization technique, re-fetching migratetype only if there is
> isolate pageblock. Pageblock isolation is rare event, so we can
> avoid re-fetching in common case with this optimization.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_alloc.c |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
