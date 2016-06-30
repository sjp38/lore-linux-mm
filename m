Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB0A6B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:57:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ao6so130801254pac.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 22:57:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h18si2682263pfk.107.2016.06.29.22.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 22:57:02 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5U5rrp3102593
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:57:01 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23uwnn63cm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:57:01 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 30 Jun 2016 11:26:58 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 103E9E006C
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 11:30:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5U5ukVb23265500
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 11:26:46 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5U5uofU019175
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 11:26:52 +0530
Date: Thu, 30 Jun 2016 11:26:45 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-3-git-send-email-minchan@kernel.org> <20160530013926.GB8683@bbox> <20160531000117.GB18314@bbox> <575E7F0B.8010201@linux.vnet.ibm.com> <20160615023249.GG17127@bbox> <5760F970.7060805@linux.vnet.ibm.com> <20160616002617.GM17127@bbox> <5762200F.5040908@linux.vnet.ibm.com> <20160616053754.GQ17127@bbox> <5770BEC5.3010807@linux.vnet.ibm.com> <20160628063912.GA25560@bbox>
In-Reply-To: <20160628063912.GA25560@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5774B49D.6080000@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 06/28/2016 12:09 PM, Minchan Kim wrote:
> On Mon, Jun 27, 2016 at 11:21:01AM +0530, Anshuman Khandual wrote:
>> On 06/16/2016 11:07 AM, Minchan Kim wrote:
>>> On Thu, Jun 16, 2016 at 09:12:07AM +0530, Anshuman Khandual wrote:
>>>> On 06/16/2016 05:56 AM, Minchan Kim wrote:
>>>>> On Wed, Jun 15, 2016 at 12:15:04PM +0530, Anshuman Khandual wrote:
>>>>>> On 06/15/2016 08:02 AM, Minchan Kim wrote:
>>>>>>> Hi,
>>>>>>>
>>>>>>> On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
>>>>>>>>> On 05/31/2016 05:31 AM, Minchan Kim wrote:
>>>>>>>>>>> @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>>>>>>>>>>  	int rc = -EAGAIN;
>>>>>>>>>>>  	int page_was_mapped = 0;
>>>>>>>>>>>  	struct anon_vma *anon_vma = NULL;
>>>>>>>>>>> +	bool is_lru = !__PageMovable(page);
>>>>>>>>>>>  
>>>>>>>>>>>  	if (!trylock_page(page)) {
>>>>>>>>>>>  		if (!force || mode == MIGRATE_ASYNC)
>>>>>>>>>>> @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>>>>>>>>>>  		goto out_unlock_both;
>>>>>>>>>>>  	}
>>>>>>>>>>>  
>>>>>>>>>>> +	if (unlikely(!is_lru)) {
>>>>>>>>>>> +		rc = move_to_new_page(newpage, page, mode);
>>>>>>>>>>> +		goto out_unlock_both;
>>>>>>>>>>> +	}
>>>>>>>>>>> +
>>>>>>>>>
>>>>>>>>> Hello Minchan,
>>>>>>>>>
>>>>>>>>> I might be missing something here but does this implementation support the
>>>>>>>>> scenario where these non LRU pages owned by the driver mapped as PTE into
>>>>>>>>> process page table ? Because the "goto out_unlock_both" statement above
>>>>>>>>> skips all the PTE unmap, putting a migration PTE and removing the migration
>>>>>>>>> PTE steps.
>>>>>>> You're right. Unfortunately, it doesn't support right now but surely,
>>>>>>> it's my TODO after landing this work.
>>>>>>>
>>>>>>> Could you share your usecase?
>>>>>>
>>>>>> Sure.
>>>>>
>>>>> Thanks a lot!
>>>>>
>>>>>>
>>>>>> My driver has privately managed non LRU pages which gets mapped into user space
>>>>>> process page table through f_ops->mmap() and vmops->fault() which then updates
>>>>>> the file RMAP (page->mapping->i_mmap) through page_add_file_rmap(page). One thing
>>>>>
>>>>> Hmm, page_add_file_rmap is not exported function. How does your driver can use it?
>>>>
>>>> Its not using the function directly, I just re-iterated the sequence of functions
>>>> above. (do_set_pte -> page_add_file_rmap) gets called after we grab the page from
>>>> driver through (__do_fault->vma->vm_ops->fault()).
>>>>
>>>>> Do you use vm_insert_pfn?
>>>>> What type your vma is? VM_PFNMMAP or VM_MIXEDMAP?
>>>>
>>>> I dont use vm_insert_pfn(). Here is the sequence of events how the user space
>>>> VMA gets the non LRU pages from the driver.
>>>>
>>>> - Driver registers a character device with 'struct file_operations' binding
>>>> - Then the 'fops->mmap()' just binds the incoming 'struct vma' with a 'struct
>>>>   vm_operations_struct' which provides the 'vmops->fault()' routine which
>>>>   basically traps all page faults on the VMA and provides one page at a time
>>>>   through a driver specific allocation routine which hands over non LRU pages
>>>>
>>>> The VMA is not anything special as such. Its what we get when we try to do a
>>>> simple mmap() on a file descriptor pointing to a character device. I can
>>>> figure out all the VM_* flags it holds after creation.
>>>>
>>>>>
>>>>> I want to make dummy driver to simulate your case.
>>>>
>>>> Sure. I hope the above mentioned steps will help you but in case you need more
>>>> information, please do let me know.
>>>
>>> I got understood now. :)
>>> I will test it with dummy driver and will Cc'ed when I send a patch.
>>
>> Hello Minchan,
>>
>> Do you have any updates on this ? The V7 of the series still has this limitation.
>> Did you get a chance to test the driver out ? I am still concerned about how to
>> handle the struct address_space override problem within the struct page.
> 
> Hi Anshuman,
> 
> Slow but I am working on that. :) However, as I said, I want to do it

