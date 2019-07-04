Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09282C0650E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 04:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CFDB21882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 04:20:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CFDB21882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E45996B0003; Thu,  4 Jul 2019 00:20:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF61A8E0003; Thu,  4 Jul 2019 00:20:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE4018E0001; Thu,  4 Jul 2019 00:20:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8EF06B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 00:20:58 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o4so5883372qko.8
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 21:20:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VjvgxdNhPmADUJRmfeTfTeGfFIsk8W3vAlS9rGS+5AM=;
        b=gWJlnvzR9ui7DqBzpAQg7H1Pu7c9N4TyEsTen4cD7FWTkGOH6MPlHBKPtxolXdMCUS
         vI9sHDPjEf4JZQQLJaKnr4d2cMa2xAovdb+T6lvE43vs2p/MM7fP0XEfBYjygUYpg2Ow
         swwR46kVRirhuvrFZoeV3fzeNam9NVLzGHABYWseiITk7xlI3W1EbZM7Rq7R3blyOrpz
         QIcorpPYPntQ+fznX6apoEv2657UIkdnGxWpiu3SzDK5QzFUJjzMUiIsVMb0zjipEaF4
         abt4oZi6HhWg2uUAWFHl1z6tXz8SAiXiG9qIJ5w4k1seSGMUNJPaWaeH/JZGERmi1/N9
         wZeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWVqiTfzodJhE5i+zW54/LdBo9mcnUt83KbnZZ0BdOYRIx44aGG
	M8GK4cgM6Fv7KvRVwSNzRQNjPpJlIc+DEX+cS2C2yJb2FB8tZ6CNdXKf6hAMjR8wyP1q2IBpqC0
	5UK4UC8dqijQUek3H0pNFELC19nPKjcCkc+Imlayx7EbcF4aPgNYg9DlToGa1BBg=
X-Received: by 2002:ac8:2646:: with SMTP id v6mr33035000qtv.205.1562214058371;
        Wed, 03 Jul 2019 21:20:58 -0700 (PDT)
X-Received: by 2002:ac8:2646:: with SMTP id v6mr33034967qtv.205.1562214057405;
        Wed, 03 Jul 2019 21:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562214057; cv=none;
        d=google.com; s=arc-20160816;
        b=UKGO2eNeGVAz1Oav4u5CmD0gJXG3xkVH387O6bkqp336R4KLo0eRN73Rhvo0c9ERij
         1IAv3eyDcb8+Rjv/09jo6lx5xDNIt/8XS+A9yCouvfxoe/ETU+c32Cb87h2Jd1qrG7ZK
         mkvKihGBvceCe2BgTnwTy0v2HEI2PJjkaNFqwWFXe4NyODljiDvFW/svbb25nu+FzHTe
         gvCyFReXCsQ81n5iU/uYcfLuZB+JXACoY39obRFMJjn0vOrYSngWpUaa/djovAAobebS
         ZkhJu1ZR6g8vZ0FzPnzXfYHWf29GwAyzTvapOJvlS1YyLcvUilJLvAdGlJFu9t0t2LJv
         Xeag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VjvgxdNhPmADUJRmfeTfTeGfFIsk8W3vAlS9rGS+5AM=;
        b=yikWsl8/lX25U+9Ajrzwq0dR2Ese8TEDDUJAVg1FJvQjolCNVeUqNFYvLSh8m2FdKn
         fulLJhMDMJvxKcrOtBqeuekH+9UUQ3ILqORy7QJyfZOIzwe5JVjNHbzwNG0NUjq0yYRU
         XO+OxljNT5+q3EJmNBcTRcPKKXhqum8hwM+Z0nkT9XgHIVZG1mJyp82FjUoYFUH118Li
         Az1OHL6da1dPYIKLkWrZz2wL7HS75CXUc6sYSrZCkRWY+RAuFwkCh9ZGXgKFJabkaUeB
         Lhsj1z05bJUXB9ebrwpJvvGoQ415zihM3MDHP5W6AuuInW0tFbVhe8E0dZm5bisq6t7/
         KoIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor6123978qtc.13.2019.07.03.21.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 21:20:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzMRVfvHpkLgMAQyujeyq9jczN9KYoJEegLcswXWtcHBnEzNE2ycM0Njt2NLU3cr/g3HsJOfA==
X-Received: by 2002:aed:3ed5:: with SMTP id o21mr33852578qtf.369.1562214057070;
        Wed, 03 Jul 2019 21:20:57 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:480::d156])
        by smtp.gmail.com with ESMTPSA id i1sm1911451qtb.7.2019.07.03.21.20.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 21:20:55 -0700 (PDT)
