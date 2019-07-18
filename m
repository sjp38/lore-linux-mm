Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16FB2C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB73321849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:48:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="r5nlN0qI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB73321849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A7198E0003; Thu, 18 Jul 2019 12:48:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5576F6B0008; Thu, 18 Jul 2019 12:48:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4457C8E0003; Thu, 18 Jul 2019 12:48:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3416B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:48:20 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v137so5934118ybb.10
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:48:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=71Izg78aTb6CFgbhsKMUIFfFgMMQWVl+aKHWkhvfNQo=;
        b=od78a8JyHgcq6Xg3brNyU25IrtzFIHd94fLO1/iO/iPR6VGyxcbaBgX7yklD+tyKaq
         DCpK1UGJP8EgoHB3awy5cJy77yI8BDUDoNZpcgFzZ5t6ye5CgjquPZ1BjvJkLp4czlkB
         ycvRqUAcV7ljim8alUZpWGy/boMWElW1YvFTST91OEimWtGVOq7spwmTP9Q1jESBxoT5
         suKmSiYb2URnRoVXkkX3UceswLZW7TpieX6pEl/o24QYSns4fcjcW9wtFy0m9KPpmY3B
         kjyhMG+r8NTWdRLjnS/Es1AsaqEUbpg8l1B2feBITvBbUWLBzIxauVc/zw1/25fvguiU
         FTnQ==
X-Gm-Message-State: APjAAAVyqVVSLdnFg+PrIwrsJLycVryGDyM0B0YQ86i5dvvqisNA33QC
	0dYHC1xqXOjMaAMM46v9/wJe3qvLdiYCxa3x7EbWlYbnCh0P/sD1zAt0SkHy5YjS+FvqiBUJnIk
	kt2wMAeTI50qzsv2r4OnMxY24PX24JU4Dz39GWck5aNvQ4+UsBeGT+cjKcYFEGp5IQw==
X-Received: by 2002:a25:bf84:: with SMTP id l4mr27499682ybk.516.1563468499801;
        Thu, 18 Jul 2019 09:48:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPzILHNqs/WE5Wq1xV+GAs8xxMgfBAmrUawQbH+meuwRb+nyHtEC0pBe3vw0/tdCA8dluf
X-Received: by 2002:a25:bf84:: with SMTP id l4mr27499622ybk.516.1563468498997;
        Thu, 18 Jul 2019 09:48:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563468498; cv=none;
        d=google.com; s=arc-20160816;
        b=UfHU920WuRc6lJrohzGHgtVdp2hlA6hWTlAeUBVKyyqVsxOsxq0WQXMklmBvFQeEZ2
         36SlIS4rnVxkXF6nuosSbwcYKpbd8ApfViBQhaFnNAqmNjdg6y1HoWaudiaDG9hKp5he
         ko1fbbeJCcs/rkyusigG3dIxGPXipmd2ZLwh/DjqsqlfDBcFtoWNlypG7zEF8F4lcbfi
         q1jRQpYDrZk23k8ejinqbT20+hBSc0hw441HbV5RDWYs+XfJqZ6Gvd6oEJPJhJLdDWXm
         7LHewvkStcckh5CxhI8B+0UElaewo5/q9yjK70unL2YBw6vKqGjGFWdsuPjmBy3NEJXw
         grmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=71Izg78aTb6CFgbhsKMUIFfFgMMQWVl+aKHWkhvfNQo=;
        b=oeU5gsBtsfXEYTT/yWtrPvJCkgkVwqoajZ6qiL5iypdwByW4PapEOLluCFvw/T3MFv
         J4mbqHN3vaUwoZwn1Qg95qEY8lDJFzQSrqH7XXuZxHOmTjocXp8YDwFziuIDFFwfDdRU
         WXuIAA0CXfSfEtsAVyWTbKixI/pko2S2K61MThIEKhIN+IQIoXbiAW6LmhH76Htw7nIB
         0RKR1CCnvUxKnnDSlOPj2jbBMyfr5WHDNtjCy1g8snEgE1odpS8qhAo1vUb74h4GIkR+
         zCzeZ83PHB+Llk/uout7n7mg761ctTLOvbJG9Fp6wvYJvKAtnxWgmr5OapgTBvUzxhmV
         1EwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=r5nlN0qI;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 62si8973265ybs.190.2019.07.18.09.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 09:48:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=r5nlN0qI;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d30a2d80000>; Thu, 18 Jul 2019 09:48:24 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 18 Jul 2019 09:48:18 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 18 Jul 2019 09:48:18 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 18 Jul
 2019 16:48:17 +0000
