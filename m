Date: Fri, 11 Jan 2008 01:44:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] fix hugetlbfs quota leak
Message-Id: <20080111014409.004af347.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0801102224o54da2bfbk4a62b0cfe1d35f37@mail.gmail.com>
References: <b040c32a0801102224o54da2bfbk4a62b0cfe1d35f37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008 22:24:12 -0800 "Ken Chen" <kenchen@google.com> wrote:

> In the error path of both shared and private hugetlb page allocation,
> the file system quota is never undone, leading to fs quota leak.
> Patch to fix them up.
> 

Thanks.

> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7224a4f..b2863f3 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -420,6 +420,8 @@ static struct page *alloc_huge_page_private(struct
> vm_area_struct *vma,

Your client is wordwrapping patches.


>  	spin_unlock(&hugetlb_lock);
>  	if (!page)
>  		page = alloc_buddy_huge_page(vma, addr);
> +	if (!page)
> +		hugetlb_put_quota(vma->vm_file->f_mapping, 1);
>  	return page ? page : ERR_PTR(-VM_FAULT_OOM);
>  }

The code was already fairly ugly and inefficient.  Let's improve that
rather than worsening it?

> @@ -1206,8 +1208,10 @@ int hugetlb_reserve_pages(struct inode *inode,
> long from, long to)
>  	if (hugetlb_get_quota(inode->i_mapping, chg))
>  		return -ENOSPC;
>  	ret = hugetlb_acct_memory(chg);
> -	if (ret < 0)
> +	if (ret < 0) {
> +		hugetlb_put_quota(inode->i_mapping, chg);
>  		return ret;
> +	}
>  	region_add(&inode->i_mapping->private_list, from, to);
>  	return 0;
>  }


--- a/mm/hugetlb.c~hugetlbfs-fix-quota-leak
+++ a/mm/hugetlb.c
@@ -418,9 +418,14 @@ static struct page *alloc_huge_page_priv
 	if (free_huge_pages > resv_huge_pages)
 		page = dequeue_huge_page(vma, addr);
 	spin_unlock(&hugetlb_lock);
-	if (!page)
+	if (!page) {
 		page = alloc_buddy_huge_page(vma, addr);
-	return page ? page : ERR_PTR(-VM_FAULT_OOM);
+		if (!page) {
+			hugetlb_put_quota(vma->vm_file->f_mapping, 1);
+			return ERR_PTR(-VM_FAULT_OOM);
+		}
+	}
+	return page;
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
@@ -1206,8 +1211,10 @@ int hugetlb_reserve_pages(struct inode *
 	if (hugetlb_get_quota(inode->i_mapping, chg))
 		return -ENOSPC;
 	ret = hugetlb_acct_memory(chg);
-	if (ret < 0)
+	if (ret < 0) {
+		hugetlb_put_quota(inode->i_mapping, chg);
 		return ret;
+	}
 	region_add(&inode->i_mapping->private_list, from, to);
 	return 0;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
