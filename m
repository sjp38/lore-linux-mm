Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id BD5446B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 12:51:15 -0400 (EDT)
Date: Thu, 16 May 2013 12:51:05 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 2/8] vmcore: allocate buffer for ELF headers on
 page-size alignment
Message-ID: <20130516165105.GB8726@redhat.com>
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
 <20130515090551.28109.73350.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130515090551.28109.73350.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Wed, May 15, 2013 at 06:05:51PM +0900, HATAYAMA Daisuke wrote:

[..]
> @@ -398,9 +403,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
>  	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr)); /* PT_NOTE hdr */
>  
>  	/* First program header is PT_NOTE header. */
> -	vmcore_off = sizeof(Elf64_Ehdr) +
> -			(ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr) +
> -			phdr_ptr->p_memsz; /* Note sections */
> +	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);
>  
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
>  		if (phdr_ptr->p_type != PT_LOAD)
> @@ -435,9 +438,7 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
>  	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
>  
>  	/* First program header is PT_NOTE header. */
> -	vmcore_off = sizeof(Elf32_Ehdr) +
> -			(ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr) +
> -			phdr_ptr->p_memsz; /* Note sections */
> +	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);

Hmm.., so we are rounding up ELF note data size too here. I think this belongs
in some other patch as in this patch we are just rounding up the elf
headers.

This might create read problems too as we have not taking care of this
rounding when adding note to vc_list and it might happen that we are
reading wrong data at a particular offset.

So may be this rounding up we should do in later patches when we take
care of copying ELF notes data to second kernel.

Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
