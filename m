Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD6BC282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:08:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B3E42175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:08:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="mlkQ6NOF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B3E42175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B8D68E0003; Mon, 28 Jan 2019 17:08:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 269868E0001; Mon, 28 Jan 2019 17:08:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10C3A8E0003; Mon, 28 Jan 2019 17:08:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFAAA8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:08:00 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 18so9197466ybx.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:08:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=atziYoVNtZlsUBpoOkRdIcTcr9ul8YlOzzub/SP3RrY=;
        b=E3Spyv3ujUDOVNd2JMy/dpy1TBt73CojLgw7yWnaNjOFM0iASoBgbhrEgtkGmH8D0+
         tC2ZBgTd6ford6QX9wO27b2m9zPz2LPhai9HtiB2Fap+niIm6Nq5E5+uBiBtFAI7p0CX
         pBZcUGj0I3Pu8F4uzkL31OTj3l3NdYnAppT7LYnza+RkamVSaZfiQqiSRM4ww7/faQCt
         LAXwPDP8+JPN51hJyAg1i8D5er6S2USP3c4807c7c6xBXEGVnvDwW7/PbacFFxTnsct1
         CqgQGrqEZI8GsvCmoDMsvj8VvEWyWLr6CYDnXV6FuJpha10LfLFsF4M44hM6EdZsgaZD
         FW1Q==
X-Gm-Message-State: AJcUukfnHYIrEBd/iRVWY3cm/I/wahO8LQcUyJFBM91uBcUnHKwiK75x
	OeXddo1FkGLZcyzoHuxmJAJsxS1OibNchd+bqEZkliqtkBc5B/wXOWqWYTZ/qWJg28vLAsy0LUO
	S24K2TkBYoIEq65U18iV7eAuopBq4rkhVSmNEwwBn3j5V0nyXA0mK8TfN8w3AyMGuwA==
X-Received: by 2002:a81:d201:: with SMTP id x1mr23774035ywi.9.1548713280473;
        Mon, 28 Jan 2019 14:08:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5UpgdgYLW6rnqwsL4ppUHCV5WGEljSptDDz+Nk8bSxxaLcnBYZbwcwvsAFiIOleDZi8gS2
X-Received: by 2002:a81:d201:: with SMTP id x1mr23773991ywi.9.1548713279621;
        Mon, 28 Jan 2019 14:07:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548713279; cv=none;
        d=google.com; s=arc-20160816;
        b=dWNHlvBCinet2SkH0uk+/VvsaFI8iS4eIpeb54xFlaCcdBt7BNcNn6uJSXVfxOMx22
         HjeFzmXDGic3M/cWV4BQUD7f+yB4o5r2q4q+P10+XGyGMrCHVHoeRPYYqgv/UPbuBF9o
         y3gfIwT6vQNlhgWWc6kCmO5qVaUzRiNSskkoKlXyPIQXkZ2VVvYzJYVkvzUOeCZhr0Aw
         Y06mVri44v0VA6FYLn9Vw/wOL1hlXR+wR7Llgjy0aTUl0yIxlq4Ynk7w+AXWbQPXAVxj
         k/j/RC2xlVPhDwpnN02vtbuBttfC0LDFChOumVrPr8YYjT/tE4agfT6KTLVDWOQEJLQx
         pYRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=atziYoVNtZlsUBpoOkRdIcTcr9ul8YlOzzub/SP3RrY=;
        b=ErvC0Vx8vGEfzCp9kDVpWF36+bQP/b143TMt8/vD92KVH76gHMtBt8pHDCj7u1gj2E
         qLLS4xyQtS3MbB6qIdqSoRUx+k7EBJCdUr3RfNs2P72UHrJNJU54PMKsNaSC9QBIXnVz
         +V+LusXMMQCp3kEXA8tGLPvYFFWn0oJb1C2uMBTQ09MSgdAg0gKKpTrRTttIItjOR5O7
         loAlRHYovFlANl2by1cCqiP+QFl40yyw5QFjnhkPQ9Tt1tj3oSaLwZBpxht7pVPsgZHz
         D0js8z5ZylH8qYm8OfsL8g5+DIXXXgRtofYCvvOG3l0LWVfdxDKPATxf/DJUjb/zLcgb
         hHPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mlkQ6NOF;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 6si19452141ybm.307.2019.01.28.14.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 14:07:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mlkQ6NOF;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c4f7d170000>; Mon, 28 Jan 2019 14:07:19 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 28 Jan 2019 14:07:58 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 28 Jan 2019 14:07:58 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 28 Jan
 2019 22:07:57 +0000
