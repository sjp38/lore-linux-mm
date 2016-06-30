Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6C06B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 02:18:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u81so57976051oia.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 23:18:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m74si3040902ioi.125.2016.06.29.23.18.28
        for <linux-mm@kvack.org>;
        Wed, 29 Jun 2016 23:18:29 -0700 (PDT)
Date: Thu, 30 Jun 2016 15:18:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160630061856.GA10526@bbox>
References: <20160531000117.GB18314@bbox>
 <575E7F0B.8010201@linux.vnet.ibm.com>
 <20160615023249.GG17127@bbox>
 <5760F970.7060805@linux.vnet.ibm.com>
 <20160616002617.GM17127@bbox>
 <5762200F.5040908@linux.vnet.ibm.com>
 <20160616053754.GQ17127@bbox>
 <5770BEC5.3010807@linux.vnet.ibm.com>
 <20160628063912.GA25560@bbox>
 <5774B49D.6080000@linux.vnet.ibm.com>
MIME-Version: 1.0
In-Reply-To: <5774B49D.6080000@linux.vnet.ibm.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Thu, Jun 30, 2016 at 11:26:45AM +0530, Anshuman Khandual wrote:

<snip>

> >> Did you get a chance to test the driver out ? I am still concerned about how to
> >> handle the struct address_space override problem within the struct page.
> > 
> > Hi Anshuman,
> > 
> > Slow but I am working on that. :) However, as I said, I want to do it
> 
> I really appreciate. Was just curious about the problem and any potential
> solution we can look into.
> 
> > after soft landing of current non-lru-no-mapped page migration to solve
> > current real field issues.
> 
> yeah it makes sense.
> 
> > 
> > About the overriding problem of non-lru-mapped-page, I implemented dummy
> > driver as miscellaneous device and in test_mmap(file_operations.mmap),
> > I changed a_ops with my address_space_operations.
> > 
> > int test_mmap(struct file *filp, struct vm_area_struct *vma)
> > {
> >         filp->f_mapping->a_ops = &test_aops;
> >         vma->vm_ops = &test_vm_ops;
> >         vma->vm_private_data = filp->private_data;
> >         return 0;
> > }
> > 
> 
> Okay.
> 
> > test_aops should have *set_page_dirty* overriding.
> > 
> > static int test_set_pag_dirty(struct page *page)
> > {
> >         if (!PageDirty(page))
> >                 SetPageDirty*page);
> >         return 0;
> > }
> > 
> > Otherwise, it goes BUG_ON during radix tree operation because
> > currently try_to_unmap is designed for file-lru pages which lives
> > in page cache so it propagates page table dirty bit to PG_dirty flag
> > of struct page by set_page_dirty. And set_page_dirty want to mark
> > dirty tag in radix tree node but it's character driver so the page
> > cache doesn't have it. That's why we encounter BUG_ON in radix tree
> > operation. Anyway, to test, I implemented set_page_dirty in my dummy
> > driver.
> 
> Okay and the above test_set_page_dirty() example is sufficient ?

I guess just return 0 is sufficeint without any dirting a page.

> 
> > 
> > With only that, it doesn't work because I need to modify migrate.c to
> > work non-lru-mapped-page and changing PG_isolated flag which is
> > override of PG_reclaim which is cleared in set_page_dirty.
> 
> Got it, so what changes you did ? Implemented PG_isolated differently
> not by overriding PG_reclaim or something else ? Yes set_page_dirty
> indeed clears the PG_reclaim flag.
> 
> > 
> > With that, it seems to work. But I'm not saying it's right model now
> 
> So the mapped pages migration was successful ? Even after overloading
> filp->f_mapping->a_ops = &test_aops, we still have the RMAP information
> intact with filp->f_mappinp pointed interval tree. But would really like
> to see the code changes.
> 
> > for device drivers. In runtime, replacing filp->f_mapping->a_ops with
> > custom a_ops of own driver seems to be hacky to me.
> 
> Yeah I thought so.
> 
> > So, I'm considering now new pseudo fs "movable_inode" which will
> > support 
> > 
> > struct file *movable_inode_getfile(const char *name,
> >                         const struct file_operations *fop,
> >                         const struct address_space_operations *a_ops)
> > {
> >         struct path path;
> >         struct qstr this;
> >         struct inode *inode;
> >         struct super_block *sb;
> > 
> >         this.name = name;
> >         this.len = strlen(name);
> >         this.hash = 0;
> >         sb = movable_mnt.mnt_sb;
> >         patch.denty = d_alloc_pseudo(movable_inode_mnt->mnt_sb, &this);
> >         patch.mnt = mntget(movable_inode_mnt);
> >         
> >         inode = new_inode(sb);
> >         ..
> >         ..
> >         inode->i_mapping->a_ops = a_ops;
> >         d_instantiate(path.dentry, inode);
> > 
> >         return alloc_file(&path, FMODE_WRITE | FMODE_READ, f_op);
> > }
> > 
> > And in our driver, we can change vma->vm_file with new one.
> > 
> > int test_mmap(struct file *filp, struct vm_area_structd *vma)
> > {
> >         struct file *newfile = movable_inode_getfile("[test"],
> >                                 filep->f_op, &test_aops);
> >         vma->vm_file = newfile;
> >         ..
> >         ..
> > }
> > 
> > When I read mmap_region in mm/mmap.c, it's reasonable usecase
> > which dirver's mmap changes vma->vm_file with own file.
> 
> I will look into these details.
> 
> > Anyway, it needs many subtle changes in mm/vfs/driver side so
> > need to review from each maintainers related subsystem so I
> > want to not be hurry.
> 
> Sure, makes sense. Mean while it will be really great if you could share
> your code changes as described above, so that I can try them out.
> 

It's almost done for draft version and I'm doing stress test now and
fortunately, doesn't see the problem until now.

I will send you when I'm ready.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
