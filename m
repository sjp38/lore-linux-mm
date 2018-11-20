Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB816B1F21
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:45:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w185so2247103qka.9
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:45:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p42si4086697qtc.174.2018.11.20.00.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 00:45:35 -0800 (PST)
Date: Tue, 20 Nov 2018 03:45:32 -0500 (EST)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1747228.35250472.1542703532881.JavaMail.zimbra@redhat.com>
In-Reply-To: <20181119101616.8901-6-david@redhat.com>
References: <20181119101616.8901-1-david@redhat.com> <20181119101616.8901-6-david@redhat.com>
Subject: Re: [PATCH v1 5/8] hv_balloon: mark inflated pages PG_offline
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Kairui Song <kasong@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>


Hi David,

> 
> Mark inflated and never onlined pages PG_offline, to tell the world that
> the content is stale and should not be dumped.
> 
> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Stephen Hemminger <sthemmin@microsoft.com>
> Cc: Kairui Song <kasong@redhat.com>
> Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/hv/hv_balloon.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 211f3fe3a038..47719862e57f 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -681,8 +681,13 @@ static struct notifier_block hv_memory_nb = {
>  /* Check if the particular page is backed and can be onlined and online it.
>  */
>  static void hv_page_online_one(struct hv_hotadd_state *has, struct page *pg)
>  {
> -	if (!has_pfn_is_backed(has, page_to_pfn(pg)))
> +	if (!has_pfn_is_backed(has, page_to_pfn(pg))) {
> +		if (!PageOffline(pg))
> +			__SetPageOffline(pg);
>  		return;
> +	}
> +	if (PageOffline(pg))
> +		__ClearPageOffline(pg);
>  
>  	/* This frame is currently backed; online the page. */
>  	__online_page_set_limits(pg);
> @@ -1201,6 +1206,7 @@ static void free_balloon_pages(struct hv_dynmem_device
> *dm,
>  
>  	for (i = 0; i < num_pages; i++) {
>  		pg = pfn_to_page(i + start_frame);
> +		__ClearPageOffline(pg);

Just thinking, do we need to care for clearing PageOffline flag before freeing
a balloon'd page?

Thanks,
Pankaj

>  		__free_page(pg);
>  		dm->num_pages_ballooned--;
>  	}
> @@ -1213,7 +1219,7 @@ static unsigned int alloc_balloon_pages(struct
> hv_dynmem_device *dm,
>  					struct dm_balloon_response *bl_resp,
>  					int alloc_unit)
>  {
> -	unsigned int i = 0;
> +	unsigned int i, j;
>  	struct page *pg;
>  
>  	if (num_pages < alloc_unit)
> @@ -1245,6 +1251,10 @@ static unsigned int alloc_balloon_pages(struct
> hv_dynmem_device *dm,
>  		if (alloc_unit != 1)
>  			split_page(pg, get_order(alloc_unit << PAGE_SHIFT));
>  
> +		/* mark all pages offline */
> +		for (j = 0; j < (1 << get_order(alloc_unit << PAGE_SHIFT)); j++)
> +			__SetPageOffline(pg + j);
> +
>  		bl_resp->range_count++;
>  		bl_resp->range_array[i].finfo.start_page =
>  			page_to_pfn(pg);
> --
> 2.17.2
> 
> 
