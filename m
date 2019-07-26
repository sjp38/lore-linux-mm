Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C1DBC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:16:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4525216F4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 11:16:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="nXCB8f2m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4525216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 711586B0005; Fri, 26 Jul 2019 07:16:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69C7C6B0006; Fri, 26 Jul 2019 07:16:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5655D8E0002; Fri, 26 Jul 2019 07:16:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEACE6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 07:16:25 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id z14so5433587lfq.21
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:16:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ecwFC3fgXFrOWyG9ohvQQEeG7yd0wdelvg82Hk6eDDo=;
        b=q4DjZHEqIC4U11bm45VvhjIY7HHQ6NvdbM8DqTZIfaxiS8LQM7M0dFTi3R7p5s6ktY
         oKRBuAZuLBXd+WK4H9M+ap9+3GCrg8KRHS6vwegel31KLY6DfXmFCkC9g6cJfyKxu40K
         kijNShCsfiCR9XXVwydY08VXbFhpjRmjyrgJnxXQ0g+ZiRJ/YP/Shm0ips5/83Cv6jW8
         yT3bqe1BfHX24StXLWy4hK+OEZmBPkJ0Q2J8EC9Bl7DqUXXXZgLXiClFsIht2AOoIUqa
         Ma0f2cVwN5eQ1UwJGuj69H6JnUcBdz3a4LQCO7nfMln7zep9JeqGYO4GLYs/Ve/RhCJI
         sbRA==
X-Gm-Message-State: APjAAAUnm35z1be+l8OpxxxzeYOMudSRrp6kbF71kuRhJzeImdGjV08x
	EZtKWXrAQlI00KKEhH27/L4qI5EBRkdxrOPElBwdxHI9MtEfrioT6E/38F1zs6XPJ3eF39cH0TY
	OenwL4ca8Y7rKWK2LO2xAY/QFz/ULXG0APgWKPvsm0BlrwhC1OTxleNnA9lJzf5mmBg==
X-Received: by 2002:a19:7006:: with SMTP id h6mr43454783lfc.5.1564139784984;
        Fri, 26 Jul 2019 04:16:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNWPwVk0m/TyZv0SVlIotMiL+qJWITArBBE/UFhHDDJE1z1z6krfZT5FBKLcIEnM8qSMv6
X-Received: by 2002:a19:7006:: with SMTP id h6mr43454746lfc.5.1564139784042;
        Fri, 26 Jul 2019 04:16:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564139784; cv=none;
        d=google.com; s=arc-20160816;
        b=Zjdx7jcldHUivHiKgcIIJb+OCNarArTU2ZjBbCA6dvgpmS85lighDzSJXVtvh9elTA
         1yWayRQ6adk4in0spHSh/am6Zd8J84A/q3CaFDtPFoPhbP+PifTSHnSYAtxWj/oudT1C
         Oij742Cu4AiGhHFzWE/vYUGnPtnYbzK9db0hg5ULJB6wYhqRle4jvOTUb0hiVp7ljYzi
         tOp2X1oBvQ2TW6MDXjAUfjL1S7rl1GlrdPHu/8iVxMfs9PT1m6w99gvKltV4Bpm0h+Vl
         LBuuK/I7DwVschbJwiyrAUK8Xzf4dNximsn9icX+41n8K2Sbwc90NnSxEDkd2y5Z0hak
         h6YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=ecwFC3fgXFrOWyG9ohvQQEeG7yd0wdelvg82Hk6eDDo=;
        b=ZHJrCH0Nx1zgpWEzr8RZGHdv1l4hpLdnzJmddXaGrAtCxWIQqvA7xqQq/vwqLmJbyc
         u12YWBEHTioeUk9OKwHMy6EbBCcrNFw6VYfIDW4x7JlTpLq9cOyEHGF2HpA1QZMC8TtJ
         6K6GHcsNwDkDoZLuSG5wkgTxifEd64G+3zZkIsncJZRQuhSBiFTF2+1z/OF5/agSvgu4
         6msIwkNDMSSbfF9IrUc4uPBwzoD0vNYmC6TuTqIOEPzLwdfGDqkhrZdxYj7RV4nfCEeT
         2XDpRUDJmdzNbTzsJqJUv9YVrqJ3u13n1jhVmLg2oQvdpgBVVgtpVkODCGORiN2CYLP9
         4zsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nXCB8f2m;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id e16si45142076ljh.141.2019.07.26.04.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 04:16:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nXCB8f2m;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 3998E2E0B10;
	Fri, 26 Jul 2019 14:16:23 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id jtgl0cVK3U-GLNGEp2n;
	Fri, 26 Jul 2019 14:16:23 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564139783; bh=ecwFC3fgXFrOWyG9ohvQQEeG7yd0wdelvg82Hk6eDDo=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=nXCB8f2mA72AK22inribUdeAvInMoGaGhDsBuAZjGmmM4hrqaBbywNFVKpV41OPyG
	 AYUfWwnLk39G30OJBeO5YcN/PQ5yq981pXG1Q1GJv8ETRhInUCv1DI3FPrdeE0HseW
	 F/QCK72cDUk+Fr/LcXRIYG2ccu4U0Lxp4GdrZobE=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id PWLMWYfpFd-GK6SXEm5;
	Fri, 26 Jul 2019 14:16:21 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
 vdavydov.dev@gmail.com, Brendan Gregg <bgregg@netflix.com>,
 kernel-team@android.com, Alexey Dobriyan <adobriyan@gmail.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton
 <akpm@linux-foundation.org>, carmenjackson@google.com,
 Christian Hansen <chansen3@cisco.com>,
 Colin Ian King <colin.king@canonical.com>, dancol@google.com,
 David Howells <dhowells@redhat.com>, fmayer@google.com, joaodias@google.com,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Kirill Tkhai <ktkhai@virtuozzo.com>, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
 namhyung@google.com, sspatil@google.com
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <20190723061358.GD128252@google.com> <20190723142049.GC104199@google.com>
 <20190724042842.GA39273@google.com> <20190724141052.GB9945@google.com>
 <c116f836-5a72-c6e6-498f-a904497ef557@yandex-team.ru>
 <20190726000654.GB66718@google.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <9cba9acb-9451-a53e-278d-92f7b66ae20b@yandex-team.ru>
