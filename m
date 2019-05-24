Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C4BEC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 04:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 724CA2081C
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 04:06:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 724CA2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16DE76B0005; Fri, 24 May 2019 00:06:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11F7A6B0006; Fri, 24 May 2019 00:06:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00CC26B0007; Fri, 24 May 2019 00:06:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE1B46B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 00:06:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r4so5886684pfh.16
        for <linux-mm@kvack.org>; Thu, 23 May 2019 21:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=So6yFBf7hJ4R+6CdQNdGVz3g63/ApEkxQiomH8Cz3rc=;
        b=I4YVg/KuNY/jIsPiw/ccRDKIZS8kJtDQw7CtUCGbOBymnagrllgqhyd4XBoUk+/n6y
         Mi4uyR6mVDmUEBLFFGgB9rSb73305u68L8tJOsDGhX/sB8w1SlLaICK8WxUq4gtUmEbX
         3tqpvlpgYY2n5Je9a8/Vif80B0nNZN16RFMYe9Y8EMem7naX1emVt4PO/M29p5IiOkDC
         ATpGH4e/8PTwbqeI/mItGZZ4zbaMlTF8QdnkrnVEIXPO4pTC6eFowN13Yv5C4UU5bgCW
         wiAlT3bXXKHg8rOzqGLcjijpV9mLanAylMsT4MRbf16OqK2hYZ4sNfBi1u9vrP4GZHNI
         nahw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWa4OKZ4hAkWSUHmAw9BRnL28ZuSbkEuMKhg1BBK751htFkFsSz
	uAClsT7OBkUsE2YYECSGheTyKPW561aKrscgvoHj4FyC2vpEi0HsRvWZWwj92eu7AESM52/s8AA
	4M0RSFDrk4Hec3akw1rDjNPRGAdVYaFe69jsLdv45r594CNHQyNRoiw/ZRLkb+c6ByA==
X-Received: by 2002:a63:27c7:: with SMTP id n190mr42736110pgn.250.1558670811407;
        Thu, 23 May 2019 21:06:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdCb5n71fagNZbChP1qA3wtMI1gz5jQqaL/GoNQ7EhV4bumsPWnbhwFHoyUA+1b7vpZunf
X-Received: by 2002:a63:27c7:: with SMTP id n190mr42736038pgn.250.1558670810313;
        Thu, 23 May 2019 21:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558670810; cv=none;
        d=google.com; s=arc-20160816;
        b=CYQvneG+WWXf/mObK4iYZ0ym6IfzTLNqfgE+7iQ5TSUCu+aZzEmeX08mM/keWKGUeZ
         PmihLeKHvGRuL2U8IF+gFinETBiyM3BhCtdbr9XfC3tww4azK64dfX23Q2csnHLetJgc
         2ifBIMmQJZJMnLsK6xwC4mMcGi8Ns4mbDMWkgRW1Vbj93esVz9zpSlcB/IfROotFhbv0
         CJ6II0qiqj7XAstOXQQkvgpVnaNlEy5GASSfycY8+wiYgi0rZldqAz/KpbF2H2EiGwIz
         MIJa+C3+uQUdW3OyY/Z1dl1+xWIh6Jt/YoeVtYz+naOtuiMFAnoJqLVwHg3wmNHeqIBc
         KXyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=So6yFBf7hJ4R+6CdQNdGVz3g63/ApEkxQiomH8Cz3rc=;
        b=Qdy3jwWIPOR80CS8WPHHTr+lu7Z7gteucCn6XSMRRuaGRjUEIlSpv4w7diTyz1WNb6
         OMLgEJ2iYTFIai/+OMrNg8p4wa9EQXIAr+LdVNL9NJQkQw/BdoA1eAjMI2adjVHM91CA
         QAe+e4oPHHt8OVp+vIj/jc8cXcnxNaj0OweiAUQFHzAKU0n3h2MprCFYcdshabsDOr/3
         HdndWi4zjpkZreAS6vvOarTwnabXdt180mdnhQeQ7p2OqlsE9Cy0VGvmIITmhvh89Bax
         P+UANj5sK5eUhYqJFgTKGZv0qs+IonB2Q70bmc/rkYNkjUi4v3XhEAYr+19N0BKTI8xQ
         BJlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id l7si2400497plt.244.2019.05.23.21.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 21:06:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TSXA6aZ_1558670807;
Received: from 30.17.232.208(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TSXA6aZ_1558670807)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 24 May 2019 12:06:47 +0800
Subject: Re: [PATCH] mm, swap: use rbtree for swap_extent
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>,
 Hugh Dickins <hughd@google.com>
References: <20190523142404.GA181@aaronlu>
 <20190523120035.efb7c3bf4c91e3aef255621c@linux-foundation.org>
From: Aaron Lu <aaron.lu@linux.alibaba.com>
Message-ID: <357d963e-2657-4926-bab0-a87096a82230@linux.alibaba.com>
Date: Fri, 24 May 2019 12:06:47 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190523120035.efb7c3bf4c91e3aef255621c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/5/24 3:00, Andrew Morton wrote:
...

> On Thu, 23 May 2019 22:24:15 +0800 Aaron Lu <aaron.lu@linux.alibaba.com> wrote:
>> ...
>>
>> +static struct swap_extent *
>> +offset_to_swap_extent(struct swap_info_struct *sis, unsigned long offset)
>> +{
>> +	struct swap_extent *se;
>> +	struct rb_node *rb;
>> +
>> +	rb = sis->swap_extent_root.rb_node;
>> +	while (rb) {
>> +		se = rb_entry(rb, struct swap_extent, rb_node);
>> +		if (offset < se->start_page)
>> +			rb = rb->rb_left;
>> +		else if (offset >= se->start_page + se->nr_pages)
>> +			rb = rb->rb_right;
>> +		else
>> +			return se;
>> +	}
>> +	/* It *must* be present */
>> +	BUG_ON(1);
> 
> I'm surprised this doesn't generate a warning about the function

Ah right, I'm also surprised after you mentioned.
This BUG_ON(1) here is meant to serve the same purpose as the
original code in map_swap_entry():

static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
{
	...

	offset = swp_offset(entry);
	start_se = sis->curr_swap_extent;
	se = start_se;

	for ( ; ; ) {
		if (se->start_page <= offset &&
				offset < (se->start_page + se->nr_pages)) {
			return se->start_block + (offset - se->start_page);
		}
		se = list_next_entry(se, list);
		sis->curr_swap_extent = se;
		BUG_ON(se == start_se);		/* It *must* be present */
	}
}

I just copied the pattern and changed the condition to 1 without
much thought.

> failing to return a value.  I guess the compiler figured out that
> BUG_ON(non-zero-constant) is equivalent to BUG(), which is noreturn.
> 
> Let's do this?

Yes, it doesn't make much sense to use BUG_ON when the condition
is 1...Thanks for the cleanup.

> 
> --- a/mm/swapfile.c~mm-swap-use-rbtree-for-swap_extent-fix
> +++ a/mm/swapfile.c
> @@ -218,7 +218,7 @@ offset_to_swap_extent(struct swap_info_s
>  			return se;
>  	}
>  	/* It *must* be present */
> -	BUG_ON(1);
> +	BUG();
>  }
>  

