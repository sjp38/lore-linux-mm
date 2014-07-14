Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 79FEC6B0037
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 02:18:30 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so1852864pad.24
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 23:18:30 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id a4si8378216pat.238.2014.07.13.23.18.28
        for <linux-mm@kvack.org>;
        Sun, 13 Jul 2014 23:18:29 -0700 (PDT)
Date: Mon, 14 Jul 2014 15:24:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 03/10] mm/page_alloc: handle page on pcp correctly if
 it's pageblock is isolated
Message-ID: <20140714062423.GB11317@js1304-P5Q-DELUXE>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404460675-24456-4-git-send-email-iamjoonsoo.kim@lge.com>
 <53BABA94.4040107@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BABA94.4040107@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 05:19:48PM +0200, Vlastimil Babka wrote:
> On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> >If pageblock of page on pcp are isolated now, we should free it to isolate
> >buddy list to prevent future allocation on it. But current code doesn't
> >do this.
> >
> >Moreover, there is a freepage counting problem on current code. Although
> >pageblock of page on pcp are isolated now, it could go normal buddy list,
> >because get_onpcp_migratetype() will return non-isolate migratetype.
> 
> get_onpcp_migratetype() is only introduced in later patch.

Yes, I will fix it.

> 
> >In this case, we should do either adding freepage count or changing
> >migratetype to MIGRATE_ISOLATE, but, current code do neither.
> 
> I wouldn't say it "do neither". It already limits the freepage
> counting to !MIGRATE_ISOLATE case (and it's not converted to
> __mod_zone_freepage_state for some reason). So there's accounting
> mismatch in addition to buddy list misplacement.

Okay.

> 
> >This patch fixes these two problems by handling pageblock migratetype
> >before calling __free_one_page(). And, if we find the page on isolated
> >pageblock, change migratetype to MIGRATE_ISOLATE to prevent future
> >allocation of this page and freepage counting problem.
> 
> So although this is not an addition of a new pageblock migratetype
> check to the fast path (the check is already there), I would prefer
> removing the check :) 

Yes, I want to do it if possible. :)

> With the approach of pcplists draining
> outlined in my reply to 00/10, we would allow a misplacement to
> happen (and the page accounted as freepage) immediately followed by
> move_frepages_block which would place the page onto isolate freelist
> with the rest. Anything newly freed will get isolate_migratetype
> determined in free_hot_cold_page or __free_pages_ok (where it would
> need moving the migratepage check under the disabled irq part) and
> be placed and buddy-merged properly.

I explained the problem of this approach in 00/10.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
