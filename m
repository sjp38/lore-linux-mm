Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C68556B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:34:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j3so5433943wrb.18
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:34:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c5sor1036247ede.41.2018.03.16.06.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 06:34:43 -0700 (PDT)
Date: Fri, 16 Mar 2018 16:34:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/shmem: Do not wait for lock_page() in
 shmem_unused_huge_shrink()
Message-ID: <20180316133417.hk2lvnvgildsc65n@node.shutemov.name>
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
Cc: mhocko@kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@lists.ewheeler.net

On Fri, Mar 16, 2018 at 10:14:24PM +0900, Tetsuo Handa wrote:
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

This won't work in this case. We need to destinct no-page-in-page-cache
from failed-to-lock-page. We take different routes depending on this.

-- 
 Kirill A. Shutemov
