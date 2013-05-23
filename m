Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2995D6B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 10:32:37 -0400 (EDT)
Date: Thu, 23 May 2013 10:32:29 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v8 7/9] vmcore: Allow user process to remap ELF note
 segment buffer
Message-ID: <20130523143229.GF2779@redhat.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
 <20130523052536.13864.67507.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130523052536.13864.67507.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, May 23, 2013 at 02:25:36PM +0900, HATAYAMA Daisuke wrote:
> Now ELF note segment has been copied in the buffer on vmalloc
> memory. To allow user process to remap the ELF note segment buffer
> with remap_vmalloc_page, the corresponding VM area object has to have
> VM_USERMAP flag set.
> 
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

Looks good to me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Vivek

> ---
> 
>  fs/proc/vmcore.c |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 937709d..9de4d91 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -375,6 +375,7 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  	Elf64_Ehdr *ehdr_ptr;
>  	Elf64_Phdr phdr;
>  	u64 phdr_sz = 0, note_off;
> +	struct vm_struct *vm;
>  
>  	ehdr_ptr = (Elf64_Ehdr *)elfptr;
>  
> @@ -391,6 +392,12 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
>  	if (!*notes_buf)
>  		return -ENOMEM;
>  
> +	/* Allow users to remap ELF note segment buffer on vmalloc
> +	 * memory using remap_vmalloc_range. */
> +	vm = find_vm_area(*notes_buf);
> +	BUG_ON(!vm);
> +	vm->flags |= VM_USERMAP;
> +
>  	rc = copy_notes_elf64(ehdr_ptr, *notes_buf);
>  	if (rc < 0)
>  		return rc;
> @@ -554,6 +561,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>  	Elf32_Ehdr *ehdr_ptr;
>  	Elf32_Phdr phdr;
>  	u64 phdr_sz = 0, note_off;
> +	struct vm_struct *vm;
>  
>  	ehdr_ptr = (Elf32_Ehdr *)elfptr;
>  
> @@ -570,6 +578,12 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
>  	if (!*notes_buf)
>  		return -ENOMEM;
>  
> +	/* Allow users to remap ELF note segment buffer on vmalloc
> +	 * memory using remap_vmalloc_range. */
> +	vm = find_vm_area(*notes_buf);
> +	BUG_ON(!vm);
> +	vm->flags |= VM_USERMAP;
> +
>  	rc = copy_notes_elf32(ehdr_ptr, *notes_buf);
>  	if (rc < 0)
>  		return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
