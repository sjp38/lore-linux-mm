In-reply-to: <Pine.LNX.4.64.0703291212080.19050@blonde.wat.veritas.com>
	(message from Hugh Dickins on Thu, 29 Mar 2007 12:56:03 +0100 (BST))
Subject: Re: [PATCH 1/4] holepunch: fix shmem_truncate_range punching too
 far
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
 <E1HWsJq-0000vz-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0703291212080.19050@blonde.wat.veritas.com>
Message-Id: <E1HWtTi-00013Z-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 29 Mar 2007 14:11:42 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, mszeredi@suse.cz, pbadari@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > >  	} else {
> > > -		limit = (end + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> > > -		if (limit > info->next_index)
> > > -			limit = info->next_index;
> > > +		if (end + 1 >= inode->i_size) {	/* we may free a little more */
> > 
> > Why end + 1?  If the hole end is at 4096 and the file size is 4097 we
> > surely don't want to truncate that second page also?
> 
> I spent ages over that!  It's the fix to one of those silly little bugs
> that were in the interim Not-Yet-Signed-off-by version I sent you earlier.
> 
> In that interim version indeed I had just "end": I thought the original
> (see the first - line above) was wrong to be rounding up "end" to a page
> boundary, since "start" has been rounded up to a page boundary - the
> right thing would be to round up start and round down end (though it's
> academic so long as the only way here is through sys_madvise, which
> enforces page alignment of start and rounds up len).
> 
> For a long time I was mystified why my final page's swap entry wasn't
> getting punched out.  Eventually I printk'ed the arguments coming in,
> then found this line in madvise_remove:
> 
> 	endoff = (loff_t)(end - vma->vm_start - 1)
> 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> 
> It subtracts 1 from the "end" I'm used to dealing with (offset of
> byte beyond the area in question), to make it the offset of the
> last byte of the hole, then passes that down as "lend" or "end"
> to truncate_inode_pages_range and shmem_truncate_range.
> 
> Personally, I'd call that "last"; or rather, I wouldn't do it like
> that at all - I find it terribly confusing to deal with; but I
> guess Badari himself found it more natural that way, or it fitted
> better with the convention of -1 he was using for full truncation.

Oh, it _is_ confusing.

> Of course, you can then question the args I gave to the additional
> unmap_mapping_range: I dithered over that for a long time too (and
> again got it wrong in the interim version), in the end decided to say
> the same as vmtruncate_range (to avoid questions!), though strictly
> unmap_mapping_range(mapping, offset, 1 + end - offset, 1)
> would be more correct - though again, it's academic since
> unmap_mapping_range does its own rounding.

I think we should at least have a

  BUG_ON((end + 1) % PAGE_CACHE_SIZE);

or something, to remind us about this wart.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
