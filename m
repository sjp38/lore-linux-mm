Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 440C16B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 18:16:53 -0400 (EDT)
Date: Mon, 6 Jun 2011 15:16:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix assertion mapping->nrpages == 0 in
 end_writeback()
Message-Id: <20110606151614.0037e236.akpm@linux-foundation.org>
In-Reply-To: <1306748258-4732-1-git-send-email-jack@suse.cz>
References: <1306748258-4732-1-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, mszeredi@suse.cz, Jay <jinshan.xiong@whamcloud.com>, stable@kernel.org, Nick Piggin <npiggin@kernel.dk>

On Mon, 30 May 2011 11:37:38 +0200
Jan Kara <jack@suse.cz> wrote:

> Under heavy memory and filesystem load, users observe the assertion
> mapping->nrpages == 0 in end_writeback() trigger. This can be caused
> by page reclaim reclaiming the last page from a mapping in the following
> race:
> 	CPU0				CPU1
>   ...
>   shrink_page_list()
>     __remove_mapping()
>       __delete_from_page_cache()
>         radix_tree_delete()
> 					evict_inode()
> 					  truncate_inode_pages()
> 					    truncate_inode_pages_range()
> 					      pagevec_lookup() - finds nothing
> 					  end_writeback()
> 					    mapping->nrpages != 0 -> BUG
>         page->mapping = NULL
>         mapping->nrpages--
> 
> Fix the problem by cycling the mapping->tree_lock at the end of
> truncate_inode_pages_range() to synchronize with page reclaim.
> 
> Analyzed by Jay <jinshan.xiong@whamcloud.com>, lost in LKML, and dug
> out by Miklos Szeredi <mszeredi@suse.de>.
> 
> CC: Jay <jinshan.xiong@whamcloud.com>
> CC: stable@kernel.org
> Acked-by: Miklos Szeredi <mszeredi@suse.de>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/truncate.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
>  Andrew, would you merge this patch please? Thanks.
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index a956675..ec3d292 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -291,6 +291,13 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  		pagevec_release(&pvec);
>  		mem_cgroup_uncharge_end();
>  	}
> +	/*
> +	 * Cycle the tree_lock to make sure all __delete_from_page_cache()
> +	 * calls run from page reclaim have finished as well (this handles the
> +	 * case when page reclaim took the last page from our range).
> +	 */
> +	spin_lock_irq(&mapping->tree_lock);
> +	spin_unlock_irq(&mapping->tree_lock);
>  }
>  EXPORT_SYMBOL(truncate_inode_pages_range);

That's one ugly patch.


Perhaps this regression was added by Nick's RCUification of pagecache. 

Before that patch, mapping->nrpages and the radix-tree state were
coherent for holders of tree_lock.  So pagevec_lookup() would never
return "no pages" while ->nrpages is non-zero.

After that patch, find_get_pages() uses RCU to protect the radix-tree
but I don't think it correctly protects the aggregate (radix-tree +
nrpages).


If it's not that then I see another possibility. 
truncate_inode_pages_range() does

        if (mapping->nrpages == 0)
                return;

Is there anything to prevent a page getting added to the inode _after_
this test?  i_mutex?  If not, that would trigger the BUG.


Either way, I don't think that the uglypatch expresses a full
understanding of te bug ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
