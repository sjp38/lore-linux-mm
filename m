Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE0146B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 07:17:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p20so99688096pgd.21
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 04:17:32 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id o5si3928513pgc.29.2017.03.28.04.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Mar 2017 04:17:31 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH V5 16/17] mm: Let arch choose the initial value of task size
In-Reply-To: <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1490153823-29241-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 28 Mar 2017 22:17:27 +1100
Message-ID: <87vaqtabw8.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

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

I'll need an ACK at least on this from someone in mm land.

I assume there's no way I can merge patch 17 without this?

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

I don't think you need to do the #define in the fallback case, it's
just extra noise.

> +#endif
> +
>  void setup_new_exec(struct linux_binprm * bprm)
>  {
>  	arch_pick_mmap_layout(current->mm);

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
