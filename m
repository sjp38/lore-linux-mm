Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 967196B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 10:28:58 -0400 (EDT)
Date: Thu, 23 May 2013 10:28:49 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v8 6/9] vmcore: allocate ELF note segment in the 2nd
 kernel vmalloc memory
Message-ID: <20130523142849.GE2779@redhat.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
 <20130523052530.13864.7616.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130523052530.13864.7616.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, May 23, 2013 at 02:25:30PM +0900, HATAYAMA Daisuke wrote:
> The reasons why we don't allocate ELF note segment in the 1st kernel
> (old memory) on page boundary is to keep backward compatibility for
> old kernels, and that if doing so, we waste not a little memory due to
> round-up operation to fit the memory to page boundary since most of
> the buffers are in per-cpu area.
> 
> ELF notes are per-cpu, so total size of ELF note segments depends on
> number of CPUs. The current maximum number of CPUs on x86_64 is 5192,
> and there's already system with 4192 CPUs in SGI, where total size
> amounts to 1MB. This can be larger in the near future or possibly even
> now on another architecture that has larger size of note per a single
> cpu. Thus, to avoid the case where memory allocation for large block
> fails, we allocate vmcore objects on vmalloc memory.
> 
> This patch adds elfnotes_buf and elfnotes_sz variables to keep pointer
> to the ELF note segment buffer and its size. There's no longer the
> vmcore object that corresponds to the ELF note segment in
> vmcore_list. Accordingly, read_vmcore() has new case for ELF note
> segment and set_vmcore_list_offsets_elf{64,32}() and other helper
> functions starts calculating offset from sum of size of ELF headers
> and size of ELF note segment.
> 
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

Looks good to me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Vivek

