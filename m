Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 83A4C6B009B
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:45:51 -0400 (EDT)
Date: Tue, 14 May 2013 10:45:41 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v5 1/8] vmcore: allocate buffer for ELF headers on
 page-size alignment
Message-ID: <20130514144541.GA16772@redhat.com>
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6>
 <20130514015712.18697.39725.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514015712.18697.39725.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org

On Tue, May 14, 2013 at 10:57:12AM +0900, HATAYAMA Daisuke wrote:
> Allocate ELF headers on page-size boundary using __get_free_pages()
> instead of kmalloc().
> 
> Later patch will merge PT_NOTE entries into a single unique one and
> decrease the buffer size actually used. Keep original buffer size in
> variable elfcorebuf_sz_orig to kfree the buffer later and actually
> used buffer size with rounded up to page-size boundary in variable
> elfcorebuf_sz separately.
> 
> The size of part of the ELF buffer exported from /proc/vmcore is
> elfcorebuf_sz.
> 
> The merged, removed PT_NOTE entries, i.e. the range [elfcorebuf_sz,
> elfcorebuf_sz_orig], is filled with 0.
> 
> Use size of the ELF headers as an initial offset value in
> set_vmcore_list_offsets_elf{64,32} and
> process_ptload_program_headers_elf{64,32} in order to indicate that
> the offset includes the holes towards the page boundary.
> 
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

Looks good to me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Vivek

