Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 28E826B0047
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:20:28 -0500 (EST)
Received: by pvh11 with SMTP id 11so1619224pvh.14
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 08:20:26 -0800 (PST)
Subject: [PATCH] kvm : remove redundant initialization of page->private
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Mar 2010 01:20:19 +0900
Message-ID: <1268065219.1254.12.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>, Avi Kivity <avi@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-08 at 17:33 +0800, Huang Shijie wrote:
> The  prep_new_page() will call set_page_private(page, 0) to initiate
> the page.
> 
> So the code is redundant.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/shmem.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index eef4ebe..dde4363 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -433,8 +433,6 @@ static swp_entry_t *shmem_swp_alloc(struct shmem_inode_info *info, unsigned long
>  
>  		spin_unlock(&info->lock);
>  		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping));
> -		if (page)
> -			set_page_private(page, 0);
>  		spin_lock(&info->lock);
>  
>  		if (!page) {

And I found another place while I review the code.

>From e64322cde914e43d080d8f3be6f72459d809a934 Mon Sep 17 00:00:00 2001
From: Minchan Kim <barrios@barrios-desktop.(none)>
Date: Tue, 9 Mar 2010 01:09:56 +0900
Subject: [PATCH] kvm : remove redundant initialization of page->private.

The prep_new_page() in page allocator calls set_page_private(page, 0).
So we don't need to reinitialize private of page.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Avi Kivity <avi@redhat.com>
---
 arch/x86/kvm/mmu.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 741373e..9851d0e 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -326,7 +326,6 @@ static int mmu_topup_memory_cache_page(struct
kvm_mmu_memory_cache *cache,
 		page = alloc_page(GFP_KERNEL);
 		if (!page)
 			return -ENOMEM;
-		set_page_private(page, 0);
 		cache->objects[cache->nobjs++] = page_address(page);
 	}
 	return 0;
-- 
1.6.5



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
