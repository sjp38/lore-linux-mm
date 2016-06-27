Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD8D26B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:51:14 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id he1so321371929pac.0
        for <linux-mm@kvack.org>; Sun, 26 Jun 2016 22:51:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c83si2851423pfd.8.2016.06.26.22.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jun 2016 22:51:13 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5R5hmsk021251
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:51:13 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23sjufu270-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:51:13 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 27 Jun 2016 11:21:09 +0530
Received: from d28relay08.in.ibm.com (d28relay08.in.ibm.com [9.184.220.159])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 91586125804F
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 11:23:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5R5p5BZ34013374
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 11:21:05 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5R5p2Vm020763
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 11:21:05 +0530
Date: Mon, 27 Jun 2016 11:21:01 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org> <1463754225-31311-3-git-send-email-minchan@kernel.org> <20160530013926.GB8683@bbox> <20160531000117.GB18314@bbox> <575E7F0B.8010201@linux.vnet.ibm.com> <20160615023249.GG17127@bbox> <5760F970.7060805@linux.vnet.ibm.com> <20160616002617.GM17127@bbox> <5762200F.5040908@linux.vnet.ibm.com> <20160616053754.GQ17127@bbox>
In-Reply-To: <20160616053754.GQ17127@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5770BEC5.3010807@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 06/16/2016 11:07 AM, Minchan Kim wrote:
> On Thu, Jun 16, 2016 at 09:12:07AM +0530, Anshuman Khandual wrote:
>> On 06/16/2016 05:56 AM, Minchan Kim wrote:
>>> On Wed, Jun 15, 2016 at 12:15:04PM +0530, Anshuman Khandual wrote:
>>>> On 06/15/2016 08:02 AM, Minchan Kim wrote:
>>>>> Hi,
>>>>>
>>>>> On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
>>>>>>> On 05/31/2016 05:31 AM, Minchan Kim wrote:
>>>>>>>>> @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>>>>>>>>  	int rc = -EAGAIN;
>>>>>>>>>  	int page_was_mapped = 0;
>>>>>>>>>  	struct anon_vma *anon_vma = NULL;
>>>>>>>>> +	bool is_lru = !__PageMovable(page);
>>>>>>>>>  
>>>>>>>>>  	if (!trylock_page(page)) {
>>>>>>>>>  		if (!force || mode == MIGRATE_ASYNC)
>>>>>>>>> @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>>>>>>>>>  		goto out_unlock_both;
>>>>>>>>>  	}
>>>>>>>>>  
>>>>>>>>> +	if (unlikely(!is_lru)) {
>>>>>>>>> +		rc = move_to_new_page(newpage, page, mode);
>>>>>>>>> +		goto out_unlock_both;
>>>>>>>>> +	}
>>>>>>>>> +
>>>>>>>
>>>>>>> Hello Minchan,
>>>>>>>
>>>>>>> I might be missing something here but does this implementation support the
>>>>>>> scenario where these non LRU pages owned by the driver mapped as PTE into
>>>>>>> process page table ? Because the "goto out_unlock_both" statement above
>>>>>>> skips all the PTE unmap, putting a migration PTE and removing the migration
>>>>>>> PTE steps.
>>>>> You're right. Unfortunately, it doesn't support right now but surely,
>>>>> it's my TODO after landing this work.
>>>>>
>>>>> Could you share your usecase?
>>>>
>>>> Sure.
>>>
>>> Thanks a lot!
>>>
>>>>
>>>> My driver has privately managed non LRU pages which gets mapped into user space
>>>> process page table through f_ops->mmap() and vmops->fault() which then updates
>>>> the file RMAP (page->mapping->i_mmap) through page_add_file_rmap(page). One thing
>>>
>>> Hmm, page_add_file_rmap is not exported function. How does your driver can use it?
>>
>> Its not using the function directly, I just re-iterated the sequence of functions
>> above. (do_set_pte -> page_add_file_rmap) gets called after we grab the page from
>> driver through (__do_fault->vma->vm_ops->fault()).
>>
>>> Do you use vm_insert_pfn?
>>> What type your vma is? VM_PFNMMAP or VM_MIXEDMAP?
>>
>> I dont use vm_insert_pfn(). Here is the sequence of events how the user space
>> VMA gets the non LRU pages from the driver.
>>
>> - Driver registers a character device with 'struct file_operations' binding
>> - Then the 'fops->mmap()' just binds the incoming 'struct vma' with a 'struct
>>   vm_operations_struct' which provides the 'vmops->fault()' routine which
>>   basically traps all page faults on the VMA and provides one page at a time
>>   through a driver specific allocation routine which hands over non LRU pages
>>
>> The VMA is not anything special as such. Its what we get when we try to do a
>> simple mmap() on a file descriptor pointing to a character device. I can
>> figure out all the VM_* flags it holds after creation.
>>
>>>
>>> I want to make dummy driver to simulate your case.
>>
>> Sure. I hope the above mentioned steps will help you but in case you need more
>> information, please do let me know.
> 
> I got understood now. :)
> I will test it with dummy driver and will Cc'ed when I send a patch.

Hello Minchan,

Do you have any updates on this ? The V7 of the series still has this limitation.
Did you get a chance to test the driver out ? I am still concerned about how to
handle the struct address_space override problem within the struct page.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
