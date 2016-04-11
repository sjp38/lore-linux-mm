Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0EE6B0268
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:28:43 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l6so141536379wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:28:43 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id gi8si28318233wjc.158.2016.04.11.04.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 04:28:42 -0700 (PDT)
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cornelia.huck@de.ibm.com>;
	Mon, 11 Apr 2016 12:28:41 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 77FFA219005F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:28:19 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3BBSeXg57540674
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:28:40 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3BBSdBE027158
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:28:40 -0600
Date: Mon, 11 Apr 2016 13:28:37 +0200
From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 13/19] s390: get rid of superfluous __GFP_REPEAT
Message-ID: <20160411132837.3cba168f.cornelia.huck@de.ibm.com>
In-Reply-To: <1460372892-8157-14-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
	<1460372892-8157-14-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-arch@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, 11 Apr 2016 13:08:06 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
> 
> arch_dup_task_struct uses __GFP_REPEAT for fpu_regs_size which is either
> sizeof(__vector128) * __NUM_VXRS = 4069B resp.
> sizeof(freg_t) * __NUM_FPRS = 1024B AFAICS. page_table_alloc then uses
> the flag for a single page allocation. This means that this flag has
> never been actually useful here because it has always been used only for
> PAGE_ALLOC_COSTLY requests.
> 
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>

Let's cc: Martin/Heiko instead :)

> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/s390/kernel/process.c | 2 +-
>  arch/s390/mm/pgalloc.c     | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
> index f8e79824e284..1837a1901d4b 100644
> --- a/arch/s390/kernel/process.c
> +++ b/arch/s390/kernel/process.c
> @@ -102,7 +102,7 @@ int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
>  	 */
>  	fpu_regs_size = MACHINE_HAS_VX ? sizeof(__vector128) * __NUM_VXRS
>  				       : sizeof(freg_t) * __NUM_FPRS;
> -	dst->thread.fpu.regs = kzalloc(fpu_regs_size, GFP_KERNEL|__GFP_REPEAT);
> +	dst->thread.fpu.regs = kzalloc(fpu_regs_size, GFP_KERNEL);
>  	if (!dst->thread.fpu.regs)
>  		return -ENOMEM;
> 
> diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
> index f6c3de26cda8..3f716741797a 100644
> --- a/arch/s390/mm/pgalloc.c
> +++ b/arch/s390/mm/pgalloc.c
> @@ -198,7 +198,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
>  			return table;
>  	}
>  	/* Allocate a fresh page */
> -	page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
> +	page = alloc_page(GFP_KERNEL);
>  	if (!page)
>  		return NULL;
>  	if (!pgtable_page_ctor(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
