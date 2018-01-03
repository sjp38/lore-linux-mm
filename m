Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E43F6B032B
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:37:04 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id r58so828983qtc.7
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:37:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r13si515089qtb.84.2018.01.03.01.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 01:37:03 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w039YADh104120
	for <linux-mm@kvack.org>; Wed, 3 Jan 2018 04:37:02 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f8v9gh2wy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Jan 2018 04:37:02 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 3 Jan 2018 09:37:00 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <7dd106bd-460a-73a7-bae8-17ffe66a69ee@linux.vnet.ibm.com>
 <20180103085804.GA11319@dhcp22.suse.cz>
Date: Wed, 3 Jan 2018 15:06:49 +0530
MIME-Version: 1.0
In-Reply-To: <20180103085804.GA11319@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <32bec0c9-60e2-0362-9446-feb4de1b119c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 01/03/2018 02:28 PM, Michal Hocko wrote:
> On Wed 03-01-18 14:12:17, Anshuman Khandual wrote:
>> On 12/08/2017 09:45 PM, Michal Hocko wrote:
> [...]

[...]

>>
>> This reuses the existing page allocation helper from migrate_pages() system
>> call. But all these allocator helper names for migrate_pages() function are
>> really confusing. Even in this case alloc_new_node_page and the original
>> new_node_page() which is still getting used in do_migrate_range() sounds
>> similar even if their implementation is quite different. IMHO either all of
>> them should be moved to the header file with proper differentiating names
>> or let them be there in their respective files with these generic names and
>> clean them up later.
> 
> I believe I've tried that but I couldn't make them into a single header
> file easily because of header file dependencies. I agree that their
> names are quite confusing. Feel free to send a patch to clean this up.

Sure. Will try once this one gets into mmotm.

[...]

>>
>>
>> Just a nit. new_page_node() and store_status() seems different. Then why
>> the git diff looks so clumsy.
> 
> Kirill was suggesting to use --patience to general the diff which leads
> to a slightly better output. It has been posted as a separate email [1].
> Maybe you will find that one easier to review.
> 
> [1] http://lkml.kernel.org/r/20171213143948.GM25185@dhcp22.suse.cz

Yeah it does look better.

[...]

>>> -		return thp;
>>> -	} else
>>> -		return __alloc_pages_node(pm->node,
>>> -				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
>>> +	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
>>> +			MIGRATE_SYNC, MR_SYSCALL);
>>> +	if (err)
>>> +		putback_movable_pages(pagelist);
>>> +	return err;
>>>  }
>>
>> Even this one. IIUC, do_move_pages_to_node() migrate a chunk of pages
>> at a time which belong to the same target node. Perhaps the name should
>> suggest so. All these helper page migration helper functions sound so
>> similar.
> 
> What do you suggest? I find do_move_pages_to_node quite explicit on its
> purpose.

Sure. Not a big deal.

[...]

>>>  {
>>> +	struct vm_area_struct *vma;
>>> +	struct page *page;
>>> +	unsigned int follflags;
>>>  	int err;
>>> -	struct page_to_node *pp;
>>> -	LIST_HEAD(pagelist);
>>>  
>>>  	down_read(&mm->mmap_sem);
>>
>> Holding mmap_sem for individual pages makes sense. Current
>> implementation is holding it for an entire batch.
> 
> I didn't bother to optimize this path to be honest. It is true that lock
> batching can lead to improvements but that would complicate the code
> (how many patches to batch?) so I've left that for later if somebody
> actually sees any problem.
> 
>>> +	err = -EFAULT;
>>> +	vma = find_vma(mm, addr);
>>> +	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
>>
>> While here, should not we add 'addr > vma->vm_end' into this condition ?
> 
> No. See what find_vma does.
> 

Right.

> [...]
> 
> Please cut out the quoted reply to minimum

Sure will do.

> 
>>> @@ -1593,79 +1556,80 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
>>>  			 const int __user *nodes,
>>>  			 int __user *status, int flags)
>>>  {
>>> -	struct page_to_node *pm;
>>> -	unsigned long chunk_nr_pages;
>>> -	unsigned long chunk_start;
>>> -	int err;
>>> -
>>> -	err = -ENOMEM;
>>> -	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
>>> -	if (!pm)
>>> -		goto out;
>>> +	int chunk_node = NUMA_NO_NODE;
>>> +	LIST_HEAD(pagelist);
>>> +	int chunk_start, i;
>>> +	int err = 0, err1;
>>
>> err init might not be required, its getting assigned to -EFAULT right away.
> 
> No, nr_pages might be 0 AFAICS.

Right but there is another err = 0 after the for loop.

> 
> [...]
>>> +		if (chunk_node == NUMA_NO_NODE) {
>>> +			chunk_node = node;
>>> +			chunk_start = i;
>>> +		} else if (node != chunk_node) {
>>> +			err = do_move_pages_to_node(mm, &pagelist, chunk_node);
>>> +			if (err)
>>> +				goto out;
>>> +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
>>> +			if (err)
>>> +				goto out;
>>> +			chunk_start = i;
>>> +			chunk_node = node;
>>>  		}

[...]

>>> +		err = do_move_pages_to_node(mm, &pagelist, chunk_node);
>>> +		if (err)
>>> +			goto out;
>>> +		if (i > chunk_start) {
>>> +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
>>> +			if (err)
>>> +				goto out;
>>> +		}
>>> +		chunk_node = NUMA_NO_NODE;
>>
>> This block of code is bit confusing.
> 
> I believe this is easier to grasp when looking at the resulting code.
>>
>> 1) Why attempt to migrate when just one page could not be isolated ?
>> 2) 'i' is always greater than chunk_start except the starting page
>> 3) Why reset chunk_node as NUMA_NO_NODE ?
> 
> This is all about flushing the pending state on an error and
> distinguising a fresh batch.

Okay. Will test it out on a multi node system once I get hold of one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
