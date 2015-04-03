Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 104136B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 13:33:18 -0400 (EDT)
Received: by wiun10 with SMTP id n10so122677wiu.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 10:33:17 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id ek3si9748961wid.2.2015.04.03.10.33.16
        for <linux-mm@kvack.org>;
        Fri, 03 Apr 2015 10:33:16 -0700 (PDT)
Date: Fri, 3 Apr 2015 20:33:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/memory: print also a_ops->readpage in print_bad_pte
Message-ID: <20150403173312.GA29118@node.dhcp.inet.fi>
References: <20150403171818.22742.92919.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150403171818.22742.92919.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org

On Fri, Apr 03, 2015 at 08:18:18PM +0300, Konstantin Khlebnikov wrote:
> A lot of filesystems use generic_file_mmap() and filemap_fault(),
> f_op->mmap and vm_ops->fault aren't enough to identify filesystem.
> 
> This prints file name, vm_ops->fault, f_op->mmap and a_ops->readpage
> (which is almost always implemented and filesystem-specific).
> 
> Example:
> 
> [   23.676410] BUG: Bad page map in process sh  pte:1b7e6025 pmd:19bbd067
> [   23.676887] page:ffffea00006df980 count:4 mapcount:1 mapping:ffff8800196426c0 index:0x97
> [   23.677481] flags: 0x10000000000000c(referenced|uptodate)
> [   23.677896] page dumped because: bad pte
> [   23.678205] addr:00007f52fcb17000 vm_flags:00000075 anon_vma:          (null) mapping:ffff8800196426c0 index:97
> [   23.678922] file:libc-2.19.so fault:filemap_fault mmap:generic_file_readonly_mmap readpage:v9fs_vfs_readpage
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  mm/memory.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 411144f977b1..ea868eea0c88 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -690,12 +690,12 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>  	/*
>  	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
>  	 */
> -	if (vma->vm_ops)
> -		printk(KERN_ALERT "vma->vm_ops->fault: %pSR\n",
> -		       vma->vm_ops->fault);
> -	if (vma->vm_file)
> -		printk(KERN_ALERT "vma->vm_file->f_op->mmap: %pSR\n",
> -		       vma->vm_file->f_op->mmap);
> +	printk(KERN_ALERT

pr_alert() ?

Otherwise,

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

It would be nice to patch dump_vma() to display this information too.

> +		"file:%pD fault:%pf mmap:%pf readpage:%pf\n",
> +		vma->vm_file,
> +		vma->vm_ops ? vma->vm_ops->fault : NULL,
> +		vma->vm_file ? vma->vm_file->f_op->mmap : NULL,
> +		mapping ? mapping->a_ops->readpage : NULL);
>  	dump_stack();
>  	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
