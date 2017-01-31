Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7026B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:11:15 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e4so352737223pfg.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 21:11:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 68si14783848pft.186.2017.01.30.21.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 21:11:14 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V59IOD034665
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:11:13 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28a69e0nng-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:11:13 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 15:11:11 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 98D2C2CE8046
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:11:09 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0V5B13G6815818
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:11:09 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0V5AbY3006887
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:10:37 +1100
Subject: Re: [RFC V2 11/12] mm: Tag VMA with VM_CDM flag during page fault
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-12-khandual@linux.vnet.ibm.com>
 <5f1ec7f6-16d3-8653-4494-50e124916a9e@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 10:40:07 +0530
MIME-Version: 1.0
In-Reply-To: <5f1ec7f6-16d3-8653-4494-50e124916a9e@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <01ed36eb-bb1d-bb75-57f9-90159985e75e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 11:21 PM, Dave Hansen wrote:
> Here's the flag definition:
> 
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +#define VM_CDM		0x00800000	/* Contains coherent device memory */
>> +#endif
> 
> But it doesn't match the implementation:
> 
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +static void mark_vma_cdm(nodemask_t *nmask,
>> +		struct page *page, struct vm_area_struct *vma)
>> +{
>> +	if (!page)
>> +		return;
>> +
>> +	if (vma->vm_flags & VM_CDM)
>> +		return;
>> +
>> +	if (nmask && !nodemask_has_cdm(*nmask))
>> +		return;
>> +
>> +	if (is_cdm_node(page_to_nid(page)))
>> +		vma->vm_flags |= VM_CDM;
>> +}
> 
> That flag is a one-way trip.  Any VMA with that flag set on it will keep
> it for the life of the VMA, despite whether it has CDM pages in it now
> or not.  Even if you changed the policy back to one that doesn't allow
> CDM and forced all the pages to be migrated out.

Right, we have this limitation right now. But as I have mentioned in the
reply on the other thread, will work towards both static and runtime
re-evaluation of the VMA flag next time around.

> 
> This also assumes that the only way to get a page mapped into a VMA is
> via alloc_pages_vma().  Do the NUMA migration APIs use this path?

Right now I have just taken care of these two paths.

* Page fault path
* mbind() path

agreed, will work on the NUMA migration APIs paths next. Wondering if
I need to update for migrate_pages() kernel API also as it will be
used by the driver or should the driver tag the VMA explicitly knowing
what has just happened ? I had also mentioned about this in the cover
letter :) But as you have pointed out will move the documentation
to the patches.

"
VM_CDM tagged VMA:

There are two parts to this problem.

* How to mark a VMA with VM_CDM ?
	- During page fault path
	- During mbind(MPOL_BIND) call
	- Any other paths ?
	- Should a driver mark a VMA with VM_CDM explicitly ?

* How VM_CDM marked VMA gets treated ?

	- Disabled from auto NUMA migrations
	- Disabled from KSM merging
	- Anything else ?
"

> 
> When you *set* this flag, you don't go and turn off KSM merging, for
> instance.  You keep it from being turned on from this point forward, but
> you don't turn it off.

I was in the impression that the KSM merging does not start unless we
do madvise(MADV_MERGEABLE) call on the VMA (where its blocked now). I
might be missing something here if it can start before hand.

> 
> This is happening with mmap_sem held for read.  Correct?  Is it OK that
> you're modifying the VMA?  That vm_flags manipulation is non-atomic, so
> how can that even be safe?

Hmm. should it be done with mmap_sem being held for write. Will look
into this further. But intercepting the page faults inside alloc_pages_vma()
for tagging the VMA is okay from over all design perspective ?. Or this
should be moved up or down the call chain in the page fault path ?

> 
> If you're going to go down this route, I think you need to be very
> careful.  We need to ensure that when this flag gets set, it's never set
> on VMAs that are "normal" and will only be set on VMAs that were
> *explicitly* set up for accessing CDM.  That means that you'll need to
> make sure that there's no possible way to get a CDM page faulted into a
> VMA unless it's via an explicitly assigned policy that would have cause
> the VMA to be split from any "normal" one in the system.
> 
> This all makes me really nervous.

Got it, will work towards this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
