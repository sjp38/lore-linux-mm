Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E565A6B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:17:16 -0400 (EDT)
Date: Thu, 23 May 2013 15:17:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 6/9] vmcore: allocate ELF note segment in the 2nd
 kernel vmalloc memory
Message-Id: <20130523151714.a4096553280794de47d0fdb6@linux-foundation.org>
In-Reply-To: <20130523052530.13864.7616.stgit@localhost6.localdomain6>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052530.13864.7616.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, 23 May 2013 14:25:30 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com> wrote:

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
> ...
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

We have min().

>
> ...
>
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

I think this gets leaked in a number of places.

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

Please review and test:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: vmcore-allocate-elf-note-segment-in-the-2nd-kernel-vmalloc-memory-fix

use min(), fix error-path vzalloc() leaks

Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lisa Mitchell <lisa.mitchell@hp.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/vmcore.c |   16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff -puN fs/proc/vmcore.c~vmcore-allocate-elf-note-segment-in-the-2nd-kernel-vmalloc-memory-fix fs/proc/vmcore.c
--- a/fs/proc/vmcore.c~vmcore-allocate-elf-note-segment-in-the-2nd-kernel-vmalloc-memory-fix
+++ a/fs/proc/vmcore.c
@@ -142,9 +142,7 @@ static ssize_t read_vmcore(struct file *
 
 	/* Read ELF core header */
 	if (*fpos < elfcorebuf_sz) {
-		tsz = elfcorebuf_sz - *fpos;
-		if (buflen < tsz)
-			tsz = buflen;
+		tsz = min(elfcorebuf_sz - (size_t)*fpos, buflen);
 		if (copy_to_user(buffer, elfcorebuf + *fpos, tsz))
 			return -EFAULT;
 		buflen -= tsz;
@@ -161,9 +159,7 @@ static ssize_t read_vmcore(struct file *
 	if (*fpos < elfcorebuf_sz + elfnotes_sz) {
 		void *kaddr;
 
-		tsz = elfcorebuf_sz + elfnotes_sz - *fpos;
-		if (buflen < tsz)
-			tsz = buflen;
+		tsz = min(elfcorebuf_sz + elfnotes_sz - (size_t)*fpos, buflen);
 		kaddr = elfnotes_buf + *fpos - elfcorebuf_sz;
 		if (copy_to_user(buffer, kaddr, tsz))
 			return -EFAULT;
@@ -179,9 +175,7 @@ static ssize_t read_vmcore(struct file *
 
 	list_for_each_entry(m, &vmcore_list, list) {
 		if (*fpos < m->offset + m->size) {
-			tsz = m->offset + m->size - *fpos;
-			if (buflen < tsz)
-				tsz = buflen;
+			tsz = min_t(size_t, m->offset + m->size - *fpos, buflen);
 			start = m->paddr + *fpos - m->offset;
 			tmp = read_from_oldmem(buffer, tsz, &start, 1);
 			if (tmp < 0)
@@ -710,6 +704,8 @@ static void free_elfcorebuf(void)
 {
 	free_pages((unsigned long)elfcorebuf, get_order(elfcorebuf_sz_orig));
 	elfcorebuf = NULL;
+	vfree(elfnotes_buf);
+	elfnotes_buf = NULL;
 }
 
 static int __init parse_crash_elf64_headers(void)
@@ -898,8 +894,6 @@ void vmcore_cleanup(void)
 		list_del(&m->list);
 		kfree(m);
 	}
-	vfree(elfnotes_buf);
-	elfnotes_buf = NULL;
 	free_elfcorebuf();
 }
 EXPORT_SYMBOL_GPL(vmcore_cleanup);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
