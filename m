Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CEAEC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:47:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C36B42087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:47:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C36B42087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 597BC8E0002; Wed, 30 Jan 2019 12:47:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 547AA8E0001; Wed, 30 Jan 2019 12:47:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40F538E0002; Wed, 30 Jan 2019 12:47:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA1C88E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:47:27 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so226759pfi.21
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:47:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=0Fw8JVJp6K6fCy+lUP6MQ0HWA2RDowGCEzx3fBC2nfw=;
        b=n4ysSYulpLDTqVXiSg2/JzBMUYQSfTFFU1MI5y3nukeylm/3gTCcrQb83sazq+vKDf
         cbJGG4+BwklAfI7Rvk19Vbf0A0n8oeRCyWVWs3EE0Q6vfPejDMMo+bhDyLATB9EU0ymf
         7A2uLfG7+O1CEU6WuGYnEsCwnbGnSPGrVnIRin/p2SkNHIdyFCkQeTYczM3DRT95WZ8z
         o7fRpA9HMaqOfAoAckhe4y7USwaLa9EarIn8mT3ZO3gGhxhg/CGLcCfZDXYR+GxMEjti
         FXwGy0Vaku9qZaxh0EkhYyAF5lK2yyIF3Hg+5HqFEiAjeew4jWU/TlcD6MBYrfsa9hjC
         WIPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukewd5Nh8dTpMSJJXKXby+SrdxeLlhZV0Ct3kSWQU6mb2NhYffZh
	DiC8BOln2InfIjJOso/VEmPS1SwpqI/0vVeUoQI4Fdzz8w53LbXjfrsjAEg9AF4PkqST6luEBvn
	DX0wISX7bzb3DXQo9bQU/jL+MD+cHtzrGZWy8ry535gshlLk/lpisBtHDwd7EtflIpA==
X-Received: by 2002:a62:5b44:: with SMTP id p65mr31074824pfb.47.1548870447552;
        Wed, 30 Jan 2019 09:47:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Id9wbYyBO1qJK52deV3NBoHmmm6/1JhnahglnqXjxP19niCAPHXr2zQFVgGOKJG3Jih1x
X-Received: by 2002:a62:5b44:: with SMTP id p65mr31074779pfb.47.1548870446642;
        Wed, 30 Jan 2019 09:47:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548870446; cv=none;
        d=google.com; s=arc-20160816;
        b=RCnA+Rzg5gOpJhqBm5yv6x/2VuerqgOxKWE9dIRaKF7nK7kS0iwLFrWq6JD32u3GM+
         QITgyqWTuK2w6Inv4bGFN+oywPT7ALJL4SNbr8g4wXITTrrffoXUH1jy96UdIdjFLj0h
         rRaRjRHHahTPJ/Kpfwu/XTPz+AmZ2/MBS/WCjVPGoW+jpvadVzc1+SNfUbVk8JxYrM4n
         +Pb+T6waGpgqB5TEUnSDzgDpR72O9hzxB0jTJZ2xKBSdGsx2JqlWYM5zpom10SdqVi6p
         0GG3C5RlfneTzNkxNtu3zE3DU/9Lx3Eq9gSWfLFndHQEOup6FOrI38HKiB/HioOeu6Wg
         1LPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0Fw8JVJp6K6fCy+lUP6MQ0HWA2RDowGCEzx3fBC2nfw=;
        b=J0YKji+yvwaMFciL7fVvaZPkDw6ZF/WrG8CWjcTSB/Ro/Q/GS26nv0cgTxsOLy7hCj
         cJXURttdTGe/95hNFNDcSqXZ1UjRDM8LrLz/zOa5HZetrrr35zyOuHPQv0IkQnPGoN7N
         c/E0f7GDgyPN3A5SfxH7GDYD8QIxFH/keO2m4J3EUdGUAz7V1VAZ4Fe5ghiMr+r0ApLC
         bd9fmVpayrHpJdx8Okec8NIjX77l6JglIn/kTKGdS6IJTnAev/GhOyaB9qu536Mk3sIW
         EUBy2JbufZfyD70CS01Tbz7aT0UqH9Zy0Fhhyv2sJsbggQ3IkTvMLc5eWBdhp3jgRdDc
         v/Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id ca6si2272974plb.141.2019.01.30.09.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:47:26 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TJHNlRE_1548870440;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TJHNlRE_1548870440)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 31 Jan 2019 01:47:23 +0800
