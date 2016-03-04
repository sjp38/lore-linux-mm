Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id A6B0A828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 19:44:58 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id rt7so36568770obb.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 16:44:58 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n84si658903oig.111.2016.03.03.16.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 16:44:58 -0800 (PST)
Subject: Re: [PATCH] tmpfs: shmem_fallocate must return ERESTARTSYS
References: <20160304002954.19844.52266.stgit@maxim-thinkpad>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56D8DA86.6020803@oracle.com>
Date: Thu, 3 Mar 2016 16:44:54 -0800
MIME-Version: 1.0
In-Reply-To: <20160304002954.19844.52266.stgit@maxim-thinkpad>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@virtuozzo.com>, hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 03/03/2016 04:30 PM, Maxim Patlasov wrote:
> shmem_fallocate() is restartable, so it can return ERESTARTSYS if
> signal_pending(). Although fallocate(2) manpage permits EINTR,
> the more places use ERESTARTSYS the better.
> 
> Signed-off-by: Maxim Patlasov <mpatlasov@virtuozzo.com>
> ---
>  mm/shmem.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 440e2a7..60e9c8a 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2229,11 +2229,13 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>  		struct page *page;
>  
>  		/*
> -		 * Good, the fallocate(2) manpage permits EINTR: we may have
> -		 * been interrupted because we are using up too much memory.
> +		 * Although fallocate(2) manpage permits EINTR, the more
> +		 * places use ERESTARTSYS the better. If we have been
> +		 * interrupted because we are using up too much memory,
> +		 * oom-killer used fatal signal and we will die anyway.
>  		 */
>  		if (signal_pending(current))
> -			error = -EINTR;
> +			error = -ERESTARTSYS;
>  		else if (shmem_falloc.nr_unswapped > shmem_falloc.nr_falloced)
>  			error = -ENOMEM;
>  		else

I used the shmem fallocate code as a basis for hugetlbfs fallocate.
See, hugetlbfs_fallocate().  Specifically:

		/*
		 * fallocate(2) manpage permits EINTR; we may have been
		 * interrupted because we are using up too much memory.
		 */
		if (signal_pending(current)) {
			error = -EINTR;
			break;
		}

I don't know much about the advantages of changing to ERESTARTSYS.  But,
if it is changed for shmem it should be changed for hugetlbfs as well.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
