Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 435C1C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 22:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F30F0216E3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 22:17:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="u36eN25C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F30F0216E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A95C6B0003; Fri,  5 Jul 2019 18:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 759D58E0003; Fri,  5 Jul 2019 18:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 620758E0001; Fri,  5 Jul 2019 18:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42B826B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 18:17:05 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so11102996iob.14
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 15:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1uUlTl7w5VrIvzH7iUQu975LgNF9PgkSKlhmaEDJNmo=;
        b=LTiRGpO0UGxlv1WuMAMEXCHux6BHF7AKwIhzuWGLssrqdRORg/NsOHup0guWdPAuPk
         Rvdl8RfyRZC58hm4ott7qayKoMa8OX+oSCC/O8iwe4/BHANjoQqDzL4emnkcGcZ+um5G
         oDAzFPPCEcNGQW5U+f05xYsSRvB3x57UD9Bt4ub5o4Ul/fDw38PE84FeIq8ivlvqVm2Y
         hy722EDvyozimzzeMmqSKT1eWotzpSomSzM21qv2jJm9bof0JPKpMR82yGb4lCPAqJvz
         lpInS8tv2/nihxMC/tvVslHbDH5aYrHZJzEsv/8lruaMmhJxhxSONV3krutmqJEZwqhS
         YRiQ==
X-Gm-Message-State: APjAAAUCDYDzbCWSASGcEg3ZWeskJQ+/XXkKqDyR5EYCdI8CMZr0pAti
	uwmeG6L0PmbDfJgTj9oDsO55NXK/xuH2VTk7rOIYKwxM8wv+vGQPgfxAk4bMBKOxnFGqajVUAPU
	QCVVOT9plnIY+Y02qqr3plnGHlRsBPiR3ptMUs7tDY7bibWx9UogdDH3JtL5qXcS03g==
X-Received: by 2002:a5d:8411:: with SMTP id i17mr4681296ion.83.1562365024991;
        Fri, 05 Jul 2019 15:17:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcxcEeIysL9vT7iXJ0CDodOlL028RGqFup+s7JGtDoMrFRlNoZOdzGA4dcCBAjxucvM5dA
X-Received: by 2002:a5d:8411:: with SMTP id i17mr4681217ion.83.1562365024083;
        Fri, 05 Jul 2019 15:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562365024; cv=none;
        d=google.com; s=arc-20160816;
        b=lw9WvaSZrr7P63YQdURqxl9GSxaZaO6Mg7gz5fiil6tbHty6aAeJGiRIhuZZE8tlN/
         2EKHG9OssyJRVKkAJLJi326FxF8yRfVBI/jJA4Z1F72b6ybnmFhMQPMlwaozgbAVxtXI
         biJBg0VCxIYAQ5oYzxlPjl/ym1s684VH9yLFD0QbOsW1qL8PuAxxqZ1KzzewtWlRK9oT
         fSNee9f38BuFB4x4xV8F5JArcfbDzQ2DxQTZvxxVU+iYz3b9bL4VpKTS/xE5LX6/s1Y1
         xH3Gt9BJMql4Dggg4i/Kr/KRl7027TvvAjmXXqn1Wne5051zbf8o2Bl2NMeXMjXylzhD
         dq0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=1uUlTl7w5VrIvzH7iUQu975LgNF9PgkSKlhmaEDJNmo=;
        b=eztBHryhEQOx0eSkUs8sXoWRc6Y4/jBC8yK3PtBOuPEufslsp7tqHGZ2qrFflqaKkc
         sqyaI8TpbF0SN3+YGe1Abug+Ye9Z7Yxo7evmVVd/fZCuBvVID4IMF3Tj8m1h6aNToscF
         k7PWbbC0vP2Y6o8trdCvfWxnuN/gOBtll9kv8K1M788GGspg9cGoeXPVS1mRojvnaUVY
         h0i7ns4UCdLq3OTx9E8ts57FeFcokR4hP91ZmYI3CLzEZqV7onblD2GJvFSDmejM/+es
         54qwLLh6QeD9sK5cH/51I00Bad5I3zhhdeGY4tQXV527T/OAMBB4YKAViPlBI6s+g8qY
         gX9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=u36eN25C;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w8si5522048ioa.65.2019.07.05.15.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 05 Jul 2019 15:17:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=u36eN25C;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=1uUlTl7w5VrIvzH7iUQu975LgNF9PgkSKlhmaEDJNmo=; b=u36eN25CfgtQh6aSiTQI+A0Lny
	uBDLqOSTSvv1bG8SVL2ZL6+4kn/iJu4fbys7eGRpYzY+pmj6kM873+cX4Z7FjwVCpH9qm72aaFqdF
	ghf9nuOxu8TbVJw8ssvUDmsucLa4mUmtW5NJIrHxn6vUUMUhBMf2YoUvOWPOIEEjPw3i38LkdjPKo
	Mi1paNiHZZthLd6ViWYEADXAdvpTjVQ7aOBaJu605RmqmxtH6oRfXY7tnROR+n266pshYxZ/+rKSH
	UJjmhoF25TyNEm2einE/REzfm9zpk/oJBIZ3LirKr4+453T/s/M7q+xtDxwEYQzc7aKk/R9+kDHLq
	HyU/2yGQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjWVj-0005SO-2M; Fri, 05 Jul 2019 22:16:55 +0000
