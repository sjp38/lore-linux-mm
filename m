Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE326B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:54:11 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 123so207051391pgj.4
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:54:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 9si7292006pfc.500.2017.07.26.00.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 00:54:10 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6Q7rjLG102934
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:54:09 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bxnxuu0au-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:54:09 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 26 Jul 2017 08:54:07 +0100
Date: Wed, 26 Jul 2017 10:54:00 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH 1/2] userfaultfd: Add feature to request for a
 signal delivery
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
Message-Id: <20170726075359.GB32369@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue, Jul 25, 2017 at 12:47:41AM -0400, Prakash Sangappa wrote:
> In some cases, userfaultfd mechanism should just deliver a SIGBUS signal
> to the faulting process, instead of the page-fault event. Dealing with
> page-fault event using a monitor thread can be an overhead in these
> cases. For example applications like the database could use the signaling
> mechanism for robustness purpose.
> 
> Database uses hugetlbfs for performance reason. Files on hugetlbfs
> filesystem are created and huge pages allocated using fallocate() API.
> Pages are deallocated/freed using fallocate() hole punching support.
> These files are mmapped and accessed by many processes as shared memory.
> The database keeps track of which offsets in the hugetlbfs file have
> pages allocated.
> 
> Any access to mapped address over holes in the file, which can occur due
> to bugs in the application, is considered invalid and expect the process
> to simply receive a SIGBUS.  However, currently when a hole in the file is
> accessed via the mapped address, kernel/mm attempts to automatically
> allocate a page at page fault time, resulting in implicitly filling the
> hole in the file. This may not be the desired behavior for applications
> like the database that want to explicitly manage page allocations of
> hugetlbfs files.
> 
> Using userfaultfd mechanism with this support to get a signal, database
> application can prevent pages from being allocated implicitly when
> processes access mapped address over holes in the file.
> 
> This patch adds UFFD_FEATURE_SIGBUS feature to userfaultfd mechnism to
> request for a SIGBUS signal.
> 
> See following for previous discussion about the database requirement
> leading to this proposal as suggested by Andrea.
> 
> http://www.spinics.net/lists/linux-mm/msg129224.html
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  fs/userfaultfd.c                 |    3 +++
>  include/uapi/linux/userfaultfd.h |   10 +++++++++-
>  2 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 1d622f2..0bbe7df 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -371,6 +371,9 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  	VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
>  	VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));
> 
> +	if (ctx->features & UFFD_FEATURE_SIGBUS)
> +		goto out;
> +
>  	/*
>  	 * If it's already released don't get it. This avoids to loop
>  	 * in __get_user_pages if userfaultfd_release waits on the
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 3b05953..d39d5db 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -23,7 +23,8 @@
>  			   UFFD_FEATURE_EVENT_REMOVE |	\
>  			   UFFD_FEATURE_EVENT_UNMAP |		\
>  			   UFFD_FEATURE_MISSING_HUGETLBFS |	\
> -			   UFFD_FEATURE_MISSING_SHMEM)
> +			   UFFD_FEATURE_MISSING_SHMEM |		\
> +			   UFFD_FEATURE_SIGBUS)
>  #define UFFD_API_IOCTLS				\
>  	((__u64)1 << _UFFDIO_REGISTER |		\
>  	 (__u64)1 << _UFFDIO_UNREGISTER |	\
> @@ -153,6 +154,12 @@ struct uffdio_api {
>  	 * UFFD_FEATURE_MISSING_SHMEM works the same as
>  	 * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
>  	 * (i.e. tmpfs and other shmem based APIs).
> +	 *
> +	 * UFFD_FEATURE_SIGBUS feature means no page-fault
> +	 * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
> +	 * a SIGBUS signal will be sent to the faulting process.
> +	 * The application process can enable this behavior by adding
> +	 * it to uffdio_api.features.
>  	 */
>  #define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
>  #define UFFD_FEATURE_EVENT_FORK			(1<<1)
> @@ -161,6 +168,7 @@ struct uffdio_api {
>  #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
>  #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
>  #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
> +#define UFFD_FEATURE_SIGBUS			(1<<7)
>  	__u64 features;
> 
>  	__u64 ioctls;
> -- 
> 1.7.1
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
