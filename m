Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2KFZYHj017834
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 10:35:34 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2KFZOOM171794
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 10:35:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2KFZNWa024486
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 10:35:24 -0500
Subject: Re: [patch] hugetlb strict commit accounting - v3
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <200603100314.k2A3Evg28313@unix-os.sc.intel.com>
References: <200603100314.k2A3Evg28313@unix-os.sc.intel.com>
Content-Type: text/plain
Date: Mon, 20 Mar 2006 09:35:21 -0600
Message-Id: <1142868921.14508.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 19:14 -0800, Chen, Kenneth W wrote:
> @@ -98,6 +98,12 @@ struct page *alloc_huge_page(struct vm_a
>  	int i;
>  
>  	spin_lock(&hugetlb_lock);
> +	if (vma->vm_flags & VM_MAYSHARE)
> +		resv_huge_pages--;
> +	else if (free_huge_pages <= resv_huge_pages) {
> +		spin_unlock(&hugetlb_lock);
> +		return NULL;
> +	}
>  	page = dequeue_huge_page(vma, addr);
>  	if (!page) {
>  		spin_unlock(&hugetlb_lock);

Unfortunately this will break down when two or more threads race to
allocate the same page. You end up with a double-decrement of
resv_huge_pages even though only one thread will win the race.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