Subject: Re: [v3 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: John Hubbard <jhubbard@nvidia.com>, ktkhai@virtuozzo.com,
 hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
 <82ba1395-baab-3b95-a3f7-47e219551881@nvidia.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7cf16cfb-3190-dfbd-ce72-92a94d9277f5@linux.alibaba.com>
Date: Wed, 30 Jan 2019 09:47:19 -0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <82ba1395-baab-3b95-a3f7-47e219551881@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 1/29/19 11:14 PM, John Hubbard wrote:
> On 1/29/19 12:29 PM, Yang Shi wrote:
>> ksmd need search stable tree to look for the suitable KSM page, but the
>> KSM page might be locked for a while due to i.e. KSM page rmap walk.
>> Basically it is not a big deal since commit 2c653d0ee2ae
>> ("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
>> since max_page_sharing limits the number of shared KSM pages.
>>
>> But it still sounds not worth waiting for the lock, the page can be 
>> skip,
>> then try to merge it in the next scan to avoid potential stall if its
>> content is still intact.
>>
>> Introduce trylock mode to get_ksm_page() to not block on page lock, like
>> what try_to_merge_one_page() does.  And, define three possible
>> operations (nolock, lock and trylock) as enum type to avoid stacking up
>> bools and make the code more readable.
>>
>> Return -EBUSY if trylock fails, since NULL means not find suitable KSM
>> page, which is a valid case.
>>
>> With the default max_page_sharing setting (256), there is almost no
>> observed change comparing lock vs trylock.
>>
>> However, with ksm02 of LTP, the reduced ksmd full scan time can be
>> observed, which has set max_page_sharing to 786432.  With lock version,
>> ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
>> may take 8s - 11s to run two full scans.  And, the number of
>> pages_sharing and pages_to_scan keep same.  Basically, this change has
>> no harm >
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Suggested-by: John Hubbard <jhubbard@nvidia.com>
>> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> Hi folks,
>>
>> This patch was with "mm: vmscan: skip KSM page in direct reclaim if 
>> priority
>> is low" in the initial submission.  Then Hugh and Andrea pointed out 
>> commit
>> 2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page 
>> deduplication
>> limit") is good enough for limiting the number of shared KSM page to 
>> prevent
>> from softlock when walking ksm page rmap.  This commit does solve the 
>> problem.
>> So, the series was dropped by Andrew from -mm tree.
>>
>> However, I thought the second patch (this one) still sounds useful.  
>> So, I did
>> some test and resubmit it.  The first version was reviewed by Krill 
>> Tkhai, so
>> I keep his Reviewed-by tag since there is no change to the patch 
>> except the
>> commit log.
>>
>> So, would you please reconsider this patch?
>>
>> v3: Use enum to define get_ksm_page operations (nolock, lock and 
>> trylock) per
>>      John Hubbard
>> v2: Updated the commit log to reflect some test result and latest 
>> discussion
>>
>>   mm/ksm.c | 46 ++++++++++++++++++++++++++++++++++++----------
>>   1 file changed, 36 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index 6c48ad1..5647bc1 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct 
>> stable_node *stable_node)
>>       free_stable_node(stable_node);
>>   }
>>   +enum get_ksm_page_flags {
>> +    GET_KSM_PAGE_NOLOCK,
>> +    GET_KSM_PAGE_LOCK,
>> +    GET_KSM_PAGE_TRYLOCK
>> +};
>> +
>>   /*
>>    * get_ksm_page: checks if the page indicated by the stable node
>>    * is still its ksm page, despite having held no reference to it.
>> @@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct 
>> stable_node *stable_node)
>>    * a page to put something that might look like our key in 
>> page->mapping.
>>    * is on its way to being freed; but it is an anomaly to bear in mind.
>>    */
>> -static struct page *get_ksm_page(struct stable_node *stable_node, 
>> bool lock_it)
>> +static struct page *get_ksm_page(struct stable_node *stable_node,
>> +                 enum get_ksm_page_flags flags)
>>   {
>>       struct page *page;
>>       void *expected_mapping;
>> @@ -728,8 +735,15 @@ static struct page *get_ksm_page(struct 
>> stable_node *stable_node, bool lock_it)
>>           goto stale;
>>       }
>>   -    if (lock_it) {
>> +    if (flags == GET_KSM_PAGE_TRYLOCK) {
>> +        if (!trylock_page(page)) {
>> +            put_page(page);
>> +            return ERR_PTR(-EBUSY);
>> +        }
>> +    } else if (flags == GET_KSM_PAGE_LOCK)
>>           lock_page(page);
>> +
>> +    if (flags != GET_KSM_PAGE_NOLOCK) {
>>           if (READ_ONCE(page->mapping) != expected_mapping) {
>>               unlock_page(page);
>>               put_page(page);
>> @@ -763,7 +777,7 @@ static void remove_rmap_item_from_tree(struct 
>> rmap_item *rmap_item)
>>           struct page *page;
>>             stable_node = rmap_item->head;
>> -        page = get_ksm_page(stable_node, true);
>> +        page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
>>           if (!page)
>>               goto out;
>>   @@ -863,7 +877,7 @@ static int remove_stable_node(struct 
>> stable_node *stable_node)
>>       struct page *page;
>>       int err;
>>   -    page = get_ksm_page(stable_node, true);
>> +    page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
>>       if (!page) {
>>           /*
>>            * get_ksm_page did remove_node_from_stable_tree itself.
>> @@ -1385,7 +1399,7 @@ static struct page *stable_node_dup(struct 
>> stable_node **_stable_node_dup,
>>            * stable_node parameter itself will be freed from
>>            * under us if it returns NULL.
>>            */
>> -        _tree_page = get_ksm_page(dup, false);
>> +        _tree_page = get_ksm_page(dup, GET_KSM_PAGE_NOLOCK);
>>           if (!_tree_page)
>>               continue;
>>           nr += 1;
>> @@ -1508,7 +1522,7 @@ static struct page *__stable_node_chain(struct 
>> stable_node **_stable_node_dup,
>>       if (!is_stable_node_chain(stable_node)) {
>>           if (is_page_sharing_candidate(stable_node)) {
>>               *_stable_node_dup = stable_node;
>> -            return get_ksm_page(stable_node, false);
>> +            return get_ksm_page(stable_node, GET_KSM_PAGE_NOLOCK);
>>           }
>>           /*
>>            * _stable_node_dup set to NULL means the stable_node
>> @@ -1613,7 +1627,8 @@ static struct page *stable_tree_search(struct 
>> page *page)
>>                * wrprotected at all times. Any will work
>>                * fine to continue the walk.
>>                */
>> -            tree_page = get_ksm_page(stable_node_any, false);
>> +            tree_page = get_ksm_page(stable_node_any,
>> +                         GET_KSM_PAGE_NOLOCK);
>>           }
>>           VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>>           if (!tree_page) {
>> @@ -1673,7 +1688,12 @@ static struct page *stable_tree_search(struct 
>> page *page)
>>                * It would be more elegant to return stable_node
>>                * than kpage, but that involves more changes.
>>                */
>> -            tree_page = get_ksm_page(stable_node_dup, true);
>> +            tree_page = get_ksm_page(stable_node_dup,
>> +                         GET_KSM_PAGE_TRYLOCK);
>> +
>> +            if (PTR_ERR(tree_page) == -EBUSY)
>> +                return ERR_PTR(-EBUSY);
>
> or just:
>
>     if (PTR_ERR(tree_page) == -EBUSY)
>         return tree_page;
>
> right?

Either looks fine to me. Returning errno may look more explicit? Anyway 
I really don't have preference.

>
>> +
>>               if (unlikely(!tree_page))
>>                   /*
>>                    * The tree may have been rebalanced,
>> @@ -1842,7 +1862,8 @@ static struct stable_node 
>> *stable_tree_insert(struct page *kpage)
>>                * wrprotected at all times. Any will work
>>                * fine to continue the walk.
>>                */
>> -            tree_page = get_ksm_page(stable_node_any, false);
>> +            tree_page = get_ksm_page(stable_node_any,
>> +                         GET_KSM_PAGE_NOLOCK);
>>           }
>>           VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>>           if (!tree_page) {
>> @@ -2060,6 +2081,10 @@ static void cmp_and_merge_page(struct page 
>> *page, struct rmap_item *rmap_item)
>>         /* We first start with searching the page inside the stable 
>> tree */
>>       kpage = stable_tree_search(page);
>> +
>> +    if (PTR_ERR(kpage) == -EBUSY)
>> +        return;
>> +
>>       if (kpage == page && rmap_item->head == stable_node) {
>>           put_page(kpage);
>>           return;
>> @@ -2242,7 +2267,8 @@ static struct rmap_item 
>> *scan_get_next_rmap_item(struct page **page)
>>                 list_for_each_entry_safe(stable_node, next,
>>                            &migrate_nodes, list) {
>> -                page = get_ksm_page(stable_node, false);
>> +                page = get_ksm_page(stable_node,
>> +                            GET_KSM_PAGE_NOLOCK);
>>                   if (page)
>>                       put_page(page);
>>                   cond_resched();
>>
>
> Hi Yang,
>
> The patch looks correct as far doing what it claims to do. I'll leave it
> to others to decide if a trylock-based approach is really what you want,
> for KSM scans. It seems reasonable from my very limited knowledge of
> KSM: there shouldn't be any cases where you really *need* to wait for
> a page lock, because the whole system is really sort of an optimization
> anyway.

Thanks!

Yang

>
>
> thanks,