I really appreciate. Was just curious about the problem and any potential
solution we can look into.

> after soft landing of current non-lru-no-mapped page migration to solve
> current real field issues.

yeah it makes sense.

> 
> About the overriding problem of non-lru-mapped-page, I implemented dummy
> driver as miscellaneous device and in test_mmap(file_operations.mmap),
> I changed a_ops with my address_space_operations.
> 
> int test_mmap(struct file *filp, struct vm_area_struct *vma)
> {
>         filp->f_mapping->a_ops = &test_aops;
>         vma->vm_ops = &test_vm_ops;
>         vma->vm_private_data = filp->private_data;
>         return 0;
> }
> 

Okay.

> test_aops should have *set_page_dirty* overriding.
> 
> static int test_set_pag_dirty(struct page *page)
> {
>         if (!PageDirty(page))
>                 SetPageDirty*page);
>         return 0;
> }
> 
> Otherwise, it goes BUG_ON during radix tree operation because
> currently try_to_unmap is designed for file-lru pages which lives
> in page cache so it propagates page table dirty bit to PG_dirty flag
> of struct page by set_page_dirty. And set_page_dirty want to mark
> dirty tag in radix tree node but it's character driver so the page
> cache doesn't have it. That's why we encounter BUG_ON in radix tree
> operation. Anyway, to test, I implemented set_page_dirty in my dummy
> driver.

Okay and the above test_set_page_dirty() example is sufficient ?

> 
> With only that, it doesn't work because I need to modify migrate.c to
> work non-lru-mapped-page and changing PG_isolated flag which is
> override of PG_reclaim which is cleared in set_page_dirty.

Got it, so what changes you did ? Implemented PG_isolated differently
not by overriding PG_reclaim or something else ? Yes set_page_dirty
indeed clears the PG_reclaim flag.

> 
> With that, it seems to work. But I'm not saying it's right model now

So the mapped pages migration was successful ? Even after overloading
filp->f_mapping->a_ops = &test_aops, we still have the RMAP information
intact with filp->f_mappinp pointed interval tree. But would really like
to see the code changes.

> for device drivers. In runtime, replacing filp->f_mapping->a_ops with
> custom a_ops of own driver seems to be hacky to me.

Yeah I thought so.

> So, I'm considering now new pseudo fs "movable_inode" which will
> support 
> 
> struct file *movable_inode_getfile(const char *name,
>                         const struct file_operations *fop,
>                         const struct address_space_operations *a_ops)
> {
>         struct path path;
>         struct qstr this;
>         struct inode *inode;
>         struct super_block *sb;
> 
>         this.name = name;
>         this.len = strlen(name);
>         this.hash = 0;
>         sb = movable_mnt.mnt_sb;
>         patch.denty = d_alloc_pseudo(movable_inode_mnt->mnt_sb, &this);
>         patch.mnt = mntget(movable_inode_mnt);
>         
>         inode = new_inode(sb);
>         ..
>         ..
>         inode->i_mapping->a_ops = a_ops;
>         d_instantiate(path.dentry, inode);
> 
>         return alloc_file(&path, FMODE_WRITE | FMODE_READ, f_op);
> }
> 
> And in our driver, we can change vma->vm_file with new one.
> 
> int test_mmap(struct file *filp, struct vm_area_structd *vma)
> {
>         struct file *newfile = movable_inode_getfile("[test"],
>                                 filep->f_op, &test_aops);
>         vma->vm_file = newfile;
>         ..
>         ..
> }
> 
> When I read mmap_region in mm/mmap.c, it's reasonable usecase
> which dirver's mmap changes vma->vm_file with own file.

I will look into these details.

> Anyway, it needs many subtle changes in mm/vfs/driver side so
> need to review from each maintainers related subsystem so I
> want to not be hurry.

Sure, makes sense. Mean while it will be really great if you could share
your code changes as described above, so that I can try them out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
