Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B6D916B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:40:53 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so100135714pac.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 01:40:53 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id b7si24917187pas.112.2015.04.27.01.40.51
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 01:40:52 -0700 (PDT)
Date: Mon, 27 Apr 2015 17:42:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage if
 steal
Message-ID: <20150427084257.GA13790@js1304-P5Q-DELUXE>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150427080850.GF2449@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150427080850.GF2449@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Mon, Apr 27, 2015 at 09:08:50AM +0100, Mel Gorman wrote:
> On Mon, Apr 27, 2015 at 04:23:39PM +0900, Joonsoo Kim wrote:
> > When we steal whole pageblock, we don't need to break highest order
> > freepage. Perhaps, there is small order freepage so we can use it.
> > 
> 
> The reason why the largest block is taken is to reduce the probability
> there will be another fallback event in the near future. Early on, there
> were a lot of tests conducted to measure the number of external fragmenting
> events and take steps to reduce them. Stealing the largest highest order
> freepage was one of those steps.

Hello, Mel.

Purpose of this patch is not "stop steal highest order freepage".
Currently, in case of that we steal all freepage including highest
order freepage in certain pageblock, we break highest order freepage and
return it even if we have low order freepage that we immediately steal.

For example,

Pageblock A has 5 freepage (4 * order 0, 1 * order 3) and
we try to steal all freepage on pageblock A.

Withouth this patch, we move all freepage to requested migratetype
buddy list and break order 3 freepage. Leftover is like as following.

(5 * order 0, 1 * order 1, 1* order 2)

With this patch, (3 * order 0, 1 * order 3) remains.

I think that this is better than before because we still have high order
page. Isn't it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
