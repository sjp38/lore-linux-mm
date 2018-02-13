Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8826B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 01:49:35 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id q185so15699942qke.2
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 22:49:35 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 134si1654108qkf.329.2018.02.12.22.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 22:49:33 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1D6nI2X027880
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 01:49:33 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g3ps7ypp7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 01:49:32 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 13 Feb 2018 06:49:31 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
 <20180126140415.GD5027@dhcp22.suse.cz>
 <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
 <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com>
 <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au>
 <20180130094205.GS21609@dhcp22.suse.cz>
 <5eccdc1b-6a10-b48a-c63f-295f69473d97@linux.vnet.ibm.com>
 <20180131131937.GA6740@dhcp22.suse.cz>
 <bfecda5e-ae8b-df91-0add-df6322b42a70@linux.vnet.ibm.com>
 <20180201134829.GL21609@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 13 Feb 2018 12:19:18 +0530
MIME-Version: 1.0
In-Reply-To: <20180201134829.GL21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <b0a751c4-9552-87b4-c768-3e1b02c18b5c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 02/01/2018 07:18 PM, Michal Hocko wrote:
> On Thu 01-02-18 08:43:34, Anshuman Khandual wrote:
> [...]
>> $dmesg | grep elf_brk
>> [    9.571192] elf_brk 10030328 elf_bss 10030000
>>
>> static int load_elf_binary(struct linux_binprm *bprm)
>> ---------------------
>>
>> 	if (unlikely (elf_brk > elf_bss)) {
>> 			unsigned long nbyte;
>> 	            
>> 			/* There was a PT_LOAD segment with p_memsz > p_filesz
>> 			   before this one. Map anonymous pages, if needed,
>> 			   and clear the area.  */
>> 			retval = set_brk(elf_bss + load_bias,
>> 					 elf_brk + load_bias,
>> 					 bss_prot);
>>
>>
>> ---------------------
> 
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
> 

Yeah, it does solve the problem on mmotm-2018-01-25-16-20.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
