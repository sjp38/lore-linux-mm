Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E34F6B0006
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:20:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v3so5110395pfm.21
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:20:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si4948114pgp.800.2018.03.16.06.20.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 06:20:26 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:20:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/shmem: Do not wait for lock_page() in
 shmem_unused_huge_shrink()
Message-ID: <20180316132023.GK23100@dhcp22.suse.cz>
References: <20180316105908.62516-1-kirill.shutemov@linux.intel.com>
 <20180316121303.GI23100@dhcp22.suse.cz>
 <20180316122508.fv4edpx34hdqybwx@node.shutemov.name>
 <20180316125827.GC11461@dhcp22.suse.cz>
 <20180316130200.rbke66zjyoc6zwzl@node.shutemov.name>
 <201803162214.ECJ30715.StOOFHOFVLJMQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803162214.ECJ30715.StOOFHOFVLJMQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kirill@shutemov.name, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@lists.ewheeler.net

On Fri 16-03-18 22:14:24, Tetsuo Handa wrote:
> f2fs is doing
> 
>   page = f2fs_pagecache_get_page(inode->i_mapping, 0, FGP_LOCK|FGP_NOWAIT, 0);
> 
> which calls
> 
>   struct page *pagecache_get_page(inode->i_mapping, 0, FGP_LOCK|FGP_NOWAIT, 0);
> 
> . Then, can't we define
> 
>   static inline struct page *find_trylock_page(struct address_space *mapping,
>   					     pgoff_t offset)
>   {
>   	return pagecache_get_page(mapping, offset, FGP_LOCK|FGP_NOWAIT, 0);
>   }
> 
> and replace find_lock_page() with find_trylock_page() ?

I haven't checked whether we have enough users of this pattern to create
a helper.

> Also, won't
> 
> ----------
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 34ce3ebf..0cfc329 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -479,6 +479,8 @@ static inline int trylock_page(struct page *page)
>  static inline void lock_page(struct page *page)
>  {
>  	might_sleep();
> +	WARN_ONCE(current->flags & PF_MEMALLOC,
> +		  "lock_page() from reclaim context might deadlock");
>  	if (!trylock_page(page))
>  		__lock_page(page);
>  }

lock_page is called from many (semi)hot paths so I wouldn't add
additional code there. Maybe we can hide it in VM_WARN. I would have
to think much more to be sure this won't lead to some strange false
positives. I suspect it won't but wouldn't bet my head on that.

In any case, you can try to send a patch and we can stick it into mmotm
and have it there for few cycles to see what falls out...
-- 
Michal Hocko
SUSE Labs
