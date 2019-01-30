Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84B5DC282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:13:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B8F12087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:13:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B8F12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB3568E0003; Wed, 30 Jan 2019 03:13:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B626C8E0001; Wed, 30 Jan 2019 03:13:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A78148E0003; Wed, 30 Jan 2019 03:13:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39FE78E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:13:40 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id h11so1972710lfc.9
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:13:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=k5oub0EypmlLKPs+qLr13gNwRtcbwMmGozDFRakplgs=;
        b=C+H1HuS0Ni7sM4rmAkjHlU4uQ0MpHAofook3JefrxJ1U/WRtFZVZg3wv1SEGSDwrYl
         8HGRAd5pfqts2nukOdIpNzHKfcnpBNSdoCmC5eoLRgjs6XHeiem1yWe7LZ9mL3bV57Wo
         Vs5bG4BEl1jJypv7b+SKm41gYUyCXw7dAWAfWzvmeXtSJaA+Y/bg9C7oKfaSRW0+51M2
         x0MKDvZXbhc9IIKZ9XW6/jr6joJoBE7pRD5/4lsgzcFq943FhKNXskSD5/vvkfXsWHsw
         hVD4KG0g3K9+58iswo38t4he1h4JlZHzU9+ebQnfe9cU3VIwyn9uvPA0MpAqblJjvhtP
         762Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AJcUukfk0EAXUj5ohXkDPDB+C96PH5wiHLlTIzt2jzWRnaMH0+7jcT3s
	ZsTKIQoCYwjHLd3m2PjYg5oeHwUOY6raJ005tXX6GDegkjLIH+nwKrwtdCVNibiBcoNsXsA07Id
	qAm8+ZMjJQHArbbfbQLEVHQTra8cAmdPeIS64VDycGuNZ2MzgPSeeJPXA78x9oLYJDQ==
X-Received: by 2002:a19:6514:: with SMTP id z20mr14763310lfb.31.1548836019475;
        Wed, 30 Jan 2019 00:13:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6lM3Fhgbg25f0FLghoteY8m9g/9HMqsSg7pczOIU7CXjUuS1G8E/BJXIfLYsyNNZGJFGjl
X-Received: by 2002:a19:6514:: with SMTP id z20mr14763247lfb.31.1548836018217;
        Wed, 30 Jan 2019 00:13:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548836018; cv=none;
        d=google.com; s=arc-20160816;
        b=BYluqYetjGsdlVk5sawwY2lUQR1YoN7SqsuEAF4ocQzJ8qCZSktjDPLWwzt/UuNWR7
         vJH9tKOJnRiW9J/zuGdrlftSrevY842WxrBBK0FGLKLsZ+l8pm9+duj4sRVwhqbYRWUW
         nWwLskXhFQpf8DMUtYqPZt+OlF1o+4OntMe6smtdIeJrLgX/Dv157vAGW8ef7YeAPIki
         VcC0LCAyIXPPkHcmjIxRMMN08drXfBFZgqPEf8J/XNo47jPaenZUkSNGtpAaPIWXoDaY
         oIME+pBzAV5Akwt7JVJ24h3SoTEc7kFlRwnv5GaEya6SPXtVx+xk7UVYADOlE3+pE8Tu
         VHmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=k5oub0EypmlLKPs+qLr13gNwRtcbwMmGozDFRakplgs=;
        b=RcSnfpqvo8lGSqhYST/H5QwaKHItzCB3v2Q8fVQYcewhOTqhbQXHNY1fX2zMQJKcWU
         pHLekusEv2WDbQKA/rP16FM10FFueYmQOGxCaIUqM0SksT+YV8nnDwHE0FoMj394tmGp
         oMcQ2ds7bEnAdqmsoEB8jCLqyfnkaPO8oMhV5BeDuqVWLJMU7/vk/ll0q59s3zxtcQZ+
         WjFBNMwxflVRyMisLwwngLJW4iYDpuy39d2AlEx1O7KKCqld8A90ZXAxWkXwGu6vaGVq
         TnMOqint0BK9WaOWNdXqlejNLcr0y31uyUGugnURe6rM2778Do37ARRYbABXmGJP7/WS
         OguA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id u26si886408lfk.29.2019.01.30.00.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:13:38 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gol01-0000Sz-QL; Wed, 30 Jan 2019 11:13:33 +0300
