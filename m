Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF926B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 20:04:00 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so1859319wgh.26
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 17:03:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si8512297wic.93.2014.07.30.17.03.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 17:03:58 -0700 (PDT)
Date: Thu, 31 Jul 2014 02:03:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
Message-ID: <20140731000355.GB25362@quack.suse.cz>
References: <53CDF437.4090306@lge.com>
 <20140722073005.GT3935@laptop>
 <20140722093838.GA22331@quack.suse.cz>
 <53D8A258.7010904@lge.com>
 <20140730101143.GB19205@quack.suse.cz>
 <53D985C0.3070300@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53D985C0.3070300@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Thu 31-07-14 08:54:40, Gioh Kim wrote:
> 2014-07-30 i??i?? 7:11, Jan Kara i?' e,?:
> >On Wed 30-07-14 16:44:24, Gioh Kim wrote:
> >>2014-07-22 i??i?? 6:38, Jan Kara i?' e,?:
> >>>On Tue 22-07-14 09:30:05, Peter Zijlstra wrote:
> >>>>On Tue, Jul 22, 2014 at 02:18:47PM +0900, Gioh Kim wrote:
> >>>>>Hello,
> >>>>>
> >>>>>This patch try to solve problem that a long-lasting page cache of
> >>>>>ext4 superblock disturbs page migration.
> >>>>>
> >>>>>I've been testing CMA feature on my ARM-based platform
> >>>>>and found some pages for page caches cannot be migrated.
> >>>>>Some of them are page caches of superblock of ext4 filesystem.
> >>>>>
> >>>>>Current ext4 reads superblock with sb_bread(). sb_bread() allocates page
> >>>>>from movable area. But the problem is that ext4 hold the page until
> >>>>>it is unmounted. If root filesystem is ext4 the page cannot be migrated forever.
> >>>>>
> >>>>>I introduce a new API for allocating page from non-movable area.
> >>>>>It is useful for ext4 and others that want to hold page cache for a long time.
> >>>>
> >>>>There's no word on why you can't teach ext4 to still migrate that page.
> >>>>For all I know it might be impossible, but at least mention why.
> >>
> >>I am very sorry for lacking of details.
> >>
> >>In ext4_fill_super() the buffer-head of superblock is stored in sbi->s_sbh.
> >>The page belongs to the buffer-head is allocated from movable area.
> >>To migrate the page the buffer-head should be released via brelse().
> >>But brelse() is not called until unmount.
> >   Hum, I don't see where in the code do we check buffer_head use count. Can
> >you please point me? Thanks.
> 
> Filesystem code does not check buffer_head use count.  sb_bread() returns
> the buffer_head that is included in bh_lru and has non-zero use count.
> You can see the bh_lru code in buffer.c: __find_get_clock() and
> lookup_bh_lru().  bh_lru_install() inserts the buffer_head into the
> bh_lru().  It first calls get_bh() to increase the use count and insert
> bh into the lru array.
> 
> The buffer_head use count is non-zero until brelse() is called.
  So I probably didn't phrase the question precisely enough. What I was
asking about is where exactly *migration* code checks buffer use count?
Because as I'm looking at buffer_migrate_page() we lock the buffers on a
migrated page but we don't look at buffer use counts... So it seems to me
that migration of a page with buffers should succeed even if buffer head
has an elevated use count. Now I think that it *should* check the buffer
use counts (it is dangerous to migrate buffers someone holds reference to)
but I just cannot find that place. Or does CMA use some other migration
function for buffer pages than buffer_migrate_page()?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
