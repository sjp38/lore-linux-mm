Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B60466B027B
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:58:18 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so48671160pgd.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:58:18 -0800 (PST)
Received: from out0-149.mail.aliyun.com (out0-149.mail.aliyun.com. [140.205.0.149])
        by mx.google.com with ESMTP id b5si2940323pll.139.2017.01.19.00.58.17
        for <linux-mm@kvack.org>;
        Thu, 19 Jan 2017 00:58:18 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com> <1484814154-1557-3-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1484814154-1557-3-git-send-email-rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] userfaultfd: non-cooperative: add madvise() event for MADV_REMOVE request
Date: Thu, 19 Jan 2017 16:58:14 +0800
Message-ID: <03ae01d27232$2b590030$820b0090$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Rapoport' <rppt@linux.vnet.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>, linux-mm@kvack.org


On Thursday, January 19, 2017 4:23 PM Mike Rapoport wrote: 
> 
> When a page is removed from a shared mapping, the uffd reader should be
> notified, so that it won't attempt to handle #PF events for the removed
> pages.
> We can reuse the UFFD_EVENT_REMOVE because from the uffd monitor point
> of view, the semantices of madvise(MADV_DONTNEED) and madvise(MADV_REMOVE)
> is exactly the same.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/madvise.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index ab5ef14..0012071 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -520,6 +520,7 @@ static long madvise_remove(struct vm_area_struct *vma,
>  	 * mmap_sem.
>  	 */
>  	get_file(f);
> +	userfaultfd_remove(vma, prev, start, end);
>  	up_read(&current->mm->mmap_sem);
>  	error = vfs_fallocate(f,
>  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> --
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
