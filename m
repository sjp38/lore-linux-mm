Message-ID: <3D74FCAC.EA4F14F8@zip.com.au>
Date: Tue, 03 Sep 2002 11:17:16 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: Buffer Head Doubts
References: <Pine.OSF.4.10.10209031404270.9204-100000@moon.cdotd.ernet.in>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anil Kumar <anilk@cdotd.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anil Kumar wrote:
> 
> Hello All,
> 
>   I am going through the source code of linux kernel 2.5.32 and have some
>  simple doubts.
> 
> 1:What is  the philosophy behind introducing Address Space concept

That's a bit before my time, but...  I view the separation of the address_space
out of struct inode as providing a few things:

- A separation between the "control plane" and the "data plane", to use a
  networking analogy.  The address_space contains stuff to do with the data
  in the file, and the inode contains the control/metadata/security/other random
  stuff.  (Arguably, things like i_size, i_blkbits, i_blocks should be in the
  address_space, not the inode).

- Some filesystems (Coda) want to back their inodes by files on other filesystems.
  For example, a Code inode's i_mapping will point at an ext2 file's i_data.

- A filesystem may wish to manage additional metadata via the rich address_space
  functions in the core kernel.  For example, ext2 indirect blocks could be a
  filesystem-private address_space.  A file's indirects don't need all the other
  inode stuff - just the data plane operations.

> ...
>    What is meaning of  field assoc_mapping,private_lock  ?

For a successful fsync(), ext2 needs to write out and wait upon its
indirect blocks as well as the file data.  Those indirects are represented
by buffer_heads (a buffer_head is the kernel's abstraction for a disk block.
It doesn't "buffer" anything any more).

So each file maintains a list of buffer_heads at mapping.private_list.  These
are the buffers which need to be written for fsync.  mapping.private_list
is the base of a list of buffers, attached via buffer_head.b_assoc_buffers.

The locking for this list used to be a single kernel-wide lock.  In 2.5 that
got changed - the lock is the mapping.private_lock of the address_space which
contains the data for those buffers.  This is usually the i_mapping of the
blockdev which backs the filesystem.

mapping.assoc_mapping is the "associated mapping".  In practice it points
at the address_space which backs the buffers which are attached to private_list.
assoc_mapping is really only there so we can find the lock for the private_list.

These things have the anonymous "private_list/private_lock" identifiers
to indicate that these are private utility objects whose application
is defined by the address space's address_space_operations.  In practice
however, they can only contain buffer_heads, because a few parts of the core
kernel still assume that (destroy_inode, generic_osync_inode).

> 2: In buffer head structure
> 
> ...
>   What is this b_assoc_buffers and where used ?

See above - blockdev buffers attached to an S_ISREG file's private_list,
protected by the blockdev's i_mapping->private_lock.
 
> 3: In file buffer.c  before function definition  buffer_busy
> comment is given about  try_to_free_buffers
> 
> /*
>  * try_to_free_buffers() checks if all the buffers on this particular page
>  * are unused, and releases them if so.
>  *
>  * Exclusion against try_to_free_buffers may be obtained by either
>  * locking the page or by holding its mapping's private_lock.
>  *
>  * If the page is dirty but all the buffers are clean then we need to
>  * be sure to mark the page clean as well.  This is because the page
>  * may be against a block device, and a later reattachment of buffers
>  * to a dirty page will set *all* buffers dirty.  Which would corrupt
>  * filesystem data on the same device.
>  *
>  * The same applies to regular filesystem pages: if all the buffers are
>  * clean then we set the page clean and proceed.  To do that, we require
>  * total exclusion from __set_page_dirty_buffers().  That is obtained with
>  * private_lock.
>  *
>  * try_to_free_buffers() is non-blocking.
>  */
> 
>  I can not understand what exactly this comment  means ?

I do ;)  Have you any specific questions?
 
> and also why  code segment (between Line  /*--------*/ is there)
> in following code.
> 
> int try_to_free_buffers(struct page *page)
> {
>         struct address_space * const mapping = page->mapping;
>         struct buffer_head *buffers_to_free = NULL;
>         int ret = 0;
> 
>         BUG_ON(!PageLocked(page));
>         if (PageWriteback(page))
>                 return 0;
> /*----------------------------------------------------------------------*/
>         if (mapping == NULL) {          /* swapped-in anon page */
>                 ret = drop_buffers(page, &buffers_to_free);
>                 goto out;
>         }
> /*------------------------------------------------------------------------*/
> 
>         spin_lock(&mapping->private_lock);
>         ret = drop_buffers(page, &buffers_to_free);
>         if (ret && !PageSwapCache(page)) {
> 
> ...
> 
>   If mapping is NULL then why we need to drop_buffers in that case.How can
> buffer head be associated with an anonymous page ?

Um.  The comment is old.  It dates from the time when buffer_heads
were used as the IO container for swapdev I/O.

We don't do that any more - swap IO pages are encapsulated directly into
BIOs.

However this code path is still needed because we can very occasionally
see pages with a NULL ->mapping and attached buffers.  They occur when
truncate_complete_page() encounters a page with busy buffers (typically
the buffer is busy because it is attached to an in-progress ext3 transaction).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
