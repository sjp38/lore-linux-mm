Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f44.google.com (mail-vk0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 632696B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 10:23:34 -0500 (EST)
Received: by vkas68 with SMTP id s68so7548642vka.2
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 07:23:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o135si3177524vkf.107.2015.11.17.07.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 07:23:33 -0800 (PST)
Date: Tue, 17 Nov 2015 17:19:28 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: fix incorrect behavior when process virtual
	address space limit is exceeded
Message-ID: <20151117161928.GA9611@redhat.com>
References: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/16, Piotr Kwapulinski wrote:
>
> @@ -1551,7 +1552,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  		 * MAP_FIXED may remove pages of mappings that intersects with
>  		 * requested mapping. Account for the pages it would unmap.
>  		 */
> -		if (!(vm_flags & MAP_FIXED))
> +		if (!(flags & MAP_FIXED))
>  			return -ENOMEM;

Agree, "vm_flags & MAP_FIXED" makes no sense and just wrong...

Can't we simply remove this check? Afaics it only helps to avoid
count_vma_pages_range() in the unlikely case when may_expand_vm() fails.
And without MAP_FIXED count_vma_pages_range() should be cheap,
find_vma_intersection() should fail.

And afaics arch/tile/mm/elf.c can use do_mmap(MAP_FIXED ...) rather than
mmap_region(), it can be changed by a separate patch. In this case we can
unexport mmap_region().


OTOH, I won't insist, this patch looks fine to me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
