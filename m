Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77CBAC282C0
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 00:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26E8821872
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 00:24:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="BtOwafei"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26E8821872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD4738E0067; Wed, 23 Jan 2019 19:23:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B83288E0066; Wed, 23 Jan 2019 19:23:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A728A8E0067; Wed, 23 Jan 2019 19:23:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83F998E0066
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 19:23:59 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id e1so1759454ybn.7
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:23:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=WKVPpYTc1aT5qPPOxmBAIk3y3CbZDzFD22w9FFX3QWw=;
        b=oDMqFIism5lm1idSO6vkeGR0oaajChnXLh3SNy0zvIxtZOvZArlj0Zj/IBzik7AsYf
         eLc9Wfua5WtrR5KfeoAp2YzlEuAVgenphUNqPR2rvCDMBLLizAca/zG6OCCjr+iAdT20
         8TnJU0Jhl9qTFpib6MxP8RPPOuhOnjJgkUjzNrmZhe37brDlIEfZCqPrKhH6Sc4vDlVe
         FXNLlJLe6ktunSsgfCIHC/BJpjms30AsUU7kBM+5bMCqIOzhaGju10qTrSzqVQBxfIDI
         9Ar0s6xAqr0CruRVSjk16k8kzhZdNR9UBfxsZjrtuPuEbWx1Ici0X1QDCoTtPqqVTqwq
         abng==
X-Gm-Message-State: AJcUukdT0600mGMzh3yjFlX28Htza+rASKyoUOMPoiwqBh2dnEWvru4c
	Vm24fdUJwZKgdlNpexZAoBm6mHEXixBcahJoYtgitbDfn5bsS1tJgavzYv71e2HKc3nJI+dMNfW
	hWxjTRoWH0xKfJg4UePzq1CjfziDVJAkrIbE64twjg54/lqMIYazbxQrB+q3VZSTBPg==
X-Received: by 2002:a25:a243:: with SMTP id b61mr4011018ybi.386.1548289439134;
        Wed, 23 Jan 2019 16:23:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5TbELenFVbKop4lnrOdIjS+3+6cUjoh9hKnGUuCwFJ248ZBAGct9lb7ZAeacfK8OacWbZI
X-Received: by 2002:a25:a243:: with SMTP id b61mr4010990ybi.386.1548289438318;
        Wed, 23 Jan 2019 16:23:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548289438; cv=none;
        d=google.com; s=arc-20160816;
        b=iTRg8OZyoqhlVnq7Nlp7RvAIU4sQWWeQPgEK1j3/TdFz7SNlkwHW4G0QJBXSqWY3mF
         Ok6krrUKAiioRYwUdFeVvyIX0jrMVoHphOx3sEBwEfUhg8swvJT47wLirfBE3Vvd+FUY
         EyQCTAdTruf1Z1TAl6GzugMtgRdCITYhzTCoYyA9QDEIX8P3nEMOPIRD9aAYyinQ/Pp7
         pZUZ5KWiK6sglgVqwRdvCPfwbRBgFIEE6Q5sM/DyX2gPJFoqvjfJWb+tBaMRy0a3FSN5
         08kfunxcFMR1Q4TMwHNqndn+CNWyqU6UVKME9AHI0jFuHL+t9y4pWeqluTls5aLVoRXW
         rlbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=WKVPpYTc1aT5qPPOxmBAIk3y3CbZDzFD22w9FFX3QWw=;
        b=Wvje5p/z68ej0sHccvRti+ps9R1r5HpjYObSSjStDLr57ugPpkLD9roBHMwGBTMFqz
         jzYG43YOnINEIar0McsQtee0vsPLSY3YKKcN3T+xZ1ju6G8SvwYzGH94qYnU3oojycfV
         xGWRXqQsxY4gteCxGO7Hr76N5EncYFA0hRLGtWiJpIKKBv1xHikv5nhE5z1TQV5oMhFB
         3pBHD3IIKes0OEd1pTEvBJbojKHeVHZ34kW+KtmFhQY7j0FBXGR+5KZEA2t/NXnzfRyD
         HkDgbiRLNuP/8KmgBC6+BaKfE0nctjomnEZx09gpeqCHeha9F/hD9KAM/OGbabrqeHZX
         E4oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BtOwafei;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id x65si13010982ybe.166.2019.01.23.16.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 16:23:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BtOwafei;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c49058b0000>; Wed, 23 Jan 2019 16:23:39 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 23 Jan 2019 16:23:57 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 23 Jan 2019 16:23:57 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 24 Jan
 2019 00:23:56 +0000
