Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2F10F6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:19:18 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so15973613pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:19:17 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id rf10si2314984pab.42.2015.07.24.09.19.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 09:19:17 -0700 (PDT)
Message-ID: <55B2655B.4040001@oracle.com>
Date: Fri, 24 Jul 2015 09:18:35 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v5 PATCH 8/9] hugetlbfs: add hugetlbfs_fallocate()
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com> <1435019919-29225-9-git-send-email-mike.kravetz@oracle.com> <20150724062533.GA4622@dhcp22.suse.cz>
In-Reply-To: <20150724062533.GA4622@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 07/23/2015 11:25 PM, Michal Hocko wrote:
> I hope this is the current version of the pathc - I somehow got lost in
> last submissions where the discussion happens in v4 thread. This version
> seems to have the same issue:

Yes, Michal this issue exists in the version put into mmotm and was
noticed by kbuild test robot and Stephen in linux-next build.

Your patch below is the most obvious.  Thanks!  However, is this
the preferred method of handling this type of issue?  Is it
preferred to create wrappers for the code which handles numa
policy?  Then there could be two versions of the wrapper:  one
if CONFIG_NUMA is defined and one (a no-op) if not.  I am happy
with either, but am a relative newbie in this area so am looking
for a little guidance.

-- 
Mike Kravetz

> ---
>  From 04c37a979c5ce8cd39d3243e4e2c12905e4f1e6e Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 24 Jul 2015 08:14:32 +0200
> Subject: [PATCH] mmotm:
>   hugetlbfs-new-huge_add_to_page_cache-helper-routine-fix
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
>
> hugetlbfs_fallocate relies on CONFIG_NUMA and fails to compile otherwise.
> This just makes the code compile but it seems it begs for a better solution.
>
> fs/hugetlbfs/inode.c: In function a??hugetlbfs_fallocatea??:
> fs/hugetlbfs/inode.c:578:13: error: a??struct vm_area_structa?? has no member named a??vm_policya??
>     pseudo_vma.vm_policy =
>               ^
> fs/hugetlbfs/inode.c:579:4: error: implicit declaration of function a??mpol_shared_policy_lookupa?? [-Werror=implicit-function-declaration]
>      mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>      ^
> fs/hugetlbfs/inode.c:595:28: error: a??struct vm_area_structa?? has no member named a??vm_policya??
>      mpol_cond_put(pseudo_vma.vm_policy);
>                              ^
> fs/hugetlbfs/inode.c:601:27: error: a??struct vm_area_structa?? has no member named a??vm_policya??
>     mpol_cond_put(pseudo_vma.vm_policy);
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   fs/hugetlbfs/inode.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index d977cae89d29..dfca09218d77 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -575,9 +575,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>   		}
>
>   		/* Get policy based on index */
> +#ifdef CONFIG_NUMA
>   		pseudo_vma.vm_policy =
>   			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>   							index);
> +#endif
>
>   		/* addr is the offset within the file (zero based) */
>   		addr = index * hpage_size;
> @@ -592,13 +594,17 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>   		if (page) {
>   			put_page(page);
>   			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +#ifdef CONFIG_NUMA
>   			mpol_cond_put(pseudo_vma.vm_policy);
> +#endif
>   			continue;
>   		}
>
>   		/* Allocate page and add to page cache */
>   		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
> +#ifdef CONFIG_NUMA
>   		mpol_cond_put(pseudo_vma.vm_policy);
> +#endif
>   		if (IS_ERR(page)) {
>   			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>   			error = PTR_ERR(page);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