Subject: Re: [linux-next:master 12342/12641] mm/vmscan.c:205:7: error:
 implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean
 'memcg_set_shrinker_bit'?
To: Andrew Morton <akpm@linux-foundation.org>,
 kbuild test robot <lkp@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, kbuild-all@01.org,
 Linux Memory Management List <linux-mm@kvack.org>
References: <201907052120.OGYPhvno%lkp@intel.com>
 <20190705142007.524daa9b5217f12c48e6ab65@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <32e76b4a-d1bd-0e77-85fb-8aaaf7f94017@infradead.org>
Date: Fri, 5 Jul 2019 15:16:52 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190705142007.524daa9b5217f12c48e6ab65@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/5/19 2:20 PM, Andrew Morton wrote:
> On Fri, 5 Jul 2019 21:09:24 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
>> tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next.git master
>> head:   22c45ec32b4a9fa8c48ef4f5bf9b189b307aae12
>> commit: 8236f517d69e2217f5200d7f700e8b18b01c94c8 [12342/12641] mm: shrinker: make shrinker not depend on memcg kmem
>> config: x86_64-randconfig-s2-07051907 (attached as .config)
>> compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
>> reproduce:
>>         git checkout 8236f517d69e2217f5200d7f700e8b18b01c94c8
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64 
>>
>> If you fix the issue, kindly add following tag
>> Reported-by: kbuild test robot <lkp@intel.com>
>>
>> All error/warnings (new ones prefixed by >>):
>>
>>    mm/vmscan.c: In function 'prealloc_memcg_shrinker':
>>>> mm/vmscan.c:205:7: error: implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean 'memcg_set_shrinker_bit'? [-Werror=implicit-function-declaration]
>>       if (memcg_expand_shrinker_maps(id)) {
>>           ^~~~~~~~~~~~~~~~~~~~~~~~~~
>>           memcg_set_shrinker_bit
>>    In file included from include/linux/rbtree.h:22:0,
>>                     from include/linux/mm_types.h:10,
>>                     from include/linux/mmzone.h:21,
>>                     from include/linux/gfp.h:6,
>>                     from include/linux/mm.h:10,
>>                     from mm/vmscan.c:17:
>>    mm/vmscan.c: In function 'shrink_slab_memcg':
>>>> mm/vmscan.c:593:54: error: 'struct mem_cgroup_per_node' has no member named 'shrinker_map'
> 
> This?
> 
> --- a/include/linux/memcontrol.h~mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix
> +++ a/include/linux/memcontrol.h
> @@ -128,7 +128,7 @@ struct mem_cgroup_per_node {
>  
>  	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
>  
> -#ifdef CONFIG_MEMCG_KMEM
> +#ifdef CONFIG_MEMCG
>  	struct memcg_shrinker_map __rcu	*shrinker_map;
>  #endif
>  	struct rb_node		tree_node;	/* RB tree node */
> @@ -1272,6 +1272,7 @@ static inline bool mem_cgroup_under_sock
>  
>  struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
>  void memcg_kmem_put_cache(struct kmem_cache *cachep);
> +extern int memcg_expand_shrinker_maps(int new_id);
>  
>  #ifdef CONFIG_MEMCG_KMEM
>  int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
> @@ -1339,8 +1340,6 @@ static inline int memcg_cache_id(struct
>  	return memcg ? memcg->kmemcg_id : -1;
>  }
>  
> -extern int memcg_expand_shrinker_maps(int new_id);
> -
>  extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
>  				   int nid, int shrinker_id);
>  #else
> _
> 

Now I see this:

ld: mm/vmscan.o: in function `prealloc_shrinker':
vmscan.c:(.text+0x3090): undefined reference to `memcg_expand_shrinker_maps'


And for the record, I reported this yesterday on mmotm:
https://lore.kernel.org/lkml/9cbdb785-b51d-9419-6b9a-ec282a4e4fa2@infradead.org/

Reported-by: Randy Dunlap <rdunlap@infradead.org>


thanks,
-- 
~Randy