Date: Fri, 26 Jul 2019 14:16:20 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726000654.GB66718@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.07.2019 3:06, Joel Fernandes wrote:
> On Thu, Jul 25, 2019 at 11:15:53AM +0300, Konstantin Khlebnikov wrote:
> [snip]
>>>>> Thanks for bringing up the swapping corner case..  Perhaps we can improve
>>>>> the heap profiler to detect this by looking at bits 0-4 in pagemap. While it
>>>>
>>>> Yeb, that could work but it could add overhead again what you want to remove?
>>>> Even, userspace should keep metadata to identify that page was already swapped
>>>> in last period or newly swapped in new period.
>>>
>>> Yep.
>> Between samples page could be read from swap and swapped out back multiple times.
>> For tracking this swap ptes could be marked with idle bit too.
>> I believe it's not so hard to find free bit for this.
>>
>> Refault\swapout will automatically clear this bit in pte even if
>> page goes nowhere stays if swap-cache.
> 
> Could you clarify more about your idea? Do you mean swapout will clear the new
> idle swap-pte bit if the page was accessed just before the swapout? >
> Instead, I thought of using is_swap_pte() to detect if the PTE belong to a
> page that was swapped. And if so, then assume the page was idle. Sure we
> would miss data that the page was accessed before the swap out in the
> sampling window, however if the page was swapped out, then it is likely idle
> anyway.


I mean page might be in swap when you mark pages idle and
then been accessed and swapped back before second pass.

I propose marking swap pte with idle bit which will be automatically
cleared by following swapin/swapout pair:

page alloc -> install page pte
page swapout -> install swap entry in pte
mark vm idle -> set swap-idle bit in swap pte
access/swapin -> install page pte (clear page idle if set)
page swapout -> install swap entry in pte (without swap idle bit)
scan vm idle -> see swap entry without idle bit -> page has been accessed since marking idle

One bit in pte is enough for tracking. This does not needs any propagation for
idle bits between page and swap, or marking pages as idle in swap cache.

> 
> My current patch was just reporting swapped out pages as non-idle (idle bit
> not set) which is wrong as Minchan pointed. So I added below patch on top of
> this patch (still testing..) :
> 
> thanks,
> 
>   - Joel
> ---8<-----------------------
> 
> diff --git a/mm/page_idle.c b/mm/page_idle.c
> index 3667ed9cc904..46c2dd18cca8 100644
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -271,10 +271,14 @@ struct page_idle_proc_priv {
>   	struct list_head *idle_page_list;
>   };
>   
> +/*
> + * Add a page to the idle page list.
> + * page can also be NULL if pte was not present or swapped.
> + */
>   static void add_page_idle_list(struct page *page,
>   			       unsigned long addr, struct mm_walk *walk)
>   {
> -	struct page *page_get;
> +	struct page *page_get = NULL;
>   	struct page_node *pn;
>   	int bit;
>   	unsigned long frames;
> @@ -290,9 +294,11 @@ static void add_page_idle_list(struct page *page,
>   			return;
>   	}
>   
> -	page_get = page_idle_get_page(page);
> -	if (!page_get)
> -		return;
> +	if (page) {
> +		page_get = page_idle_get_page(page);
> +		if (!page_get)
> +			return;
> +	}
>   
>   	pn = &(priv->page_nodes[priv->cur_page_node++]);
>   	pn->page = page_get;
> @@ -326,6 +332,15 @@ static int pte_page_idle_proc_range(pmd_t *pmd, unsigned long addr,
>   
>   	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>   	for (; addr != end; pte++, addr += PAGE_SIZE) {
> +		/*
> +		 * We add swapped pages to the idle_page_list so that we can
> +		 * reported to userspace that they are idle.
> +		 */
> +		if (is_swap_pte(*pte)) {
> +			add_page_idle_list(NULL, addr, walk);
> +			continue;
> +		}
> +
>   		if (!pte_present(*pte))
>   			continue;
>   
> @@ -413,10 +428,12 @@ ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
>   			goto remove_page;
>   
>   		if (write) {
> -			page_idle_clear_pte_refs(page);
> -			set_page_idle(page);
> +			if (page) {
> +				page_idle_clear_pte_refs(page);
> +				set_page_idle(page);
> +			}
>   		} else {
> -			if (page_really_idle(page)) {
> +			if (!page || page_really_idle(page)) {
>   				off = ((cur->addr) >> PAGE_SHIFT) - start_frame;
>   				bit = off % BITMAP_CHUNK_BITS;
>   				index = off / BITMAP_CHUNK_BITS;
> 

