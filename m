Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65C116B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:42:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so20122832wmr.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 20:42:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id is10si2877124wjb.68.2016.06.15.20.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 20:42:18 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5G3dVYP095122
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:42:17 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23je2n9ts3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:42:17 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 09:12:13 +0530
Received: from d28relay08.in.ibm.com (d28relay08.in.ibm.com [9.184.220.159])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 336FBE0040
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:15:48 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5G3gAkV37945414
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:12:10 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5G3g8On006480
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:12:09 +0530
Date: Thu, 16 Jun 2016 09:12:07 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org> <1463754225-31311-3-git-send-email-minchan@kernel.org> <20160530013926.GB8683@bbox> <20160531000117.GB18314@bbox> <575E7F0B.8010201@linux.vnet.ibm.com> <20160615023249.GG17127@bbox> <5760F970.7060805@linux.vnet.ibm.com> <20160616002617.GM17127@bbox>
In-Reply-To: <20160616002617.GM17127@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5762200F.5040908@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 06/16/2016 05:56 AM, Minchan Kim wrote:
> On Wed, Jun 15, 2016 at 12:15:04PM +0530, Anshuman Khandual wrote:
>> On 06/15/2016 08:02 AM, Minchan Kim wrote:
>>> Hi,
>>>
>>> On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
>>>>> On 05/31/2016 05:31 AM, Minchan Kim wrote:
>>>>>>> @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>>>>>>  	int rc = -EAGAIN;
>>>>>>>  	int page_was_mapped = 0;
>>>>>>>  	struct anon_vma *anon_vma = NULL;
>>>>>>> +	bool is_lru = !__PageMovable(page);
>>>>>>>  
>>>>>>>  	if (!trylock_page(page)) {
>>>>>>>  		if (!force || mode == MIGRATE_ASYNC)
>>>>>>> @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>>>>>>  		goto out_unlock_both;
>>>>>>>  	}
>>>>>>>  
>>>>>>> +	if (unlikely(!is_lru)) {
>>>>>>> +		rc = move_to_new_page(newpage, page, mode);
>>>>>>> +		goto out_unlock_both;
>>>>>>> +	}
>>>>>>> +
>>>>>
>>>>> Hello Minchan,
>>>>>
>>>>> I might be missing something here but does this implementation support the
>>>>> scenario where these non LRU pages owned by the driver mapped as PTE into
>>>>> process page table ? Because the "goto out_unlock_both" statement above
>>>>> skips all the PTE unmap, putting a migration PTE and removing the migration
>>>>> PTE steps.
>>> You're right. Unfortunately, it doesn't support right now but surely,
>>> it's my TODO after landing this work.
>>>
>>> Could you share your usecase?
>>
>> Sure.
> 
> Thanks a lot!
> 
>>
>> My driver has privately managed non LRU pages which gets mapped into user space
>> process page table through f_ops->mmap() and vmops->fault() which then updates
>> the file RMAP (page->mapping->i_mmap) through page_add_file_rmap(page). One thing
> 
> Hmm, page_add_file_rmap is not exported function. How does your driver can use it?

Its not using the function directly, I just re-iterated the sequence of functions
above. (do_set_pte -> page_add_file_rmap) gets called after we grab the page from
driver through (__do_fault->vma->vm_ops->fault()).

> Do you use vm_insert_pfn?
> What type your vma is? VM_PFNMMAP or VM_MIXEDMAP?

I dont use vm_insert_pfn(). Here is the sequence of events how the user space
VMA gets the non LRU pages from the driver.

- Driver registers a character device with 'struct file_operations' binding
- Then the 'fops->mmap()' just binds the incoming 'struct vma' with a 'struct
  vm_operations_struct' which provides the 'vmops->fault()' routine which
  basically traps all page faults on the VMA and provides one page at a time
  through a driver specific allocation routine which hands over non LRU pages

The VMA is not anything special as such. Its what we get when we try to do a
simple mmap() on a file descriptor pointing to a character device. I can
figure out all the VM_* flags it holds after creation.

> 
> I want to make dummy driver to simulate your case.

Sure. I hope the above mentioned steps will help you but in case you need more
information, please do let me know.

> It would be very helpful to implement/test pte-mapped non-lru page
> migration feature. That's why I ask now.
> 
>> to note here is that the page->mapping eventually points to struct address_space
>> (file->f_mapping) which belongs to the character device file (created using mknod)
>> which we are using for establishing the mmap() regions in the user space.
>>
>> Now as per this new framework, all the page's are to be made __SetPageMovable before
>> passing the list down to migrate_pages(). Now __SetPageMovable() takes *new* struct
>> address_space as an argument and replaces the existing page->mapping. Now thats the
>> problem, we have lost all our connection to the existing file RMAP information. This
> 
> We could change __SetPageMovable doesn't need mapping argument.
> Instead, it just marks PAGE_MAPPING_MOVABLE into page->mapping.
> For that, user should take care of setting page->mapping earlier than
> marking the flag.

Sounds like a good idea, that way we dont loose the reverse mapping information.

> 
>> stands as a problem when we try to migrate these non LRU pages which are PTE mapped.
>> The rmap_walk_file() never finds them in the VMA, skips all the migrate PTE steps and
>> then the migration eventually fails.
>>
>> Seems like assigning a new struct address_space to the page through __SetPageMovable()
>> is the source of the problem. Can it take the existing (file->f_mapping) as an argument

> We can set existing file->f_mapping under the page_lock.

Thats another option along with what you mentioned above.

> 
>> in there ? Sure, but then can we override file system generic ->isolate(), ->putback(),
> 
> I don't get it. Why does it override file system generic functions?

Sure it does not, it was just an wild idea to over come the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