Subject: Re: [v2 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: Yang Shi <yang.shi@linux.alibaba.com>, <ktkhai@virtuozzo.com>,
	<hughd@google.com>, <aarcange@redhat.com>, <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
References: <1548287573-15084-1-git-send-email-yang.shi@linux.alibaba.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <aecc642c-d485-ed95-7935-19cda48800bc@nvidia.com>
Date: Wed, 23 Jan 2019 16:23:56 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1548287573-15084-1-git-send-email-yang.shi@linux.alibaba.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548289419; bh=WKVPpYTc1aT5qPPOxmBAIk3y3CbZDzFD22w9FFX3QWw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=BtOwafeiEXgC2KiqqX2pf2pRZIdk9LGkRl6qasfM+kOZV+o2jCz+I+IYU8oXynaBy
	 CaS8P76IDotSoYwsshn/9WvHBQMcTlFRNaXL/sRxK2b27CDIGBhe5Q0QfACaKPOVjB
	 Y9r9BNQrIyLdbBjjOXt6KADdukxmCmpQ1C/oEqL7FM36SXl7WZkELP3QfZKmtLyuDz
	 HEyDS2gwZYOFpTljKQnyt1SRlnqutHdUALvLUt6RjBoLfQg8oF2aN1t2MPo9S59g9/
	 DCZ08g6kQm2+TNPaPNVhheZ7f2nwyE7B0bURbFT7wtBOd7jDASRMKhdjP6+59cs0l7
	 hjltB70Jf4N8g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190124002356.8JTPvwztVmyPcraSxecmtp0ymvjoMSf_HRbsHiwwjtM@z>

On 1/23/19 3:52 PM, Yang Shi wrote:
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
> Introduce async mode to get_ksm_page() to not block on page lock, like
> what try_to_merge_one_page() does.
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
> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
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
> v2: Updated the commit log to reflect some test result and latest discussion
> 
>  mm/ksm.c | 29 +++++++++++++++++++++++++----
>  1 file changed, 25 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 6c48ad1..f66405c 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -668,7 +668,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  }
>  
>  /*
> - * get_ksm_page: checks if the page indicated by the stable node
> + * __get_ksm_page: checks if the page indicated by the stable node
>   * is still its ksm page, despite having held no reference to it.
>   * In which case we can trust the content of the page, and it
>   * returns the gotten page; but if the page has now been zapped,
> @@ -686,7 +686,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>   * a page to put something that might look like our key in page->mapping.
>   * is on its way to being freed; but it is an anomaly to bear in mind.
>   */
> -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> +static struct page *__get_ksm_page(struct stable_node *stable_node,
> +				   bool lock_it, bool async)
>  {
>  	struct page *page;
>  	void *expected_mapping;
> @@ -729,7 +730,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>  	}
>  
>  	if (lock_it) {
> -		lock_page(page);
> +		if (async) {
> +			if (!trylock_page(page)) {
> +				put_page(page);
> +				return ERR_PTR(-EBUSY);
> +			}
> +		} else
> +			lock_page(page);
> +
>  		if (READ_ONCE(page->mapping) != expected_mapping) {
>  			unlock_page(page);
>  			put_page(page);
> @@ -752,6 +760,11 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>  	return NULL;
>  }
>  
> +static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> +{
> +	return __get_ksm_page(stable_node, lock_it, false);
> +}
> +
>  /*
>   * Removing rmap_item from stable or unstable tree.
>   * This function will clean the information from the stable/unstable tree.
> @@ -1673,7 +1686,11 @@ static struct page *stable_tree_search(struct page *page)
>  			 * It would be more elegant to return stable_node
>  			 * than kpage, but that involves more changes.
>  			 */
> -			tree_page = get_ksm_page(stable_node_dup, true);
> +			tree_page = __get_ksm_page(stable_node_dup, true, true);

Hi Yang,

The bools are stacking up: now you've got two, and the above invocation is no longer
understandable on its own. At this point, we normally shift to flags and/or an
enum.

Also, I see little value in adding a stub function here, so how about something more
like the following approximation (untested, and changes to callers are not shown):

diff --git a/mm/ksm.c b/mm/ksm.c
index 6c48ad13b4c9..8390b7905b44 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
        free_stable_node(stable_node);
 }
 
+typedef enum {
+       GET_KSM_PAGE_NORMAL,
+       GET_KSM_PAGE_LOCK_PAGE,
+       GET_KSM_PAGE_TRYLOCK_PAGE
+} get_ksm_page_t;
+
 /*
  * get_ksm_page: checks if the page indicated by the stable node
  * is still its ksm page, despite having held no reference to it.
@@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
  * a page to put something that might look like our key in page->mapping.
  * is on its way to being freed; but it is an anomaly to bear in mind.
  */
-static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
+static struct page *get_ksm_page(struct stable_node *stable_node,
+                                get_ksm_page_t flags)
 {
        struct page *page;
        void *expected_mapping;
@@ -728,8 +735,17 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
                goto stale;
        }
 
-       if (lock_it) {
+       if (flags == GET_KSM_PAGE_TRYLOCK_PAGE) {
+               if (!trylock_page(page)) {
+                       put_page(page);
+                       return ERR_PTR(-EBUSY);
+               }
+       } else if (flags == GET_KSM_PAGE_LOCK_PAGE) {
                lock_page(page);
+       }
+
+       if (flags == GET_KSM_PAGE_LOCK_PAGE ||
+           flags == GET_KSM_PAGE_TRYLOCK_PAGE) {
                if (READ_ONCE(page->mapping) != expected_mapping) {
                        unlock_page(page);
                        put_page(page);


thanks,
-- 
John Hubbard
NVIDIA 

> +
> +			if (PTR_ERR(tree_page) == -EBUSY)
> +				return ERR_PTR(-EBUSY);
> +
>  			if (unlikely(!tree_page))
>  				/*
>  				 * The tree may have been rebalanced,
> @@ -2060,6 +2077,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
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
> 

