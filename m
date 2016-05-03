Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0A756B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 10:24:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so16676745lfd.1
        for <linux-mm@kvack.org>; Tue, 03 May 2016 07:24:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa10si4444833wjd.171.2016.05.03.07.24.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 May 2016 07:24:58 -0700 (PDT)
Date: Tue, 3 May 2016 16:24:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 01/29] radix-tree: Introduce radix_tree_empty
Message-ID: <20160503142454.GE25436@quack2.suse.cz>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
 <1460643410-30196-2-git-send-email-willy@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460643410-30196-2-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu 14-04-16 10:16:22, Matthew Wilcox wrote:
> The irqdomain code was checking for 0 or 1 entries, not 0 entries like
> the comment said they were.  Introduce a new helper that will actually
> check for an empty tree.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/radix-tree.h | 5 +++++
>  kernel/irq/irqdomain.c     | 7 +------
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 51a97ac..83f708e 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -136,6 +136,11 @@ do {									\
>  	(root)->rnode = NULL;						\
>  } while (0)
>  
> +static inline bool radix_tree_empty(struct radix_tree_root *root)
> +{
> +	return root->rnode == NULL;
> +}
> +
>  /**
>   * Radix-tree synchronization
>   *
> diff --git a/kernel/irq/irqdomain.c b/kernel/irq/irqdomain.c
> index 3a519a0..ba3f60d 100644
> --- a/kernel/irq/irqdomain.c
> +++ b/kernel/irq/irqdomain.c
> @@ -139,12 +139,7 @@ void irq_domain_remove(struct irq_domain *domain)
>  {
>  	mutex_lock(&irq_domain_mutex);
>  
> -	/*
> -	 * radix_tree_delete() takes care of destroying the root
> -	 * node when all entries are removed. Shout if there are
> -	 * any mappings left.
> -	 */
> -	WARN_ON(domain->revmap_tree.height);
> +	WARN_ON(!radix_tree_empty(&domain->revmap_tree));
>  
>  	list_del(&domain->link);
>  
> -- 
> 2.8.0.rc3
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
