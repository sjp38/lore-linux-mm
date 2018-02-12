Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 277C96B005A
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:45:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j100so9080804wrj.4
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:45:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si3788405wmg.258.2018.02.12.07.45.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Feb 2018 07:45:45 -0800 (PST)
Date: Mon, 12 Feb 2018 15:48:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Message-ID: <20180212144831.GF3443@dhcp22.suse.cz>
References: <20180126140415.GD5027@dhcp22.suse.cz>
 <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
 <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com>
 <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au>
 <20180130094205.GS21609@dhcp22.suse.cz>
 <5eccdc1b-6a10-b48a-c63f-295f69473d97@linux.vnet.ibm.com>
 <20180131131937.GA6740@dhcp22.suse.cz>
 <bfecda5e-ae8b-df91-0add-df6322b42a70@linux.vnet.ibm.com>
 <20180201134829.GL21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201134829.GL21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

Did you have any chance to test the following hack, Anshuman?

On Thu 01-02-18 14:48:29, Michal Hocko wrote:
[...]
> Just a blind shot... Does the following make any difference?
> ---
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 021fe78998ea..04b24d00c911 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -895,7 +895,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  	   the correct location in memory. */
>  	for(i = 0, elf_ppnt = elf_phdata;
>  	    i < loc->elf_ex.e_phnum; i++, elf_ppnt++) {
> -		int elf_prot = 0, elf_flags;
> +		int elf_prot = 0, elf_flags, elf_fixed = MAP_FIXED_NOREPLACE;
>  		unsigned long k, vaddr;
>  		unsigned long total_size = 0;
>  
> @@ -927,6 +927,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  					 */
>  				}
>  			}
> +			elf_fixed = MAP_FIXED;
>  		}
>  
>  		if (elf_ppnt->p_flags & PF_R)
> @@ -944,7 +945,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  		 * the ET_DYN load_addr calculations, proceed normally.
>  		 */
>  		if (loc->elf_ex.e_type == ET_EXEC || load_addr_set) {
> -			elf_flags |= MAP_FIXED_NOREPLACE;
> +			elf_flags |= elf_fixed;
>  		} else if (loc->elf_ex.e_type == ET_DYN) {
>  			/*
>  			 * This logic is run once for the first LOAD Program
> @@ -980,7 +981,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  				load_bias = ELF_ET_DYN_BASE;
>  				if (current->flags & PF_RANDOMIZE)
>  					load_bias += arch_mmap_rnd();
> -				elf_flags |= MAP_FIXED_NOREPLACE;
> +				elf_flags |= elf_fixed;
>  			} else
>  				load_bias = 0;
>  
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
