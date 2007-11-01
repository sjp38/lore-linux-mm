Subject: Re: per-bdi-throttling: synchronous writepage doesn't work
	correctly
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <E1InfZx-0004Eu-00@dorka.pomaz.szeredi.hu>
References: <E1IndEw-00046x-00@dorka.pomaz.szeredi.hu>
	 <1193935886.27652.313.camel@twins>
	 <E1IndPT-00047e-00@dorka.pomaz.szeredi.hu>
	 <1193936949.27652.321.camel@twins>  <1193937408.27652.326.camel@twins>
	 <1193942132.27652.331.camel@twins>
	 <E1InfZx-0004Eu-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 01 Nov 2007 20:55:37 +0100
Message-Id: <1193946937.5911.10.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jdike@addtoit.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-01 at 20:19 +0100, Miklos Szeredi wrote:
> > > 
> > >       See the file "Locking" for more details.
> > > 
> > > 
> > > The "should set PG_Writeback" bit threw me off I guess.
> > 
> > Hmm, set_page_writeback() is also the one clearing the radix tree dirty
> > tag. So if that is not called, we get in a bit of a mess, no?
> > 
> > Which makes me think hostfs is buggy.
> 
> Yes, looks like that sort of usage is not valid.  But not clearing the
> dirty tag won't cause any malfunction, it'll just waste some CPU when
> looking for dirty pages to write back.  This is probably why this
> wasn't noticed earlier.

Documentation/filesystems/Locking is also quite clear on the need to
call set_page_writeback() and end_page_writeback().

minimal fix for hostfs

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 8966b05..b6c1e12 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -415,6 +415,7 @@ int hostfs_writepage(struct page *page, struct writeback_control *wbc)
 	int end_index = inode->i_size >> PAGE_CACHE_SHIFT;
 	int err;
 
+	set_page_writeback(page);
 	if (page->index >= end_index)
 		count = inode->i_size & (PAGE_CACHE_SIZE-1);
 
@@ -438,6 +439,7 @@ int hostfs_writepage(struct page *page, struct writeback_control *wbc)
 	kunmap(page);
 
 	unlock_page(page);
+	end_page_writeback(page);
 	return err;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
