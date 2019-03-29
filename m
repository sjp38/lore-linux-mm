Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2FBBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 07:52:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32E1A2173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 07:52:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32E1A2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963726B0007; Fri, 29 Mar 2019 03:52:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90FC76B0008; Fri, 29 Mar 2019 03:52:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FFCE6B000C; Fri, 29 Mar 2019 03:52:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26CA06B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:52:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x13so666688edq.11
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 00:52:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rq6G0SONBGFDEumyZh9GcQkd0WSRmkvWg51HhaPl8rc=;
        b=idGVLUlbSqVnRBk1FpY90sJmBOum5lEvYnUt7bKMsbOQQbZ0NgtEnd/T6lwu+pbJ2x
         tCZcPCEzIg28SkGpkavvh+ts5eqqdLLOwQxfXQYbPMZP8lD6cvpBsKYvr6wGYa/rHwK/
         U0Fbkg6DZioEXsdjst0IVWeTg2/En+4Vswnegu69w079GxtXNrWiIpHvVWQ7QXjBkWTa
         JCWuJehTxtsPWgjOVwezOOhseMuFF+Jb7eilxLaqnIzWpCRLAhOcUfO+Hn+ObayUB5eh
         6knEm7EohQxMT3TC/wOeR/PoGu3YjS8t4x0Dh7dYLWlY6MsuSI6qgq24syDRgbMxaRrO
         6Zag==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXDwKQ50zv+Uykx5bzHhphYkJTB3vDP9Y9JpUgOOW1hiBwn6vzu
	SlcsQA/0Zf0mXoRrBGE/es0aL8HkckMwD2eeEwr5HERr6ca+rVEvHqLN08t1t1gOGGI0Y1cOu0S
	5s61em6D+EvtjsSoStR8QtgE8Ibuqha782XNHI2jDyT/LZvS81IHJNl7gO7Tww7k=
X-Received: by 2002:a50:9b56:: with SMTP id a22mr10027556edj.22.1553845929674;
        Fri, 29 Mar 2019 00:52:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO3zcH6VJKZIGD6REj0/6W4wk6IKnUyBFbdQxJbxTQvwxXx+WGtuAuRdC8pXxZMDnSn/RU
X-Received: by 2002:a50:9b56:: with SMTP id a22mr10027504edj.22.1553845928599;
        Fri, 29 Mar 2019 00:52:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553845928; cv=none;
        d=google.com; s=arc-20160816;
        b=0SHCaOvyVGnlUvnA5ij03pLjWH406IIhAC/26+gLAxe20QNDbtZP8X6BMb2/P3teKL
         m9/eVtgY3zRjBEpctiZRL44jiLQHW2TMwNb7xDqRzVbKQcL4tRdiYFZd0AR/Ts2ASPa3
         GEr3wH3tXNeoxmIZ2audP7BqRQblgWzOSrowB3EwIjFhqc4C+1kVscoLWTN+dYIdawFm
         hwxvT6d+gV9ngdZTaeT0kl3eAFPGRG7UOOPbtWMUQM/VcMsa6bonl+jfPdtCMjZvOdBj
         c60mfjIlVGeAkkdQIlMMrRwQuUHAyRlVOoav6jAjwJYneXfNpLX/ijdjgCDqfB7ttARl
         jWHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rq6G0SONBGFDEumyZh9GcQkd0WSRmkvWg51HhaPl8rc=;
        b=uyO9D8qKzcdTy2FsmkIAxMVKchhd0k2Rc5irxHiIDG1BwtmTvLO/3woknrqQYxWKXm
         GUouDmCBbtKm3cu0j3JkfLea7EjmVr61e7sCQZxZpZ9vNINAP1lhznxl92OElrEriFbz
         tDHyV+TYxfs1Ou7Y5bgdHy6yGuXzBwwAWua5CYdQBw0Dq/PfcJgOsbTl0EfVhta+/cZ8
         K0OOwAxKA8QjUeQoqKob/HyNcZP6GbVcBXGvdGy1MPU59xDQ62Bv3CQcMz3KhcC9jXbJ
         8e7gRQkRplFBkyDv/siZp3zYBrKKV7jzIq776Z79w32Ti30OspgHV9lC5fYd3VxMcvT/
         riyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x43si624045edb.439.2019.03.29.00.52.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 00:52:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DAFECAF8F;
	Fri, 29 Mar 2019 07:52:07 +0000 (UTC)
