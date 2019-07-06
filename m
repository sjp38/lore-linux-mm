Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E0A7C5B57D
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 02:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E0EE21670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 02:14:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V7IG4Bu3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E0EE21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A02208E0003; Fri,  5 Jul 2019 22:14:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98BD38E0001; Fri,  5 Jul 2019 22:14:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82D478E0003; Fri,  5 Jul 2019 22:14:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 340608E0001
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 22:14:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v7so4594709wrt.6
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 19:14:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ENZPF6R6wk6HWGZ7gxgU5owHKCaaKurqCqCqOxT+OvQ=;
        b=kprLy4yAivMpCtHFQ4r3YyIJB0Zr+FOvJhre889LH24uamziNUyW9MwVh2jlnvnKEA
         d2vopqot1FO/HritM36UPQayOBhQfMPy6woUkfPe8Z6nqgwfuzCch2Ey42e6OdrA+nm6
         oq+t3n0dI3IQQK7Oor7t2x70SAjEAT6f6zhFadzZa5oHwuJPZVqwlPmKPb72JP0jPDAa
         TYSddSfZz7wKc78kv3/W9fj/JCrkVKJXG+UbS+r14UpgJL/Wgs/d715flwDkqUx/1UeW
         nJPRvYUWftL3FGpJTCK/tqIyT707u4RsX7BW88JfGieNdDiuRWYb/WuasjWX417cUq84
         EWvw==
X-Gm-Message-State: APjAAAXBg8gBCUfVGoL7SIX3hSOMKSdABEpJB64gUkD1IMpFBzom+dpT
	lX3MXvKp0XLWx6mNJWuIoEPP8Te7gKc+vWYcpv3/P/xtR9bBOGWQPuhCxdxVFAcv4Fos6sklD8u
	3metUtpfkIT7PuktqKDE+NiRXjNuuKvbwf4xAszGyTMOHe2awvv3fiT2Stu2IhfV5Zw==
X-Received: by 2002:a1c:c2d5:: with SMTP id s204mr5409633wmf.174.1562379288752;
        Fri, 05 Jul 2019 19:14:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydXM8vRbzfUxtq9maCHHBRuIckeHLsziRoZaCrI+BgW68p8vHQ5DSZSZf1ZvTvl792a0sh
X-Received: by 2002:a1c:c2d5:: with SMTP id s204mr5409563wmf.174.1562379287731;
        Fri, 05 Jul 2019 19:14:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562379287; cv=none;
        d=google.com; s=arc-20160816;
        b=bEyyg47dDinuVc7VKfd3DOGvUAn2PqZqHY0jsO9RBpRs9HfDAvyGUwK9amWAu8EwqH
         J5KYxcwpBm/a5XqXbS7vwW323vjn2OH6SmI935Hs7prfI+p8seU/UjfGcyel0HrIHwG+
         081nmTnvW6wY+MnEX8P4iEfsgm9tdAWw6X9sOKSzsmh1uOCsbAHQeRL3xHd+Hx//yo0M
         hOIbWUfzJAo8lvlKKu0RZg6sCgsxk3KTIpLend1ylPydCxY1X+tm6qOg4RGOpAWcMzpI
         r2iZ5TUzYw1p/mEP9jcEarb1cDtmD6KG0voQuEXgfWXj8MHS5UDcZ9ua6n9JeaZ8AMsK
         2ylw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=ENZPF6R6wk6HWGZ7gxgU5owHKCaaKurqCqCqOxT+OvQ=;
        b=lyM/prQm//isCPBVNSVZbeOTgEH0G/YUFyh4e1qd9KOQ+n3ExrVIINHuX/RHyunVkz
         zTgYs4p0KIdz+JXdV7jMJC0aoOr/57wc4BB/Hg0IPbsHVG3fTJ0utaa+eijybF4qsXaR
         Oc/WKHRcvcndmRe5aYtjeWnRQJRUygFJhf0Fgb9QKVQnOaXqgKXoFV8qKxn9ooXStKDB
         yxNsNR+kLSpyzUXFm8R9ZVQqJDMHVrbPJ5vNbVt5fB7RgFkXOzOidu6sLZEaO4gCJgLZ
         QHagF6rrYfYWJWZyvQcx0hp9HpXk1HA6+VjROCU3KL42LjfZeTiNE7QhRoPt49nuTtS+
         L9Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V7IG4Bu3;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q83si4584825wme.93.2019.07.05.19.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 05 Jul 2019 19:14:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V7IG4Bu3;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:References:Cc:To:From:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ENZPF6R6wk6HWGZ7gxgU5owHKCaaKurqCqCqOxT+OvQ=; b=V7IG4Bu3FwLnY6cMt5fRTGpvHk
	82YdhsQLjXaHjBo5gE6u/YIIOua3lQw7owBd7i/ip4LVcu8FcdohuapffAHB4q3RgiduAeXruxrNX
	ul5T79cRoLbBgbyF/qmje4Lj0d0pSqyvD9vL4FnC/6jGDDbR+CCXWlI3aV+zTdEtQwApQW4Htokcp
	g5cpl7Kyz9LQawCXIYjK9u9/d+ypDWkEvpX5Y5z013e6h7I5N1QjtBHbONBENKxYIdid3pfQ5JNS5
	lZvmHJbZBrNLX0gViQ0u4bPz9S8Gaol++qURw2i9RVBxOMknxN6b9zbU1fmAEFqaxA4sPf7wZ1La/
	XstWQ6Iw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjaDu-0006PB-Py; Sat, 06 Jul 2019 02:14:46 +0000
