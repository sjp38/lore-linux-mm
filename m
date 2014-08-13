Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DEE426B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 04:09:59 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so14504123pac.17
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 01:09:59 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id id5si923820pbb.222.2014.08.13.01.09.57
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 01:09:58 -0700 (PDT)
Date: Wed, 13 Aug 2014 17:09:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 4/8] mm/isolation: close the two race problems related
 to pageblock isolation
Message-ID: <20140813080956.GA30451@js1304-P5Q-DELUXE>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-8-git-send-email-iamjoonsoo.kim@lge.com>
 <20140812051745.GC23418@gmail.com>
 <53E9E23C.6030709@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E9E23C.6030709@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 12, 2014 at 11:45:32AM +0200, Vlastimil Babka wrote:
> On 08/12/2014 07:17 AM, Minchan Kim wrote:
> >On Wed, Aug 06, 2014 at 04:18:33PM +0900, Joonsoo Kim wrote:
> >>
> >>One solution to this problem is checking pageblock migratetype with
> >>holding zone lock in __free_one_page() and I posted it before, but,
> >>it didn't get welcome since it needs the hook in zone lock critical
> >>section on freepath.
> >
> >I didn't review your v1 but IMHO, this patchset is rather complex.
> 
> It is, but the complexity is in the isolation code, and not fast
> paths, so that's justifiable IMHO.
> 
> >Normally, we don't like adding more overhead in fast path but we did
> >several time on hotplug/cma, esp so I don't know a few more thing is
> >really hesitant.
> 
> This actually undoes most of the overhead, so I'm all for it. Better
> than keep doing stuff the same way just because it was done
> previously.
> 
> >In addition, you proved by this patchset how this
> >isolation code looks ugly and fragile for race problem so I vote
> >adding more overhead in fast path if it can make code really simple.
> 
> Well, I recommend you to check out the v1 then :) That wasn't really
> simple, that was even more hooks rechecking migratetypes at various
> places of the fast paths, when merging buddies etc. This is much
> better. The complexity is mostly in the isolation code, and the
> overhead happens only during isolation.

Hmm... Okay.

I agree that this way is so complicated. In fact, the real save is just
one is_migrate_isolate_page() check in free_pcppages_bulk() and
this approach makes isolation process really complicated.

I guess that I could improve v1 patchset. How about waiting my
improved v1 and comparing v1' with v2?

If v1 is implemented cleanly, it may be better than this.
I want to try and compare. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
