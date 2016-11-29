Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 053766B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:02:45 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c21so261247967ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:02:44 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id c83si20499755itb.42.2016.11.28.16.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 16:02:43 -0800 (PST)
Subject: Re: [PATCH v3 24/33] radix-tree: Add radix_tree_split
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1480369871-5271-25-git-send-email-mawilcox@linuxonhyperv.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ebdda64e-2309-49cb-7d9c-1820e8783e1c@infradead.org>
Date: Mon, 28 Nov 2016 16:02:35 -0800
MIME-Version: 1.0
In-Reply-To: <1480369871-5271-25-git-send-email-mawilcox@linuxonhyperv.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 11/28/16 13:50, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> This new function splits a larger multiorder entry into smaller entries
> (potentially multi-order entries).  These entries are initialised to
> RADIX_TREE_RETRY to ensure that RCU walkers who see this state aren't
> confused.  The caller should then call radix_tree_for_each_slot() and
> radix_tree_replace_slot() in order to turn these retry entries into the
> intended new entries.  Tags are replicated from the original multiorder
> entry into each new entry.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> ---
>  include/linux/radix-tree.h            |  12 +++
>  lib/radix-tree.c                      | 142 +++++++++++++++++++++++++++++++++-
>  tools/testing/radix-tree/multiorder.c |  64 +++++++++++++++
>  3 files changed, 214 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 935293a..1f4b561 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -293,6 +301,8 @@ void __radix_tree_replace(struct radix_tree_root *root,
>  			  struct radix_tree_node *node,
>  			  void **slot, void *item,
>  			  radix_tree_update_node_t update_node, void *private);
> +void radix_tree_iter_replace(struct radix_tree_root *,
> +		const struct radix_tree_iter *, void **slot, void *item);

above

>  void radix_tree_replace_slot(struct radix_tree_root *root,
>  			     void **slot, void *item);
>  void __radix_tree_delete_node(struct radix_tree_root *root,
> @@ -335,6 +345,8 @@ static inline void radix_tree_preload_end(void)
>  	preempt_enable();
>  }
>  
> +int radix_tree_split(struct radix_tree_root *, unsigned long index,
> +			unsigned new_order);

and above:

and in patch 25/33: Add radix_tree_split_preload()

As indicated in CodingStyle:
In function prototypes, include parameter names with their data types.
Although this is not required by the C language, it is preferred in Linux
because it is a simple way to add valuable information for the reader.

>  int radix_tree_join(struct radix_tree_root *, unsigned long index,
>  			unsigned new_order, void *);
>  

Yes, the source file already omits some function prototype parameter names,
so these patches just follow that tradition.  It's weird (to me) though that
the existing code even mixes this style in one function prototype (see
immed. above).


Thanks.
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
