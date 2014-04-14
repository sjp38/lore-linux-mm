Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 74E226B00E6
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 12:05:05 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so6761031eek.16
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 09:05:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si21737140eel.170.2014.04.14.09.05.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 09:05:01 -0700 (PDT)
Date: Mon, 14 Apr 2014 18:04:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140414160457.GB13860@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408220525.GC26019@quack.suse.cz>
 <20140409204806.GF5727@linux.intel.com>
 <20140409211203.GP32103@quack.suse.cz>
 <20140413112132.GP5727@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140413112132.GP5727@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 13-04-14 07:21:32, Matthew Wilcox wrote:
> On Wed, Apr 09, 2014 at 11:12:03PM +0200, Jan Kara wrote:
> >   This would be fine except that unmap_mapping_range() grabs i_mmap_mutex
> > again :-|. But it might be easier to provide a version of that function
> > which assumes i_mmap_mutex is already locked than what I was suggesting.
> 
> *sigh*.  I knew that once ... which was why the call was after dropping
> the lock.  OK, another try at fixing the problem; handle it down in the
> insert_pfn code:
  OK, that change looks OK to me (although you might want to introduce
vm_replace_mixed() in a separate patch).
 
> > > > > +int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> > > > > +			get_block_t get_block)
> > > > > +{
> > > > > +	int result;
> > > > > +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> > > > > +
> > > > > +	sb_start_pagefault(sb);
> > > >   You don't need any filesystem freeze protection for the fault handler
> > > > since that's not going to modify the filesystem.
> > > 
> > > Err ... we might allocate a block as a result of doing a write to a hole.
> > > Or does that not count as 'modifying the filesystem' in this context?
> >   Ah, it does. But it would be nice to avoid doing sb_start_pagefault() if
> > it's not a write fault - because you don't want to block reading from a
> > frozen filesystem (imagine what would happen when you freeze your root
> > filesystem to do a snapshot...).
> > 
> > I have somewhat a mindset of standard pagecache mmap where filemap_fault()
> > only reads in data regardless of FAULT_FLAG_WRITE setting so I was confused
> > by your difference :).
> 
> Understood!  So this should work:
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 2453025..e4d00fc 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -431,10 +431,13 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	int result;
>  	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
>  
> -	sb_start_pagefault(sb);
> -	file_update_time(vma->vm_file);
> +	if (vmf->flags & FAULT_FLAG_WRITE) {
> +		sb_start_pagefault(sb);
> +		file_update_time(vma->vm_file);
> +	}
  Yup, this looks good to me. Later if we find file_update_time() is
slowing down faults too much, we can defer the actual update to msync()
/ close() time (POSIX actually allows that). But that's definitely for
future.

>  	result = do_dax_fault(vma, vmf, get_block);
> -	sb_end_pagefault(sb);
> +	if (vmf->flags & FAULT_FLAG_WRITE)
> +		sb_end_pagefault(sb);
>  
>  	return result;
>  }

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
