Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 748B98E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 10:23:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so33984949edb.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 07:23:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m22si1157980edj.434.2019.01.03.07.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 07:23:50 -0800 (PST)
Date: Thu, 3 Jan 2019 16:23:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm/vmalloc: pass VM_USERMAP flags directly to
 __vmalloc_node_range()
Message-ID: <20190103152348.GS31793@dhcp22.suse.cz>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-4-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103145954.16942-4-rpenyaev@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 15:59:54, Roman Penyaev wrote:
> vmalloc_user*() calls differ from normal vmalloc() only in that they
> set VM_USERMAP flags for the area.  During the whole history of
> vmalloc.c changes now it is possible simply to pass VM_USERMAP flags
> directly to __vmalloc_node_range() call instead of finding the area
> (which obviously takes time) after the allocation.

Yes, this looks correct and a nice cleanup

> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/vmalloc.c | 30 ++++++++----------------------
>  1 file changed, 8 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index dc6a62bca503..83fa4c642f5e 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1865,18 +1865,10 @@ EXPORT_SYMBOL(vzalloc);
>   */
>  void *vmalloc_user(unsigned long size)
>  {
> -	struct vm_struct *area;
> -	void *ret;
> -
> -	ret = __vmalloc_node(size, SHMLBA,
> -			     GFP_KERNEL | __GFP_ZERO,
> -			     PAGE_KERNEL, NUMA_NO_NODE,
> -			     __builtin_return_address(0));
> -	if (ret) {
> -		area = find_vm_area(ret);
> -		area->flags |= VM_USERMAP;
> -	}
> -	return ret;
> +	return __vmalloc_node_range(size, SHMLBA,  VMALLOC_START, VMALLOC_END,
> +				    GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL,
> +				    VM_USERMAP, NUMA_NO_NODE,
> +				    __builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(vmalloc_user);
>  
> @@ -1970,16 +1962,10 @@ EXPORT_SYMBOL(vmalloc_32);
>   */
>  void *vmalloc_32_user(unsigned long size)
>  {
> -	struct vm_struct *area;
> -	void *ret;
> -
> -	ret = __vmalloc_node(size, 1, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
> -			     NUMA_NO_NODE, __builtin_return_address(0));
> -	if (ret) {
> -		area = find_vm_area(ret);
> -		area->flags |= VM_USERMAP;
> -	}
> -	return ret;
> +	return __vmalloc_node_range(size, 1,  VMALLOC_START, VMALLOC_END,
> +				    GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
> +				    VM_USERMAP, NUMA_NO_NODE,
> +				    __builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(vmalloc_32_user);
>  
> -- 
> 2.19.1

-- 
Michal Hocko
SUSE Labs
