Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 43A776B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 06:00:08 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so132727174wic.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 03:00:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lj1si3028388wjc.111.2015.08.13.03.00.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 03:00:07 -0700 (PDT)
Date: Thu, 13 Aug 2015 11:00:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
Message-ID: <20150813100002.GA9854@suse.de>
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Thu, Aug 13, 2015 at 10:58:54AM +0200, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The patch c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
> added the checks for page->pfmemalloc to __skb_fill_page_desc():
> 
>         if (page->pfmemalloc && !page->mapping)
>                 skb->pfmemalloc = true;
> 
> It assumes page->mapping == NULL implies that page->pfmemalloc can be
> trusted.  However, __delete_from_page_cache() can set set page->mapping
> to NULL and leave page->index value alone. Due to being in union, a
> non-zero page->index will be interpreted as true page->pfmemalloc.
> 
> So the assumption is invalid if the networking code can see such a
> page. And it seems it can. We have encountered this with a NFS over
> loopback setup when such a page is attached to a new skbuf. There is no
> copying going on in this case so the page confuses __skb_fill_page_desc
> which interprets the index as pfmemalloc flag and the network stack
> drops packets that have been allocated using the reserves unless they
> are to be queued on sockets handling the swapping which is the case here
> and that leads to hangs when the nfs client waits for a response from
> the server which has been dropped and thus never arrive.
> 
> The struct page is already heavily packed so rather than finding
> another hole to put it in, let's do a trick instead. We can reuse the
> index again but define it to an impossible value (-1UL). This is the
> page index so it should never see the value that large. Replace all
> direct users of page->pfmemalloc by page_is_pfmemalloc which will
> hide this nastiness from unspoiled eyes.
> 
> The information will get lost if somebody wants to use page->index
> obviously but that was the case before and the original code expected
> that the information should be persisted somewhere else if that is
> really needed (e.g. what SLAB and SLUB do).
> 
> Fixes: c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
> Cc: stable # 3.6+
> Debugged-by: Vlastimil Babka <vbabka@suse.com>
> Debugged-by: Jiri Bohac <jbohac@suse.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
