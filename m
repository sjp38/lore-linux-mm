Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4EAC6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:23:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p20so26534425pfj.2
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:23:37 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id y38si537033plh.1023.2017.08.08.01.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:23:36 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id l64so11958408pge.5
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:23:36 -0700 (PDT)
Date: Tue, 8 Aug 2017 17:23:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 5/6] zram: remove zram_rw_page
Message-ID: <20170808082350.GD7765@jagdpanzerIV.localdomain>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-6-git-send-email-minchan@kernel.org>
 <20170808070226.GC7765@jagdpanzerIV.localdomain>
 <20170808081338.GA30908@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808081338.GA30908@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello Minchan,

On (08/08/17 17:13), Minchan Kim wrote:
> Hi Sergey,
> 
> On Tue, Aug 08, 2017 at 04:02:26PM +0900, Sergey Senozhatsky wrote:
> > On (08/08/17 15:50), Minchan Kim wrote:
> > > With on-stack-bio, rw_page interface doesn't provide a clear performance
> > > benefit for zram and surely has a maintenance burden, so remove the
> > > last user to remove rw_page completely.
> > 
> > OK, never really liked it, I think we had that conversation before.
> > 
> > as far as I remember, zram_rw_page() was the reason we had to do some
> > tricks with init_lock to make lockdep happy. may be now we can "simplify"
> > the things back.
> 
> I cannot remember. Blame my brain. ;-)

no worries. I didn't remember it clearly as well, hence the "may be" part.

commit 08eee69fcf6baea543a2b4d2a2fcba0e61aa3160
Author: Minchan Kim

    zram: remove init_lock in zram_make_request
    
    Admin could reset zram during I/O operation going on so we have used
    zram->init_lock as read-side lock in I/O path to prevent sudden zram
    meta freeing.
    
    However, the init_lock is really troublesome.  We can't do call
    zram_meta_alloc under init_lock due to lockdep splat because
    zram_rw_page is one of the function under reclaim path and hold it as
    read_lock while other places in process context hold it as write_lock.
    So, we have used allocation out of the lock to avoid lockdep warn but
    it's not good for readability and fainally, I met another lockdep splat
    between init_lock and cpu_hotplug from kmem_cache_destroy during working
    zsmalloc compaction.  :(
    
    Yes, the ideal is to remove horrible init_lock of zram in rw path.  This
    patch removes it in rw path and instead, add atomic refcount for meta
    lifetime management and completion to free meta in process context.
    It's important to free meta in process context because some of resource
    destruction needs mutex lock, which could be held if we releases the
    resource in reclaim context so it's deadlock, again.
    
    As a bonus, we could remove init_done check in rw path because
    zram_meta_get will do a role for it, instead.

> Anyway, it's always welcome to make thing simple.
> Could you send a patch after settle down this patchset?

well, if it will improve anything after all :)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
