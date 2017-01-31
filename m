Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED20D6B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 12:54:13 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so270223731pfd.0
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:54:13 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q2si6473874pge.319.2017.01.31.09.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 09:54:12 -0800 (PST)
Subject: Re: [RFC V2 11/12] mm: Tag VMA with VM_CDM flag during page fault
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-12-khandual@linux.vnet.ibm.com>
 <5f1ec7f6-16d3-8653-4494-50e124916a9e@intel.com>
 <01ed36eb-bb1d-bb75-57f9-90159985e75e@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <abc1d8b7-cde0-ac40-6664-c10694666659@intel.com>
Date: Tue, 31 Jan 2017 09:54:02 -0800
MIME-Version: 1.0
In-Reply-To: <01ed36eb-bb1d-bb75-57f9-90159985e75e@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 09:10 PM, Anshuman Khandual wrote:
>> This is happening with mmap_sem held for read.  Correct?  Is it OK that
>> you're modifying the VMA?  That vm_flags manipulation is non-atomic, so
>> how can that even be safe?
> Hmm. should it be done with mmap_sem being held for write. Will look
> into this further. But intercepting the page faults inside alloc_pages_vma()
> for tagging the VMA is okay from over all design perspective ?. Or this
> should be moved up or down the call chain in the page fault path ?

Doing it in the fault path seems wrong to me.

Apps have to take *explicit* action to go and get access to device
memory.  It seems like we should mark the VMA *then*, at the time of the
explicit action.  I also think _implying_ that we want KSM, etc...
turned off just because of the target of an mbind() is a bad idea.  Apps
have to ask for this stuff *explicitly*, so why not also have them turn
KSM off explicitly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
