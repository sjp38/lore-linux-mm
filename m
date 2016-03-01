Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5570D6B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 16:59:56 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id 4so41908502pfd.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:59:56 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id am4si14355955pad.172.2016.03.01.13.59.55
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 13:59:55 -0800 (PST)
Date: Tue, 1 Mar 2016 14:59:36 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/3] radix-tree: make 'indirect' bit available to
 exception entries.
Message-ID: <20160301215936.GC12700@linux.intel.com>
References: <145663588892.3865.9987439671424028216.stgit@notabene>
 <145663616977.3865.9772784012366988314.stgit@notabene>
 <100D68C7BA14664A8938383216E40DE0421D3AE9@FMSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <100D68C7BA14664A8938383216E40DE0421D3AE9@FMSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: NeilBrown <neilb@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 29, 2016 at 02:41:55PM +0000, Wilcox, Matthew R wrote:
> So based on the bottom two bits, we can tell what this entry is:
> 
> 00 - data pointer
> 01 - indirect entry (pointer to another level of the radix tree)
> 10 - exceptional entry
> 11 - locked exceptional entry
> 
> I was concerned that this patch would clash with the support for multi-order
> entries in the radix tree, but after some thought, I now believe that it
> doesn't.  The multi-order entries changes permit finding data pointers or
> exceptional entries in the tree where before only indirect entries could be
> found, but with the changes to radix_tree_is_indirect_ptr below, everything
> should work fine.

Yep, this seems workable to me.

> -----Original Message-----
> From: NeilBrown [mailto:neilb@suse.com] 
> Sent: Saturday, February 27, 2016 9:09 PM
> To: Ross Zwisler; Wilcox, Matthew R; Andrew Morton; Jan Kara
> Cc: linux-kernel@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-mm@kvack.org
> Subject: [PATCH 2/3] radix-tree: make 'indirect' bit available to exception entries.
> 
> A pointer to a radix_tree_node will always have the 'exception'
> bit cleared, so if the exception bit is set the value cannot
> be an indirect pointer.  Thus it is safe to make the 'indirect bit'
> available to store extra information in exception entries.
> 
> This patch adds a 'PTR_MASK' and a value is only treated as
> an indirect (pointer) entry the 2 ls-bits are '01'.
> 
> The change in radix-tree.c ensures the stored value still looks like an
> indirect pointer, and saves a load as well.
> 
> We could swap the two bits and so keep all the exectional bits contigious.
> But I have other plans for that bit....
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  include/linux/radix-tree.h |   11 +++++++++--
>  lib/radix-tree.c           |    2 +-
>  2 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 968150ab8a1c..450c12b546b7 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -40,8 +40,13 @@
>   * Indirect pointer in fact is also used to tag the last pointer of a node
>   * when it is shrunk, before we rcu free the node. See shrink code for
>   * details.
> + *
> + * To allow an exception entry to only lose one bit, we ignore
> + * the INDIRECT bit when the exception bit is set.  So an entry is
> + * indirect if the least significant 2 bits are 01.
>   */
>  #define RADIX_TREE_INDIRECT_PTR		1
> +#define RADIX_TREE_INDIRECT_MASK	3
>  /*
>   * A common use of the radix tree is to store pointers to struct pages;
>   * but shmem/tmpfs needs also to store swap entries in the same tree:
> @@ -53,7 +58,8 @@
>  
>  static inline int radix_tree_is_indirect_ptr(void *ptr)
>  {
> -	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
> +	return ((unsigned long)ptr & RADIX_TREE_INDIRECT_MASK)
> +		== RADIX_TREE_INDIRECT_PTR;
>  }
>  
>  /*** radix-tree API starts here ***/
> @@ -221,7 +227,8 @@ static inline void *radix_tree_deref_slot_protected(void **pslot,
>   */
>  static inline int radix_tree_deref_retry(void *arg)
>  {
> -	return unlikely((unsigned long)arg & RADIX_TREE_INDIRECT_PTR);
> +	return unlikely(((unsigned long)arg & RADIX_TREE_INDIRECT_MASK)
> +			== RADIX_TREE_INDIRECT_PTR);
>  }
>  
>  /**
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 6b79e9026e24..37d4643ab5c0 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -1305,7 +1305,7 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
>  		 * to force callers to retry.
>  		 */
>  		if (root->height == 0)
> -			*((unsigned long *)&to_free->slots[0]) |=
> +			*((unsigned long *)&to_free->slots[0]) =
>  						RADIX_TREE_INDIRECT_PTR;
>  
>  		radix_tree_node_free(to_free);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
