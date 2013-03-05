Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A918B6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 08:47:44 -0500 (EST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MJ600CKMWUFENC0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Mar 2013 13:47:42 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MJ6009WDWZG3B50@eusync4.samsung.com> for linux-mm@kvack.org;
 Tue, 05 Mar 2013 13:47:42 +0000 (GMT)
Message-id: <5135F77C.9060706@samsung.com>
Date: Tue, 05 Mar 2013 14:47:40 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH 0/5] Contiguous Memory Allocator and get_user_pages()
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
 <201303050850.26615.arnd@arndb.de>
In-reply-to: <201303050850.26615.arnd@arndb.de>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

On 3/5/2013 9:50 AM, Arnd Bergmann wrote:
> On Tuesday 05 March 2013, Marek Szyprowski wrote:
> > To solving this issue requires preventing locking of the pages, which
> > are placed in CMA regions, for a long time. Our idea is to migrate
> > anonymous page content before locking the page in get_user_pages(). This
> > cannot be done automatically, as get_user_pages() interface is used very
> > often for various operations, which usually last for a short period of
> > time (like for example exec syscall). We have added a new flag
> > indicating that the given get_user_space() call will grab pages for a
> > long time, thus it is suitable to use the migration workaround in such
> > cases.
>
> Can you explain the tradeoff here? I would have expected that the default
> should be to migrate pages out, and annotate the instances that we know
> are performance critical and short-lived. That would at least appear
> more reliable to me.

The problem is that the opposite approach is imho easier. get_user_pages()
is used in quite a lot of places (I was quite surprised when I've added some
debug to it and saw the logs) and it seems to be easier to identify places
where references are kept for significant amount of time. Usually such 
places
are in the device drivers. In our case only videobuf2 and some closed-source
driver were causing the real migration problems, so I decided to leave the
default approach unchanged.

If we use this workaround for every get_user_pages() call we will sooner or
later end with most of the anonymous pages migrated to non-movable 
pageblocks
what make the whole CMA approach a bit pointless.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
