Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD9D06B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 02:38:50 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id b13so14272979pat.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 23:38:50 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id ap9si31763501pad.30.2016.06.27.23.38.49
        for <linux-mm@kvack.org>;
        Mon, 27 Jun 2016 23:38:49 -0700 (PDT)
Date: Tue, 28 Jun 2016 15:39:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160628063912.GA25560@bbox>
References: <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox>
 <20160531000117.GB18314@bbox>
 <575E7F0B.8010201@linux.vnet.ibm.com>
 <20160615023249.GG17127@bbox>
 <5760F970.7060805@linux.vnet.ibm.com>
 <20160616002617.GM17127@bbox>
 <5762200F.5040908@linux.vnet.ibm.com>
 <20160616053754.GQ17127@bbox>
 <5770BEC5.3010807@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5770BEC5.3010807@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Mon, Jun 27, 2016 at 11:21:01AM +0530, Anshuman Khandual wrote:
> On 06/16/2016 11:07 AM, Minchan Kim wrote:
> > On Thu, Jun 16, 2016 at 09:12:07AM +0530, Anshuman Khandual wrote:
> >> On 06/16/2016 05:56 AM, Minchan Kim wrote:
> >>> On Wed, Jun 15, 2016 at 12:15:04PM +0530, Anshuman Khandual wrote:
> >>>> On 06/15/2016 08:02 AM, Minchan Kim wrote:
> >>>>> Hi,
> >>>>>
> >>>>> On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
> >>>>>>> On 05/31/2016 05:31 AM, Minchan Kim wrote:
> >>>>>>>>> @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >>>>>>>>>  	int rc = -EAGAIN;
> >>>>>>>>>  	int page_was_mapped = 0;
> >>>>>>>>>  	struct anon_vma *anon_vma = NULL;
> >>>>>>>>> +	bool is_lru = !__PageMovable(page);
> >>>>>>>>>  
> >>>>>>>>>  	if (!trylock_page(page)) {
> >>>>>>>>>  		if (!force || mode == MIGRATE_ASYNC)
> >>>>>>>>> @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >>>>>>>>>  		goto out_unlock_both;
> >>>>>>>>>  	}
> >>>>>>>>>  
> >>>>>>>>> +	if (unlikely(!is_lru)) {
> >>>>>>>>> +		rc = move_to_new_page(newpage, page, mode);
> >>>>>>>>> +		goto out_unlock_both;
> >>>>>>>>> +	}
> >>>>>>>>> +
> >>>>>>>
> >>>>>>> Hello Minchan,
> >>>>>>>
> >>>>>>> I might be missing something here but does this implementation support the
> >>>>>>> scenario where these non LRU pages owned by the driver mapped as PTE into
> >>>>>>> process page table ? Because the "goto out_unlock_both" statement above
> >>>>>>> skips all the PTE unmap, putting a migration PTE and removing the migration
> >>>>>>> PTE steps.
> >>>>> You're right. Unfortunately, it doesn't support right now but surely,
> >>>>> it's my TODO after landing this work.
> >>>>>
> >>>>> Could you share your usecase?
> >>>>
> >>>> Sure.
> >>>
> >>> Thanks a lot!
> >>>
> >>>>
> >>>> My driver has privately managed non LRU pages which gets mapped into user space
> >>>> process page table through f_ops->mmap() and vmops->fault() which then updates
> >>>> the file RMAP (page->mapping->i_mmap) through page_add_file_rmap(page). One thing
> >>>
> >>> Hmm, page_add_file_rmap is not exported function. How does your driver can use it?
> >>
> >> Its not using the function directly, I just re-iterated the sequence of functions
> >> above. (do_set_pte -> page_add_file_rmap) gets called after we grab the page from
> >> driver through (__do_fault->vma->vm_ops->fault()).
> >>
> >>> Do you use vm_insert_pfn?
> >>> What type your vma is? VM_PFNMMAP or VM_MIXEDMAP?
> >>
> >> I dont use vm_insert_pfn(). Here is the sequence of events how the user space
> >> VMA gets the non LRU pages from the driver.
> >>
> >> - Driver registers a character device with 'struct file_operations' binding
> >> - Then the 'fops->mmap()' just binds the incoming 'struct vma' with a 'struct
> >>   vm_operations_struct' which provides the 'vmops->fault()' routine which
> >>   basically traps all page faults on the VMA and provides one page at a time
> >>   through a driver specific allocation routine which hands over non LRU pages
> >>
> >> The VMA is not anything special as such. Its what we get when we try to do a
> >> simple mmap() on a file descriptor pointing to a character device. I can
> >> figure out all the VM_* flags it holds after creation.
> >>
> >>>
> >>> I want to make dummy driver to simulate your case.
> >>
> >> Sure. I hope the above mentioned steps will help you but in case you need more
> >> information, please do let me know.
> > 
> > I got understood now. :)
> > I will test it with dummy driver and will Cc'ed when I send a patch.
> 
> Hello Minchan,
> 
> Do you have any updates on this ? The V7 of the series still has this limitation.
> Did you get a chance to test the driver out ? I am still concerned about how to
> handle the struct address_space override problem within the struct page.

