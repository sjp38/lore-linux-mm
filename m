Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2CB6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:29:32 -0400 (EDT)
Date: Tue, 7 Jul 2009 15:30:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/3] fs: convert ext2,tmpfs to new truncate
Message-ID: <20090707133014.GA2714@wotan.suse.de>
References: <20090706165438.GQ2714@wotan.suse.de> <20090706165629.GS2714@wotan.suse.de> <4A533559.90303@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A533559.90303@panasas.com>
Sender: owner-linux-mm@kvack.org
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 02:45:29PM +0300, Boaz Harrosh wrote:
> On 07/06/2009 07:56 PM, Nick Piggin wrote:
> > Convert filemap_xip.c, buffer.c, and some filesystems to the new truncate
> > convention. Converting generic helpers is using some ugly code (testing
> > for i_op->ftruncate) to distinguish new and old callers... better
> > alternative might be just define a new function for these guys.
> > @@ -770,13 +793,22 @@ ext2_nobh_write_begin(struct file *file,
> >  		loff_t pos, unsigned len, unsigned flags,
> >  		struct page **pagep, void **fsdata)
> >  {
> > +	int ret;
> > +
> >  	/*
> >  	 * Dir-in-pagecache still uses ext2_write_begin. Would have to rework
> >  	 * directory handling code to pass around offsets rather than struct
> >  	 * pages in order to make this work easily.
> >  	 */
> > -	return nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
> > +	ret = nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
> >  							ext2_get_block);
> > +	if (ret < 0) {
> > +		loff_t isize;
> > +		isize = i_size_read(inode);
> 
> Unlike the other places you use i_size_read() here, please explain what is the
> locking rules for this?
> 
> Did your patchset change things in this regard?

i_mutex should protect i_size. I was doing a bit of cutting and pasting
so it probably isn't perfect. I'll double check.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
