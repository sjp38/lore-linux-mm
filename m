Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0A986B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:41:41 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id j26so5919321iod.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 03:41:41 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b189si10109601oii.14.2017.09.14.03.41.39
        for <linux-mm@kvack.org>;
        Thu, 14 Sep 2017 03:41:39 -0700 (PDT)
Subject: Re: [PATCH v6 05/11] arm64/mm: Add support for XPFO
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-6-tycho@docker.com>
 <20170908075347.GC4957@infradead.org>
 <20170908172422.rxmhwd2vl6eye2or@docker>
From: Julien Grall <julien.grall@arm.com>
Message-ID: <d637a56d-399d-fefa-806b-a9e2b0babb75@arm.com>
Date: Thu, 14 Sep 2017 11:41:34 +0100
MIME-Version: 1.0
In-Reply-To: <20170908172422.rxmhwd2vl6eye2or@docker>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, Christoph Hellwig <hch@infradead.org>
Cc: Marco Benatto <marco.antonio.780@gmail.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Juerg Haefliger <juerg.haefliger@canonical.com>, xen-devel@lists.xenproject.org, linux-arm-kernel@lists.infradead.org, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>

Hi,

CC Juergen, Boris and Stefano.

On 08/09/17 18:24, Tycho Andersen wrote:
> On Fri, Sep 08, 2017 at 12:53:47AM -0700, Christoph Hellwig wrote:
>>> +/*
>>> + * Lookup the page table entry for a virtual address and return a pointer to
>>> + * the entry. Based on x86 tree.
>>> + */
>>> +static pte_t *lookup_address(unsigned long addr)
>>
>> Seems like this should be moved to common arm64 mm code and used by
>> kernel_page_present.
> 
> Sounds good, I'll include something like the patch below in the next
> series.
> 
> Unfortunately, adding an implementation of lookup_address seems to be
> slightly more complicated than necessary, because of the xen piece. We
> have to define lookup_address() with the level parameter, but it's not
> obvious to me to name the page levels. So for now I've just left it as
> a WARN() if someone supplies it.
> 
> It seems like xen still does need this to be defined, because if I
> define it without level:
> 
> drivers/xen/xenbus/xenbus_client.c: In function a??xenbus_unmap_ring_vfree_pva??:
> drivers/xen/xenbus/xenbus_client.c:760:4: error: too many arguments to function a??lookup_addressa??
>      lookup_address(addr, &level)).maddr;
>      ^~~~~~~~~~~~~~
> In file included from ./arch/arm64/include/asm/page.h:37:0,
>                   from ./include/linux/mmzone.h:20,
>                   from ./include/linux/gfp.h:5,
>                   from ./include/linux/mm.h:9,
>                   from drivers/xen/xenbus/xenbus_client.c:33:
> ./arch/arm64/include/asm/pgtable-types.h:67:15: note: declared here
>   extern pte_t *lookup_address(unsigned long addr);
>                 ^~~~~~~~~~~~~~
> 
> I've cc-d the xen folks, maybe they can suggest a way to untangle it?
> Alternatively, if someone can suggest a good naming scheme for the
> page levels, I can just do that.

The implementation of lookup_address(...) on ARM for Xen (see 
include/xen/arm/page.h) is just a BUG(). This is because this code 
should never be called (only used for x86 PV code).

Furthermore, xenbus client does not use at all the level. It is just to 
cope with the x86 version of lookup_address.

So one way to solve the problem would be to introduce 
xen_lookup_address(addr) that would be implemented as:
	- on x86
		unsigned int level;

		return lookup_address(addr, &level).maddr;
	- on ARM
		BUG();

With that there would be no prototype clash and avoid introducing a 
level parameter.

Cheers,

-- 
Julien Grall

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