Subject: Re: [PATCH v4 2/2] balloon: fix up comments
To: "Michael S. Tsirkin" <mst@redhat.com>, <linux-kernel@vger.kernel.org>
CC: Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	<virtualization@lists.linux-foundation.org>, <linux-mm@kvack.org>
References: <20190718140006.15052-1-mst@redhat.com>
 <20190718140006.15052-2-mst@redhat.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <97bc457a-6e9c-50d7-0060-555547e9f65b@nvidia.com>
Date: Thu, 18 Jul 2019 09:48:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190718140006.15052-2-mst@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563468504; bh=71Izg78aTb6CFgbhsKMUIFfFgMMQWVl+aKHWkhvfNQo=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=r5nlN0qIvjN4cJP5Al6hkRxP7jUFNYjTcfyHHVfqmgbIs1/Tsl7+tJyTBE0eIWCTG
	 WIUBKCytgAfXZP2wSvfVP4HNXXKHBf5hS6HeoyXYHbJxC3jPlYW7O2uJx/IrzFo6DE
	 c1Um9tRFXbdAjgHXFDw3T+bk6dhsOTLlYnyAtKgxUDwlBbEbLd90zTvLXlCg+76GCr
	 Kk3GA7ANtc1fzZFgScV1LOk6tgiVSbLv4trXKthZ7W6aT33OkJ9TAcz/5T9fr6PkWj
	 YKlzdNBDImCLxpd9tKC43JgTkfUSWcr3Xcn+BoZR2zptnwA8+dQWIsh+lStf1lYN0T
	 hgei965JI1ALw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/18/19 7:01 AM, Michael S. Tsirkin wrote:
> Lots of comments bitrotted. Fix them up.
> 
> Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> Reviewed-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> fixes since v3:
> 	teaks suggested by Wei
> 
>   mm/balloon_compaction.c | 71 ++++++++++++++++++++++-------------------
>   1 file changed, 39 insertions(+), 32 deletions(-)
> 
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index d25664e1857b..7e95d2cd185a 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -32,10 +32,10 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
>    * @b_dev_info: balloon device descriptor where we will insert a new page to
>    * @pages: pages to enqueue - allocated using balloon_page_alloc.
>    *
> - * Driver must call it to properly enqueue a balloon pages before definitively
> - * removing it from the guest system.
> + * Driver must call this function to properly enqueue balloon pages before
> + * definitively removing them from the guest system.
>    *
> - * Return: number of pages that were enqueued.
> + * Returns: number of pages that were enqueued.

According to Documentation/doc-guide/kernel-doc.rst,
this is going in the wrong direction and "Return:" is correct.
Ditto for other occurrences below.

