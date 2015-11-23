Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5766B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:19:50 -0500 (EST)
Received: by wmww144 with SMTP id w144so85431220wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 00:19:49 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id c64si17646674wmi.55.2015.11.23.00.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 00:19:49 -0800 (PST)
Received: by wmec201 with SMTP id c201so148306179wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 00:19:48 -0800 (PST)
Date: Mon, 23 Nov 2015 09:19:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm/mmap.c: remove incorrect MAP_FIXED flag
 comparison from mmap_region
Message-ID: <20151123081946.GA21050@dhcp22.suse.cz>
References: <20151118162939.GA1842@home.local>
 <1448037734-4734-1-git-send-email-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448037734-4734-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 20-11-15 17:42:14, Piotr Kwapulinski wrote:
> The following flag comparison in mmap_region makes no sense:
> 
> if (!(vm_flags & MAP_FIXED))
>     return -ENOMEM;
> 
> The condition is always false and thus the above "return -ENOMEM" is never
> executed. The vm_flags must not be compared with MAP_FIXED flag.
> The vm_flags may only be compared with VM_* flags.
> MAP_FIXED has the same value as VM_MAYREAD.
> It has no user visible effect.
> 
> Remove the code that makes no sense.
> 
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

I think this is preferable. Hitting the rlimit is a slow path and
find_vma_intersection should realize that there is no overlapping
VMA for !MAP_FIXED case pretty quickly.

I would prefer this to be in the changelog rather than/in addition to
"It has no user visible effect" which is really vague.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> I made a mistake in a changelog in a previous version of this patch.
> I'm Sorry for the confusion.
> This patch may be considered to be applied only in case the patch
> "[PATCH v2 1/2] mm: fix incorrect behavior when process virtual
> address space limit is exceeded"
> is not going to be accepted.
> 
>  mm/mmap.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2ce04a6..42a8259 100644
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
> -- 
> 2.6.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
