Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A66236B0623
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 12:53:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c8-v6so11309193edt.23
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 09:53:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5-v6si817565edk.25.2018.11.08.09.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 09:53:04 -0800 (PST)
Date: Thu, 8 Nov 2018 18:53:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mmap: remove verify_mm_writelocked()
Message-ID: <20181108175301.GC18390@dhcp22.suse.cz>
References: <20181108174856.10811-1-tiny.windzz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108174856.10811-1-tiny.windzz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yangtao Li <tiny.windzz@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, dan.j.williams@intel.com, linux@dominikbrodowski.net, dave.hansen@linux.intel.com, dwmw@amazon.co.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 08-11-18 12:48:56, Yangtao Li wrote:
> We should get rid of this function. It no longer serves its purpose.This
> is a historical artifact from 2005 where do_brk was called outside of
> the core mm.We do have a proper abstraction in vm_brk_flags and that one
> does the locking properly.So there is no need to use this function.
> 
> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mmap.c | 16 ----------------
>  1 file changed, 16 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f7cd9cb966c0..1cee506494d2 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2910,16 +2910,6 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  	return ret;
>  }
>  
> -static inline void verify_mm_writelocked(struct mm_struct *mm)
> -{
> -#ifdef CONFIG_DEBUG_VM
> -	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
> -		WARN_ON(1);
> -		up_read(&mm->mmap_sem);
> -	}
> -#endif
> -}
> -
>  /*
>   *  this is really a simplified "do_mmap".  it only handles
>   *  anonymous maps.  eventually we may be able to do some
> @@ -2946,12 +2936,6 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
>  	if (error)
>  		return error;
>  
> -	/*
> -	 * mm->mmap_sem is required to protect against another thread
> -	 * changing the mappings in case we sleep.
> -	 */
> -	verify_mm_writelocked(mm);
> -
>  	/*
>  	 * Clear old maps.  this also does some error checking for us
>  	 */
> -- 
> 2.17.0
> 

-- 
Michal Hocko
SUSE Labs
