Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB01C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:57:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDD1B214D9
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:57:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDD1B214D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A74C6B0003; Mon, 16 Sep 2019 11:57:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7579F6B0006; Mon, 16 Sep 2019 11:57:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6460B6B0007; Mon, 16 Sep 2019 11:57:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id 4557B6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:57:40 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B342A18DF
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:57:39 +0000 (UTC)
X-FDA: 75941239038.29.earth97_42c857d1b2828
X-HE-Tag: earth97_42c857d1b2828
X-Filterd-Recvd-Size: 4349
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:57:38 +0000 (UTC)
Received: from [172.16.25.5]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1i9tNU-0003lm-Nv; Mon, 16 Sep 2019 18:57:24 +0300
Subject: Re: [PATCH v3] mm/kasan: dump alloc and free stack for page allocator
To: Vlastimil Babka <vbabka@suse.cz>, Walter Wu <walter-zh.wu@mediatek.com>
Cc: Qian Cai <cai@lca.pw>, Alexander Potapenko <glider@google.com>,
 Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
 <matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrey Konovalov <andreyknvl@google.com>, Arnd Bergmann <arnd@arndb.de>,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190911083921.4158-1-walter-zh.wu@mediatek.com>
 <5E358F4B-552C-4542-9655-E01C7B754F14@lca.pw>
 <c4d2518f-4813-c941-6f47-73897f420517@suse.cz>
 <1568297308.19040.5.camel@mtksdccf07>
 <613f9f23-c7f0-871f-fe13-930c35ef3105@suse.cz>
 <79fede05-735b-8477-c273-f34db93fd72b@virtuozzo.com>
 <6d58ce86-b2a4-40af-bf40-c604b457d086@suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4e76e7ce-1d61-524a-622b-663c01d19707@virtuozzo.com>
Date: Mon, 16 Sep 2019 18:57:23 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <6d58ce86-b2a4-40af-bf40-c604b457d086@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/16/19 12:42 PM, Vlastimil Babka wrote:
> On 9/12/19 7:05 PM, Andrey Ryabinin wrote:
>>
>> Or another alternative option (and actually easier one to implement), leave PAGE_OWNER as is (no "select"s in Kconfigs)
>> Make PAGE_OWNER_FREE_STACK like this:
>>
>> +config PAGE_OWNER_FREE_STACK
>> +	def_bool KASAN || DEBUG_PAGEALLOC
>> +	depends on PAGE_OWNER
>> +
>>
>> So, users that want alloc/free stack will have to enable CONFIG_PAGE_OWNER=y and add page_owner=on to boot cmdline.
>>
>>
>> Basically the difference between these alternative is whether we enable page_owner by default or not. But there is always a possibility to disable it.
> 
> OK, how about this?
> 
 ...

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c5d62f1c2851..d9e44671af3f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -710,8 +710,12 @@ static int __init early_debug_pagealloc(char *buf)
>  	if (kstrtobool(buf, &enable))
>  		return -EINVAL;
>  
> -	if (enable)
> +	if (enable) {
>  		static_branch_enable(&_debug_pagealloc_enabled);
> +#ifdef CONFIG_PAGE_OWNER
> +		page_owner_free_stack_disabled = false;

I think this won't work with CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y

> +#endif
> +	}
>  
>  	return 0;
>  }
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index dee931184788..b589bfbc4795 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -24,13 +24,15 @@ struct page_owner {
>  	short last_migrate_reason;
>  	gfp_t gfp_mask;
>  	depot_stack_handle_t handle;
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> +#ifdef CONFIG_PAGE_OWNER_FREE_STACK
>  	depot_stack_handle_t free_handle;
>  #endif
>  };
>  
>  static bool page_owner_disabled = true;
> +bool page_owner_free_stack_disabled = true;
>  DEFINE_STATIC_KEY_FALSE(page_owner_inited);
> +static DEFINE_STATIC_KEY_FALSE(page_owner_free_stack);
>  
>  static depot_stack_handle_t dummy_handle;
>  static depot_stack_handle_t failure_handle;
> @@ -46,6 +48,9 @@ static int __init early_page_owner_param(char *buf)
>  	if (strcmp(buf, "on") == 0)
>  		page_owner_disabled = false;
>  
> +	if (!page_owner_disabled && IS_ENABLED(CONFIG_KASAN))

I'd rather keep all logic in one place, i.e. "if (!page_owner_disabled && (IS_ENABLED(CONFIG_KASAN) || debug_pagealloc_enabled())"
With this no changes in early_debug_pagealloc() required and CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y should also work correctly.

> +		page_owner_free_stack_disabled = false;
> +
>  	return 0;
>  }
>  early_param("page_owner", early_page_owner_param);
 

