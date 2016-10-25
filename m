Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C22176B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 04:56:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so2397721wmy.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 01:56:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jc5si21069137wjb.204.2016.10.25.01.56.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 01:56:31 -0700 (PDT)
Subject: Re: [PATCH v2] shmem: avoid maybe-uninitialized warning
References: <20161024205725.786455-1-arnd@arndb.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <627676b7-a210-cb76-f470-d86ce452a658@suse.cz>
Date: Tue, 25 Oct 2016 10:56:28 +0200
MIME-Version: 1.0
In-Reply-To: <20161024205725.786455-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andreas Gruenbacher <agruenba@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/24/2016 10:57 PM, Arnd Bergmann wrote:
> After enabling -Wmaybe-uninitialized warnings, we get a false-postive
> warning for shmem:
>
> mm/shmem.c: In function a??shmem_getpage_gfpa??:
> include/linux/spinlock.h:332:21: error: a??infoa?? may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> This can be easily avoided, since the correct 'info' pointer is known
> at the time we first enter the function, so we can simply move the
> initialization up. Moving it before the first label avoids the
> warning and lets us remove two later initializations.
>
> Note that the function is so hard to read that it not only confuses
> the compiler, but also most readers and without this patch it could\
> easily break if one of the 'goto's changed.
>
> Link: https://www.spinics.net/lists/kernel/msg2368133.html
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/shmem.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad7813d73ea7..95c4bb690f98 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1537,7 +1537,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	struct mm_struct *fault_mm, int *fault_type)
>  {
>  	struct address_space *mapping = inode->i_mapping;
> -	struct shmem_inode_info *info;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
>  	struct shmem_sb_info *sbinfo;
>  	struct mm_struct *charge_mm;
>  	struct mem_cgroup *memcg;
> @@ -1587,7 +1587,6 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	 * Fast cache lookup did not find it:
>  	 * bring it back from swap or allocate.
>  	 */
> -	info = SHMEM_I(inode);
>  	sbinfo = SHMEM_SB(inode->i_sb);
>  	charge_mm = fault_mm ? : current->mm;
>
> @@ -1835,7 +1834,6 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
>  		put_page(page);
>  	}
>  	if (error == -ENOSPC && !once++) {
> -		info = SHMEM_I(inode);
>  		spin_lock_irq(&info->lock);
>  		shmem_recalc_inode(inode);
>  		spin_unlock_irq(&info->lock);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
