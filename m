Date: Tue, 2 Jan 2007 11:17:46 +0000
From: 'Christoph Hellwig' <hch@infradead.org>
Subject: Re: [PATCH]  incorrect error handling inside generic_file_direct_write
Message-ID: <20070102111746.GA22657@infradead.org>
References: <20061215104341.GA20089@infradead.org> <000101c7207a$48c138f0$ff0da8c0@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101c7207a$48c138f0$ff0da8c0@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, 'Andrew Morton' <akpm@osdl.org>, Dmitriy Monakhov <dmonakhov@sw.ru>, Dmitriy Monakhov <dmonakhov@openvz.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Dec 15, 2006 at 10:53:18AM -0800, Chen, Kenneth W wrote:
> Christoph Hellwig wrote on Friday, December 15, 2006 2:44 AM
> > So we're doing the sync_page_range once in __generic_file_aio_write
> > with i_mutex held.
> > 
> > 
> > >  	mutex_lock(&inode->i_mutex);
> > > -	ret = __generic_file_aio_write_nolock(iocb, iov, nr_segs,
> > > -			&iocb->ki_pos);
> > > +	ret = __generic_file_aio_write(iocb, iov, nr_segs, pos);
> > >  	mutex_unlock(&inode->i_mutex);
> > >  
> > >  	if (ret > 0 && ((file->f_flags & O_SYNC) || IS_SYNC(inode))) {
> > 
> > And then another time after it's unlocked, this seems wrong.
> 
> 
> I didn't invent that mess though.
> 
> I should've ask the question first: in 2.6.20-rc1, generic_file_aio_write
> will call sync_page_range twice, once from __generic_file_aio_write_nolock
> and once within the function itself.  Is it redundant?  Can we delete the
> one in the top level function?  Like the following?

Really?  I'm looking at -rc3 now as -rc1 is rather old and it's definitly
not the case there.  I also can't remember ever doing this - when I
started the generic read/write path untangling I had exactly the same
situation that's now in -rc3:

  - generic_file_aio_write_nolock calls sync_page_range_nolock
  - generic_file_aio_write calls sync_page_range
  - __generic_file_aio_write_nolock doesn't call any sync_page_range variant

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
