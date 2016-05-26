Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 393436B0261
	for <linux-mm@kvack.org>; Wed, 25 May 2016 20:36:25 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id sq19so112569065igc.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 17:36:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y187si776425itf.81.2016.05.25.17.36.23
        for <linux-mm@kvack.org>;
        Wed, 25 May 2016 17:36:24 -0700 (PDT)
Date: Thu, 26 May 2016 09:37:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: use early_pfn_to_nid in
 register_page_bootmem_info_node
Message-ID: <20160526003718.GA9302@js1304-P5Q-DELUXE>
References: <1464210007-30930-1-git-send-email-yang.shi@linaro.org>
 <20160525152319.fa87b4cc0b8326fef89a1b92@linux-foundation.org>
 <03d44563-3860-052b-1c49-e81208bdd697@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <03d44563-3860-052b-1c49-e81208bdd697@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Mel Gorman <mgorman@techsingularity.net>

Ccing Mel.

On Wed, May 25, 2016 at 03:36:48PM -0700, Shi, Yang wrote:
> On 5/25/2016 3:23 PM, Andrew Morton wrote:
> >On Wed, 25 May 2016 14:00:07 -0700 Yang Shi <yang.shi@linaro.org> wrote:
> >
> >>register_page_bootmem_info_node() is invoked in mem_init(), so it will be
> >>called before page_alloc_init_late() if CONFIG_DEFERRED_STRUCT_PAGE_INIT
> >>is enabled. But, pfn_to_nid() depends on memmap which won't be fully setup
> >>until page_alloc_init_late() is done, so replace pfn_to_nid() by
> >>early_pfn_to_nid().
> >
> >What are the runtime effects of this fix?
> 
> I didn't experience any problem without the fix. During working on
> the page_ext_init() fix (replace to early_pfn_to_nid()), I added
> printk before each pfn_to_nid() calls to check which one might be
> called before page_alloc_init_late(), then this one is caught.
> 
> From the code perspective, it sounds not right since
> register_page_bootmem_info_section() may miss some pfns when
> CONFIG_DEFERRED_STRUCT_PAGE_INIT is enabled, just like the problem
> happened in page_ext_init().

Hello, Mel.

There was an issue in page_ext [1] due to your deferred struct page init
feature. Before your change, we assumed that we can use pfn_to_nid()
after memmap init is called. But, after your change, we can use
pfn_to_nid() after page_alloc_init_late(). Yang found two call sites
that uses pfn_to_nid() before page_alloc_init_late() and they could be
fixed by using early_pfn_to_nid(). I guess that there are more
problems due to this change so it's better to check it by patch author.

One thing I have noticed is that dirty_limit could be set wrongly. It
is intialized by using freepage count. Since it is intialized before
page_alloc_init_late(), freepages are not initialized yet and it could
be wrong. If my analysis is correct, please fix it.

And, could you check again that there is no more problem?

Thanks.

[1]
http://lkml.kernel.org/r/CAAmzW4OUmyPwQjvd7QUfc6W1Aic__TyAuH80MLRZNMxKy0-wPQ@mail.gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
