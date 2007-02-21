In-reply-to: <45DC8A47.5050900@redhat.com> (message from Peter Staubach on
	Wed, 21 Feb 2007 13:07:03 -0500)
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <45DC8A47.5050900@redhat.com>
Message-Id: <E1HJw7l-0003Tq-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 21 Feb 2007 19:23:29 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: staubach@redhat.com
Cc: akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Inspired by Peter Staubach's patch and the resulting comments.
> >
> >   
> 
> An updated version of the original patch was submitted to LKML
> yesterday...  :-)

Strange coincidence :)

> >  		file = vma->vm_file;
> >  		start = vma->vm_end;
> > +		mapping_update_time(file);
> >  		if ((flags & MS_SYNC) && file &&
> >  				(vma->vm_flags & VM_SHARED)) {
> >  			get_file(file);
> >   
> 
> It seems to me that this might lead to file times being updated for
> non-MAP_SHARED mappings.

In theory no, because the COW-ed pages become anonymous and are not
part of the original mapping any more.

> > +int set_page_dirty_mapping(struct page *page);
> >   
> 
> This aspect of the design seems intrusive to me.  I didn't see a strong
> reason to introduce new versions of many of the routines just to handle
> these semantics.  What motivated this part of your design?  Why the new
> _mapping versions of routines?

Because there's no way to know inside the set_page_dirty() functions
if the dirtying comes from a memory mapping or from a modification
through a normal write().  And they have different semantics, for
write() the modification times are updated immediately.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
