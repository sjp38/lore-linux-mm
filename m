Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFDC6B0255
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 05:31:45 -0400 (EDT)
Received: by wijp15 with SMTP id p15so250699387wij.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:31:44 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id jm8si1157865wjb.12.2015.08.13.02.31.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 02:31:42 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so131844946wic.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:31:42 -0700 (PDT)
Date: Thu, 13 Aug 2015 11:31:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
Message-ID: <20150813093140.GB31736@dhcp22.suse.cz>
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
 <55CC5FA0.300@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55CC5FA0.300@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org

On Thu 13-08-15 11:13:04, Vlastimil Babka wrote:
> On 08/13/2015 10:58 AM, mhocko@kernel.org wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >The patch c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
> >added the checks for page->pfmemalloc to __skb_fill_page_desc():
> >
> >         if (page->pfmemalloc && !page->mapping)
> >                 skb->pfmemalloc = true;
> >
> >It assumes page->mapping == NULL implies that page->pfmemalloc can be
> >trusted.  However, __delete_from_page_cache() can set set page->mapping
> >to NULL and leave page->index value alone. Due to being in union, a
> >non-zero page->index will be interpreted as true page->pfmemalloc.
> >
> >So the assumption is invalid if the networking code can see such a
> >page. And it seems it can. We have encountered this with a NFS over
> >loopback setup when such a page is attached to a new skbuf. There is no
> >copying going on in this case so the page confuses __skb_fill_page_desc
> >which interprets the index as pfmemalloc flag and the network stack
> >drops packets that have been allocated using the reserves unless they
> >are to be queued on sockets handling the swapping which is the case here
> 
>                                                             ^ not ?

Dohh, you are right of course, updated...

> The full story (according to Jiri Bohac and my understanding, I don't know
> much about netdev) is that the __skb_fill_page_desc() is invoked here during
> *sending* and normally the skb->pfmemalloc would be ignored in the end. But
> because it is a localhost connection, the receiving code will think it was a
> memalloc allocation during receive, and then do the socket restriction.
> 
> Given that this apparently isn't the first case of this localhost issue, I
> wonder if network code should just clear skb->pfmemalloc during send (or
> maybe just send over localhost). That would be probably easier than
> distinguish the __skb_fill_page_desc() callers for send vs receive.

Maybe the networking code can behave "better" in this particular case
but the core thing remains though. Relying on page->mapping as you have
properly found out during the debugging cannot be used for the reliable
detection of pfmemalloc. So I would argue that a more robust detection
is really worthwhile. Note there are other places which even do not
bother to test for mapping - maybe they are safe but I got lost quickly
when trying to track the allocation source to be clear that nothing
could have stepped in in the meantime.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
