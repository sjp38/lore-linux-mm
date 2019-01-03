Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7A38E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 10:14:00 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b24so25608069pls.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 07:14:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c191si499116pfg.72.2019.01.03.07.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 07:13:59 -0800 (PST)
Date: Thu, 3 Jan 2019 16:13:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix size check for
 remap_vmalloc_range_partial()
Message-ID: <20190103151357.GR31793@dhcp22.suse.cz>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-2-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103145954.16942-2-rpenyaev@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu 03-01-19 15:59:52, Roman Penyaev wrote:
> area->size can include adjacent guard page but get_vm_area_size()
> returns actual size of the area.
> 
> This fixes possible kernel crash when userspace tries to map area
> on 1 page bigger: size check passes but the following vmalloc_to_page()
> returns NULL on last guard (non-existing) page.

Can this actually happen? I am not really familiar with all the callers
of this API but VM_NO_GUARD is not really used wildly in the kernel.
All I can see is kasan na arm64 which doesn't really seem to use it
for vmalloc.

So is the problem real or this is a mere cleanup?
 
> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 871e41c55e23..2cd24186ba84 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2248,7 +2248,7 @@ int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
>  	if (!(area->flags & VM_USERMAP))
>  		return -EINVAL;
>  
> -	if (kaddr + size > area->addr + area->size)
> +	if (kaddr + size > area->addr + get_vm_area_size(area))
>  		return -EINVAL;
>  
>  	do {
> -- 
> 2.19.1

-- 
Michal Hocko
SUSE Labs
