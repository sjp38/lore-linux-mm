Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 841836B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 20:06:36 -0500 (EST)
Received: by mail-lf0-f52.google.com with SMTP id m1so33376409lfg.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 17:06:36 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id ml3si15192895lbc.61.2016.02.01.17.06.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 17:06:34 -0800 (PST)
Message-ID: <56B00004.1070706@huawei.com>
Date: Tue, 2 Feb 2016 09:01:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] avoid external fragmentation related to migration
 fallback
References: <cover.1454094692.git.chengyihetaipei@gmail.com> <56ABD3B8.3080306@suse.cz> <20160201135351.GB8337@techsingularity.net>
In-Reply-To: <20160201135351.GB8337@techsingularity.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, ChengYi He <chengyihetaipei@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/2/1 21:53, Mel Gorman wrote:

> On Fri, Jan 29, 2016 at 10:03:52PM +0100, Vlastimil Babka wrote:
>>> Since the root cause is that fallbacks might frequently split order-2
>>> and order-3 pages of the other migration types. This patch tweaks
>>> fallback mechanism to avoid splitting order-2 and order-3 pages. while
>>> fallbacks happen, if the largest feasible pages are less than or queal to
>>> COSTLY_ORDER, i.e. 3, then try to select the smallest feasible pages. The
>>> reason why fallbacks prefer the largest feasiable pages is to increase
>>> fallback efficiency since fallbacks are likely to happen again. By
>>> stealing the largest feasible pages, it could reduce the oppourtunities
>>> of antoher fallback. Besides, it could make consecutive allocations more
>>> approximate to each other and make system less fragment. However, if the
>>> largest feasible pages are less than or equal to order-3, fallbacks might
>>> split it and make the upcoming order-3 page allocations fail.
>>
>> In theory I don't see immediately why preferring smaller pages for
>> fallback should be a clear win. If it's Unmovable allocations stealing
>> from Movable pageblocks, the allocations will spread over larger areas
>> instead of being grouped together. Maybe, for Movable allocations
>> stealing from Unmovable allocations, preferring smallest might make
>> sense and be safe, as any extra fragmentation is fixable bycompaction.
> 
> I strongly agree that spreading the fallback allocations over a larger
> area is likely to have a negative impact. Given the age of the kernel
> being tested, it would make sense to either rebase or at the very last
> backport the patches that affect watermark calculations and the
> treatment of high-order pages.
> 

Is it the feature of MIGRATE_HIGHATOMIC?

Thanks,
Xishi Qiu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
