Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9OKMJj8013291
	for <linux-mm@kvack.org>; Mon, 24 Oct 2005 16:22:19 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9OKMJdH522728
	for <linux-mm@kvack.org>; Mon, 24 Oct 2005 14:22:19 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9OKMIkK024408
	for <linux-mm@kvack.org>; Mon, 24 Oct 2005 14:22:19 -0600
Message-ID: <435D426A.6070007@us.ibm.com>
Date: Mon, 24 Oct 2005 13:22:02 -0700
From: Darren Hart <dvhltc@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
References: <1129570219.23632.34.camel@localhost.localdomain>  <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>  <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>  <1129651502.23632.63.camel@localhost.localdomain>  <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>  <1129747855.8716.12.camel@localhost.localdomain>  <20051019204732.GA9922@localhost.localdomain>  <1129821065.16301.5.camel@localhost.localdomain>  <20051020172757.GB6590@localhost.localdomain> <1129847844.16301.37.camel@localhost.localdomain> <Pine.LNX.4.61.0510242027001.6509@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0510242027001.6509@goblin.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Jeff Dike <jdike@addtoit.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 20 Oct 2005, Badari Pulavarty wrote:
> 
>>Changes from previous:
>>
>>1) madvise(DISCARD) - zaps the range and discards the pages. So, no
>>need to call madvise(DONTNEED) before.
>>
>>2) I added truncate_inode_pages2_range() to just discard only the
>>range of pages - not the whole file.
>>
>>Hugh, when you get a chance could you review this instead ?
> 
> 
> I haven't had time to go through it thoroughly, and will have no time
> the next couple of days, but here are some remarks.

Excellent points all, I'll take some time here in the next couple days and work 
up a response to each and an updated patch.  Regarding the spaces... I must have 
  used the wrong vi wrapper to edit the patch - apologies, will be fixed in next 
rev.

--Darren


> 
> --- linux-2.6.14-rc3/include/asm-alpha/mman.h	2005-09-30 14:17:35.000000000 -0700
> +++ linux-2.6.14-rc3.db2/include/asm-alpha/mman.h	2005-10-20 10:52:37.000000000 -0700
> @@ -42,6 +42,7 @@
>  #define MADV_WILLNEED	3		/* will need these pages */
>  #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
>  #define MADV_DONTNEED	6		/* don't need these pages */
> +#define MADV_DISCARD    7               /* discard pages right now */
> 
> Throughout the patch there's lots of spaces where there should be tabs.
> But I'm glad you've put a space after the "#define" here, unlike in that
> MADV_SPACEAVAIL higher up!  Not so glad at your spaces to the right of it.
> 
> Are we free to define MADV_DISCARD, coming after the others, in each of
> the architectures?  In general, I think mman.h reflects definitions made
> by native Operating Systems of the architectures in question, and they
> might have added a few since.
> 
> --- linux-2.6.14-rc3/include/linux/mm.h	2005-09-30 14:17:35.000000000 -0700
> +++ linux-2.6.14-rc3.db2/include/linux/mm.h	2005-10-20 13:41:57.000000000 -0700
> @@ -865,6 +865,7 @@ extern unsigned long do_brk(unsigned lon
>  /* filemap.c */
>  extern unsigned long page_unuse(struct page *);
>  extern void truncate_inode_pages(struct address_space *, loff_t);
> +extern void truncate_inode_pages2_range(struct address_space *, loff_t, loff_t);
> 
> Personally, I have an aversion to sticking a "2" in there.  I know you're
> just following the convention established by invalidate_inode_pages2, but..
> 
> Hold on, -mm already contains reiser4-truncate_inode_pages_range.patch,
> you should be working with that.  Doesn't it do just what you need,
> even without a "2" :-?
>  
> --- linux-2.6.14-rc3/mm/madvise.c	2005-09-30 14:17:35.000000000 -0700
> +++ linux-2.6.14-rc3.db2/mm/madvise.c	2005-10-20 13:37:41.000000000 -0700
> @@ -137,6 +137,40 @@ static long madvise_dontneed(struct vm_a
>  	return 0;
>  }
>  
> +static long madvise_discard(struct vm_area_struct * vma,
> +			     struct vm_area_struct ** prev,
> +			     unsigned long start, unsigned long end)
> +{
> ....
> +	error = madvise_dontneed(vma, prev, start, end);
> +	if (error)
> +		return error;
> +
> +	/* looks good, try and rip it out of page cache */
> +	printk("%s: trying to rip shm vma (%p) inode from page cache\n", __FUNCTION__, vma);
> +	offset = (loff_t)(start - vma->vm_start);
> +	endoff = (loff_t)(end - vma->vm_start);
> +	printk("call truncate_inode_pages(%p, %x %x)\n", mapping, 
> +			(unsigned int)offset, (unsigned int)endoff);
> +	down(&mapping->host->i_sem);
> +	truncate_inode_pages2_range(mapping, offset, endoff);
> +	up(&mapping->host->i_sem);
> +	return 0;
> +}
> 
> Hmm.  I don't think it's consistent to zap the pages from a single mm,
> then remove them from the page cache, while leaving the pages mapped into
> other mms.  Just what would those pages then be?  they're not file pages,
> they're not anonymous pages, such pages have given trouble in the past.
> 
> I think you'll need to follow vmtruncate much more closely - and the
> unmap_mapping_range code already allows for a range, shouldn't need
> much change - going through all the vmas before truncating the range.
> 
> Which makes it feel more like sys_fpunch than an madvise.
> 
> You of course need write access to the underlying file, is that checked?
> 
> What should it be doing to anonymous COWed pages?  Not clear whether
> it should be following truncate in discarding those too, or not.
> 
> Hugh
> 


-- 
Darren Hart
IBM Linux Technology Center
Linux Kernel Team
Phone: 503 578 3185
   T/L: 775 3185

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
