Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3434C6B0038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 12:14:30 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so23784759wiw.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 09:14:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si3934132wiv.114.2015.06.09.09.14.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 09:14:28 -0700 (PDT)
Message-ID: <557710E1.6060103@suse.cz>
Date: Tue, 09 Jun 2015 18:14:25 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm:add VM_BUG_ON_PAGE() for page_mapcount()
References: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com> <35FD53F367049845BC99AC72306C23D103E688B313F9@CNBJMBX05.corpusers.net> <35FD53F367049845BC99AC72306C23D103E688B313FA@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FA@CNBJMBX05.corpusers.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, 'Hillf Danton' <hillf.zj@alibaba-inc.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>

On 12/08/2014 10:59 AM, Wang, Yalin wrote:
> This patch add VM_BUG_ON_PAGE() for slab page,
> because _mapcount is an union with slab struct in struct page,
> avoid access _mapcount if this page is a slab page.
> Also remove the unneeded bracket.
>
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>   include/linux/mm.h | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b464611..a117527 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -449,7 +449,8 @@ static inline void page_mapcount_reset(struct page *page)
>
>   static inline int page_mapcount(struct page *page)
>   {
> -	return atomic_read(&(page)->_mapcount) + 1;
> +	VM_BUG_ON_PAGE(PageSlab(page), page);
> +	return atomic_read(&page->_mapcount) + 1;
>   }
>

I think this might theoretically trigger on the following code in 
compaction's isolate_migratepages_block():

/*
   * Migration will fail if an anonymous page is pinned in memory,
   * so avoid taking lru_lock and isolating it unnecessarily in an
   * admittedly racy check.
   */
if (!page_mapping(page) &&
     page_count(page) > page_mapcount(page))
	continue;

This is done after PageLRU() was positive, but the lru_lock might be not 
taken yet. So, there's some time window during which the page might have 
been reclaimed from LRU and become a PageSlab(page). !page_mapping(page) 
will be true in that case so it will proceed with page_mapcount(page) 
test and trigger the VM_BUG_ON.

(That test was added by DavidR year ago in commit 
119d6d59dcc0980dcd581fdadb6b2033b512a473)

Vlastimil





>   static inline int page_count(struct page *page)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
