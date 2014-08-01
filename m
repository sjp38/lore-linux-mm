Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 954E86B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 04:27:46 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so5120787pde.32
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 01:27:46 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id sf3si8833135pbb.149.2014.08.01.01.27.44
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 01:27:45 -0700 (PDT)
Date: Fri, 1 Aug 2014 17:34:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
Message-ID: <20140801083446.GA2613@js1304-P5Q-DELUXE>
References: <53CDF437.4090306@lge.com>
 <20140722073005.GT3935@laptop>
 <20140722093838.GA22331@quack.suse.cz>
 <53D8A258.7010904@lge.com>
 <20140730101143.GB19205@quack.suse.cz>
 <53D985C0.3070300@lge.com>
 <20140731000355.GB25362@quack.suse.cz>
 <53D98FBB.6060700@lge.com>
 <20140731122114.GA5240@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140731122114.GA5240@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Gioh Kim <gioh.kim@lge.com>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On Thu, Jul 31, 2014 at 02:21:14PM +0200, Jan Kara wrote:
> On Thu 31-07-14 09:37:15, Gioh Kim wrote:
> > 
> > 
> > 2014-07-31 i??i ? 9:03, Jan Kara i?' e,?:
> > >On Thu 31-07-14 08:54:40, Gioh Kim wrote:
> > >>2014-07-30 i??i?? 7:11, Jan Kara i?' e,?:
> > >>>On Wed 30-07-14 16:44:24, Gioh Kim wrote:
> > >>>>2014-07-22 i??i?? 6:38, Jan Kara i?' e,?:
> > >>>>>On Tue 22-07-14 09:30:05, Peter Zijlstra wrote:
> > >>>>>>On Tue, Jul 22, 2014 at 02:18:47PM +0900, Gioh Kim wrote:
> > >>>>>>>Hello,
> > >>>>>>>
> > >>>>>>>This patch try to solve problem that a long-lasting page cache of
> > >>>>>>>ext4 superblock disturbs page migration.
> > >>>>>>>
> > >>>>>>>I've been testing CMA feature on my ARM-based platform
> > >>>>>>>and found some pages for page caches cannot be migrated.
> > >>>>>>>Some of them are page caches of superblock of ext4 filesystem.
> > >>>>>>>
> > >>>>>>>Current ext4 reads superblock with sb_bread(). sb_bread() allocates page
> > >>>>>>>from movable area. But the problem is that ext4 hold the page until
> > >>>>>>>it is unmounted. If root filesystem is ext4 the page cannot be migrated forever.
> > >>>>>>>
> > >>>>>>>I introduce a new API for allocating page from non-movable area.
> > >>>>>>>It is useful for ext4 and others that want to hold page cache for a long time.
> > >>>>>>
> > >>>>>>There's no word on why you can't teach ext4 to still migrate that page.
> > >>>>>>For all I know it might be impossible, but at least mention why.
> > >>>>
> > >>>>I am very sorry for lacking of details.
> > >>>>
> > >>>>In ext4_fill_super() the buffer-head of superblock is stored in sbi->s_sbh.
> > >>>>The page belongs to the buffer-head is allocated from movable area.
> > >>>>To migrate the page the buffer-head should be released via brelse().
> > >>>>But brelse() is not called until unmount.
> > >>>   Hum, I don't see where in the code do we check buffer_head use count. Can
> > >>>you please point me? Thanks.
> > >>
> > >>Filesystem code does not check buffer_head use count.  sb_bread() returns
> > >>the buffer_head that is included in bh_lru and has non-zero use count.
> > >>You can see the bh_lru code in buffer.c: __find_get_clock() and
> > >>lookup_bh_lru().  bh_lru_install() inserts the buffer_head into the
> > >>bh_lru().  It first calls get_bh() to increase the use count and insert
> > >>bh into the lru array.
> > >>
> > >>The buffer_head use count is non-zero until brelse() is called.
> > >   So I probably didn't phrase the question precisely enough. What I was
> > >asking about is where exactly *migration* code checks buffer use count?
> > >Because as I'm looking at buffer_migrate_page() we lock the buffers on a
> > >migrated page but we don't look at buffer use counts... So it seems to me
> > >that migration of a page with buffers should succeed even if buffer head
> > >has an elevated use count. Now I think that it *should* check the buffer
> > >use counts (it is dangerous to migrate buffers someone holds reference to)
> > >but I just cannot find that place. Or does CMA use some other migration
> > >function for buffer pages than buffer_migrate_page()?
> > 
> > CMA allocation function is cma_alloc().
> > Function flow is alloc_contig_range() -> __alloc_contig_migrate_range() -> migrate_pages -> unmap_and_move
> > -> __unmap_and_move -> try_to_free_buffers -> drop_buffers -> buffer_busy.
> > 
> > The buffer_busy() is checking b_count.
> > If buffer is busy buffer-cache cannot be removed.
> > So the page that includes buffer_head and the page that is refered by
> > buffer_head are not movable.
> > 
> > Is this what you need?
>   Yes, this is what I was asking about. Thanks! But as I'm looking into
> __unmap_and_move() it calls try_to_free_buffers() only if page->mapping ==
> NULL. As the comment before that test states, this can happen only for swap
> cache (not our case) or for pagecache pages that were truncated and not yet
> fully cleaned up. But superblock page cannot really be truncated. So I
> somewhat doubt you can hit the above path for a page holding superblock...

Hello,

Although page->mapping != NULL, mapping->a_ops->migratepage could be
NULL. This is the case of block_device. See def_blk_aops in
fs/block_dev.c. In this case, fallback_migrate_page() is called and
then try_to_release_page() and try_to_free_buffers() would be called.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
