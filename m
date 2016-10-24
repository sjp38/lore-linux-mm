Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31E8B6B0261
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:22:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f193so35486823wmg.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 09:22:48 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id dd4si16968851wjb.54.2016.10.24.09.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 09:22:46 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o81so10547531wma.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 09:22:46 -0700 (PDT)
Date: Mon, 24 Oct 2016 18:22:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] shmem: avoid maybe-uninitialized warning
Message-ID: <20161024162243.GA13148@dhcp22.suse.cz>
References: <20161024152511.2597880-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161024152511.2597880-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 24-10-16 17:25:03, Arnd Bergmann wrote:
> After enabling -Wmaybe-uninitialized warnings, we get a false-postive
> warning for shmem:
> 
> mm/shmem.c: In function a??shmem_getpage_gfpa??:
> include/linux/spinlock.h:332:21: error: a??infoa?? may be used uninitialized in this function [-Werror=maybe-uninitialized]

Is this really a false positive? If we goto clear and then 
        if (sgp <= SGP_CACHE &&
            ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
                if (alloced) {

we could really take a spinlock on an unitialized variable. But maybe
there is something that prevents from that... Anyway the whole
shmem_getpage_gfp is really hard to follow due to gotos and labels
proliferation.

> This can be easily avoided, since the correct 'info' pointer is known
> at the time we first enter the function, so we can simply move the
> initialization up. Moving it before the first label avoids the
> warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Looks good to me.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/shmem.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad7813d73ea7..69e6777096a3 100644
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
> -- 
> 2.9.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
