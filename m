Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 225936B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 12:59:52 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n141so1208339qke.20
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 09:59:52 -0800 (PST)
Date: Tue, 6 Mar 2018 12:59:48 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/7] HMM: Remove superflous RCU protection around radix
 tree lookup
Message-ID: <20180306175948.GA4791@redhat.com>
References: <20180306172657.3060270-1-tj@kernel.org>
 <20180306173316.3088458-1-tj@kernel.org>
 <20180306173316.3088458-4-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180306173316.3088458-4-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, jannh@google.com, paulmck@linux.vnet.ibm.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, kent.overstreet@gmail.com, security@kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 09:33:13AM -0800, Tejun Heo wrote:
> hmm_devmem_find() requires rcu_read_lock_held() but there's nothing
> which actually uses the RCU protection.  The only caller is
> hmm_devmem_pages_create() which already grabs the mutex and does
> superflous rcu_read_lock/unlock() around the function.
> 
> This doesn't add anything and just adds to confusion.  Remove the RCU
> protection and open-code the radix tree lookup.  If this needs to
> become more sophisticated in the future, let's add them back when
> necessary.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

> Cc: linux-mm@kvack.org
> Cc: Linus Torvalds <torvalds@linux-foundation.org>

> ---
> Hello, Jerome.
> 
> This came up while auditing percpu_ref users for missing explicit RCU
> grace periods.  HMM doesn't seem to depend on RCU protection at all,
> so I thought it'd be better to remove it for now.  It's only compile
> tested.

Good catch some left over of old logic. I have more cleanup queued up
now that i am about to post nouveau patches to use all this. Thanks for
fixing this.

> 
> Thanks.
> 
>  mm/hmm.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 320545b98..d4627c5 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -845,13 +845,6 @@ static void hmm_devmem_release(struct device *dev, void *data)
>  	hmm_devmem_radix_release(resource);
>  }
>  
> -static struct hmm_devmem *hmm_devmem_find(resource_size_t phys)
> -{
> -	WARN_ON_ONCE(!rcu_read_lock_held());
> -
> -	return radix_tree_lookup(&hmm_devmem_radix, phys >> PA_SECTION_SHIFT);
> -}
> -
>  static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  {
>  	resource_size_t key, align_start, align_size, align_end;
> @@ -892,9 +885,8 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	for (key = align_start; key <= align_end; key += PA_SECTION_SIZE) {
>  		struct hmm_devmem *dup;
>  
> -		rcu_read_lock();
> -		dup = hmm_devmem_find(key);
> -		rcu_read_unlock();
> +		dup = radix_tree_lookup(&hmm_devmem_radix,
> +					key >> PA_SECTION_SHIFT);
>  		if (dup) {
>  			dev_err(device, "%s: collides with mapping for %s\n",
>  				__func__, dev_name(dup->device));
> -- 
> 2.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
