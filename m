Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5586B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 02:00:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id t10so22884948pgo.20
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 23:00:23 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u17si14517347pge.390.2017.11.14.23.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 23:00:21 -0800 (PST)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
 <20171110010907.qfkqhrbtdkt5y3hy@smitten>
 <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
 <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
 <20171115034430.GA24257@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d1459463-061c-2aba-ff89-936284c138a3@intel.com>
Date: Tue, 14 Nov 2017 23:00:20 -0800
MIME-Version: 1.0
In-Reply-To: <20171115034430.GA24257@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 11/14/2017 07:44 PM, Matthew Wilcox wrote:
> On Mon, Nov 13, 2017 at 02:46:25PM -0800, Dave Hansen wrote:
>> On 11/13/2017 02:20 PM, Dave Hansen wrote:
>>> On 11/09/2017 05:09 PM, Tycho Andersen wrote:
>>>> which I guess is from the additional flags in grow_dev_page() somewhere down
>>>> the stack. Anyway... it seems this is a kernel allocation that's using
>>>> MIGRATE_MOVABLE, so perhaps we need some more fine tuned heuristic than just
>>>> all MOVABLE allocations are un-mapped via xpfo, and all the others are mapped.
>>>>
>>>> Do you have any ideas?
>>>
>>> It still has to do a kmap() or kmap_atomic() to be able to access it.  I
>>> thought you hooked into that.  Why isn't that path getting hit for these?
>>
>> Oh, this looks to be accessing data mapped by a buffer_head.  It
>> (rudely) accesses data via:
>>
>> void set_bh_page(struct buffer_head *bh,
>> ...
>> 	bh->b_data = page_address(page) + offset;
> 
> We don't need to kmap in order to access MOVABLE allocations.  kmap is
> only needed for HIGHMEM allocations.  So there's nothing wrong with ext4
> or set_bh_page().

Yeah, it's definitely not _buggy_.

Although, I do wonder what we should do about these for XPFO.  Should we
just stick a kmap() in there and comment it?  What we really need is a
mechanism to say "use this as a kernel page" and "stop using this as a
kernel page".  kmap() does that... kinda.  It's not a perfect fit, but
it's pretty close.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