Date: Fri, 29 Mar 2019 08:52:06 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Ben Gardon <bgardon@google.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	linux-mm@kvack.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm, kvm: account kvm_vcpu_mmap to kmemcg
Message-ID: <20190329075206.GA28616@dhcp22.suse.cz>
References: <20190329012836.47013-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329012836.47013-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 18:28:36, Shakeel Butt wrote:
> A VCPU of a VM can allocate upto three pages which can be mmap'ed by the
> user space application. At the moment this memory is not charged. On a
> large machine running large number of VMs (or small number of VMs having
> large number of VCPUs), this unaccounted memory can be very significant.

Is this really the case. How many machines are we talking about? Say I
have a virtual machines with 1K cpus, this will result in 12MB. Is this
significant to the overal size of the virtual machine to even care?

> So, this memory should be charged to a kmemcg. However that is not
> possible as these pages are mmapped to the userspace and PageKmemcg()
> was designed with the assumption that such pages will never be mmapped
> to the userspace.
>
> One way to solve this problem is by introducing an additional memcg
> charging API similar to mem_cgroup_[un]charge_skmem(). However skmem
> charging API usage is contained and shared and no new users are
> expected but the pages which can be mmapped and should be charged to
> kmemcg can and will increase. So, requiring the usage for such API will
> increase the maintenance burden. The simplest solution is to remove the
> assumption of no mmapping PageKmemcg() pages to user space.