Subject: Re: [v3 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: Yang Shi <yang.shi@linux.alibaba.com>, jhubbard@nvidia.com,
 hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <1c259bd4-443e-ac84-ed4a-1b7e36e729aa@virtuozzo.com>
Date: Wed, 30 Jan 2019 11:13:32 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.01.2019 23:29, Yang Shi wrote:
> ksmd need search stable tree to look for the suitable KSM page, but the
> KSM page might be locked for a while due to i.e. KSM page rmap walk.
> Basically it is not a big deal since commit 2c653d0ee2ae
> ("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
> since max_page_sharing limits the number of shared KSM pages.
> 
> But it still sounds not worth waiting for the lock, the page can be skip,
> then try to merge it in the next scan to avoid potential stall if its
> content is still intact.
> 
> Introduce trylock mode to get_ksm_page() to not block on page lock, like
> what try_to_merge_one_page() does.  And, define three possible
> operations (nolock, lock and trylock) as enum type to avoid stacking up
> bools and make the code more readable.
> 
> Return -EBUSY if trylock fails, since NULL means not find suitable KSM
> page, which is a valid case.
> 
> With the default max_page_sharing setting (256), there is almost no
> observed change comparing lock vs trylock.
> 
> However, with ksm02 of LTP, the reduced ksmd full scan time can be
> observed, which has set max_page_sharing to 786432.  With lock version,
> ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
> may take 8s - 11s to run two full scans.  And, the number of
> pages_sharing and pages_to_scan keep same.  Basically, this change has
> no harm.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Suggested-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Also looks good for me.

> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> Hi folks,
> 
> This patch was with "mm: vmscan: skip KSM page in direct reclaim if priority
> is low" in the initial submission.  Then Hugh and Andrea pointed out commit
> 2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page deduplication
> limit") is good enough for limiting the number of shared KSM page to prevent
> from softlock when walking ksm page rmap.  This commit does solve the problem.
> So, the series was dropped by Andrew from -mm tree.
> 
> However, I thought the second patch (this one) still sounds useful.  So, I did
> some test and resubmit it.  The first version was reviewed by Krill Tkhai, so
> I keep his Reviewed-by tag since there is no change to the patch except the
> commit log.
> 
> So, would you please reconsider this patch?
> 
> v3: Use enum to define get_ksm_page operations (nolock, lock and trylock) per
>     John Hubbard
> v2: Updated the commit log to reflect some test result and latest discussion
> 
>  mm/ksm.c | 46 ++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 36 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 6c48ad1..5647bc1 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  	free_stable_node(stable_node);
>  }
>  
> +enum get_ksm_page_flags {
> +	GET_KSM_PAGE_NOLOCK,
> +	GET_KSM_PAGE_LOCK,
> +	GET_KSM_PAGE_TRYLOCK
> +};
> +
>  /*
>   * get_ksm_page: checks if the page indicated by the stable node
>   * is still its ksm page, despite having held no reference to it.
> @@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>   * a page to put something that might look like our key in page->mapping.
>   * is on its way to being freed; but it is an anomaly to bear in mind.
>   */
> -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> +static struct page *get_ksm_page(struct stable_node *stable_node,
> +				 enum get_ksm_page_flags flags)
>  {
>  	struct page *page;
>  	void *expected_mapping;
> @@ -728,8 +735,15 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>  		goto stale;
>  	}
>  
> -	if (lock_it) {
> +	if (flags == GET_KSM_PAGE_TRYLOCK) {
> +		if (!trylock_page(page)) {
> +			put_page(page);
> +			return ERR_PTR(-EBUSY);
> +		}
> +	} else if (flags == GET_KSM_PAGE_LOCK)
>  		lock_page(page);
> +
> +	if (flags != GET_KSM_PAGE_NOLOCK) {
>  		if (READ_ONCE(page->mapping) != expected_mapping) {
>  			unlock_page(page);
>  			put_page(page);
> @@ -763,7 +777,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  		struct page *page;
>  
>  		stable_node = rmap_item->head;
> -		page = get_ksm_page(stable_node, true);
> +		page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
>  		if (!page)
>  			goto out;
>  
> @@ -863,7 +877,7 @@ static int remove_stable_node(struct stable_node *stable_node)
>  	struct page *page;
>  	int err;
>  
> -	page = get_ksm_page(stable_node, true);
> +	page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
>  	if (!page) {
>  		/*
>  		 * get_ksm_page did remove_node_from_stable_tree itself.
> @@ -1385,7 +1399,7 @@ static struct page *stable_node_dup(struct stable_node **_stable_node_dup,
>  		 * stable_node parameter itself will be freed from
>  		 * under us if it returns NULL.
>  		 */
> -		_tree_page = get_ksm_page(dup, false);
> +		_tree_page = get_ksm_page(dup, GET_KSM_PAGE_NOLOCK);
>  		if (!_tree_page)
>  			continue;
>  		nr += 1;
> @@ -1508,7 +1522,7 @@ static struct page *__stable_node_chain(struct stable_node **_stable_node_dup,
>  	if (!is_stable_node_chain(stable_node)) {
>  		if (is_page_sharing_candidate(stable_node)) {
>  			*_stable_node_dup = stable_node;
> -			return get_ksm_page(stable_node, false);
> +			return get_ksm_page(stable_node, GET_KSM_PAGE_NOLOCK);
>  		}
>  		/*
>  		 * _stable_node_dup set to NULL means the stable_node
> @@ -1613,7 +1627,8 @@ static struct page *stable_tree_search(struct page *page)
>  			 * wrprotected at all times. Any will work
>  			 * fine to continue the walk.
>  			 */
> -			tree_page = get_ksm_page(stable_node_any, false);
> +			tree_page = get_ksm_page(stable_node_any,
> +						 GET_KSM_PAGE_NOLOCK);
>  		}
>  		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>  		if (!tree_page) {
> @@ -1673,7 +1688,12 @@ static struct page *stable_tree_search(struct page *page)
>  			 * It would be more elegant to return stable_node
>  			 * than kpage, but that involves more changes.
>  			 */
> -			tree_page = get_ksm_page(stable_node_dup, true);
> +			tree_page = get_ksm_page(stable_node_dup,
> +						 GET_KSM_PAGE_TRYLOCK);
> +
> +			if (PTR_ERR(tree_page) == -EBUSY)
> +				return ERR_PTR(-EBUSY);
> +
>  			if (unlikely(!tree_page))
>  				/*
>  				 * The tree may have been rebalanced,
> @@ -1842,7 +1862,8 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  			 * wrprotected at all times. Any will work
>  			 * fine to continue the walk.
>  			 */
> -			tree_page = get_ksm_page(stable_node_any, false);
> +			tree_page = get_ksm_page(stable_node_any,
> +						 GET_KSM_PAGE_NOLOCK);
>  		}
>  		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>  		if (!tree_page) {
> @@ -2060,6 +2081,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  
>  	/* We first start with searching the page inside the stable tree */
>  	kpage = stable_tree_search(page);
> +
> +	if (PTR_ERR(kpage) == -EBUSY)
> +		return;
> +
>  	if (kpage == page && rmap_item->head == stable_node) {
>  		put_page(kpage);
>  		return;
> @@ -2242,7 +2267,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  
>  			list_for_each_entry_safe(stable_node, next,
>  						 &migrate_nodes, list) {
> -				page = get_ksm_page(stable_node, false);
> +				page = get_ksm_page(stable_node,
> +						    GET_KSM_PAGE_NOLOCK);
>  				if (page)
>  					put_page(page);
>  				cond_resched();
> 

