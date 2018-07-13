Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B431F6B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:25:03 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m6-v6so37923493qkd.20
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 06:25:03 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s1-v6si6122761qkc.287.2018.07.13.06.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 06:25:02 -0700 (PDT)
Subject: Re: [PATCH v5 1/5] mm/sparse: abstract sparse buffer allocations
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
 <20180712203730.8703-2-pasha.tatashin@oracle.com>
 <20180713131749.GA16765@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <23f6e4e5-6e32-faf6-433d-67e50d2895a2@oracle.com>
Date: Fri, 13 Jul 2018 09:24:44 -0400
MIME-Version: 1.0
In-Reply-To: <20180713131749.GA16765@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au



On 07/13/2018 09:17 AM, Oscar Salvador wrote:
> On Thu, Jul 12, 2018 at 04:37:26PM -0400, Pavel Tatashin wrote:
>> +static void *sparsemap_buf __meminitdata;
>> +static void *sparsemap_buf_end __meminitdata;
>> +
>> +void __init sparse_buffer_init(unsigned long size, int nid)
>> +{
>> +	BUG_ON(sparsemap_buf);
> 
> Why do we need a BUG_ON() here?
> Looking at the code I cannot really see how we can end up with sparsemap_buf being NULL.
> Is it just for over-protection?

This checks that we do not accidentally leak memory by calling sparse_buffer_init() consequently without sparse_buffer_fini() in-between.

> 
>> +	sparsemap_buf =
>> +		memblock_virt_alloc_try_nid_raw(size, PAGE_SIZE,
>> +						__pa(MAX_DMA_ADDRESS),
>> +						BOOTMEM_ALLOC_ACCESSIBLE, nid);
> 
> In your previous version, you didn't pass a required alignment when setting up sparsemap_buf.
> size is already PMD_SIZE aligned, do we need to align it also to PAGE_SIZE?
> 

I decided to add PAGE_SIZE alignment, because the implicit memblock alignment is SMP_CACHE_BYTES which is smaller than page size. While, in practice we will most likely get a page size aligned allocation, it is still possible that some ranges in memblock are not page size aligned if that the way they were passed from BIOS.

Thank you,
Pavel
