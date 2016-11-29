Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 671556B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:43:03 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id m67so144226471qkf.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:43:03 -0800 (PST)
Received: from mail-qt0-f178.google.com (mail-qt0-f178.google.com. [209.85.216.178])
        by mx.google.com with ESMTPS id 21si36019399qkj.43.2016.11.29.14.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 14:43:02 -0800 (PST)
Received: by mail-qt0-f178.google.com with SMTP id n6so171214404qtd.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:43:02 -0800 (PST)
Subject: Re: [PATCHv4 06/10] xen: Switch to using __pa_symbol
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-7-git-send-email-labbott@redhat.com>
 <935fefbf-97dc-83fc-b7c3-ba3f19f2087f@oracle.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <b7bcf276-6983-7eef-07a9-890ad7158789@redhat.com>
Date: Tue, 29 Nov 2016 14:42:58 -0800
MIME-Version: 1.0
In-Reply-To: <935fefbf-97dc-83fc-b7c3-ba3f19f2087f@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org

On 11/29/2016 02:26 PM, Boris Ostrovsky wrote:
> On 11/29/2016 01:55 PM, Laura Abbott wrote:
>> __pa_symbol is the correct macro to use on kernel
>> symbols. Switch to this from __pa.
>>
>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>> Found during a sweep of the kernel. Untested.
>> ---
>>  drivers/xen/xenbus/xenbus_dev_backend.c | 2 +-
>>  drivers/xen/xenfs/xenstored.c           | 2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenbus/xenbus_dev_backend.c
>> index 4a41ac9..31ca2bf 100644
>> --- a/drivers/xen/xenbus/xenbus_dev_backend.c
>> +++ b/drivers/xen/xenbus/xenbus_dev_backend.c
>> @@ -99,7 +99,7 @@ static int xenbus_backend_mmap(struct file *file, struct vm_area_struct *vma)
>>  		return -EINVAL;
>>  
>>  	if (remap_pfn_range(vma, vma->vm_start,
>> -			    virt_to_pfn(xen_store_interface),
>> +			    PHYS_PFN(__pa_symbol(xen_store_interface)),
>>  			    size, vma->vm_page_prot))
>>  		return -EAGAIN;
>>  
>> diff --git a/drivers/xen/xenfs/xenstored.c b/drivers/xen/xenfs/xenstored.c
>> index fef20db..21009ea 100644
>> --- a/drivers/xen/xenfs/xenstored.c
>> +++ b/drivers/xen/xenfs/xenstored.c
>> @@ -38,7 +38,7 @@ static int xsd_kva_mmap(struct file *file, struct vm_area_struct *vma)
>>  		return -EINVAL;
>>  
>>  	if (remap_pfn_range(vma, vma->vm_start,
>> -			    virt_to_pfn(xen_store_interface),
>> +			    PHYS_PFN(__pa_symbol(xen_store_interface)),
>>  			    size, vma->vm_page_prot))
>>  		return -EAGAIN;
>>  
> 
> 
> I suspect this won't work --- xen_store_interface doesn't point to a
> kernel symbol.
> 
> -boris
> 

I reviewed this again and yes you are right. I missed that this
was a pointer and not just a symbol so I think this patch can
just be dropped.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