Subject: Re: [linux-next:master 12342/12641] mm/vmscan.c:205:7: error:
 implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean
 'memcg_set_shrinker_bit'?
From: Randy Dunlap <rdunlap@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>,
 kbuild test robot <lkp@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, kbuild-all@01.org,
 Linux Memory Management List <linux-mm@kvack.org>
References: <201907052120.OGYPhvno%lkp@intel.com>
 <20190705142007.524daa9b5217f12c48e6ab65@linux-foundation.org>
 <32e76b4a-d1bd-0e77-85fb-8aaaf7f94017@infradead.org>
Message-ID: <517a3638-b7bc-517c-326b-cde81ef9bc9b@infradead.org>
Date: Fri, 5 Jul 2019 19:14:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <32e76b4a-d1bd-0e77-85fb-8aaaf7f94017@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/5/19 3:16 PM, Randy Dunlap wrote:
> On 7/5/19 2:20 PM, Andrew Morton wrote:
>> On Fri, 5 Jul 2019 21:09:24 +0800 kbuild test robot <lkp@intel.com> wrote:
>>
>>> tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next.git master
>>> head:   22c45ec32b4a9fa8c48ef4f5bf9b189b307aae12
>>> commit: 8236f517d69e2217f5200d7f700e8b18b01c94c8 [12342/12641] mm: shrinker: make shrinker not depend on memcg kmem
>>> config: x86_64-randconfig-s2-07051907 (attached as .config)
>>> compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
>>> reproduce:
>>>         git checkout 8236f517d69e2217f5200d7f700e8b18b01c94c8
>>>         # save the attached .config to linux build tree
>>>         make ARCH=x86_64 
>>>
>>> If you fix the issue, kindly add following tag
>>> Reported-by: kbuild test robot <lkp@intel.com>
>>>
>>> All error/warnings (new ones prefixed by >>):
>>>
>>>    mm/vmscan.c: In function 'prealloc_memcg_shrinker':
>>>>> mm/vmscan.c:205:7: error: implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean 'memcg_set_shrinker_bit'? [-Werror=implicit-function-declaration]
>>>       if (memcg_expand_shrinker_maps(id)) {
>>>           ^~~~~~~~~~~~~~~~~~~~~~~~~~
>>>           memcg_set_shrinker_bit
>>>    In file included from include/linux/rbtree.h:22:0,
>>>                     from include/linux/mm_types.h:10,
>>>                     from include/linux/mmzone.h:21,
>>>                     from include/linux/gfp.h:6,
>>>                     from include/linux/mm.h:10,
>>>                     from mm/vmscan.c:17:
>>>    mm/vmscan.c: In function 'shrink_slab_memcg':
>>>>> mm/vmscan.c:593:54: error: 'struct mem_cgroup_per_node' has no member named 'shrinker_map'
>>
>> This?
>>
>> --- a/include/linux/memcontrol.h~mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix
>> +++ a/include/linux/memcontrol.h
>> @@ -128,7 +128,7 @@ struct mem_cgroup_per_node {
>>  
>>  	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
>>  
>> -#ifdef CONFIG_MEMCG_KMEM
>> +#ifdef CONFIG_MEMCG
>>  	struct memcg_shrinker_map __rcu	*shrinker_map;
>>  #endif
>>  	struct rb_node		tree_node;	/* RB tree node */
>> @@ -1272,6 +1272,7 @@ static inline bool mem_cgroup_under_sock
>>  
>>  struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
>>  void memcg_kmem_put_cache(struct kmem_cache *cachep);
>> +extern int memcg_expand_shrinker_maps(int new_id);
>>  
>>  #ifdef CONFIG_MEMCG_KMEM
>>  int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
>> @@ -1339,8 +1340,6 @@ static inline int memcg_cache_id(struct
>>  	return memcg ? memcg->kmemcg_id : -1;
>>  }
>>  
>> -extern int memcg_expand_shrinker_maps(int new_id);
>> -
>>  extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
>>  				   int nid, int shrinker_id);
>>  #else
>> _
>>
> 
> Now I see this:
> 
> ld: mm/vmscan.o: in function `prealloc_shrinker':
> vmscan.c:(.text+0x3090): undefined reference to `memcg_expand_shrinker_maps'
> 
> 
> And for the record, I reported this yesterday on mmotm:
> https://lore.kernel.org/lkml/9cbdb785-b51d-9419-6b9a-ec282a4e4fa2@infradead.org/
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> 
> 
> thanks,

I did a similar change as Andrew's, but to mm/memcontrol.c, but that just
causes duplicate function definition errors from <linux/memcontrol.h> because
it has stubs for some functions that are now being built.


-- 
~Randy