Date: Thu, 4 Jul 2019 00:20:53 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] percpu: Make pcpu_setup_first_chunk() void function
Message-ID: <20190704042053.GA29349@dennisz-mbp.dhcp.thefacebook.com>
References: <20190703082552.69951-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190703082552.69951-1-wangkefeng.wang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 04:25:52PM +0800, Kefeng Wang wrote:
> pcpu_setup_first_chunk() will panic or BUG_ON if the are some
> error and doesn't return any error, hence it can be defined to
> return void.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---
>  arch/ia64/mm/contig.c    |  5 +----
>  arch/ia64/mm/discontig.c |  5 +----
>  include/linux/percpu.h   |  2 +-
>  mm/percpu.c              | 17 ++++++-----------
>  4 files changed, 9 insertions(+), 20 deletions(-)
> 
> diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
> index d29fb6b9fa33..db09a693f094 100644
> --- a/arch/ia64/mm/contig.c
> +++ b/arch/ia64/mm/contig.c
> @@ -134,10 +134,7 @@ setup_per_cpu_areas(void)
>  	ai->atom_size		= page_size;
>  	ai->alloc_size		= percpu_page_size;
>  
> -	rc = pcpu_setup_first_chunk(ai, __per_cpu_start + __per_cpu_offset[0]);
> -	if (rc)
> -		panic("failed to setup percpu area (err=%d)", rc);
> -
> +	pcpu_setup_first_chunk(ai, __per_cpu_start + __per_cpu_offset[0]);
>  	pcpu_free_alloc_info(ai);
>  }
>  #else
> diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> index 05490dd073e6..004dee231874 100644
> --- a/arch/ia64/mm/discontig.c
> +++ b/arch/ia64/mm/discontig.c
> @@ -245,10 +245,7 @@ void __init setup_per_cpu_areas(void)
>  		gi->cpu_map		= &cpu_map[unit];
>  	}
>  
> -	rc = pcpu_setup_first_chunk(ai, base);
> -	if (rc)
> -		panic("failed to setup percpu area (err=%d)", rc);
> -
> +	pcpu_setup_first_chunk(ai, base);
>  	pcpu_free_alloc_info(ai);
>  }
>  #endif
> diff --git a/include/linux/percpu.h b/include/linux/percpu.h
> index 9909dc0e273a..5e76af742c80 100644
> --- a/include/linux/percpu.h
> +++ b/include/linux/percpu.h
> @@ -105,7 +105,7 @@ extern struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
>  							     int nr_units);
>  extern void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai);
>  
> -extern int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> +extern void __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  					 void *base_addr);
>  
>  #ifdef config_need_per_cpu_embed_first_chunk
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 9821241fdede..ad32c3d11ca7 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2267,12 +2267,9 @@ static void pcpu_dump_alloc_info(const char *lvl,
>   * share the same vm, but use offset regions in the area allocation map.
>   * the chunk serving the dynamic region is circulated in the chunk slots
>   * and available for dynamic allocation like any other chunk.
> - *
> - * returns:
> - * 0 on success, -errno on failure.
>   */
> -int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> -				  void *base_addr)
> +void __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> +				   void *base_addr)
>  {
>  	size_t size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
>  	size_t static_size, dyn_size;
> @@ -2457,7 +2454,6 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  
>  	/* we're done */
>  	pcpu_base_addr = base_addr;
> -	return 0;
>  }
>  
>  #ifdef config_smp
> @@ -2710,7 +2706,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  	struct pcpu_alloc_info *ai;
>  	size_t size_sum, areas_size;
>  	unsigned long max_distance;
> -	int group, i, highest_group, rc;
> +	int group, i, highest_group, rc = 0;
>  
>  	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
>  				   cpu_distance_fn);
> @@ -2795,7 +2791,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  		pfn_down(size_sum), ai->static_size, ai->reserved_size,
>  		ai->dyn_size, ai->unit_size);
>  
> -	rc = pcpu_setup_first_chunk(ai, base);
> +	pcpu_setup_first_chunk(ai, base);
>  	goto out_free;
>  
>  out_free_areas:
> @@ -2920,7 +2916,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
>  		unit_pages, psize_str, ai->static_size,
>  		ai->reserved_size, ai->dyn_size);
>  
> -	rc = pcpu_setup_first_chunk(ai, vm.addr);
> +	pcpu_setup_first_chunk(ai, vm.addr);
>  	goto out_free_ar;
>  
>  enomem:
> @@ -3014,8 +3010,7 @@ void __init setup_per_cpu_areas(void)
>  	ai->groups[0].nr_units = 1;
>  	ai->groups[0].cpu_map[0] = 0;
>  
> -	if (pcpu_setup_first_chunk(ai, fc) < 0)
> -		panic("failed to initialize percpu areas.");
> +	pcpu_setup_first_chunk(ai, fc);
>  	pcpu_free_alloc_info(ai);
>  }
>  
> -- 
> 2.20.1
> 

Hi Kefeng,

This makes sense to me. I've applied this to for-5.4.

Thanks,
Dennis