>    */
>   size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
>   				 struct list_head *pages)
> @@ -63,14 +63,15 @@ EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
>    * @n_req_pages: number of requested pages.
>    *
>    * Driver must call this function to properly de-allocate a previous enlisted
> - * balloon pages before definetively releasing it back to the guest system.
> + * balloon pages before definitively releasing it back to the guest system.
>    * This function tries to remove @n_req_pages from the ballooned pages and
>    * return them to the caller in the @pages list.
>    *
> - * Note that this function may fail to dequeue some pages temporarily empty due
> - * to compaction isolated pages.
> + * Note that this function may fail to dequeue some pages even if the balloon
> + * isn't empty - since the page list can be temporarily empty due to compaction
> + * of isolated pages.
>    *
> - * Return: number of pages that were added to the @pages list.
> + * Returns: number of pages that were added to the @pages list.
>    */
>   size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
>   				 struct list_head *pages, size_t n_req_pages)
> @@ -112,12 +113,13 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
>   
>   /*
>    * balloon_page_alloc - allocates a new page for insertion into the balloon
> - *			  page list.
> + *			page list.
>    *
> - * Driver must call it to properly allocate a new enlisted balloon page.
> - * Driver must call balloon_page_enqueue before definitively removing it from
> - * the guest system.  This function returns the page address for the recently
> - * allocated page or NULL in the case we fail to allocate a new page this turn.
> + * Driver must call this function to properly allocate a new balloon page.
> + * Driver must call balloon_page_enqueue before definitively removing the page
> + * from the guest system.
> + *
> + * Returns: struct page for the allocated page or NULL on allocation failure.
>    */
>   struct page *balloon_page_alloc(void)
>   {
> @@ -130,19 +132,15 @@ EXPORT_SYMBOL_GPL(balloon_page_alloc);
>   /*
>    * balloon_page_enqueue - inserts a new page into the balloon page list.
>    *
> - * @b_dev_info: balloon device descriptor where we will insert a new page to
> + * @b_dev_info: balloon device descriptor where we will insert a new page
>    * @page: new page to enqueue - allocated using balloon_page_alloc.
>    *
> - * Driver must call it to properly enqueue a new allocated balloon page
> - * before definitively removing it from the guest system.
> + * Drivers must call this function to properly enqueue a new allocated balloon
> + * page before definitively removing the page from the guest system.
>    *
> - * Drivers must not call balloon_page_enqueue on pages that have been
> - * pushed to a list with balloon_page_push before removing them with
> - * balloon_page_pop. To all pages on a list, use balloon_page_list_enqueue
> - * instead.
> - *
> - * This function returns the page address for the recently enqueued page or
> - * NULL in the case we fail to allocate a new page this turn.
> + * Drivers must not call balloon_page_enqueue on pages that have been pushed to
> + * a list with balloon_page_push before removing them with balloon_page_pop. To
> + * enqueue a list of pages, use balloon_page_list_enqueue instead.
>    */
>   void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>   			  struct page *page)
> @@ -157,14 +155,23 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>   
>   /*
>    * balloon_page_dequeue - removes a page from balloon's page list and returns
> - *			  the its address to allow the driver release the page.
> + *			  its address to allow the driver to release the page.
>    * @b_dev_info: balloon device decriptor where we will grab a page from.
>    *
> - * Driver must call it to properly de-allocate a previous enlisted balloon page
> - * before definetively releasing it back to the guest system.
> - * This function returns the page address for the recently dequeued page or
> - * NULL in the case we find balloon's page list temporarily empty due to
> - * compaction isolated pages.
> + * Driver must call this function to properly dequeue a previously enqueued page
> + * before definitively releasing it back to the guest system.
> + *
> + * Caller must perform its own accounting to ensure that this
> + * function is called only if some pages are actually enqueued.
> + *
> + * Note that this function may fail to dequeue some pages even if there are
> + * some enqueued pages - since the page list can be temporarily empty due to
> + * the compaction of isolated pages.
> + *
> + * TODO: remove the caller accounting requirements, and allow caller to wait
> + * until all pages can be dequeued.
> + *
> + * Returns: struct page for the dequeued page, or NULL if no page was dequeued.
>    */
>   struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>   {
> @@ -177,9 +184,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>   	if (n_pages != 1) {
>   		/*
>   		 * If we are unable to dequeue a balloon page because the page
> -		 * list is empty and there is no isolated pages, then something
> +		 * list is empty and there are no isolated pages, then something
>   		 * went out of track and some balloon pages are lost.
> -		 * BUG() here, otherwise the balloon driver may get stuck into
> +		 * BUG() here, otherwise the balloon driver may get stuck in
>   		 * an infinite loop while attempting to release all its pages.
>   		 */
>   		spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> @@ -230,8 +237,8 @@ int balloon_page_migrate(struct address_space *mapping,
>   
>   	/*
>   	 * We can not easily support the no copy case here so ignore it as it
> -	 * is unlikely to be use with ballon pages. See include/linux/hmm.h for
> -	 * user of the MIGRATE_SYNC_NO_COPY mode.
> +	 * is unlikely to be used with balloon pages. See include/linux/hmm.h
> +	 * for a user of the MIGRATE_SYNC_NO_COPY mode.
>   	 */
>   	if (mode == MIGRATE_SYNC_NO_COPY)
>   		return -EINVAL;
> 
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