Hi Anshuman,

Slow but I am working on that. :) However, as I said, I want to do it
after soft landing of current non-lru-no-mapped page migration to solve
current real field issues.

About the overriding problem of non-lru-mapped-page, I implemented dummy
driver as miscellaneous device and in test_mmap(file_operations.mmap),
I changed a_ops with my address_space_operations.

int test_mmap(struct file *filp, struct vm_area_struct *vma)
{
        filp->f_mapping->a_ops = &test_aops;
        vma->vm_ops = &test_vm_ops;
        vma->vm_private_data = filp->private_data;
        return 0;
}

test_aops should have *set_page_dirty* overriding.

static int test_set_pag_dirty(struct page *page)
{
        if (!PageDirty(page))
                SetPageDirty*page);
        return 0;
}

Otherwise, it goes BUG_ON during radix tree operation because
currently try_to_unmap is designed for file-lru pages which lives
in page cache so it propagates page table dirty bit to PG_dirty flag
of struct page by set_page_dirty. And set_page_dirty want to mark
dirty tag in radix tree node but it's character driver so the page
cache doesn't have it. That's why we encounter BUG_ON in radix tree
operation. Anyway, to test, I implemented set_page_dirty in my dummy
driver.

With only that, it doesn't work because I need to modify migrate.c to
work non-lru-mapped-page and changing PG_isolated flag which is
override of PG_reclaim which is cleared in set_page_dirty.

With that, it seems to work. But I'm not saying it's right model now
for device drivers. In runtime, replacing filp->f_mapping->a_ops with
custom a_ops of own driver seems to be hacky to me.
So, I'm considering now new pseudo fs "movable_inode" which will
support 

struct file *movable_inode_getfile(const char *name,
                        const struct file_operations *fop,
                        const struct address_space_operations *a_ops)
{
        struct path path;
        struct qstr this;
        struct inode *inode;
        struct super_block *sb;

        this.name = name;
        this.len = strlen(name);
        this.hash = 0;
        sb = movable_mnt.mnt_sb;
        patch.denty = d_alloc_pseudo(movable_inode_mnt->mnt_sb, &this);
        patch.mnt = mntget(movable_inode_mnt);
        
        inode = new_inode(sb);
        ..
        ..
        inode->i_mapping->a_ops = a_ops;
        d_instantiate(path.dentry, inode);

        return alloc_file(&path, FMODE_WRITE | FMODE_READ, f_op);
}

And in our driver, we can change vma->vm_file with new one.

int test_mmap(struct file *filp, struct vm_area_structd *vma)
{
        struct file *newfile = movable_inode_getfile("[test"],
                                filep->f_op, &test_aops);
        vma->vm_file = newfile;
        ..
        ..
}

When I read mmap_region in mm/mmap.c, it's reasonable usecase
which dirver's mmap changes vma->vm_file with own file.

Anyway, it needs many subtle changes in mm/vfs/driver side so
need to review from each maintainers related subsystem so I
want to not be hurry.

Thanks.

> 
> - Anshuman
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
