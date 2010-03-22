Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 958EA6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 06:54:49 -0400 (EDT)
Date: Mon, 22 Mar 2010 21:54:42 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322105442.GH17637@laptop>
References: <20100322053937.GA17637@laptop>
 <4BA7359B.2060603@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BA7359B.2060603@panasas.com>
Sender: owner-linux-mm@kvack.org
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 11:17:15AM +0200, Boaz Harrosh wrote:
> On 03/22/2010 07:39 AM, Nick Piggin wrote:
> > It's ugly and lazy that we do these default aops in case it has not
> > been filled in by the filesystem.
> > 
> > A NULL operation should always mean either: we don't support the
> > operation; we don't require any action; or a bug in the filesystem,
> > depending on the context.
> > 
> > In practice, if we get rid of these fallbacks, it will be clearer
> > what operations are used by a given address_space_operations struct,
> > reduce branches, reduce #if BLOCK ifdefs, and should allow us to get
> > rid of all the buffer_head knowledge from core mm and fs code.
> > 
> > We could add a patch like this which spits out a recipe for how to fix
> > up filesystems and get them all converted quite easily.
> > 
> 
> Guilty as charged.

Well, everyone's a bit guilty.


> It could be nice if the first thing this patch will
> do is: Add a comment at struct address_space_operations that states
> that all operations should be defined and perhaps what are the minimum
> defaults for some of these, as below. I do try to be good, I was under
> the impression that defaults are OK.

Defaults will usually be OK for aops that use buffer head functions for
their other operations.


> Below are changes to exofs as proposed by this mail. Please comment?
> I will push such a patch to exofs later.

OK, thanks very much for being such a proactive fs maintainer. And
for the comments.


> 
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c
> > +++ linux-2.6/mm/filemap.c
> > @@ -2472,7 +2472,14 @@ int try_to_release_page(struct page *pag
> >  
> >  	if (mapping && mapping->a_ops->releasepage)
> >  		return mapping->a_ops->releasepage(page, gfp_mask);
> > -	return try_to_free_buffers(page);
> > +	else {
> > +		static bool warned = false;
> > +		if (!warned) {
> > +			warned = true;
> > +			print_symbol("address_space_operations %s missing releasepage method. Use try_to_free_buffers.\n", (unsigned long)page->mapping->a_ops);
> > +		}
> > +		return try_to_free_buffers(page);
> 
> This is not nice! we should have an export that looks like:
> 
> int default_releasepage(struct page *page, gfp_t gfp)
> {
> 	return try_to_free_buffers(page);
> }
> 
> otherwise 3ton FSes would have to define the same thing all over again

Yes definitely (or block_releasepage really).

> 
> > +	}
> >  }
> >  
> >  EXPORT_SYMBOL(try_to_release_page);
> > Index: linux-2.6/mm/page-writeback.c
> > ===================================================================
> > --- linux-2.6.orig/mm/page-writeback.c
> > +++ linux-2.6/mm/page-writeback.c
> > @@ -1159,8 +1159,14 @@ int set_page_dirty(struct page *page)
> >  	if (likely(mapping)) {
> >  		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
> >  #ifdef CONFIG_BLOCK
> > -		if (!spd)
> > +		if (!spd) {
> > +			static bool warned = false;
> > +			if (!warned) {
> > +				warned = true;
> > +				print_symbol("address_space_operations %s missing set_page_dirty method. Use __set_page_dirty_buffers.\n", (unsigned long)page->mapping->a_ops);
> > +			}
> >  			spd = __set_page_dirty_buffers;
> > +		}
> 
> We could do better then __set_page_dirty_buffers for something lots of FSes use

block_set_page_dirty? I don't know, not such a big deal and it's already
widely used. Probably worry about renames as another issue. (I do agree
that good names are important though)


> > @@ -311,8 +312,14 @@ void clear_inode(struct inode *inode)
> >  
> >  	might_sleep();
> >  	/* XXX: filesystems should invalidate this before calling */
> > -	if (!mapping->a_ops->release)
> > +	if (!mapping->a_ops->release) {
> 
> Where is this code from? As of 2.6.34-rc2 I don't have a release in a_ops->

Sorry this is from the earlier patch I posted (get rid of buffer heads
from mm/fs). That is what prompted this patch.


> > @@ -827,9 +828,14 @@ int simple_fsync(struct file *file, stru
> >  	int err;
> >  	int ret;
> >  
> > -	if (!mapping->a_ops->sync)
> > +	if (!mapping->a_ops->sync) {
> 
> And this one is new as well, right?
> 
> New added vectors should be added to all in-tree FSes by the submitter.

Yes they should. Although maybe not trivial because the fs may not
use that functionality even if it uses buffer-heads. We don't want
to fill in an operation if it is unused. But the patches should go
through fs maintainers trees.


> and a deprecate warning for out of tree FSes (If we care)

We do care, and yes this is another good reason for the warnings (even
once we do fix up all in-tree filesystems).

> 
> > +		static bool warned = false;
> > +		if (!warned) {
> > +			warned = true;
> > +			print_symbol("address_space_operations %s missing sync method. Using sync_mapping_buffers.\n", (unsigned long)mapping->a_ops);
> > +		}
> >  		ret = sync_mapping_buffers(mapping);
> > -	else
> > +	} else
> >  		ret = mapping->a_ops->sync(mapping, AOP_SYNC_WRITE|AOP_SYNC_WAIT);
> >  
> >  	if (!(inode->i_state & I_DIRTY))
> > --
> ---
> exofs: Add default address_space_operations
> 
> All vectors of address_space_operations should be initialized by the filesystem.
> Add the missing parts.
> 
> ---
> git diff --stat -p -M fs/exofs/inode.c
>  fs/exofs/inode.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
> index a17e4b7..85dd847 100644
> --- a/fs/exofs/inode.c
> +++ b/fs/exofs/inode.c
> @@ -754,6 +754,11 @@ static int exofs_write_end(struct file *file, struct address_space *mapping,
>  	return ret;
>  }
>  
> +static int exofs_releasepage(struct page *page, gfp_t gfp)
> +{
> +	return try_to_free_buffers(page);
> +}
> +
>  const struct address_space_operations exofs_aops = {
>  	.readpage	= exofs_readpage,
>  	.readpages	= exofs_readpages,
> @@ -761,6 +766,9 @@ const struct address_space_operations exofs_aops = {
>  	.writepages	= exofs_writepages,
>  	.write_begin	= exofs_write_begin_export,
>  	.write_end	= exofs_write_end,
> +	.releasepage	= exofs_releasepage,
> +	.set_page_dirty	= __set_page_dirty_buffers,
> +	.invalidatepage = block_invalidatepage,
>  };

AFAIKS, you aren't using buffer heads at all (except nobh_truncate,
which will not attach buffers to pages)?

If so, you should only need __set_page_dirty_nobuffers.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
