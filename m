Date: Tue, 3 Sep 2002 14:11:12 +0500 (GMT+0500)
From: Anil Kumar <anilk@cdotd.ernet.in>
Subject: Buffer Head Doubts 
Message-ID: <Pine.OSF.4.10.10209031404270.9204-100000@moon.cdotd.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello All,

  I am going through the source code of linux kernel 2.5.32 and have some 
 simple doubts.
 
1:What is  the philosophy behind introducing Address Space concept 
  

struct address_space{

        struct inode            *host;          /* owner: inode,  
block_device */
        struct radix_tree_root  page_tree;      /* radix tree of all pages
*/   
        rwlock_t                page_lock;      /* and rwlock protecting
it */
        struct list_head        clean_pages;    /* list of clean pages */
        struct list_head        dirty_pages;    /* list of dirty pages */
        struct list_head        locked_pages;   /* list of locked pages */
        struct list_head        io_pages;       /* being prepared for I/O
*/
        unsigned long           nrpages;        /* number of total pages
*/
        struct address_space_operations *a_ops; /* methods */
        list_t                  i_mmap;         /* list of private
mappings */
        list_t                  i_mmap_shared;  /* list of private
mappings */
        spinlock_t              i_shared_lock;  /* and spinlock protecting
it */
        unsigned long           dirtied_when;   /* jiffies of first page
dirtying */
        int                     gfp_mask;       /* how to allocate the
pages */
        struct backing_dev_info *backing_dev_info; /* device readahead,
etc */
        spinlock_t               private_lock;   /* for use by the
address_space*/
        struct list_head        private_list;   /* ditto */
        struct address_space    *assoc_mapping; /* ditto */
};

   What is meaning of  field assoc_mapping,private_lock  ?
 
2: In buffer head structure

struct buffer_head {
        /* First cache line: */
        unsigned long b_state;          /* buffer state bitmap (see above)
*/
        atomic_t b_count;               /* users using this block */
        struct buffer_head *b_this_page;/* circular list of page's buffers
*/
        struct page *b_page;            /* the page this bh is mapped to
*/

        sector_t b_blocknr;             /* block number */
        u32 b_size;                     /* block size */
        char *b_data;                   /* pointer to data block */

        struct block_device *b_bdev;
        bh_end_io_t *b_end_io;          /* I/O completion */
        void *b_private;                /* reserved for b_end_io */
        struct list_head b_assoc_buffers; /* associated with another
mapping */
};

  What is this b_assoc_buffers and where used ?

3: In file buffer.c  before function definition  buffer_busy
comment is given about  try_to_free_buffers

/*
 * try_to_free_buffers() checks if all the buffers on this particular page
 * are unused, and releases them if so.
 *
 * Exclusion against try_to_free_buffers may be obtained by either
 * locking the page or by holding its mapping's private_lock.
 *
 * If the page is dirty but all the buffers are clean then we need to
 * be sure to mark the page clean as well.  This is because the page
 * may be against a block device, and a later reattachment of buffers
 * to a dirty page will set *all* buffers dirty.  Which would corrupt
 * filesystem data on the same device.
 *
 * The same applies to regular filesystem pages: if all the buffers are
 * clean then we set the page clean and proceed.  To do that, we require
 * total exclusion from __set_page_dirty_buffers().  That is obtained with
 * private_lock.
 *
 * try_to_free_buffers() is non-blocking.
 */

 I can not understand what exactly this comment  means ?

and also why  code segment (between Line  /*--------*/ is there)
in following code.

int try_to_free_buffers(struct page *page)
{
        struct address_space * const mapping = page->mapping;
        struct buffer_head *buffers_to_free = NULL;
        int ret = 0;

        BUG_ON(!PageLocked(page));
        if (PageWriteback(page))
                return 0;
/*----------------------------------------------------------------------*/
        if (mapping == NULL) {          /* swapped-in anon page */
                ret = drop_buffers(page, &buffers_to_free);
                goto out;
        }
/*------------------------------------------------------------------------*/

        spin_lock(&mapping->private_lock);
        ret = drop_buffers(page, &buffers_to_free);
        if (ret && !PageSwapCache(page)) {

...


  If mapping is NULL then why we need to drop_buffers in that case.How can
buffer head be associated with an anonymous page ?

Regards,
Anil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
