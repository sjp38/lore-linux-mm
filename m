Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEAB86B01FB
	for <linux-mm@kvack.org>; Tue, 11 May 2010 18:09:13 -0400 (EDT)
Date: Tue, 11 May 2010 15:09:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3.1 -mmotm 2/2] memcg: move charge of file pages
Message-Id: <20100511150903.090202ab.akpm@linux-foundation.org>
In-Reply-To: <20100408170858.d7249445.nishimura@mxp.nes.nec.co.jp>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
	<20100408141131.6bf5fd1a.nishimura@mxp.nes.nec.co.jp>
	<20100408154434.0f87bddf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100408170858.d7249445.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 17:08:58 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

>
> ...
>
> This patch adds support for moving charge of file pages, which include normal
> file, tmpfs file and swaps of tmpfs file. It's enabled by setting bit 1 of
> <target cgroup>/memory.move_charge_at_immigrate. Unlike the case of anonymous
> pages, file pages(and swaps) in the range mmapped by the task will be moved even
> if the task hasn't done page fault, i.e. they might not be the task's "RSS",
> but other task's "RSS" that maps the same file. And mapcount of the page is
> ignored(the page can be moved even if page_mapcount(page) > 1). So, conditions
> that the page/swap should be met to be moved is that it must be in the range
> mmapped by the target task and it must be charged to the old cgroup.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> ...
>
> +static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
> +			unsigned long addr, pte_t ptent, swp_entry_t *entry)
> +{
> +	struct page *page = NULL;
> +	struct inode *inode;
> +	struct address_space *mapping;
> +	pgoff_t pgoff;
> +
> +	if (!vma->vm_file) /* anonymous vma */
> +		return NULL;
> +	if (!move_file())
> +		return NULL;
> +
> +	inode = vma->vm_file->f_path.dentry->d_inode;
> +	mapping = vma->vm_file->f_mapping;
> +	if (pte_none(ptent))
> +		pgoff = linear_page_index(vma, addr);
> +	if (pte_file(ptent))
> +		pgoff = pte_to_pgoff(ptent);
> +
> +	/* page is moved even if it's not RSS of this task(page-faulted). */
> +	if (!mapping_cap_swap_backed(mapping)) { /* normal file */
> +		page = find_get_page(mapping, pgoff);
> +	} else { /* shmem/tmpfs file. we should take account of swap too. */
> +		swp_entry_t ent;
> +		mem_cgroup_get_shmem_target(inode, pgoff, &page, &ent);
> +		if (do_swap_account)
> +			entry->val = ent.val;
> +	}
> +
> +	return page;
> +}

mm/memcontrol.c: In function 'is_target_pte_for_mc':
mm/memcontrol.c:4247: warning: 'pgoff' may be used uninitialized in this function

Either this is a real bug, or we can do

--- a/mm/memcontrol.c~a
+++ a/mm/memcontrol.c
@@ -4255,7 +4255,7 @@ static struct page *mc_handle_file_pte(s
 	mapping = vma->vm_file->f_mapping;
 	if (pte_none(ptent))
 		pgoff = linear_page_index(vma, addr);
-	if (pte_file(ptent))
+	else /* pte_file(ptent) is true */
 		pgoff = pte_to_pgoff(ptent);
 
 	/* page is moved even if it's not RSS of this task(page-faulted). */
_

??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
