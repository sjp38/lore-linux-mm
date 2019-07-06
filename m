Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F41D0C5B57D
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 02:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8452521670
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 02:13:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rgS5SCnF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8452521670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E70C96B0003; Fri,  5 Jul 2019 22:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E224A8E0003; Fri,  5 Jul 2019 22:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0FB68E0001; Fri,  5 Jul 2019 22:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86DDF6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 22:13:28 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id p16so3187021wmi.8
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 19:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tpxiSiGL1fDxbzXWhV8PKgakAx+WdwtT+P/1NbBtPsQ=;
        b=GrCtKW9Ki6QJUupeuFTzCCAVcwJw2xfZqOnYOSyFnWkV/xlNXSbV3Kn7npP6m1J9oD
         D3Xi99zclj6JbXKZuA3mS0CFsMdkVp7ILGjj4hs9zRO0Jm4i+OXNHQ63t1ZZ1SQ751L9
         6IR0Pop2n5DypOm4pfQssSciEshrbOkLOIo/unYYvbJ1aN9RwICairSn0JG8HUtwmvOy
         C6YScV7iP3IJHdoVLZEXQ1hv1o+6bSOXi9gMbkqtEQNRwny5qSKwa/1OO3K9gGpstaJ+
         I1ha1eqS6QdwE4v0VRZeqVMrJwBZuA5LXF9jgYYQTW/qiGR5BDSclM4zlnP8KpiVx1//
         VFkQ==
X-Gm-Message-State: APjAAAXaBuT/ppeAb8VLF82wtDmOL4pHOuGmM/Y6yWOyATHwe99tVxvY
	ktAg635T50zjKDniAPz8F60TwsXzrKjeupvoXiOn9aVhk0Q/s3ZJMMdso2+8SfxOR/TPQsjJR1a
	sCxN307NILURSU6QoSyurmlBa9QYR/uBI0iinq9SKLpqNC8aXBcqTNZm2sOwE4E71Dw==
X-Received: by 2002:adf:8183:: with SMTP id 3mr6064328wra.181.1562379207918;
        Fri, 05 Jul 2019 19:13:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPo2eYp7bZilRJ3DfdIjPK8hrxGNUFm3gw1dKHdTRYnaq0kYtvlHTI04IcaHHr5eae6Fti
X-Received: by 2002:adf:8183:: with SMTP id 3mr6064229wra.181.1562379206774;
        Fri, 05 Jul 2019 19:13:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562379206; cv=none;
        d=google.com; s=arc-20160816;
        b=qoQZvJ25rd/795+y/98XRnc7WhQAw+cF/JZlFZRiugfyYdzMSmaS4Q+Owbz04G7jO1
         pf9Y73GSLyhlXbtV9mbTsKpZqyQJgl0RZOvo96GmFQcN2JJo0OpPimIv8x8T/cuMwwoe
         CO8n8hs3/FmvBrXQp+HJzqHQ4zF8IIy/+SsVy/lAq+0cU15OZR7pj09Khmf1cpR6l5ET
         0APPlXdYJN3UUNq2wdXiWkXfOuf+Cqm2tOhGELVKkQwT97rj2XenMKhCD9czXhlFJGoI
         DJAXsaxUwrVtFYPXdhz92BBZaiUdF8LPBDo4GMVImjATr2o9Z77Qwhzzs4nZqkFfYWlG
         LDew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=tpxiSiGL1fDxbzXWhV8PKgakAx+WdwtT+P/1NbBtPsQ=;
        b=O95aiSxEIzPYxePOjWK25mxNGevJP5PQTaj66M5cWYmhgtxvHGntpXK1XWznKq18Dm
         nxWpLCwePCkVLLiuG64l3UWW1XRBTg6/JkRmLUcocg+JGRdAZCV6ghOHpYoi+obu8eJy
         CQyy0A/F7jne3gbM1X8wXeQHn4Fwmo2JNsVMrgqr+DxRwxz8f52W37grcx/V3vCAjjE1
         B8W4P1TbbHO+CQgx4B9o7qJGM1PBnG6Apv2fRh5kVlr0y0EYLTbBaDwZshg7+JvwAu30
         aNgGVxpz1NqKuv4ZCPMeqK8JgSwt9axAsFrn+FNTxPBSS2BJme6tQ/LP6dyWW16pkcJZ
         gRvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=rgS5SCnF;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v76si6788889wmf.124.2019.07.05.19.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 05 Jul 2019 19:13:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=rgS5SCnF;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tpxiSiGL1fDxbzXWhV8PKgakAx+WdwtT+P/1NbBtPsQ=; b=rgS5SCnFQUPHyCDLpWGa3JZPui
	XlnatcNxXHLAQ77OLqWzesvDr3WiR4XXJ8pzHPSAtZIsdjcZngEcIBOcsyml3x4UtUzWSE5jGbxr5
	0D5iklll02+Ro4H8DtKpUztIVFpS5WlzyEIEsC78dBU6a/KK59w4GK3tuypQENefOLkWxMA9E7cwG
	I6xQEs9Zu2NiXs8LYNXU6oxvHQOxWLe79Ow9LSD/eMYXcj1z5t9V4QU5ZD9x0yLvAX7FgHyOO26dj
	gcLNrduMUwwPc7PL3fAfry/YstuMyf5rHOl/yxIIxYTzFtcH/QDI6BBjewwGlIKFk6MS2pM1qSdcT
	JCxLmDlA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjaCQ-0006Op-KQ; Sat, 06 Jul 2019 02:13:14 +0000
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
Message-ID: <af597469-6634-8f55-a1ce-1c7faafa8157@infradead.org>
Date: Fri, 5 Jul 2019 19:13:12 -0700
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

I suggest that someone drop these patches until they are better.

E.g., in include/linux/memcontrol.h:

65: #ifdef CONFIG_MEMCG
131: #ifdef CONFIG_MEMCG
133: #endif
802: #else /* CONFIG_MEMCG */
1138: #endif /* CONFIG_MEMCG */

so lines 131 & 133 are redundant.

-- 
~Randy

