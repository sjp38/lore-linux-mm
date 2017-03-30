Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF2BD6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:03:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b10so29782988pgn.8
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 20:03:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 80si733240pga.172.2017.03.29.20.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 20:03:16 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2sTji058668
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:03:16 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29gfrj8kp3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:03:15 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 30 Mar 2017 08:33:13 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2U33COE11206728
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:33:12 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v2U33BMm019177
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:33:11 +0530
Subject: Re: [PATCH V5 16/17] mm: Let arch choose the initial value of task
 size
References: <1490153823-29241-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 30 Mar 2017 08:33:11 +0530
MIME-Version: 1.0
In-Reply-To: <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <77aeea83-0334-45b7-3f40-4a1d8619d191@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 03/22/2017 09:07 AM, Aneesh Kumar K.V wrote:
> As we start supporting larger address space (>128TB), we want to give
> architecture a control on max task size of an application which is different
> from the TASK_SIZE. For ex: ppc64 needs to track the base page size of a segment
> and it is copied from mm_context_t to PACA on each context switch. If we know that
> application has not used an address range above 128TB we only need to copy
> details about 128TB range to PACA. This will help in improving context switch
> performance by avoiding larger copy operation.
> 
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/exec.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 65145a3df065..5550a56d03c3 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1308,6 +1308,14 @@ void would_dump(struct linux_binprm *bprm, struct file *file)
>  }
>  EXPORT_SYMBOL(would_dump);
>  
> +#ifndef arch_init_task_size
> +static inline void arch_init_task_size(void)
> +{
> +	current->mm->task_size = TASK_SIZE;
> +}
> +#define arch_init_task_size arch_init_task_size
> +#endif

Why not a proper CONFIG_ARCH_DEFINED_TASK_SIZE kind of option for
this ? Also are there no assumptions about task current->mm->size
being TASK_SIZE in other places which might get broken ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