IIRC the only purpose of PageKmemcg is to keep accounting in the legacy
memcg right. Spending a page flag for that is just no-go. If PageKmemcg
cannot reuse mapping then we have to find a better place for it (e.g.
bottom bit in the page->memcg pointer or rethink the whole PageKmemcg.
 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  arch/s390/kvm/kvm-s390.c       |  2 +-
>  arch/x86/kvm/x86.c             |  2 +-
>  include/linux/page-flags.h     | 26 ++++++++++++++++++--------
>  include/trace/events/mmflags.h |  9 ++++++++-
>  virt/kvm/coalesced_mmio.c      |  2 +-
>  virt/kvm/kvm_main.c            |  2 +-
>  6 files changed, 30 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> index 4638303ba6a8..1a9e337ed5da 100644
> --- a/arch/s390/kvm/kvm-s390.c
> +++ b/arch/s390/kvm/kvm-s390.c
> @@ -2953,7 +2953,7 @@ struct kvm_vcpu *kvm_arch_vcpu_create(struct kvm *kvm,
>  		goto out;
>  
>  	BUILD_BUG_ON(sizeof(struct sie_page) != 4096);
> -	sie_page = (struct sie_page *) get_zeroed_page(GFP_KERNEL);
> +	sie_page = (struct sie_page *) get_zeroed_page(GFP_KERNEL_ACCOUNT);
>  	if (!sie_page)
>  		goto out_free_cpu;
>  
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 65e4559eef2f..05c0c7eaa5c6 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -9019,7 +9019,7 @@ int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
>  	else
>  		vcpu->arch.mp_state = KVM_MP_STATE_UNINITIALIZED;
>  
> -	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> +	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
>  	if (!page) {
>  		r = -ENOMEM;
>  		goto fail;
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 9f8712a4b1a5..b47a6a327d6a 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -78,6 +78,10 @@
>   * PG_hwpoison indicates that a page got corrupted in hardware and contains
>   * data with incorrect ECC bits that triggered a machine check. Accessing is
>   * not safe since it may cause another machine check. Don't touch!
> + *
> + * PG_kmemcg indicates that a kmem page is charged to a memcg. If kmemcg is
> + * enabled, the page allocator will set PageKmemcg() on  pages allocated with
> + * __GFP_ACCOUNT. It gets cleared on page free.
>   */
>  
>  /*
> @@ -130,6 +134,9 @@ enum pageflags {
>  #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
>  	PG_young,
>  	PG_idle,
> +#endif
> +#ifdef CONFIG_MEMCG_KMEM
> +	PG_kmemcg,
>  #endif
>  	__NR_PAGEFLAGS,
>  
> @@ -289,6 +296,9 @@ static inline int Page##uname(const struct page *page) { return 0; }
>  #define SETPAGEFLAG_NOOP(uname)						\
>  static inline void SetPage##uname(struct page *page) {  }
>  
> +#define __SETPAGEFLAG_NOOP(uname)					\
> +static inline void __SetPage##uname(struct page *page) {  }
> +
>  #define CLEARPAGEFLAG_NOOP(uname)					\
>  static inline void ClearPage##uname(struct page *page) {  }
>  
> @@ -427,6 +437,13 @@ TESTCLEARFLAG(Young, young, PF_ANY)
>  PAGEFLAG(Idle, idle, PF_ANY)
>  #endif
>  
> +#ifdef CONFIG_MEMCG_KMEM
> +__PAGEFLAG(Kmemcg, kmemcg, PF_NO_TAIL)
> +#else
> +TESTPAGEFLAG_FALSE(kmemcg)
> +__SETPAGEFLAG_NOOP(kmemcg)
> +__CLEARPAGEFLAG_NOOP(kmemcg)
> +#endif
>  /*
>   * On an anonymous page mapped into a user virtual memory area,
>   * page->mapping points to its anon_vma, not to a struct address_space;
> @@ -701,8 +718,7 @@ PAGEFLAG_FALSE(DoubleMap)
>  #define PAGE_MAPCOUNT_RESERVE	-128
>  #define PG_buddy	0x00000080
>  #define PG_offline	0x00000100
> -#define PG_kmemcg	0x00000200
> -#define PG_table	0x00000400
> +#define PG_table	0x00000200
>  
>  #define PageType(page, flag)						\
>  	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
> @@ -743,12 +759,6 @@ PAGE_TYPE_OPS(Buddy, buddy)
>   */
>  PAGE_TYPE_OPS(Offline, offline)
>  
> -/*
> - * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
> - * pages allocated with __GFP_ACCOUNT. It gets cleared on page free.
> - */
> -PAGE_TYPE_OPS(Kmemcg, kmemcg)
> -
>  /*
>   * Marks pages in use as page tables.
>   */
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index a1675d43777e..d93b78eac5b9 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -79,6 +79,12 @@
>  #define IF_HAVE_PG_IDLE(flag,string)
>  #endif
>  
> +#ifdef CONFIG_MEMCG_KMEM
> +#define IF_HAVE_PG_KMEMCG(flag,string) ,{1UL << flag, string}
> +#else
> +#define IF_HAVE_PG_KMEMCG(flag,string)
> +#endif
> +
>  #define __def_pageflag_names						\
>  	{1UL << PG_locked,		"locked"	},		\
>  	{1UL << PG_waiters,		"waiters"	},		\
> @@ -105,7 +111,8 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
>  IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
>  IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
>  IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
> -IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
> +IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
> +IF_HAVE_PG_KMEMCG(PG_kmemcg,		"kmemcg"	)
>  
>  #define show_page_flags(flags)						\
>  	(flags) ? __print_flags(flags, "|",				\
> diff --git a/virt/kvm/coalesced_mmio.c b/virt/kvm/coalesced_mmio.c
> index 5294abb3f178..ebf1601de2a5 100644
> --- a/virt/kvm/coalesced_mmio.c
> +++ b/virt/kvm/coalesced_mmio.c
> @@ -110,7 +110,7 @@ int kvm_coalesced_mmio_init(struct kvm *kvm)
>  	int ret;
>  
>  	ret = -ENOMEM;
> -	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> +	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
>  	if (!page)
>  		goto out_err;
>  
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index f25aa98a94df..de6328dff251 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -306,7 +306,7 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *kvm, unsigned id)
>  	vcpu->pre_pcpu = -1;
>  	INIT_LIST_HEAD(&vcpu->blocked_vcpu_list);
>  
> -	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> +	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
>  	if (!page) {
>  		r = -ENOMEM;
>  		goto fail;
> -- 
> 2.21.0.392.gf8f6787159e-goog
> 

-- 
Michal Hocko
SUSE Labs

