Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5991D6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 14:28:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 13so246082329pgg.8
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 11:28:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w1si17017359plk.360.2017.07.04.11.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jul 2017 11:28:17 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v64INcHG008377
	for <linux-mm@kvack.org>; Tue, 4 Jul 2017 14:28:16 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bg4yht0eg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jul 2017 14:28:16 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 4 Jul 2017 19:28:13 +0100
Date: Tue, 4 Jul 2017 21:28:07 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v2] userfaultfd: Add feature to request for a signal
 delivery
References: <ff16daf5-7ba0-3dc2-7f73-eb7db8336df7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ff16daf5-7ba0-3dc2-7f73-eb7db8336df7@oracle.com>
Message-Id: <20170704182806.GB4070@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Jun 27, 2017 at 09:08:40AM -0700, Prakash Sangappa wrote:
> Applications like the database use hugetlbfs for performance reason.
> Files on hugetlbfs filesystem are created and huge pages allocated
> using fallocate() API. Pages are deallocated/freed using fallocate() hole
> punching support. These files are mmap'ed and accessed by many
> single threaded processes as shared memory.  The database keeps
> track of which offsets in the hugetlbfs file have pages allocated.
> 
> Any access to mapped address over holes in the file, which can occur due
> to bugs in the application, is considered invalid and expect the process
> to simply receive a SIGBUS.  However, currently when a hole in the file is
> accessed via the mmap'ed address, kernel/mm attempts to automatically
> allocate a page at page fault time, resulting in implicitly filling the
> hole in the file. This may not be the desired behavior for applications
> like the database that want to explicitly manage page allocations of
> hugetlbfs files. The requirement here is for a way to prevent the kernel
> from implicitly allocating a page  to fill holes in hugetbfs file.
> 
> This can be achieved using userfaultfd mechanism to intercept page-fault
> events when mmap'ed address over holes in the file are accessed, and
> prevent kernel from implicitly filling the hole. However, currently using
> userfaultfd would require each of the database processes to use a monitor
> thread and the setup cost associated with it,  is considered an overhead.
> 
> It would be better if userfaultd mechanism could have a way to request
> simply sending a signal,for the robustness use case described above.
> This would not require the use of a monitor thread.
> 
> This patch adds the feature to userfaultfd mechanism to request for a
> SIGBUS signal delivery to the faulting process, instead of the
> page-fault event.
> 
> See following for previous discussion about a different solution
> to the above database requirement, leading to this proposal to enhance
> userfaultfd, as suggested by Andrea.
> 
> http://www.spinics.net/lists/linux-mm/msg129224.html
> 
> Signed-off-by: Prakash <prakash.sangappa@oracle.com>
> ---
>  fs/userfaultfd.c                 |  5 +++++
>  include/uapi/linux/userfaultfd.h | 10 +++++++++-
>  2 files changed, 14 insertions(+), 1 deletion(-)

Apparently your mail client clobbered the white space, can you please
resend with proper formatting?
 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 1d622f2..5686d6d2 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -371,6 +371,11 @@ int handle_userfault(struct vm_fault *vmf, unsigned
> long reason)
>      VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
>      VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));
> 
> +    if (ctx->features & UFFD_FEATURE_SIGBUS) {
> +        goto out;
> +    }

Please remove the curly braces.

> +
>      /*
>       * If it's already released don't get it. This avoids to loop
>       * in __get_user_pages if userfaultfd_release waits on the
> diff --git a/include/uapi/linux/userfaultfd.h
> b/include/uapi/linux/userfaultfd.h
> index 3b05953..d39d5db 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -23,7 +23,8 @@
>                 UFFD_FEATURE_EVENT_REMOVE |    \
>                 UFFD_FEATURE_EVENT_UNMAP |        \
>                 UFFD_FEATURE_MISSING_HUGETLBFS |    \
> -               UFFD_FEATURE_MISSING_SHMEM)
> +               UFFD_FEATURE_MISSING_SHMEM |        \
> +               UFFD_FEATURE_SIGBUS)
>  #define UFFD_API_IOCTLS                \
>      ((__u64)1 << _UFFDIO_REGISTER |        \
>       (__u64)1 << _UFFDIO_UNREGISTER |    \
> @@ -153,6 +154,12 @@ struct uffdio_api {
>       * UFFD_FEATURE_MISSING_SHMEM works the same as
>       * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
>       * (i.e. tmpfs and other shmem based APIs).
> +     *
> +     * UFFD_FEATURE_SIGBUS feature means no page-fault
> +     * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
> +     * a SIGBUS signal will be sent to the faulting process.
> +     * The application process can enable this behavior by adding
> +     * it to uffdio_api.features.

I think that it maybe worth making UFFD_FEATURE_SIGBUS mutually exclusive
with the non-cooperative events. There is no point of having monitor if the
page fault handler will anyway just kill the faulting process.

>       */
>  #define UFFD_FEATURE_PAGEFAULT_FLAG_WP (1<<0)
>  #define UFFD_FEATURE_EVENT_FORK            (1<<1)
> @@ -161,6 +168,7 @@ struct uffdio_api {
>  #define UFFD_FEATURE_MISSING_HUGETLBFS (1<<4)
>  #define UFFD_FEATURE_MISSING_SHMEM        (1<<5)
>  #define UFFD_FEATURE_EVENT_UNMAP        (1<<6)
> +#define UFFD_FEATURE_SIGBUS            (1<<7)
>      __u64 features;
> 
>      __u64 ioctls;
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
