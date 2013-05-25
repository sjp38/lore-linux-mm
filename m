Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 2DD826B0032
	for <linux-mm@kvack.org>; Fri, 24 May 2013 22:15:16 -0400 (EDT)
Message-ID: <51A01DBE.2090201@huawei.com>
Date: Sat, 25 May 2013 10:11:10 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mem-hotplug: Skip LOCAL_NODE_DATA pages in memory
 offline procedure.
References: <1369387807-17956-1-git-send-email-tangchen@cn.fujitsu.com> <1369387807-17956-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1369387807-17956-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mingo@redhat.com, hpa@zytor.com, minchan@kernel.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, yinghai@kernel.org, jiang.liu@huawei.com, tj@kernel.org, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/5/24 17:30, Tang Chen wrote:

> In memory offline procedure, skip pages marked as LOCAL_NODE_DATA.
> For now, this kind of pages are used to store local node pagetables.
> 
> The minimum unit of memory online/offline is a memory block. In a
> block, the movable pages will be offlined as usual (unmapped and
> isolated), and the pagetable pages will be skipped. After the iteration
> of all page, the block will be set as offline, but the kernel can
> still access the pagetable pages. This is user transparent.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  mm/page_alloc.c     |   18 ++++++++++++++++--
>  mm/page_isolation.c |    6 ++++++
>  2 files changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 557b21b..73b8f0b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5701,11 +5701,18 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>  		unsigned long check = pfn + iter;
> +		unsigned long magic;
>  
>  		if (!pfn_valid_within(check))
>  			continue;
>  
>  		page = pfn_to_page(check);
> +
> +		/* Skip pages storing local node kernel data. */


> +		magic = (unsigned long)page->lru.next;
> +		if (magic == LOCAL_NODE_DATA)

Hi Tang,

I think can define this as a macro, and can be reused in the other places.

Thanks,
Jianguo Wu.

> +			continue;
> +
>  		/*
>  		 * We can't use page_count without pin a page
>  		 * because another CPU can free compound page.
> @@ -6029,8 +6036,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	struct page *page;
>  	struct zone *zone;
>  	int order, i;
> -	unsigned long pfn;
> -	unsigned long flags;
> +	unsigned long pfn, flags, magic;
>  	/* find the first valid pfn */
>  	for (pfn = start_pfn; pfn < end_pfn; pfn++)
>  		if (pfn_valid(pfn))
> @@ -6046,6 +6052,14 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +
> +		/* Skip pages storing local node kernel data. */
> +		magic = (unsigned long)page->lru.next;
> +		if (magic == LOCAL_NODE_DATA) {
> +			pfn++;
> +			continue;
> +		}
> +
>  		/*
>  		 * The HWPoisoned page may be not in buddy system, and
>  		 * page_count() is not 0.
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 383bdbb..fb60a27 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -174,6 +174,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>  				  bool skip_hwpoisoned_pages)
>  {
>  	struct page *page;
> +	unsigned long magic;
>  
>  	while (pfn < end_pfn) {
>  		if (!pfn_valid_within(pfn)) {
> @@ -181,6 +182,8 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +		magic = (unsigned long)page->lru.next;
> +
>  		if (PageBuddy(page)) {
>  			/*
>  			 * If race between isolatation and allocation happens,
> @@ -208,6 +211,9 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>  			 */
>  			pfn++;
>  			continue;
> +		} else if (magic == LOCAL_NODE_DATA) {
> +			pfn++;
> +			continue;
>  		}
>  		else
>  			break;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
