Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1BDDC6B0032
	for <linux-mm@kvack.org>; Wed, 22 May 2013 15:22:41 -0400 (EDT)
Date: Wed, 22 May 2013 15:21:22 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v7 6/8] vmcore: allocate ELF note segment in the 2nd
 kernel vmalloc memory
Message-ID: <20130522192122.GE5332@redhat.com>
References: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
 <20130522025606.12215.36133.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130522025606.12215.36133.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Wed, May 22, 2013 at 11:56:06AM +0900, HATAYAMA Daisuke wrote:

[..]
> -/* Merges all the PT_NOTE headers into one. */
> -static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
> -						struct list_head *vc_list)
> +/**
> + * get_note_number_and_size_elf64 - get the number of PT_NOTE program
> + * headers and sum of real size of their ELF note segment headers and
> + * data.
> + *
> + * @ehdr_ptr: ELF header
> + * @nr_ptnotep: buffer for the number of PT_NOTE program headers
> + * @phdr_szp: buffer for size of unique PT_NOTE program header

How about calling them nr_ptnote  and sz_ptnote respectively. Just feels
more readable to me.

[..]
> +static int __init copy_notes_elf64(const Elf64_Ehdr *ehdr_ptr, char *notes_buf)
> +{
> +	int i, rc=0;
> +	Elf64_Phdr *phdr_ptr;
> +	Elf64_Nhdr *nhdr_ptr;
> +	u64 phdr_sz = 0;
> +
> +	phdr_ptr = (Elf64_Phdr*)(ehdr_ptr + 1);
> +
> +	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
> +		int j;
> +		void *notes_section;
> +		u64 offset, max_sz, sz, real_sz = 0;
> +		if (phdr_ptr->p_type != PT_NOTE)
> +			continue;
> +		max_sz = phdr_ptr->p_memsz;
> +		offset = phdr_ptr->p_offset;
> +		notes_section = kmalloc(max_sz, GFP_KERNEL);
> +		if (!notes_section)
>  			return -ENOMEM;
> +		rc = read_from_oldmem(notes_section, max_sz, &offset, 0);
> +		if (rc < 0) {
> +			kfree(notes_section);
> +			return rc;
> +		}
> +		nhdr_ptr = notes_section;
> +		for (j = 0; j < max_sz; j += sz) {
> +			if (nhdr_ptr->n_namesz == 0)
> +				break;
> +			sz = sizeof(Elf64_Nhdr) +
> +				((nhdr_ptr->n_namesz + 3) & ~3) +
> +				((nhdr_ptr->n_descsz + 3) & ~3);
> +			real_sz += sz;
> +			nhdr_ptr = (Elf64_Nhdr*)((char*)nhdr_ptr + sz);
> +		}
> +		offset = phdr_ptr->p_offset;
> +		rc = read_from_oldmem(notes_buf + phdr_sz, real_sz,
> +				      &offset, 0);

We have already copied notes in notes_section. So there is no need to
do read_from_oldmem again.

Also going through notes size multiple times seems unnecessary. How
about writing a function which goes through notes once and updates
the size in PT_NOTE header p_memsz field. And then later
copy_notes_elf64() and get_note_number_and_size_elf64() can simply
make use of it.

Also copy_notes_elf64() does not have to cpy notes temporarily in
notes_section memory in that case.

So how about something like, update_note_header_size().


[..]
> +	vm = find_vm_area(*notes_buf);
> +	BUG_ON(!vm);
> +	vm->flags |= VM_USERMAP;
> +

This code is new and is not related to copying of notes. Can you please
move it into a separate patch with explanation.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
