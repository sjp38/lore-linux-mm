Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C68A16B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 11:57:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so41333074pgq.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:57:43 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w67si53562239pgb.145.2016.12.14.08.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 08:57:42 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, dax: make pmd_fault() and friends to be the same
 as fault()
References: <148123286127.108913.2695398781030517780.stgit@djiang5-desk3.ch.intel.com>
 <20161213121535.GI15362@quack2.suse.cz>
 <e41d16fb-672d-1d61-b60d-6fd3a2201e41@intel.com>
 <20161214095719.GA18624@quack2.suse.cz>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <f27b102c-c745-c149-f12c-2d570bc1d2c1@intel.com>
Date: Wed, 14 Dec 2016 09:57:41 -0700
MIME-Version: 1.0
In-Reply-To: <20161214095719.GA18624@quack2.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org, linux-nvdimm@lists.01.org, david@fromorbit.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, dan.j.williams@intel.com, hch@lst.de



On 12/14/2016 02:57 AM, Jan Kara wrote:
> On Tue 13-12-16 11:29:54, Dave Jiang wrote:
>>
>>
>> On 12/13/2016 05:15 AM, Jan Kara wrote:
>>> On Thu 08-12-16 14:34:21, Dave Jiang wrote:
>>>> Instead of passing in multiple parameters in the pmd_fault() handler,
>>>> a vmf can be passed in just like a fault() handler. This will simplify
>>>> code and remove the need for the actual pmd fault handlers to allocate a
>>>> vmf. Related functions are also modified to do the same.
>>>>
>>>> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
>>>> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>>>
>>> I like the idea however see below:
>>>
>>>> @@ -1377,21 +1376,20 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>>>>  	if (iomap.offset + iomap.length < pos + PMD_SIZE)
>>>>  		goto unlock_entry;
>>>>  
>>>> -	vmf.pgoff = pgoff;
>>>> -	vmf.flags = flags;
>>>> -	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
>>>> +	vmf->pgoff = pgoff;
>>>> +	vmf->gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
>>>
>>> But now it's really unexpected that you change pgoff and gfp_mask because
>>> that will propagate back to the caller and if we return VM_FAULT_FALLBACK
>>> we may fault in wrong PTE because of this. So dax_iomap_pmd_fault() should
>>> not modify the passed gfp_mask, just make its callers clear __GFP_FS from
>>> it because *they* are responsible for acquiring locks / transactions that
>>> block __GFP_FS allocations. They are also responsible for restoring
>>> original gfp_mask once dax_iomap_pmd_fault() returns.
>>
>> Ok will fix.
>>
>>>
>>> dax_iomap_pmd_fault() needs to modify pgoff however it must restore it to
>>> the original value before it returns.
>>
>> Need clarification here. Do you mean "If" dax_iomap_pmd_fault() needs to
>> modify.... and right now it doesn't appear to need to modify pgoff so
>> nothing needs to be done? Thanks.
> 
> How come? I can see:
> 
> 	pgoff = linear_page_index(vma, pmd_addr);
> 
> a few lines above - we need to modify pgoff to contain huge page aligned
> file index instead of only page aligned...
> 
> 								Honza
> 

Yep. My mistake. I misunderstood. Will fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
