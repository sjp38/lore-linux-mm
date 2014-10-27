Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 86A3D6B0078
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:14:44 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id n15so2277716lbi.31
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:14:43 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id 4si20901722laq.88.2014.10.27.10.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 10:14:42 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id ge10so2164583lab.2
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:14:41 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v4 1/4] mm/page_alloc: fix incorrect isolation behavior by rechecking migratetype
In-Reply-To: <1414051821-12769-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com> <1414051821-12769-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 27 Oct 2014 18:14:36 +0100
Message-ID: <xa1toasxo2o3.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Oct 23 2014, Joonsoo Kim wrote:
> There are two paths to reach core free function of buddy allocator,
> __free_one_page(), one is free_one_page()->__free_one_page() and the
> other is free_hot_cold_page()->free_pcppages_bulk()->__free_one_page().
> Each paths has race condition causing serious problems. At first, this
> patch is focused on first type of freepath. And then, following patch
> will solve the problem in second type of freepath.
>
> In the first type of freepath, we got migratetype of freeing page without
> holding the zone lock, so it could be racy. There are two cases of this
> race.
>
> 1. pages are added to isolate buddy list after restoring orignal
> migratetype
>
> CPU1                                   CPU2
>
> get migratetype =3D> return MIGRATE_ISOLATE
> call free_one_page() with MIGRATE_ISOLATE
>
> 				grab the zone lock
> 				unisolate pageblock
> 				release the zone lock
>
> grab the zone lock
> call __free_one_page() with MIGRATE_ISOLATE
> freepage go into isolate buddy list,
> although pageblock is already unisolated
>
> This may cause two problems. One is that we can't use this page anymore
> until next isolation attempt of this pageblock, because freepage is on
> isolate buddy list. The other is that freepage accouting could be wrong
> due to merging between different buddy list. Freepages on isolate buddy
> list aren't counted as freepage, but ones on normal buddy list are counted
> as freepage. If merge happens, buddy freepage on normal buddy list is
> inevitably moved to isolate buddy list without any consideration of
> freepage accouting so it could be incorrect.
>
> 2. pages are added to normal buddy list while pageblock is isolated.
> It is similar with above case.
>
> This also may cause two problems. One is that we can't keep these
> freepages from being allocated. Although this pageblock is isolated,
> freepage would be added to normal buddy list so that it could be
> allocated without any restriction. And the other problem is same as
> case 1, that it, incorrect freepage accouting.
>
> This race condition would be prevented by checking migratetype again
> with holding the zone lock. Because it is somewhat heavy operation
> and it isn't needed in common case, we want to avoid rechecking as much
> as possible. So this patch introduce new variable, nr_isolate_pageblock
> in struct zone to check if there is isolated pageblock.
> With this, we can avoid to re-check migratetype in common case and do
> it only if there is isolated pageblock or migratetype is MIGRATE_ISOLATE.
> This solve above mentioned problems.
>
> Changes from v3:
> Add one more check in free_one_page() that checks whether migratetype is
> MIGRATE_ISOLATE or not. Without this, abovementioned case 1 could happens.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/linux/mmzone.h         |    9 +++++++++
>  include/linux/page-isolation.h |    8 ++++++++
>  mm/page_alloc.c                |   11 +++++++++--
>  mm/page_isolation.c            |    2 ++
>  4 files changed, 28 insertions(+), 2 deletions(-)

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
