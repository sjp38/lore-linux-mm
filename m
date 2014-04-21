Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id B0E7A6B0038
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 09:36:28 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id j5so3835123qaq.0
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 06:36:28 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id u10si15315020qcz.58.2014.04.21.06.36.27
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 06:36:28 -0700 (PDT)
Date: Mon, 21 Apr 2014 08:36:25 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH 5/6] drivers,sgi-gru/grufault.c: call find_vma with the
 mmap_sem held
Message-ID: <20140421133625.GA17522@sgi.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
 <1397960791-16320-6-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397960791-16320-6-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, zeus@gnu.org, aswin@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dimitri@domain.invalid, "Sivanich <sivanich"@sgi.com

On Sat, Apr 19, 2014 at 07:26:30PM -0700, Davidlohr Bueso wrote:
> From: Jonathan Gonzalez V <zeus@gnu.org>
> 
> Performing vma lookups without taking the mm->mmap_sem is asking
> for trouble. While doing the search, the vma in question can
> be modified or even removed before returning to the caller.
> Take the lock in order to avoid races while iterating through
> the vmacache and/or rbtree.
> 
> This patch is completely *untested*.

The mmap_sem is already taken in all paths calling gru_vtop().

The gru_intr() function takes it before calling gru_try_dropin(), from which
all calls to gru_vtop() originate.

The gru_find_lock_gts() function takes it when called from
gru_handle_user_call_os(), which then calls gru_user_dropin()->gru_try_dropin().

Nacked-by: Dimitri Sivanich <sivanich@sgi.com>

> 
> Signed-off-by: Jonathan Gonzalez V <zeus@gnu.org>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Dimitri Sivanich <sivanich@sgi.com
> ---
>  drivers/misc/sgi-gru/grufault.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
> index f74fc0c..15adc84 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -266,6 +266,7 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  	unsigned long paddr;
>  	int ret, ps;
>  
> +	down_write(&mm->mmap_sem);
>  	vma = find_vma(mm, vaddr);
>  	if (!vma)
>  		goto inval;
> @@ -277,22 +278,26 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  	rmb();	/* Must/check ms_range_active before loading PTEs */
>  	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
>  	if (ret) {
> -		if (atomic)
> -			goto upm;
> +		if (atomic) {
> +			up_write(&mm->mmap_sem);
> +			return VTOP_RETRY;
> +		}
>  		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
>  			goto inval;
>  	}
>  	if (is_gru_paddr(paddr))
>  		goto inval;
> +
> +	up_write(&mm->mmap_sem);
> +
>  	paddr = paddr & ~((1UL << ps) - 1);
>  	*gpa = uv_soc_phys_ram_to_gpa(paddr);
>  	*pageshift = ps;
>  	return VTOP_SUCCESS;
>  
>  inval:
> +	up_write(&mm->mmap_sem);
>  	return VTOP_INVALID;
> -upm:
> -	return VTOP_RETRY;
>  }
>  
>  
> -- 
> 1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
