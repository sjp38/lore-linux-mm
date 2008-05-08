In-reply-to: <20080508130759.GA30499@unused.rdu.redhat.com> (message from
	Josef Bacik on Thu, 8 May 2008 09:07:59 -0400)
Subject: Re: NFS infinite loop in filemap_fault()
References: <E1JtqLW-0005j5-KU@pomaz-ex.szeredi.hu> <E1JtzuH-0006nY-AM@pomaz-ex.szeredi.hu> <20080508130759.GA30499@unused.rdu.redhat.com>
Message-Id: <E1JuB47-0008C9-5n@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 08 May 2008 20:42:03 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jbacik@redhat.com
Cc: miklos@szeredi.hu, trond.myklebust@fys.uio.no, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Index: linux.git/mm/filemap.c
> > ===================================================================
> > --- linux.git.orig/mm/filemap.c	2008-05-08 08:17:22.000000000 +0200
> > +++ linux.git/mm/filemap.c	2008-05-08 08:19:59.000000000 +0200
> > @@ -1461,6 +1461,12 @@ page_not_uptodate:
> >  	 */
> >  	ClearPageError(page);
> >  	error = mapping->a_ops->readpage(file, page);
> > +	if (!error && !PageUptodate(page)) {
> 
> Shouldn't you have (!error || error != AOP_TRUNCATED_PAGE),

That would be a rather useless condition (hint: '!error' means 'error == 0')

> since the fs can
> return AOP_TRUNCATED_PAGE if it needs vfs to try the readpage again?

Yep, I din't touch the 'error != 0' codepath.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
