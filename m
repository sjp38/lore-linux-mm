Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB12E6B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 04:53:07 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id m15so3786521wgh.29
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 01:53:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh5si15000228wib.94.2014.08.07.01.53.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 01:53:06 -0700 (PDT)
Message-ID: <53E33E6D.1080002@suse.cz>
Date: Thu, 07 Aug 2014 10:53:01 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/8] mm/isolation: change pageblock isolation logic
 to fix freepage counting bugs
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com> <53E245D4.9080506@suse.cz> <20140807081945.GA2427@js1304-P5Q-DELUXE>
In-Reply-To: <20140807081945.GA2427@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/07/2014 10:19 AM, Joonsoo Kim wrote:
>> Is it needed to disable the pcp list? Shouldn't drain be enough?
>> After the drain you already are sure that future freeing will see
>> MIGRATE_ISOLATE and skip pcp list anyway, so why disable it
>> completely?
>
> Yes, it is needed. Until we move freepages from normal buddy list
> to isolate buddy list, freepages could be allocated by others. In this
> case, they could be moved to pcp list. When it is flushed from pcp list
> to buddy list, we need to check whether it is on isolate migratetype
> pageblock or not. But, we don't want that hook in free_pcppages_bulk()
> because it is page allocator's normal freepath. To remove it, we shoule
> disable the pcp list here.

Ah, right. I thought that everything going to pcp lists would be through 
freeing which would already observe the isolate migratetype and skip 
pcplist. I forgot about the direct filling of pcplists from buddy list. 
You're right that we don't want extra hooks there.

Still, couldn't this be solved in a simpler way via another pcplist 
drain after the pages are moved from normal to isolate buddy list? 
Should be even faster because instead of disable - drain - enable (5 
all-cpu kicks, since each pageset_update does 2 kicks) you have drain - 
drain (2 kicks). While it's true that pageset_update is single-zone 
operation, I guess we would easily benefit from having a single-zone 
drain operation as well.

Vlastimil



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
