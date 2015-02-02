Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 83B506B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:27:30 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so78876306pab.3
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:27:30 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id fz11si22461481pdb.238.2015.02.01.23.27.28
        for <linux-mm@kvack.org>;
        Sun, 01 Feb 2015 23:27:29 -0800 (PST)
Date: Mon, 2 Feb 2015 16:29:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH v3 1/3] mm/cma: change fallback behaviour for CMA
 freepage
Message-ID: <20150202072907.GA6940@js1304-P5Q-DELUXE>
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Feb 02, 2015 at 04:15:46PM +0900, Joonsoo Kim wrote:
> freepage with MIGRATE_CMA can be used only for MIGRATE_MOVABLE and
> they should not be expanded to other migratetype buddy list
> to protect them from unmovable/reclaimable allocation. Implementing
> these requirements in __rmqueue_fallback(), that is, finding largest
> possible block of freepage has bad effect that high order freepage
> with MIGRATE_CMA are broken continually although there are suitable
> order CMA freepage. Reason is that they are not be expanded to other
> migratetype buddy list and next __rmqueue_fallback() invocation try to
> finds another largest block of freepage and break it again. So,
> MIGRATE_CMA fallback should be handled separately. This patch
> introduces __rmqueue_cma_fallback(), that just wrapper of
> __rmqueue_smallest() and call it before __rmqueue_fallback()
> if migratetype == MIGRATE_MOVABLE.
> 
> This results in unintended behaviour change that MIGRATE_CMA freepage
> is always used first rather than other migratetype as movable
> allocation's fallback. But, as already mentioned above,
> MIGRATE_CMA can be used only for MIGRATE_MOVABLE, so it is better
> to use MIGRATE_CMA freepage first as much as possible. Otherwise,
> we needlessly take up precious freepages with other migratetype and
> increase chance of fragmentation.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---

Hello, Vlastimil.

This RFC is targeted to you, but, I mistakenly omit your e-mail
on CC list. Sorry about that. :/

How about this v3 which try to clean-up __rmqueue_fallback() much more?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
