Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 842B06B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 05:13:08 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so250701579wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:13:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fn5si2835131wib.71.2015.08.13.02.13.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 02:13:07 -0700 (PDT)
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55CC5FA0.300@suse.cz>
Date: Thu, 13 Aug 2015 11:13:04 +0200
MIME-Version: 1.0
In-Reply-To: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 08/13/2015 10:58 AM, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> The patch c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
> added the checks for page->pfmemalloc to __skb_fill_page_desc():
>
>          if (page->pfmemalloc && !page->mapping)
>                  skb->pfmemalloc = true;
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

                                                             ^ not ?

The full story (according to Jiri Bohac and my understanding, I don't 
know much about netdev) is that the __skb_fill_page_desc() is invoked 
here during *sending* and normally the skb->pfmemalloc would be ignored 
in the end. But because it is a localhost connection, the receiving code 
will think it was a memalloc allocation during receive, and then do the 
socket restriction.

Given that this apparently isn't the first case of this localhost issue, 
I wonder if network code should just clear skb->pfmemalloc during send 
(or maybe just send over localhost). That would be probably easier than 
distinguish the __skb_fill_page_desc() callers for send vs receive.

> and that leads to hangs when the nfs client waits for a response from
> the server which has been dropped and thus never arrive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