> ---
> 
>  fs/proc/vmcore.c |  355 ++++++++++++++++++++++++++++++++++++++++++++----------
>  1 files changed, 288 insertions(+), 67 deletions(-)
> 
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 686068d..937709d 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -34,6 +34,9 @@ static char *elfcorebuf;
>  static size_t elfcorebuf_sz;
>  static size_t elfcorebuf_sz_orig;
>  
> +static char *elfnotes_buf;
> +static size_t elfnotes_sz;
> +
>  /* Total size of vmcore file. */
>  static u64 vmcore_size;
>  
> @@ -154,6 +157,26 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
>  			return acc;
>  	}
>  
> +	/* Read Elf note segment */
> +	if (*fpos < elfcorebuf_sz + elfnotes_sz) {
> +		void *kaddr;
> +
> +		tsz = elfcorebuf_sz + elfnotes_sz - *fpos;
> +		if (buflen < tsz)
> +			tsz = buflen;
> +		kaddr = elfnotes_buf + *fpos - elfcorebuf_sz;
> +		if (copy_to_user(buffer, kaddr, tsz))
> +			return -EFAULT;
> +		buflen -= tsz;
> +		*fpos += tsz;
> +		buffer += tsz;
> +		acc += tsz;
> +
> +		/* leave now if filled buffer already */
> +		if (buflen == 0)
> +			return acc;
> +	}
> +
>  	list_for_each_entry(m, &vmcore_list, list) {
>  		if (*fpos < m->offset + m->size) {
>  			tsz = m->offset + m->size - *fpos;
> @@ -221,27 +244,27 @@ static u64 __init get_vmcore_size_elf32(char *elfptr, size_t elfsz)
>  	return size;
>  }
>  
> -/* Merges all the PT_NOTE headers into one. */
> -static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
> -						struct list_head *vc_list)
> +/**
> + * update_note_header_size_elf64 - update p_memsz member of each PT_NOTE entry
> + *
> + * @ehdr_ptr: ELF header
> + *
> + * This function updates p_memsz member of each PT_NOTE entry in the
> + * program header table pointed to by @ehdr_ptr to real size of ELF
> + * note segment.
> + */
> +static int __init update_note_header_size_elf64(const Elf64_Ehdr *ehdr_ptr)
>  {
> -	int i, nr_ptnote=0, rc=0;
> -	char *tmp;
> -	Elf64_Ehdr *ehdr_ptr;
> -	Elf64_Phdr phdr, *phdr_ptr;
> +	int i, rc=0;
> +	Elf64_Phdr *phdr_ptr;
>  	Elf64_Nhdr *nhdr_ptr;
> -	u64 phdr_sz = 0, note_off;
>  
> -	ehdr_ptr = (Elf64_Ehdr *)elfptr;
> -	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr));
> +	phdr_ptr = (Elf64_Phdr *)(ehdr_ptr + 1);
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> -		int j;
>  		void *notes_section;
> -		struct vmcore *new;
>  		u64 offset, max_sz, sz, real_sz = 0;
>  		if (phdr_ptr->p_type != PT_NOTE)
>  			continue;
> -		nr_ptnote++;
>  		max_sz = phdr_ptr->p_memsz;
>  		offset = phdr_ptr->p_offset;
>  		notes_section = kmalloc(max_sz, GFP_KERNEL);
> @@ -253,7 +276,7 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  			return rc;
>  		}
>  		nhdr_ptr = notes_section;
> -		for (j = 0; j < max_sz; j += sz) {
> +		while (real_sz < max_sz) {
>  			if (nhdr_ptr->n_namesz == 0)
>  				break;
>  			sz = sizeof(Elf64_Nhdr) +
> @@ -262,26 +285,122 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  			real_sz += sz;
>  			nhdr_ptr = (Elf64_Nhdr*)((char*)nhdr_ptr + sz);
>  		}
> -
> -		/* Add this contiguous chunk of notes section to vmcore list.*/
> -		new = get_new_element();
> -		if (!new) {
> -			kfree(notes_section);
> -			return -ENOMEM;
> -		}
> -		new->paddr = phdr_ptr->p_offset;
> -		new->size = real_sz;
> -		list_add_tail(&new->list, vc_list);
> -		phdr_sz += real_sz;
>  		kfree(notes_section);
> +		phdr_ptr->p_memsz = real_sz;
> +	}
> +
> +	return 0;
> +}
> +
> +/**
> + * get_note_number_and_size_elf64 - get the number of PT_NOTE program
> + * headers and sum of real size of their ELF note segment headers and
> + * data.
> + *
> + * @ehdr_ptr: ELF header
> + * @nr_ptnote: buffer for the number of PT_NOTE program headers
> + * @sz_ptnote: buffer for size of unique PT_NOTE program header
> + *
> + * This function is used to merge multiple PT_NOTE program headers
> + * into a unique single one. The resulting unique entry will have
> + * @sz_ptnote in its phdr->p_mem.
> + *
> + * It is assumed that program headers with PT_NOTE type pointed to by
> + * @ehdr_ptr has already been updated by update_note_header_size_elf64
> + * and each of PT_NOTE program headers has actual ELF note segment
> + * size in its p_memsz member.
> + */
> +static int __init get_note_number_and_size_elf64(const Elf64_Ehdr *ehdr_ptr,
> +						 int *nr_ptnote, u64 *sz_ptnote)
> +{
> +	int i;
> +	Elf64_Phdr *phdr_ptr;
> +
> +	*nr_ptnote = *sz_ptnote = 0;
> +
> +	phdr_ptr = (Elf64_Phdr *)(ehdr_ptr + 1);
> +	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> +		if (phdr_ptr->p_type != PT_NOTE)
> +			continue;
> +		*nr_ptnote += 1;
> +		*sz_ptnote += phdr_ptr->p_memsz;
>  	}
>  
> +	return 0;
> +}
> +
> +/**
> + * copy_notes_elf64 - copy ELF note segments in a given buffer
> + *
> + * @ehdr_ptr: ELF header
> + * @notes_buf: buffer into which ELF note segments are copied
> + *
> + * This function is used to copy ELF note segment in the 1st kernel
> + * into the buffer @notes_buf in the 2nd kernel. It is assumed that
> + * size of the buffer @notes_buf is equal to or larger than sum of the
> + * real ELF note segment headers and data.
> + *
> + * It is assumed that program headers with PT_NOTE type pointed to by
> + * @ehdr_ptr has already been updated by update_note_header_size_elf64
> + * and each of PT_NOTE program headers has actual ELF note segment
> + * size in its p_memsz member.
> + */
> +static int __init copy_notes_elf64(const Elf64_Ehdr *ehdr_ptr, char *notes_buf)
> +{
> +	int i, rc=0;
> +	Elf64_Phdr *phdr_ptr;
> +
> +	phdr_ptr = (Elf64_Phdr*)(ehdr_ptr + 1);
> +
> +	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> +		u64 offset;
> +		if (phdr_ptr->p_type != PT_NOTE)
> +			continue;
> +		offset = phdr_ptr->p_offset;
> +		rc = read_from_oldmem(notes_buf, phdr_ptr->p_memsz, &offset, 0);
> +		if (rc < 0)
> +			return rc;
> +		notes_buf += phdr_ptr->p_memsz;
> +	}
> +
> +	return 0;
> +}
> +
> +/* Merges all the PT_NOTE headers into one. */
> +static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
> +					   char **notes_buf, size_t *notes_sz)
> +{
> +	int i, nr_ptnote=0, rc=0;
> +	char *tmp;
> +	Elf64_Ehdr *ehdr_ptr;
> +	Elf64_Phdr phdr;
> +	u64 phdr_sz = 0, note_off;
> +
> +	ehdr_ptr = (Elf64_Ehdr *)elfptr;
> +
> +	rc = update_note_header_size_elf64(ehdr_ptr);
> +	if (rc < 0)
> +		return rc;
> +
> +	rc = get_note_number_and_size_elf64(ehdr_ptr, &nr_ptnote, &phdr_sz);
> +	if (rc < 0)
> +		return rc;
> +
> +	*notes_sz = roundup(phdr_sz, PAGE_SIZE);
> +	*notes_buf = vzalloc(*notes_sz);
> +	if (!*notes_buf)
> +		return -ENOMEM;
> +
> +	rc = copy_notes_elf64(ehdr_ptr, *notes_buf);
> +	if (rc < 0)
> +		return rc;
> +
>  	/* Prepare merged PT_NOTE program header. */
>  	phdr.p_type    = PT_NOTE;
>  	phdr.p_flags   = 0;
>  	note_off = sizeof(Elf64_Ehdr) +
>  			(ehdr_ptr->e_phnum - nr_ptnote +1) * sizeof(Elf64_Phdr);
> -	phdr.p_offset  = note_off;
> +	phdr.p_offset  = roundup(note_off, PAGE_SIZE);
>  	phdr.p_vaddr   = phdr.p_paddr = 0;
>  	phdr.p_filesz  = phdr.p_memsz = phdr_sz;
>  	phdr.p_align   = 0;
> @@ -304,27 +423,27 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  	return 0;
>  }
>  
> -/* Merges all the PT_NOTE headers into one. */
> -static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
> -						struct list_head *vc_list)
> +/**
> + * update_note_header_size_elf32 - update p_memsz member of each PT_NOTE entry
> + *
> + * @ehdr_ptr: ELF header
> + *
> + * This function updates p_memsz member of each PT_NOTE entry in the
> + * program header table pointed to by @ehdr_ptr to real size of ELF
> + * note segment.
> + */
> +static int __init update_note_header_size_elf32(const Elf32_Ehdr *ehdr_ptr)
>  {
> -	int i, nr_ptnote=0, rc=0;
> -	char *tmp;
> -	Elf32_Ehdr *ehdr_ptr;
> -	Elf32_Phdr phdr, *phdr_ptr;
> +	int i, rc=0;
> +	Elf32_Phdr *phdr_ptr;
>  	Elf32_Nhdr *nhdr_ptr;
> -	u64 phdr_sz = 0, note_off;
>  
> -	ehdr_ptr = (Elf32_Ehdr *)elfptr;
> -	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr));
> +	phdr_ptr = (Elf32_Phdr *)(ehdr_ptr + 1);
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> -		int j;
>  		void *notes_section;
> -		struct vmcore *new;
>  		u64 offset, max_sz, sz, real_sz = 0;
>  		if (phdr_ptr->p_type != PT_NOTE)
>  			continue;
> -		nr_ptnote++;
>  		max_sz = phdr_ptr->p_memsz;
>  		offset = phdr_ptr->p_offset;
>  		notes_section = kmalloc(max_sz, GFP_KERNEL);
> @@ -336,7 +455,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>  			return rc;
>  		}
>  		nhdr_ptr = notes_section;
> -		for (j = 0; j < max_sz; j += sz) {
> +		while (real_sz < max_sz) {
>  			if (nhdr_ptr->n_namesz == 0)
>  				break;
>  			sz = sizeof(Elf32_Nhdr) +
> @@ -345,26 +464,122 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>  			real_sz += sz;
>  			nhdr_ptr = (Elf32_Nhdr*)((char*)nhdr_ptr + sz);
>  		}
> -
> -		/* Add this contiguous chunk of notes section to vmcore list.*/
> -		new = get_new_element();
> -		if (!new) {
> -			kfree(notes_section);
> -			return -ENOMEM;
> -		}
> -		new->paddr = phdr_ptr->p_offset;
> -		new->size = real_sz;
> -		list_add_tail(&new->list, vc_list);
> -		phdr_sz += real_sz;
>  		kfree(notes_section);
> +		phdr_ptr->p_memsz = real_sz;
> +	}
> +
> +	return 0;
> +}
> +
> +/**
> + * get_note_number_and_size_elf32 - get the number of PT_NOTE program
> + * headers and sum of real size of their ELF note segment headers and
> + * data.
> + *
> + * @ehdr_ptr: ELF header
> + * @nr_ptnote: buffer for the number of PT_NOTE program headers
> + * @sz_ptnote: buffer for size of unique PT_NOTE program header
> + *
> + * This function is used to merge multiple PT_NOTE program headers
> + * into a unique single one. The resulting unique entry will have
> + * @sz_ptnote in its phdr->p_mem.
> + *
> + * It is assumed that program headers with PT_NOTE type pointed to by
> + * @ehdr_ptr has already been updated by update_note_header_size_elf32
> + * and each of PT_NOTE program headers has actual ELF note segment
> + * size in its p_memsz member.
> + */
> +static int __init get_note_number_and_size_elf32(const Elf32_Ehdr *ehdr_ptr,
> +						 int *nr_ptnote, u64 *sz_ptnote)
> +{
> +	int i;
> +	Elf32_Phdr *phdr_ptr;
> +
> +	*nr_ptnote = *sz_ptnote = 0;
> +
> +	phdr_ptr = (Elf32_Phdr *)(ehdr_ptr + 1);
> +	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> +		if (phdr_ptr->p_type != PT_NOTE)
> +			continue;
> +		*nr_ptnote += 1;
> +		*sz_ptnote += phdr_ptr->p_memsz;
>  	}
>  
> +	return 0;
> +}
> +
> +/**
> + * copy_notes_elf32 - copy ELF note segments in a given buffer
> + *
> + * @ehdr_ptr: ELF header
> + * @notes_buf: buffer into which ELF note segments are copied
> + *
> + * This function is used to copy ELF note segment in the 1st kernel
> + * into the buffer @notes_buf in the 2nd kernel. It is assumed that
> + * size of the buffer @notes_buf is equal to or larger than sum of the
> + * real ELF note segment headers and data.
> + *
> + * It is assumed that program headers with PT_NOTE type pointed to by
> + * @ehdr_ptr has already been updated by update_note_header_size_elf32
> + * and each of PT_NOTE program headers has actual ELF note segment
> + * size in its p_memsz member.
> + */
> +static int __init copy_notes_elf32(const Elf32_Ehdr *ehdr_ptr, char *notes_buf)
> +{
> +	int i, rc=0;
> +	Elf32_Phdr *phdr_ptr;
> +
> +	phdr_ptr = (Elf32_Phdr*)(ehdr_ptr + 1);
> +
> +	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> +		u64 offset;
> +		if (phdr_ptr->p_type != PT_NOTE)
> +			continue;
> +		offset = phdr_ptr->p_offset;
> +		rc = read_from_oldmem(notes_buf, phdr_ptr->p_memsz, &offset, 0);
> +		if (rc < 0)
> +			return rc;
> +		notes_buf += phdr_ptr->p_memsz;
> +	}
> +
> +	return 0;
> +}
> +
> +/* Merges all the PT_NOTE headers into one. */
> +static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
> +					   char **notes_buf, size_t *notes_sz)
> +{
> +	int i, nr_ptnote=0, rc=0;
> +	char *tmp;
> +	Elf32_Ehdr *ehdr_ptr;
> +	Elf32_Phdr phdr;
> +	u64 phdr_sz = 0, note_off;
> +
> +	ehdr_ptr = (Elf32_Ehdr *)elfptr;
> +
> +	rc = update_note_header_size_elf32(ehdr_ptr);
> +	if (rc < 0)
> +		return rc;
> +
> +	rc = get_note_number_and_size_elf32(ehdr_ptr, &nr_ptnote, &phdr_sz);
> +	if (rc < 0)
> +		return rc;
> +
> +	*notes_sz = roundup(phdr_sz, PAGE_SIZE);
> +	*notes_buf = vzalloc(*notes_sz);
> +	if (!*notes_buf)
> +		return -ENOMEM;
> +
> +	rc = copy_notes_elf32(ehdr_ptr, *notes_buf);
> +	if (rc < 0)
> +		return rc;
> +
>  	/* Prepare merged PT_NOTE program header. */
>  	phdr.p_type    = PT_NOTE;
>  	phdr.p_flags   = 0;
>  	note_off = sizeof(Elf32_Ehdr) +
>  			(ehdr_ptr->e_phnum - nr_ptnote +1) * sizeof(Elf32_Phdr);
> -	phdr.p_offset  = note_off;
> +	phdr.p_offset  = roundup(note_off, PAGE_SIZE);
>  	phdr.p_vaddr   = phdr.p_paddr = 0;
>  	phdr.p_filesz  = phdr.p_memsz = phdr_sz;
>  	phdr.p_align   = 0;
> @@ -391,6 +606,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>   * the new offset fields of exported program headers. */
>  static int __init process_ptload_program_headers_elf64(char *elfptr,
>  						size_t elfsz,
> +						size_t elfnotes_sz,
>  						struct list_head *vc_list)
>  {
>  	int i;
> @@ -402,9 +618,8 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
>  	ehdr_ptr = (Elf64_Ehdr *)elfptr;
>  	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr)); /* PT_NOTE hdr */
>  
> -	/* First program header is PT_NOTE header. */
> -	vmcore_off = elfsz +
> -			phdr_ptr->p_memsz; /* Note sections */
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore_off = elfsz + elfnotes_sz;
>  
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
>  		u64 paddr, start, end, size;
> @@ -434,6 +649,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
>  
>  static int __init process_ptload_program_headers_elf32(char *elfptr,
>  						size_t elfsz,
> +						size_t elfnotes_sz,
>  						struct list_head *vc_list)
>  {
>  	int i;
> @@ -445,9 +661,8 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
>  	ehdr_ptr = (Elf32_Ehdr *)elfptr;
>  	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
>  
> -	/* First program header is PT_NOTE header. */
> -	vmcore_off = elfsz +
> -			phdr_ptr->p_memsz; /* Note sections */
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore_off = elfsz + elfnotes_sz;
>  
>  	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
>  		u64 paddr, start, end, size;
> @@ -476,14 +691,14 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
>  }
>  
>  /* Sets offset fields of vmcore elements. */
> -static void __init set_vmcore_list_offsets(size_t elfsz,
> +static void __init set_vmcore_list_offsets(size_t elfsz, size_t elfnotes_sz,
>  					   struct list_head *vc_list)
>  {
>  	loff_t vmcore_off;
>  	struct vmcore *m;
>  
> -	/* Skip Elf header and program headers. */
> -	vmcore_off = elfsz;
> +	/* Skip Elf header, program headers and Elf note segment. */
> +	vmcore_off = elfsz + elfnotes_sz;
>  
>  	list_for_each_entry(m, vc_list, list) {
>  		m->offset = vmcore_off;
> @@ -534,20 +749,22 @@ static int __init parse_crash_elf64_headers(void)
>  	}
>  
>  	/* Merge all PT_NOTE headers into one. */
> -	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
> +	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz,
> +				      &elfnotes_buf, &elfnotes_sz);
>  	if (rc) {
>  		free_pages((unsigned long)elfcorebuf,
>  			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  	rc = process_ptload_program_headers_elf64(elfcorebuf, elfcorebuf_sz,
> -							&vmcore_list);
> +						  elfnotes_sz,
> +						  &vmcore_list);
>  	if (rc) {
>  		free_pages((unsigned long)elfcorebuf,
>  			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
> -	set_vmcore_list_offsets(elfcorebuf_sz, &vmcore_list);
> +	set_vmcore_list_offsets(elfcorebuf_sz, elfnotes_sz, &vmcore_list);
>  	return 0;
>  }
>  
> @@ -594,20 +811,22 @@ static int __init parse_crash_elf32_headers(void)
>  	}
>  
>  	/* Merge all PT_NOTE headers into one. */
> -	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
> +	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz,
> +				      &elfnotes_buf, &elfnotes_sz);
>  	if (rc) {
>  		free_pages((unsigned long)elfcorebuf,
>  			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
>  	rc = process_ptload_program_headers_elf32(elfcorebuf, elfcorebuf_sz,
> -								&vmcore_list);
> +						  elfnotes_sz,
> +						  &vmcore_list);
>  	if (rc) {
>  		free_pages((unsigned long)elfcorebuf,
>  			   get_order(elfcorebuf_sz_orig));
>  		return rc;
>  	}
> -	set_vmcore_list_offsets(elfcorebuf_sz, &vmcore_list);
> +	set_vmcore_list_offsets(elfcorebuf_sz, elfnotes_sz, &vmcore_list);
>  	return 0;
>  }
>  
> @@ -686,6 +905,8 @@ void vmcore_cleanup(void)
>  		list_del(&m->list);
>  		kfree(m);
>  	}
> +	vfree(elfnotes_buf);
> +	elfnotes_buf = NULL;
>  	free_pages((unsigned long)elfcorebuf,
>  		   get_order(elfcorebuf_sz_orig));
>  	elfcorebuf = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
