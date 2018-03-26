Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id D468D6B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:54:35 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id m3-v6so2661352ybk.19
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 07:54:35 -0700 (PDT)
Date: Mon, 26 Mar 2018 07:54:31 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/8] HMM: Remove superflous RCU protection around radix
 tree lookup
Message-ID: <20180326145431.GC1840639@devbig577.frc2.facebook.com>
References: <20180314194205.1651587-1-tj@kernel.org>
 <20180314194515.1661824-1-tj@kernel.org>
 <20180314194515.1661824-4-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180314194515.1661824-4-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: security@kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org, torvalds@linux-foundation.org, jannh@google.com, paulmck@linux.vnet.ibm.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, kent.overstreet@gmail.com

Hello, Andrew.

Do you mind picking up the following patch?  I can't find a good tree
to route this through.  The raw patch can be found at

  https://marc.info/?l=linux-mm&m=152105674112496&q=raw

Thank you very much.

On Wed, Mar 14, 2018 at 12:45:11PM -0700, Tejun Heo wrote:
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
> Reviewed-by: Jerome Glisse <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> ---
> Hello,
> 
> Jerome, how do you want to route this patch?  If you prefer, I can
> route it together with other patches.
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
tejun
