Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DE04A6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:19:59 -0400 (EDT)
Received: by wijp11 with SMTP id p11so77216614wij.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:19:59 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id ee8si4983589wic.1.2015.10.23.06.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 06:19:57 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so31050223wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:19:57 -0700 (PDT)
Date: Fri, 23 Oct 2015 15:19:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151023131956.GA15375@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 22-10-15 00:21:33, Johannes Weiner wrote:
> Socket memory can be a significant share of overall memory consumed by
> common workloads. In order to provide reasonable resource isolation
> out-of-the-box in the unified hierarchy, this type of memory needs to
> be accounted and tracked per default in the memory controller.

What about users who do not want to pay an additional overhead for the
accounting? How can they disable it?

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

[...]

> @@ -5453,10 +5470,9 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
>  	commit_charge(newpage, memcg, true);
>  }
>  
> -/* Writing them here to avoid exposing memcg's inner layout */
> -#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> +#ifdef CONFIG_INET
>  
> -DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> +DEFINE_STATIC_KEY_TRUE(mem_cgroup_sockets);

AFAIU this means that the jump label is enabled by default. Is this
intended when you enable it explicitly where needed?

>  
>  void sock_update_memcg(struct sock *sk)
>  {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
