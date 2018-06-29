Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8A266B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:30:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21-v6so2940697edq.23
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:30:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10-v6si4672610edl.132.2018.06.29.07.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 07:30:47 -0700 (PDT)
Date: Fri, 29 Jun 2018 16:30:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] kvm, mm: account shadow page tables to kmemcg
Message-ID: <20180629143044.GF5963@dhcp22.suse.cz>
References: <20180629140224.205849-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180629140224.205849-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, stable@vger.kernel.org

On Fri 29-06-18 07:02:24, Shakeel Butt wrote:
> The size of kvm's shadow page tables corresponds to the size of the
> guest virtual machines on the system. Large VMs can spend a significant
> amount of memory as shadow page tables which can not be left as system
> memory overhead. So, account shadow page tables to the kmemcg.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
> Cc: Peter Feiner <pfeiner@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: stable@vger.kernel.org

I am not familiar wtih kvm to judge but if we are going to account this
memory we will probably want to let oom_badness know how much memory
to account to a specific process. Is this something that we can do?
We will probably need a new MM_KERNEL rss_stat stat for that purpose.

Just to make it clear. I am not opposing to this patch but considering
that shadow page tables might consume a lot of memory it would be good
to know who is responsible for it from the OOM perspective. Something to
solve on top of this.

I would also love to see a note how this memory is bound to the owner
life time in the changelog. That would make the review much more easier.

> ---
> Changelog since v1:
> - replaced (GFP_KERNEL|__GFP_ACCOUNT) with GFP_KERNEL_ACCOUNT
> 
>  arch/x86/kvm/mmu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index d594690d8b95..6b8f11521c41 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -890,7 +890,7 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
>  	if (cache->nobjs >= min)
>  		return 0;
>  	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
> -		page = (void *)__get_free_page(GFP_KERNEL);
> +		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
>  		if (!page)
>  			return -ENOMEM;
>  		cache->objects[cache->nobjs++] = page;
> -- 
> 2.18.0.rc2.346.g013aa6912e-goog

-- 
Michal Hocko
SUSE Labs
