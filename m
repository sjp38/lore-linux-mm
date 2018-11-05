Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48F2F6B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 01:51:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id h25-v6so4824199eds.21
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 22:51:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l6-v6si423989edc.66.2018.11.04.22.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 22:51:08 -0800 (PST)
Date: Mon, 5 Nov 2018 07:51:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mmap: remove unnecessary unlikely()
Message-ID: <20181105065037.GA4361@dhcp22.suse.cz>
References: <20181104124456.3424-1-tiny.windzz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181104124456.3424-1-tiny.windzz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yangtao Li <tiny.windzz@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, rientjes@google.com, linux@dominikbrodowski.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 04-11-18 07:44:56, Yangtao Li wrote:
> WARN_ON() already contains an unlikely(), so it's not necessary to use
> unlikely.

We should just get rid of this ugliness altogether. It no longer serves
its purpose.  This is a historical artifact from 2005 where do_brk
was called outside of the core mm. We do have a proper abstraction in
vm_brk_flags and that one does the locking properly.

> 
> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
> ---
>  mm/mmap.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 6c04292e16a7..2077008ade0c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2965,10 +2965,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  static inline void verify_mm_writelocked(struct mm_struct *mm)
>  {
>  #ifdef CONFIG_DEBUG_VM
> -	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
> -		WARN_ON(1);
> +	if (WARN_ON(down_read_trylock(&mm->mmap_sem)))
>  		up_read(&mm->mmap_sem);
> -	}
>  #endif
>  }
>  
> -- 
> 2.17.0
> 

-- 
Michal Hocko
SUSE Labs
