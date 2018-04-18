Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 901F36B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:33:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p4-v6so1483014wrf.17
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:33:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 40si799085edr.266.2018.04.18.04.33.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 04:33:02 -0700 (PDT)
Date: Wed, 18 Apr 2018 13:33:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
Message-ID: <20180418113301.GY17484@dhcp22.suse.cz>
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213092550.2774-3-mhocko@kernel.org>
 <0b5c541a-91ee-220b-3196-f64264f9f0bc@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b5c541a-91ee-220b-3196-f64264f9f0bc@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-04-18 19:51:05, Tetsuo Handa wrote:
> >From 0ba20dcbbc40b703413c9a6907a77968b087811b Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 18 Apr 2018 15:31:48 +0900
> Subject: [PATCH] fs, elf: don't complain MAP_FIXED_NOREPLACE if mapping
>  failed.
> 
> Commit 4ed28639519c7bad ("fs, elf: drop MAP_FIXED usage from elf_map") is
> printing spurious messages under memory pressure due to map_addr == -ENOMEM.
> 
>  9794 (a.out): Uhuuh, elf segment at 00007f2e34738000(fffffffffffffff4) requested but the memory is mapped already
>  14104 (a.out): Uhuuh, elf segment at 00007f34fd76c000(fffffffffffffff4) requested but the memory is mapped already
>  16843 (a.out): Uhuuh, elf segment at 00007f930ecc7000(fffffffffffffff4) requested but the memory is mapped already

Hmm this is ENOMEM.

> Don't complain if IS_ERR_VALUE(),

this is simply wrong. We do want to warn on the failure because this is
when the actual clash happens. We should just warn on EEXIST.

> and use %px for printing the address.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrei Vagin <avagin@openvz.org>
> Cc: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
> Cc: Joel Stanley <joel@jms.id.au>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  fs/binfmt_elf.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 41e0418..559d35b 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -377,10 +377,10 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
>  	} else
>  		map_addr = vm_mmap(filep, addr, size, prot, type, off);
>  
> -	if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr))
> -		pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
> -				task_pid_nr(current), current->comm,
> -				(void *)addr);
> +	if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr) &&
> +	    !IS_ERR_VALUE(map_addr))
> +		pr_info("%d (%s): Uhuuh, elf segment at %px requested but the memory is mapped already\n",
> +			task_pid_nr(current), current->comm, (void *)addr);
>  
>  	return(map_addr);
>  }
> -- 
> 1.8.3.1
> 
> 

-- 
Michal Hocko
SUSE Labs
