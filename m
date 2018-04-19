Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 914E56B0008
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 01:58:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e14so2210620pfi.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 22:58:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o129si2434966pga.253.2018.04.18.22.58.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 22:58:24 -0700 (PDT)
Date: Thu, 19 Apr 2018 07:57:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] fs, elf: don't complain MAP_FIXED_NOREPLACE unless
 -EEXIST error.
Message-ID: <20180419055754.GH17484@dhcp22.suse.cz>
References: <20171213092550.2774-3-mhocko@kernel.org>
 <0b5c541a-91ee-220b-3196-f64264f9f0bc@I-love.SAKURA.ne.jp>
 <20180418113301.GY17484@dhcp22.suse.cz>
 <201804182043.JFH90161.LStOOMFFOJQHVF@I-love.SAKURA.ne.jp>
 <20180418115546.GZ17484@dhcp22.suse.cz>
 <201804182307.FAC17665.SFMOFJVFtHOLOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804182307.FAC17665.SFMOFJVFtHOLOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, avagin@openvz.org, khalid.aziz@oracle.com, mpe@ellerman.id.au, keescook@chromium.org, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, khandual@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 18-04-18 23:07:12, Tetsuo Handa wrote:
> >From 3f396857d23d4bf1fac4d4332316b5ba0af6d2f9 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 18 Apr 2018 23:00:53 +0900
> Subject: [PATCH v2] fs, elf: don't complain MAP_FIXED_NOREPLACE unless -EEXIST error.
> 
> Commit 4ed28639519c7bad ("fs, elf: drop MAP_FIXED usage from elf_map") is
> printing spurious messages under memory pressure due to map_addr == -ENOMEM.
> 
>  9794 (a.out): Uhuuh, elf segment at 00007f2e34738000(fffffffffffffff4) requested but the memory is mapped already
>  14104 (a.out): Uhuuh, elf segment at 00007f34fd76c000(fffffffffffffff4) requested but the memory is mapped already
>  16843 (a.out): Uhuuh, elf segment at 00007f930ecc7000(fffffffffffffff4) requested but the memory is mapped already
> 
> Complain only if -EEXIST, and use %px for printing the address.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Andrei Vagin <avagin@openvz.org>
> Cc: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
> Cc: Joel Stanley <joel@jms.id.au>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Thanks!

> ---
>  fs/binfmt_elf.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 41e0418..4ad6f66 100644
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
> +	if ((type & MAP_FIXED_NOREPLACE) &&
> +	    PTR_ERR((void *)map_addr) == -EEXIST)
> +		pr_info("%d (%s): Uhuuh, elf segment at %px requested but the memory is mapped already\n",
> +			task_pid_nr(current), current->comm, (void *)addr);
>  
>  	return(map_addr);
>  }
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
