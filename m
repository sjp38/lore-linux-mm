Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3716B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:50:30 -0500 (EST)
Received: by mail-yk0-f180.google.com with SMTP id 9so1880116ykp.11
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:50:30 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id z1si3409262ykb.29.2015.01.08.09.50.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 09:50:29 -0800 (PST)
Message-ID: <54AEC358.9000001@citrix.com>
Date: Thu, 8 Jan 2015 17:50:16 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: allow for an alternate set of pages for userspace
 mappings
References: <1420730924-22811-1-git-send-email-david.vrabel@citrix.com> <1420730924-22811-2-git-send-email-david.vrabel@citrix.com> <20150108172007.GB32079@phnom.home.cmpxchg.org>
In-Reply-To: <20150108172007.GB32079@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 08/01/15 17:20, Johannes Weiner wrote:
> On Thu, Jan 08, 2015 at 03:28:43PM +0000, David Vrabel wrote:
>> Add an optional array of pages to struct vm_area_struct that can be
>> used find the page backing a VMA.  This is useful in cases where the
>> normal mechanisms for finding the page don't work.  This array is only
>> inspected if the PTE is special.
>>
>> Splitting a VMA with such an array of pages is trivially done by
>> adjusting vma->pages.  The original creator of the VMA must only free
>> the page array once all sub-VMAs are closed (e.g., by ref-counting in
>> vm_ops->open and vm_ops->close).
>>
>> One use case is a Xen PV guest mapping foreign pages into userspace.
>>
>> In a Xen PV guest, the PTEs contain MFNs so get_user_pages() (for
>> example) must do an MFN to PFN (M2P) lookup before it can get the
>> page.  For foreign pages (those owned by another guest) the M2P lookup
>> returns the PFN as seen by the foreign guest (which would be
>> completely the wrong page for the local guest).
>>
>> This cannot be fixed up improving the M2P lookup since one MFN may be
>> mapped onto two or more pages so getting the right page is impossible
>> given just the MFN.
[...]
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -309,6 +309,14 @@ struct vm_area_struct {
>>  #ifdef CONFIG_NUMA
>>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>>  #endif
>> +	/*
>> +	 * Array of pages to override the default vm_normal_page()
>> +	 * result iff the PTE is special.
>> +	 *
>> +	 * The memory for this should be refcounted in vm_ops->open
>> +	 * and vm_ops->close.
>> +	 */
>> +	struct page **pages;
> 
> Please make this configuration-dependent, not every Linux user should
> have to pay for a Xen optimization.

If the additional field in struct vm_area_struct is a concern, I would
prefer to use a vm_flag bit and union pages with an existing field.

Perhaps using VM_PFNMAP and reusing vm_file?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
