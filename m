In-reply-to: <20081021133814.GA26942@fogou.chygwyn.com> (steve@chygwyn.com)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com>
Message-Id: <E1KsIHV-0006JW-65@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 21 Oct 2008 16:32:21 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: miklos@szeredi.hu, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, steve@chygwyn.com
> Once thats done, the dlm/glock is dropped (again notification is via
> the dlm) and if Node A has outstanding requests queued up, it
> re-requests the glock. This is a slightly simplified explanation
> but, I hope it gives the general drift.

Yes, thanks.

> So to return to the original subject, in order to allow all
> this locking to occur with no lock ordering problems, we have
> to define a suitable ordering of page locks vs. glocks, and the
> ordering that we use is that glocks must come before page locks. The
> full ordering of locks in GFS2 is in Documentation/filesystems/gfs2-glocks.txt
> 
> As a result of that, the VFS needs reads (and page_mkwrite) to
> retry when !PageUptodate() in case the returned page has been
> invalidated at any time when the page lock has been dropped.

Since this commit PG_uptodate isn't cleared on invalidate:

  commit 84209e02de48d72289650cc5a7ae8dd18223620f
  Author: Miklos Szeredi <mszeredi@suse.cz>
  Date:   Fri Aug 1 20:28:47 2008 +0200
  
      mm: dont clear PG_uptodate on truncate/invalidate

Testing for !page->mapping, however, is a reliable way to detect both
truncation and invalidation.

So the page can have the following states:

  !PG_uptodate                    -> page has not been read
  PG_uptodate && page->mapping    -> page has been read and is valid
  PG_uptodate && !page->mapping   -> page has been read but no longer valid

So PG_uptodate does not reflect the validity of the data, only whether
the data was ever made up-to-date.

Does this make sense?  Should it be documented somewhere?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
