Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E2EBF6B0047
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:46:44 -0400 (EDT)
Date: Thu, 19 Mar 2009 17:46:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090319164638.GB3899@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <alpine.LFD.2.00.0903181634500.17240@localhost.localdomain> <604427e00903181654y308d57d8w2cb32eab831cf45a@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903200248.22623.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

  Hi,

On Fri 20-03-09 02:48:21, Nick Piggin wrote:
> On Thursday 19 March 2009 10:54:33 Ying Han wrote:
> > On Wed, Mar 18, 2009 at 4:36 PM, Linus Torvalds
> >
> > <torvalds@linux-foundation.org> wrote:
> > > On Wed, 18 Mar 2009, Ying Han wrote:
> > >> > Can you say what filesystem, and what mount-flags you use? Iirc, last
> > >> > time we had MAP_SHARED lost writes it was at least partly triggered by
> > >> > the filesystem doing its own flushing independently of the VM (ie ext3
> > >> > with "data=journal", I think), so that kind of thing does tend to
> > >> > matter.
> > >>
> > >> /etc/fstab
> > >> "/dev/hda1 / ext2 defaults 1 0"
> > >
> > > Sadly, /etc/fstab is not necessarily accurate for the root filesystem. At
> > > least Fedora will ignore the flags in it.
> > >
> > > What does /proc/mounts say? That should be a more reliable indication of
> > > what the kernel actually does.
> >
> > "/dev/root / ext2 rw,errors=continue 0 0"
> 
> No luck with finding the problem yet.
  I've been staring at the code whole yesterday and didn't find the problem
either.

> But I think we do have a race in __set_page_dirty_buffers():
> 
> The page may not have buffers between the mapping->private_lock
> critical section and the __set_page_dirty call there. So between
> them, another thread might do a create_empty_buffers which can
> see !PageDirty and thus it will create clean buffers. The page
> will get dirtied by the original thread, but if the buffers are
> clean it can be cleaned without writing out buffers.
> 
> Holding mapping->private_lock over the __set_page_dirty should
> fix it, although I guess you'd want to release it before calling
> __mark_inode_dirty so as not to put inode_lock under there. I
> have a patch for this if it sounds reasonable.
  Yes, that seems to be a bug - the function actually looked suspitious to
me yesterday but I somehow convinced myself that it's fine. Probably
because fsx-linux is single-threaded.
  Anyway, I've tried the following hack:

diff --git a/fs/buffer.c b/fs/buffer.c
index 985f617..f764c8a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -763,10 +763,15 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
 static int __set_page_dirty(struct page *page,
                struct address_space *mapping, int warn)
 {
+       int ret;
+
        if (unlikely(!mapping))
                return !TestSetPageDirty(page);
 
-       if (TestSetPageDirty(page))
+       ret = TestSetPageDirty(page);
+       if (warn)
+               spin_unlock(&mapping->private_lock);
+       if (ret)
                return 0;
 
        spin_lock_irq(&mapping->tree_lock);
@@ -831,8 +836,6 @@ int __set_page_dirty_buffers(struct page *page)
                        bh = bh->b_this_page;
                } while (bh != head);
        }
-       spin_unlock(&mapping->private_lock);
-
        return __set_page_dirty(page, mapping, 1);
 }

   But it didn't help my data corruption under UML :(.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