Subject: Re: [v2 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: Yang Shi <shy828301@gmail.com>
CC: Yang Shi <yang.shi@linux.alibaba.com>, Kirill Tkhai
	<ktkhai@virtuozzo.com>, <hughd@google.com>, Andrea Arcangeli
	<aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM
	<linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>
References: <1548287573-15084-1-git-send-email-yang.shi@linux.alibaba.com>
 <aecc642c-d485-ed95-7935-19cda48800bc@nvidia.com>
 <CAHbLzkqTZK05g0191dKyTXGDcAuqMi9AGWPHbAEysQdgT7ayBQ@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <968651e7-b734-2963-5def-71201729c5cf@nvidia.com>
Date: Mon, 28 Jan 2019 14:07:57 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAHbLzkqTZK05g0191dKyTXGDcAuqMi9AGWPHbAEysQdgT7ayBQ@mail.gmail.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548713239; bh=atziYoVNtZlsUBpoOkRdIcTcr9ul8YlOzzub/SP3RrY=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=mlkQ6NOFlum/2kum5K+LpXqlbXHrJqx8TYD92UbrTOgIqfgSlhPr6cVxHFL1YUdll
	 pD8aJOiECAEE0qs66jey6fnnnGnQD/M8MO1Wix4fn2RxtuTm7aSEveTtB0LA648o2P
	 YPsjI4bt3jzSWqQRH4p/Ondq94dpJtLQDLVYG+VE4+9Ymog1anbmZAFvuItauKa7b9
	 v+gZOLoFCEYl/xE72UtGZzZqYd9Bk451kS7zqf1t8S0Ad8bo8+62I9snp2X6tL9B0N
	 3BanO6EhtGirwF32pGzKepUp41M74AyeSYQF/AiKWSZIJMeTwaVQfAc+9x6yhbBQeH
	 p67g2mhkEotlQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/28/19 12:06 PM, Yang Shi wrote:
> Hi John,
> 
> Sorry for the late reply. It seems your email didn't reach my company
> mailbox. So, I replied you with my personal email.
> 
> Thanks for your suggestion. This does make the code looks neater.
> However, I'm not sure how Andrew thought about this patch. Once he is
> ok to this patch in overall, I will update v3 by following your
> suggestion.
> 
> Regards,
> Yang

Hi Yang, 

OK, great.

On the email, I took a quick peek at it looks like my email reached the
main lists, anyway, in case this helps with troubleshooting on your end:0

https://lore.kernel.org/lkml/aecc642c-d485-ed95-7935-19cda48800bc@nvidia.com/

thanks,
-- 
John Hubbard
NVIDIA
 
> 
> On Wed, Jan 23, 2019 at 4:24 PM John Hubbard <jhubbard@nvidia.com> wrote:
>>
>> On 1/23/19 3:52 PM, Yang Shi wrote:
>>> ksmd need search stable tree to look for the suitable KSM page, but the
>>> KSM page might be locked for a while due to i.e. KSM page rmap walk.
>>> Basically it is not a big deal since commit 2c653d0ee2ae
>>> ("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
>>> since max_page_sharing limits the number of shared KSM pages.
>>>
>>> But it still sounds not worth waiting for the lock, the page can be skip,
>>> then try to merge it in the next scan to avoid potential stall if its
>>> content is still intact.
>>>
>>> Introduce async mode to get_ksm_page() to not block on page lock, like
>>> what try_to_merge_one_page() does.
>>>
>>> Return -EBUSY if trylock fails, since NULL means not find suitable KSM
>>> page, which is a valid case.
>>>
>>> With the default max_page_sharing setting (256), there is almost no
>>> observed change comparing lock vs trylock.
>>>
>>> However, with ksm02 of LTP, the reduced ksmd full scan time can be
>>> observed, which has set max_page_sharing to 786432.  With lock version,
>>> ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
>>> may take 8s - 11s to run two full scans.  And, the number of
>>> pages_sharing and pages_to_scan keep same.  Basically, this change has
>>> no harm.
>>>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> Hi folks,
>>>
>>> This patch was with "mm: vmscan: skip KSM page in direct reclaim if priority
>>> is low" in the initial submission.  Then Hugh and Andrea pointed out commit
>>> 2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page deduplication
>>> limit") is good enough for limiting the number of shared KSM page to prevent
>>> from softlock when walking ksm page rmap.  This commit does solve the problem.
>>> So, the series was dropped by Andrew from -mm tree.
>>>
>>> However, I thought the second patch (this one) still sounds useful.  So, I did
>>> some test and resubmit it.  The first version was reviewed by Krill Tkhai, so
>>> I keep his Reviewed-by tag since there is no change to the patch except the
>>> commit log.
>>>
>>> So, would you please reconsider this patch?
>>>
>>> v2: Updated the commit log to reflect some test result and latest discussion
>>>
>>>  mm/ksm.c | 29 +++++++++++++++++++++++++----
>>>  1 file changed, 25 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/mm/ksm.c b/mm/ksm.c
>>> index 6c48ad1..f66405c 100644
>>> --- a/mm/ksm.c
>>> +++ b/mm/ksm.c
>>> @@ -668,7 +668,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>>>  }
>>>
>>>  /*
>>> - * get_ksm_page: checks if the page indicated by the stable node
>>> + * __get_ksm_page: checks if the page indicated by the stable node
>>>   * is still its ksm page, despite having held no reference to it.
>>>   * In which case we can trust the content of the page, and it
>>>   * returns the gotten page; but if the page has now been zapped,
>>> @@ -686,7 +686,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>>>   * a page to put something that might look like our key in page->mapping.
>>>   * is on its way to being freed; but it is an anomaly to bear in mind.
>>>   */
>>> -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>>> +static struct page *__get_ksm_page(struct stable_node *stable_node,
>>> +                                bool lock_it, bool async)
>>>  {
>>>       struct page *page;
>>>       void *expected_mapping;
>>> @@ -729,7 +730,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>>>       }
>>>
>>>       if (lock_it) {
>>> -             lock_page(page);
>>> +             if (async) {
>>> +                     if (!trylock_page(page)) {
>>> +                             put_page(page);
>>> +                             return ERR_PTR(-EBUSY);
>>> +                     }
>>> +             } else
>>> +                     lock_page(page);
>>> +
>>>               if (READ_ONCE(page->mapping) != expected_mapping) {
>>>                       unlock_page(page);
>>>                       put_page(page);
>>> @@ -752,6 +760,11 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>>>       return NULL;
>>>  }
>>>
>>> +static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>>> +{
>>> +     return __get_ksm_page(stable_node, lock_it, false);
>>> +}
>>> +
>>>  /*
>>>   * Removing rmap_item from stable or unstable tree.
>>>   * This function will clean the information from the stable/unstable tree.
>>> @@ -1673,7 +1686,11 @@ static struct page *stable_tree_search(struct page *page)
>>>                        * It would be more elegant to return stable_node
>>>                        * than kpage, but that involves more changes.
>>>                        */
>>> -                     tree_page = get_ksm_page(stable_node_dup, true);
>>> +                     tree_page = __get_ksm_page(stable_node_dup, true, true);
>>
>> Hi Yang,
>>
>> The bools are stacking up: now you've got two, and the above invocation is no longer
>> understandable on its own. At this point, we normally shift to flags and/or an
>> enum.
>>
>> Also, I see little value in adding a stub function here, so how about something more
>> like the following approximation (untested, and changes to callers are not shown):
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index 6c48ad13b4c9..8390b7905b44 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>>         free_stable_node(stable_node);
>>  }
>>
>> +typedef enum {
>> +       GET_KSM_PAGE_NORMAL,
>> +       GET_KSM_PAGE_LOCK_PAGE,
>> +       GET_KSM_PAGE_TRYLOCK_PAGE
>> +} get_ksm_page_t;
>> +
>>  /*
>>   * get_ksm_page: checks if the page indicated by the stable node
>>   * is still its ksm page, despite having held no reference to it.
>> @@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>>   * a page to put something that might look like our key in page->mapping.
>>   * is on its way to being freed; but it is an anomaly to bear in mind.
>>   */
>> -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>> +static struct page *get_ksm_page(struct stable_node *stable_node,
>> +                                get_ksm_page_t flags)
>>  {
>>         struct page *page;
>>         void *expected_mapping;
>> @@ -728,8 +735,17 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>>                 goto stale;
>>         }
>>
>> -       if (lock_it) {
>> +       if (flags == GET_KSM_PAGE_TRYLOCK_PAGE) {
>> +               if (!trylock_page(page)) {
>> +                       put_page(page);
>> +                       return ERR_PTR(-EBUSY);
>> +               }
>> +       } else if (flags == GET_KSM_PAGE_LOCK_PAGE) {
>>                 lock_page(page);
>> +       }
>> +
>> +       if (flags == GET_KSM_PAGE_LOCK_PAGE ||
>> +           flags == GET_KSM_PAGE_TRYLOCK_PAGE) {
>>                 if (READ_ONCE(page->mapping) != expected_mapping) {
>>                         unlock_page(page);
>>                         put_page(page);
>>
>>
>> thanks,
>> --
>> John Hubbard
>> NVIDIA
>>
>>> +
>>> +                     if (PTR_ERR(tree_page) == -EBUSY)
>>> +                             return ERR_PTR(-EBUSY);
>>> +
>>>                       if (unlikely(!tree_page))
>>>                               /*
>>>                                * The tree may have been rebalanced,
>>> @@ -2060,6 +2077,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>>>
>>>       /* We first start with searching the page inside the stable tree */
>>>       kpage = stable_tree_search(page);
>>> +
>>> +     if (PTR_ERR(kpage) == -EBUSY)
>>> +             return;
>>> +
>>>       if (kpage == page && rmap_item->head == stable_node) {
>>>               put_page(kpage);
>>>               return;
>>>
>>

