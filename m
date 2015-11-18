Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6088E6B0267
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 19:52:53 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so26357851pab.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 16:52:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wf3si249210pac.218.2015.11.17.16.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 16:52:52 -0800 (PST)
Date: Tue, 17 Nov 2015 16:52:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mmap.c: remove incorrect MAP_FIXED flag comparison
 from mmap_region
Message-Id: <20151117165251.ccfe80f7007dfc3d0f346cd7@linux-foundation.org>
In-Reply-To: <1447781198-5496-1-git-send-email-kwapulinski.piotr@gmail.com>
References: <20151117161928.GA9611@redhat.com>
	<1447781198-5496-1-git-send-email-kwapulinski.piotr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mhocko@suse.com, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 Nov 2015 18:26:38 +0100 Piotr Kwapulinski <kwapulinski.piotr@gmail.com> wrote:

> The following flag comparison in mmap_region is not fully correct:
> 
> if (!(vm_flags & MAP_FIXED))
> 
> The vm_flags should not be compared with MAP_FIXED (0x10). It is a bit
> confusing. This condition is almost always true since VM_MAYREAD (0x10)
> flag is almost always set by default. This patch removes this condition.
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1547,13 +1547,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
>  		unsigned long nr_pages;
>  
> -		/*
> -		 * MAP_FIXED may remove pages of mappings that intersects with
> -		 * requested mapping. Account for the pages it would unmap.
> -		 */
> -		if (!(vm_flags & MAP_FIXED))
> -			return -ENOMEM;
> -
>  		nr_pages = count_vma_pages_range(mm, addr, addr + len);
>  
>  		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))

That looks simpler.

However the changelog doesn't describe the end-user visible effects of
the bug, as changelogs should always do.  Presumably this is causing
incorrect ENOMEM reporting due to RLIMIT_AS being exceeded, but this
isn't very specific.

So can you please fill in the details here?  Such info is needed when
deciding which kernel version(s) need the fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
