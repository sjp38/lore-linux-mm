Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D70AD82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:19:32 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so8699119wic.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:19:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qr8si26385940wjc.131.2015.10.16.15.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:19:31 -0700 (PDT)
Date: Fri, 16 Oct 2015 15:19:22 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-ID: <20151016221922.GA4355@cmpxchg.org>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
 <20151016131726.GA602@node.shutemov.name>
 <20151016135106.GJ11309@esperanza>
 <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 16, 2015 at 03:12:23PM -0700, Hugh Dickins wrote:
> --- 4035m/mm/list_lru.c	2015-10-15 15:26:59.835572128 -0700
> +++ 4035M/mm/list_lru.c	2015-10-16 03:11:51.000000000 -0700
> @@ -63,6 +63,16 @@ list_lru_from_memcg_idx(struct list_lru_
>  	return &nlru->lru;
>  }
>  
> +static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
> +{
> +	struct page *page;
> +
> +	if (!memcg_kmem_enabled())
> +		return NULL;
> +	page = virt_to_head_page(ptr);
> +	return page->mem_cgroup;
> +}
> +
>  static inline struct list_lru_one *
>  list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
>  {

I like this better than the mm.h include, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
