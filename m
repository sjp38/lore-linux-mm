Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E84FC6B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 10:36:33 -0400 (EDT)
Received: by wijq8 with SMTP id q8so14043185wij.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 07:36:33 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id je1si5499876wic.24.2015.10.16.07.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 07:36:32 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so14179069wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 07:36:31 -0700 (PDT)
Date: Fri, 16 Oct 2015 16:36:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-ID: <20151016143629.GE19597@dhcp22.suse.cz>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
 <20151016131726.GA602@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20151016131726.GA602@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-10-15 16:17:26, Kirill A. Shutemov wrote:
[...]

I've just encountered the same while updating mmotm git tree. Thanks for
the fix. All other configs which I am testing are good as well.

> virt_to_head_page() is defined in <linux/mm.h> but you don't include it,
> and the commit breaks build for me (on v4.3-rc5-mmotm-2015-10-15-15-20).
> 
>   CC      arch/x86/kernel/asm-offsets.s
> In file included from /home/kas/linux/mm/include/linux/swap.h:8:0,
>                  from /home/kas/linux/mm/include/linux/suspend.h:4,
>                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:12:
> /home/kas/linux/mm/include/linux/memcontrol.h: In function a??mem_cgroup_from_kmema??:
> /home/kas/linux/mm/include/linux/memcontrol.h:841:9: error: implicit declaration of function a??virt_to_head_pagea?? [-Werror=implicit-function-declaration]
>   page = virt_to_head_page(ptr);
>          ^
> /home/kas/linux/mm/include/linux/memcontrol.h:841:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
>   page = virt_to_head_page(ptr);
>        ^
> In file included from /home/kas/linux/mm/include/linux/suspend.h:8:0,
>                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:12:
> /home/kas/linux/mm/include/linux/mm.h: At top level:
> /home/kas/linux/mm/include/linux/mm.h:452:28: error: conflicting types for a??virt_to_head_pagea??
>  static inline struct page *virt_to_head_page(const void *x)
>                             ^
> In file included from /home/kas/linux/mm/include/linux/swap.h:8:0,
>                  from /home/kas/linux/mm/include/linux/suspend.h:4,
>                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:12:
> /home/kas/linux/mm/include/linux/memcontrol.h:841:9: note: previous implicit declaration of a??virt_to_head_pagea?? was here
>   page = virt_to_head_page(ptr);
>          ^
> cc1: some warnings being treated as errors
> 
> The patch below fixes it for me (and for allmodconfig on x86-64), but I'm not
> sure if it have any side effects on other configurations.
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 47677acb4516..e8e52e502c20 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -26,6 +26,7 @@
>  #include <linux/page_counter.h>
>  #include <linux/vmpressure.h>
>  #include <linux/eventfd.h>
> +#include <linux/mm.h>
>  #include <linux/mmzone.h>
>  #include <linux/writeback.h>
>  
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
