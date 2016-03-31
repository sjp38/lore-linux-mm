Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 682336B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 20:55:32 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id tt10so53136838pab.3
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 17:55:32 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 74si9972108pfk.37.2016.03.30.17.55.30
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 17:55:31 -0700 (PDT)
Date: Thu, 31 Mar 2016 09:57:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 00/16] Support non-lru page migration
Message-ID: <20160331005717.GB6736@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <20160330161141.4332b189e7a4930e117d765b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160330161141.4332b189e7a4930e117d765b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Wed, Mar 30, 2016 at 04:11:41PM -0700, Andrew Morton wrote:
> On Wed, 30 Mar 2016 16:11:59 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Recently, I got many reports about perfermance degradation
> > in embedded system(Android mobile phone, webOS TV and so on)
> > and failed to fork easily.
> > 
> > The problem was fragmentation caused by zram and GPU driver
> > pages. Their pages cannot be migrated so compaction cannot
> > work well, either so reclaimer ends up shrinking all of working
> > set pages. It made system very slow and even to fail to fork
> > easily.
> > 
> > Other pain point is that they cannot work with CMA.
> > Most of CMA memory space could be idle(ie, it could be used
> > for movable pages unless driver is using) but if driver(i.e.,
> > zram) cannot migrate his page, that memory space could be
> > wasted. In our product which has big CMA memory, it reclaims
> > zones too exccessively although there are lots of free space
> > in CMA so system was very slow easily.
> > 
> > To solve these problem, this patch try to add facility to
> > migrate non-lru pages via introducing new friend functions
> > of migratepage in address_space_operation and new page flags.
> > 
> > 	(isolate_page, putback_page)
> > 	(PG_movable, PG_isolated)
> > 
> > For details, please read description in
> > "mm/compaction: support non-lru movable page migration".
> 
> OK, I grabbed all these.
> 
> I wonder about testing coverage during the -next period.  How many
> people are likely to exercise these code paths in a serious way before
> it all hits mainline?

I asked this patchset to production team in my company for stress
testing. They alaways catch zram/zsmalloc bugs I have missed so
I hope they help me well, too.

About ballooning part, I hope Rafael Aquini get a time to review
and test it.

Other than that, IOW, linux-next will have a enough time to
test common migration part modification, I guess. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