> ---
> 
>  fs/proc/vmcore.c |   80 ++++++++++++++++++++++++++++++------------------------
>  1 files changed, 45 insertions(+), 35 deletions(-)
> 
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 17f7e08..69e1198 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -32,6 +32,7 @@ static LIST_HEAD(vmcore_list);
>  /* Stores the pointer to the buffer containing kernel elf core headers. */
>  static char *elfcorebuf;
>  static size_t elfcorebuf_sz;
> +static size_t elfcorebuf_sz_orig;
>  
>  /* Total size of vmcore file. */
>  static u64 vmcore_size;
> @@ -214,7 +215,7 @@ static struct vmcore* __init get_new_element(void)
>  	return kzalloc(sizeof(struct vmcore), GFP_KERNEL);
>  }
>  
> -static u64 __init get_vmcore_size_elf64(char *elfptr)
> +static u64 __init get_vmcore_size_elf64(char *elfptr, size_t elfsz)
>  {
>  	int i;
>  	u64 size;
> @@ -223,7 +224,7 @@ static u64 __init get_vmcore_size_elf64(char *elfptr)
>  
>  	ehdr_ptr = (Elf64_Ehdr *)elfptr;
>  	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr));
> -	size = sizeof(Elf64_Ehdr) + ((ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr));
> +	size = elfsz;
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++) {
>  		size += phdr_ptr->p_memsz;
>  		phdr_ptr++;
> @@ -231,7 +232,7 @@ static u64 __init get_vmcore_size_elf64(char *elfptr)
>  	return size;
>  }
>  
> -static u64 __init get_vmcore_size_elf32(char *elfptr)
> +static u64 __init get_vmcore_size_elf32(char *elfptr, size_t elfsz)
>  {
>  	int i;
>  	u64 size;
> @@ -240,7 +241,7 @@ static u64 __init get_vmcore_size_elf32(char *elfptr)
>  
>  	ehdr_ptr = (Elf32_Ehdr *)elfptr;
>  	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr));
> -	size = sizeof(Elf32_Ehdr) + ((ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr));
> +	size = elfsz;
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++) {
>  		size += phdr_ptr->p_memsz;
>  		phdr_ptr++;
> @@ -308,7 +309,7 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  	phdr.p_flags   = 0;
>  	note_off = sizeof(Elf64_Ehdr) +
>  			(ehdr_ptr->e_phnum - nr_ptnote +1) * sizeof(Elf64_Phdr);
> -	phdr.p_offset  = note_off;
> +	phdr.p_offset  = roundup(note_off, PAGE_SIZE);
>  	phdr.p_vaddr   = phdr.p_paddr = 0;
>  	phdr.p_filesz  = phdr.p_memsz = phdr_sz;
>  	phdr.p_align   = 0;
> @@ -322,6 +323,8 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  	i = (nr_ptnote - 1) * sizeof(Elf64_Phdr);
>  	*elfsz = *elfsz - i;
>  	memmove(tmp, tmp+i, ((*elfsz)-sizeof(Elf64_Ehdr)-sizeof(Elf64_Phdr)));
> +	memset(elfptr + *elfsz, 0, i);
> +	*elfsz = roundup(*elfsz, PAGE_SIZE);
>  
>  	/* Modify e_phnum to reflect merged headers. */
>  	ehdr_ptr->e_phnum = ehdr_ptr->e_phnum - nr_ptnote + 1;
> @@ -389,7 +392,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>  	phdr.p_flags   = 0;
>  	note_off = sizeof(Elf32_Ehdr) +
>  			(ehdr_ptr->e_phnum - nr_ptnote +1) * sizeof(Elf32_Phdr);
> -	phdr.p_offset  = note_off;
> +	phdr.p_offset  = roundup(note_off, PAGE_SIZE);
>  	phdr.p_vaddr   = phdr.p_paddr = 0;
>  	phdr.p_filesz  = phdr.p_memsz = phdr_sz;
>  	phdr.p_align   = 0;
> @@ -403,6 +406,8 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>  	i = (nr_ptnote - 1) * sizeof(Elf32_Phdr);
>  	*elfsz = *elfsz - i;
>  	memmove(tmp, tmp+i, ((*elfsz)-sizeof(Elf32_Ehdr)-sizeof(Elf32_Phdr)));
> +	memset(elfptr + *elfsz, 0, i);
> +	*elfsz = roundup(*elfsz, PAGE_SIZE);
>  
>  	/* Modify e_phnum to reflect merged headers. */
>  	ehdr_ptr->e_phnum = ehdr_ptr->e_phnum - nr_ptnote + 1;
> @@ -426,9 +431,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
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
> @@ -463,9 +466,7 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
>  	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
>  
>  	/* First program header is PT_NOTE header. */
> -	vmcore_off = sizeof(Elf32_Ehdr) +
> -			(ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr) +
> -			phdr_ptr->p_memsz; /* Note sections */
> +	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);
>  
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
>  		if (phdr_ptr->p_type != PT_LOAD)
> @@ -487,7 +488,7 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
>  }
>  
>  /* Sets offset fields of vmcore elements. */
> -static void __init set_vmcore_list_offsets_elf64(char *elfptr,
> +static void __init set_vmcore_list_offsets_elf64(char *elfptr, size_t elfsz,
>  						struct list_head *vc_list)
>  {
>  	loff_t vmcore_off;
> @@ -497,8 +498,7 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr,
>  	ehdr_ptr = (Elf64_Ehdr *)elfptr;
>  
>  	/* Skip Elf header and program headers. */
> -	vmcore_off = sizeof(Elf64_Ehdr) +
> -			(ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr);
> +	vmcore_off = elfsz;
>  
>  	list_for_each_entry(m, vc_list, list) {
>  		m->offset = vmcore_off;
> @@ -507,7 +507,7 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr,
>  }
>  
>  /* Sets offset fields of vmcore elements. */
> -static void __init set_vmcore_list_offsets_elf32(char *elfptr,
> +static void __init set_vmcore_list_offsets_elf32(char *elfptr, size_t elfsz,
>  						struct list_head *vc_list)
>  {
>  	loff_t vmcore_off;
> @@ -517,8 +517,7 @@ static void __init set_vmcore_list_offsets_elf32(char *elfptr,
>  	ehdr_ptr = (Elf32_Ehdr *)elfptr;
>  
>  	/* Skip Elf header and program headers. */
> -	vmcore_off = sizeof(Elf32_Ehdr) +
> -			(ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr);
> +	vmcore_off = elfsz;
>  
>  	list_for_each_entry(m, vc_list, list) {
>  		m->offset = vmcore_off;
> @@ -554,30 +553,35 @@ static int __init parse_crash_elf64_headers(void)
>  	}
>  
>  	/* Read in all elf headers. */
> -	elfcorebuf_sz = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
> -	elfcorebuf = kmalloc(elfcorebuf_sz, GFP_KERNEL);
> +	elfcorebuf_sz_orig = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
> +	elfcorebuf_sz = elfcorebuf_sz_orig;
> +	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
> +					       get_order(elfcorebuf_sz_orig));
>  	if (!elfcorebuf)
>  		return -ENOMEM;
>  	addr = elfcorehdr_addr;
> -	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz, &addr, 0);
> +	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
>  	if (rc < 0) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  
>  	/* Merge all PT_NOTE headers into one. */
>  	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  	rc = process_ptload_program_headers_elf64(elfcorebuf, elfcorebuf_sz,
>  							&vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
> -	set_vmcore_list_offsets_elf64(elfcorebuf, &vmcore_list);
> +	set_vmcore_list_offsets_elf64(elfcorebuf, elfcorebuf_sz, &vmcore_list);
>  	return 0;
>  }
>  
> @@ -609,30 +613,35 @@ static int __init parse_crash_elf32_headers(void)
>  	}
>  
>  	/* Read in all elf headers. */
> -	elfcorebuf_sz = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
> -	elfcorebuf = kmalloc(elfcorebuf_sz, GFP_KERNEL);
> +	elfcorebuf_sz_orig = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
> +	elfcorebuf_sz = elfcorebuf_sz_orig;
> +	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
> +					       get_order(elfcorebuf_sz_orig));
>  	if (!elfcorebuf)
>  		return -ENOMEM;
>  	addr = elfcorehdr_addr;
> -	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz, &addr, 0);
> +	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
>  	if (rc < 0) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  
>  	/* Merge all PT_NOTE headers into one. */
>  	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  	rc = process_ptload_program_headers_elf32(elfcorebuf, elfcorebuf_sz,
>  								&vmcore_list);
>  	if (rc) {
> -		kfree(elfcorebuf);
> +		free_pages((unsigned long)elfcorebuf,
> +			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
> -	set_vmcore_list_offsets_elf32(elfcorebuf, &vmcore_list);
> +	set_vmcore_list_offsets_elf32(elfcorebuf, elfcorebuf_sz, &vmcore_list);
>  	return 0;
>  }
>  
> @@ -657,14 +666,14 @@ static int __init parse_crash_elf_headers(void)
>  			return rc;
>  
>  		/* Determine vmcore size. */
> -		vmcore_size = get_vmcore_size_elf64(elfcorebuf);
> +		vmcore_size = get_vmcore_size_elf64(elfcorebuf, elfcorebuf_sz);
>  	} else if (e_ident[EI_CLASS] == ELFCLASS32) {
>  		rc = parse_crash_elf32_headers();
>  		if (rc)
>  			return rc;
>  
>  		/* Determine vmcore size. */
> -		vmcore_size = get_vmcore_size_elf32(elfcorebuf);
> +		vmcore_size = get_vmcore_size_elf32(elfcorebuf, elfcorebuf_sz);
>  	} else {
>  		pr_warn("Warning: Core image elf header is not sane\n");
>  		return -EINVAL;
> @@ -711,7 +720,8 @@ void vmcore_cleanup(void)
>  		list_del(&m->list);
>  		kfree(m);
>  	}
> -	kfree(elfcorebuf);
> +	free_pages((unsigned long)elfcorebuf,
> +		   get_order(elfcorebuf_sz_orig));
>  	elfcorebuf = NULL;
>  }
>  EXPORT_SYMBOL_GPL(vmcore_cleanup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
