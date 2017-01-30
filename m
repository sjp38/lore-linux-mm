Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 550B56B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:51:27 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 194so462814544pgd.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:51:27 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p22si5236714pgc.160.2017.01.30.09.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 09:51:26 -0800 (PST)
Subject: Re: [RFC V2 11/12] mm: Tag VMA with VM_CDM flag during page fault
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-12-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5f1ec7f6-16d3-8653-4494-50e124916a9e@intel.com>
Date: Mon, 30 Jan 2017 09:51:25 -0800
MIME-Version: 1.0
In-Reply-To: <20170130033602.12275-12-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

Here's the flag definition:

> +#ifdef CONFIG_COHERENT_DEVICE
> +#define VM_CDM		0x00800000	/* Contains coherent device memory */
> +#endif

But it doesn't match the implementation:

> +#ifdef CONFIG_COHERENT_DEVICE
> +static void mark_vma_cdm(nodemask_t *nmask,
> +		struct page *page, struct vm_area_struct *vma)
> +{
> +	if (!page)
> +		return;
> +
> +	if (vma->vm_flags & VM_CDM)
> +		return;
> +
> +	if (nmask && !nodemask_has_cdm(*nmask))
> +		return;
> +
> +	if (is_cdm_node(page_to_nid(page)))
> +		vma->vm_flags |= VM_CDM;
> +}

That flag is a one-way trip.  Any VMA with that flag set on it will keep
it for the life of the VMA, despite whether it has CDM pages in it now
or not.  Even if you changed the policy back to one that doesn't allow
CDM and forced all the pages to be migrated out.

This also assumes that the only way to get a page mapped into a VMA is
via alloc_pages_vma().  Do the NUMA migration APIs use this path?

When you *set* this flag, you don't go and turn off KSM merging, for
instance.  You keep it from being turned on from this point forward, but
you don't turn it off.

This is happening with mmap_sem held for read.  Correct?  Is it OK that
you're modifying the VMA?  That vm_flags manipulation is non-atomic, so
how can that even be safe?

If you're going to go down this route, I think you need to be very
careful.  We need to ensure that when this flag gets set, it's never set
on VMAs that are "normal" and will only be set on VMAs that were
*explicitly* set up for accessing CDM.  That means that you'll need to
make sure that there's no possible way to get a CDM page faulted into a
VMA unless it's via an explicitly assigned policy that would have cause
the VMA to be split from any "normal" one in the system.

This all makes me really nervous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
