Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 398596B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 17:14:06 -0500 (EST)
Received: by wmec201 with SMTP id c201so1875944wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:14:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bt17si21983247wjb.137.2015.11.23.14.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 14:14:05 -0800 (PST)
Date: Mon, 23 Nov 2015 14:14:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm/mmap.c: remove incorrect MAP_FIXED flag
 comparison from mmap_region
Message-Id: <20151123141401.0ad7e291be4d62ec83de7101@linux-foundation.org>
In-Reply-To: <1448300202-5004-1-git-send-email-kwapulinski.piotr@gmail.com>
References: <20151123081946.GA21050@dhcp22.suse.cz>
	<1448300202-5004-1-git-send-email-kwapulinski.piotr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mhocko@suse.com, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 Nov 2015 18:36:42 +0100 Piotr Kwapulinski <kwapulinski.piotr@gmail.com> wrote:

> The following flag comparison in mmap_region makes no sense:
> 
> if (!(vm_flags & MAP_FIXED))
>     return -ENOMEM;
> 
> The condition is always false and thus the above "return -ENOMEM" is never
> executed. The vm_flags must not be compared with MAP_FIXED flag.
> The vm_flags may only be compared with VM_* flags.
> MAP_FIXED has the same value as VM_MAYREAD.
> Hitting the rlimit is a slow path and find_vma_intersection should realize
> that there is no overlapping VMA for !MAP_FIXED case pretty quickly.
> 
> Remove the code that makes no sense.
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1551,9 +1551,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  		 * MAP_FIXED may remove pages of mappings that intersects with
>  		 * requested mapping. Account for the pages it would unmap.
>  		 */
> -		if (!(vm_flags & MAP_FIXED))
> -			return -ENOMEM;
> -
>  		nr_pages = count_vma_pages_range(mm, addr, addr + len);
>  
>  		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))

Did you intend to retain the stale comment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
