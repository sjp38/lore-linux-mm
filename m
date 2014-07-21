Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 596E66B0039
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:33:52 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so10404344pab.16
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:33:52 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id qf7si15152979pbc.250.2014.07.21.12.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 12:33:50 -0700 (PDT)
Message-ID: <53CD6B1C.2010801@codeaurora.org>
Date: Mon, 21 Jul 2014 12:33:48 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv4 3/5] common: dma-mapping: Introduce common remapping
 functions
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org> <1404324218-4743-4-git-send-email-lauraa@codeaurora.org> <20140718135349.GB4608@arm.com>
In-Reply-To: <20140718135349.GB4608@arm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 7/18/2014 6:53 AM, Catalin Marinas wrote:
> On Wed, Jul 02, 2014 at 07:03:36PM +0100, Laura Abbott wrote:
>> +void *dma_common_pages_remap(struct page **pages, size_t size,
>> +			unsigned long vm_flags, pgprot_t prot,
>> +			const void *caller)
>> +{
>> +	struct vm_struct *area;
>> +
>> +	area = get_vm_area_caller(size, vm_flags, caller);
>> +	if (!area)
>> +		return NULL;
>> +
>> +	if (map_vm_area(area, prot, &pages)) {
>> +		vunmap(area->addr);
>> +		return NULL;
>> +	}
>> +
>> +	return area->addr;
>> +}
> 
> Why not just replace this function with vmap()? It is nearly identical.
> 

With this version, the caller stored and printed via /proc/vmallocinfo
is the actual caller of the DMA API whereas if we just call vmap we
don't get any useful caller information. Going to vmap would change
the existing behavior on ARM so it seems unwise to switch. Another
option is to move this into vmalloc.c and add vmap_caller.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
