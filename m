Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id AB0F36B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 21:06:21 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id xx9so40451550obc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 18:06:21 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id wy7si1030155obc.54.2016.02.29.18.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 18:06:20 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id jj9so1881303obb.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 18:06:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D4DCFE.9040806@suse.cz>
References: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160201214213.2bdf9b4e.akpm@linux-foundation.org>
	<56D43AAB.2010802@suse.cz>
	<CAPcyv4i587ow4yEFN+81rd=_kVL3YV1daU7cDM4V4YCAhDMRVA@mail.gmail.com>
	<56D4DCFE.9040806@suse.cz>
Date: Mon, 29 Feb 2016 18:06:20 -0800
Message-ID: <CAPcyv4j1JbpuoiurRe7hbnBbxthK3wtuoQXzwQ7rAcc+2MYV9A@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: CONFIG_NR_ZONES_EXTENDED
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Mon, Feb 29, 2016 at 4:06 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 29.2.2016 18:55, Dan Williams wrote:
>> On Mon, Feb 29, 2016 at 4:33 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>> On 02/02/2016 06:42 AM, Andrew Morton wrote:
>>>> So if you want ZONE_DMA, you're limited to 512 NUMA nodes?
>>>>
>>>> That seems reasonable.
>>>
>>>
>>> Sorry for the late reply, but it seems that with !SPARSEMEM, or with
>>> SPARSEMEM_VMEMMAP, reducing NUMA nodes isn't even necessary, because
>>> SECTIONS_WIDTH is zero (see the diagrams in linux/page-flags-layout.h). In
>>> my brief tests with 4.4 based kernel with SPARSEMEM_VMEMMAP it seems that
>>> with 1024 NUMA nodes and 8192 CPU's, there's still 7 bits left (i.e. 6 with
>>> CONFIG_NR_ZONES_EXTENDED).
>>>
>>> With the danger of becoming even more complex, could the limit also depend
>>> on CONFIG_SPARSEMEM/VMEMMAP to reflect that somehow?
>>
>> In this case it's already part of the equation because:
>>
>> config ZONE_DEVICE
>>        depends on MEMORY_HOTPLUG
>>        depends on MEMORY_HOTREMOVE
>>
>> ...and those in turn depend on SPARSEMEM.
>
> Fine, but then SPARSEMEM_VMEMMAP should be still an available subvariant of
> SPARSEMEM with SECTION_WIDTH=0.

It should be, but not for the ZONE_DEVICE case.  ZONE_DEVICE depends
on x86_64 which means ZONE_DEVICE also implies SPARSEMEM_VMEMMAP
since:

config ARCH_SPARSEMEM_ENABLE
       def_bool y
       depends on X86_64 || NUMA || X86_32 || X86_32_NON_STANDARD
       select SPARSEMEM_STATIC if X86_32
       select SPARSEMEM_VMEMMAP_ENABLE if X86_64

Now, if a future patch wants to reclaim page flags space for other
usages outside of ZONE_DEVICE it can do the work to handle the
SPARSEMEM_VMEMMAP=n case.  I don't see a reason to fold that
distinction into the current patch given the current constraints.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
