Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 86EE06B003D
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:18:47 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so8432953pdj.11
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:18:47 -0800 (PST)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id eb3si25213598pbc.296.2014.02.04.08.18.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:18:46 -0800 (PST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so8611809pbb.17
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:18:45 -0800 (PST)
Message-ID: <1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Feb 2014 08:18:41 -0800
In-Reply-To: <87r47jsb2p.fsf@xmission.com>
References: <87r47jsb2p.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Mon, 2014-02-03 at 21:26 -0800, Eric W. Biederman wrote:
> Recently due to a spike in connections per second memcached on 3
> separate boxes triggered the OOM killer from accept.  At the time the
> OOM killer was triggered there was 4GB out of 36GB free in zone 1. The
> problem was that alloc_fdtable was allocating an order 3 page (32KiB) to
> hold a bitmap, and there was sufficient fragmentation that the largest
> page available was 8KiB.
> 
> I find the logic that PAGE_ALLOC_COSTLY_ORDER can't fail pretty dubious
> but I do agree that order 3 allocations are very likely to succeed.
> 
> There are always pathologies where order > 0 allocations can fail when
> there are copious amounts of free memory available.  Using the pigeon
> hole principle it is easy to show that it requires 1 page more than 50%
> of the pages being free to guarantee an order 1 (8KiB) allocation will
> succeed, 1 page more than 75% of the pages being free to guarantee an
> order 2 (16KiB) allocation will succeed and 1 page more than 87.5% of
> the pages being free to guarantee an order 3 allocate will succeed.
> 
> A server churning memory with a lot of small requests and replies like
> memcached is a common case that if anything can will skew the odds
> against large pages being available.
> 
> Therefore let's not give external applications a practical way to kill
> linux server applications, and specify __GFP_NORETRY to the kmalloc in
> alloc_fdmem.  Unless I am misreading the code and by the time the code
> reaches should_alloc_retry in __alloc_pages_slowpath (where
> __GFP_NORETRY becomes signification).  We have already tried everything
> reasonable to allocate a page and the only thing left to do is wait.  So
> not waiting and falling back to vmalloc immediately seems like the
> reasonable thing to do even if there wasn't a chance of triggering the
> OOM killer.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  fs/file.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/file.c b/fs/file.c
> index 771578b33fb6..db25c2bdfe46 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -34,7 +34,7 @@ static void *alloc_fdmem(size_t size)
>  	 * vmalloc() if the allocation size will be considered "large" by the VM.
>  	 */
>  	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> -		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
> +		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY);
>  		if (data != NULL)
>  			return data;
>  	}

Hi Eric

I wrote yesterday a similar patch adding __GFP_NORETRY in following
paths. I feel that alloc_fdmem() is only a part of the problem ;)

What do you think, should we merge our changes or have distinct
patches ?

diff --git a/net/core/sock.c b/net/core/sock.c
index 0c127dcdf6a8..5b6a9431b017 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1775,7 +1775,9 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 			while (order) {
 				if (npages >= 1 << order) {
 					page = alloc_pages(sk->sk_allocation |
-							   __GFP_COMP | __GFP_NOWARN,
+							   __GFP_COMP |
+							   __GFP_NOWARN |
+							   __GFP_NORETRY,
 							   order);
 					if (page)
 						goto fill_page;
@@ -1845,7 +1847,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
 		gfp_t gfp = prio;
 
 		if (order)
-			gfp |= __GFP_COMP | __GFP_NOWARN;
+			gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
 		pfrag->page = alloc_pages(gfp, order);
 		if (likely(pfrag->page)) {
 			pfrag->offset = 0;






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
