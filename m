Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6CF6B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:57:58 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id j5so1586850qaq.14
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 06:57:58 -0800 (PST)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id el7si11696824qeb.105.2013.12.16.06.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 06:57:57 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so5576367pbc.39
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 06:57:56 -0800 (PST)
Date: Mon, 16 Dec 2013 23:01:09 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [RFC][PATCH] vfs: don't fallback to buffered read if the offset
 of dio read is beyond eof
Message-ID: <20131216150109.GA4257@gmail.com>
References: <1385022854-2683-1-git-send-email-wenqing.lz@taobao.com>
 <20131215232132.194f406f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131215232132.194f406f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Zheng Liu <wenqing.lz@taobao.com>, linux-mm@kvack.org

Hi Andrew,

Thanks for reviewing this patch.  This patch has been updated.  The
following links are the v2 [1] and v3 [2].  In v2 I use a new approach
to fix this bug, and in v3 only change is to add a 'Reviewed-by' tag.

1. http://permalink.gmane.org/gmane.linux.file-systems/80327
2. http://www.spinics.net/lists/linux-fsdevel/msg70899.html

On Sun, Dec 15, 2013 at 11:21:32PM -0800, Andrew Morton wrote:
[...]
> > As we expected, we should read nothing or data with 'a'.  But now we
> > read data with '0'.  I take a closer look at the code and it seems that
> > there is a bug in vfs.  Let me describe my found here.
> > 
> >   reader					writer
> >                                                 generic_file_aio_write()
> >                                                 ->__generic_file_aio_write()
> >                                                   ->generic_file_direct_write()
> >   generic_file_aio_read()
> >   ->do_generic_file_read()
> >     [fallback to buffered read]
> > 
> >     ->find_get_page()
> >     ->page_cache_sync_readahead()
> >     ->find_get_page()
> >     [in find_page label, we couldn't find a
> >      page before and after calling
> >      page_cache_sync_readahead().  So go to
> >      no_cached_page label]
> 
> It's odd that do_generic_file_read() is permitting a "read" outside
> i_size.  Perhaps we should be checking for this in the `no_cached_page'
> block.

In v2 I check i_size at the beginning of do_generic_file_read() to avoid
permitting a read outside i_size.

> 
> >     ->page_cache_alloc_cold()
> >     ->add_to_page_cache_lru()
> >     [in no_cached_page label, we alloc a page
> >      and goto readpage label.]
> > 
> >     ->aops->readpage()
> >     [in readpage label, readpage() callback
> >      is called and mpage_readpage() return a
> >      zero-filled page (e.g. ext3/4), and go
> >      to page_ok label]
> > 
> >                                                   ->a_ops->direct_IO()
> >                                                   ->i_size_write()
> >                                                   [we enlarge the i_size]
> > 
> >     Here we check i_size
> >     [in page_ok label, we check i_size but
> >      it has been enlarged.  Thus, we pass
> >      the check and return a zero-filled page]
> 
> OK, so it's a race.
> 
> > This commit let dio read return directly if the current offset of the
> > dio read is beyond the end of file in order to avoid this problem.
> > 
> > ...
> >
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1452,6 +1452,8 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
> >  				file_accessed(filp);
> >  				goto out;
> >  			}
> > +		} else {
> > +			goto out;
> >  		}
> >  	}
> 
> OK, so we don't fall back to buffered reading at all if we're outside
> i_size.
> 
> I'm not sure this 100% fixes the problem.  In generic_file_aio_read():
> 
> : 		if (pos < size) {
> 
> write() extends i_size now.

Uhh, I don't think so.  If write() extends i_size here, we will read
something after calling ->direct_IO().  So '*ppos' should be equal to
'size (old i_size)', and we will goto 'out' label.

> 
> : 			retval = filemap_write_and_wait_range(mapping, pos,
> : 					pos + iov_length(iov, nr_segs) - 1);
> : 			if (!retval) {
> : 				retval = mapping->a_ops->direct_IO(READ, iocb,
> : 							iov, pos, nr_segs);
> : 			}
> : 			if (retval > 0) {
> : 				*ppos = pos + retval;
> : 				count -= retval;
> : 			}
> : 
> : 			/*
> : 			 * Btrfs can have a short DIO read if we encounter
> : 			 * compressed extents, so if there was an error, or if
> : 			 * we've already read everything we wanted to, or if
> : 			 * there was a short read because we hit EOF, go ahead
> : 			 * and return.  Otherwise fallthrough to buffered io for
> : 			 * the rest of the read.
> : 			 */
> : 			if (retval < 0 || !count || *ppos >= size) {

We will goto 'out' label here.

Thanks,
                                                - Zheng

> : 				file_accessed(filp);
> : 				goto out;
> : 			}
> 
> we can still fall through to buffered read.
> 
> : 		} else {
> : 			goto out;
> : 		}
> : 	}
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
