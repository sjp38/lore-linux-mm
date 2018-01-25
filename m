Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 023EE800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 07:00:03 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id u2so3930062oif.11
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 04:00:02 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 69si1743202otu.552.2018.01.25.04.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 04:00:01 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <6c6a3f47-fc5b-0365-4663-6908ad1fc4a7@huawei.com>
Date: Thu, 25 Jan 2018 13:59:58 +0200
MIME-Version: 1.0
In-Reply-To: <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel
 Hardening <kernel-hardening@lists.openwall.com>

Hi,

thanks for the review. My reply below.

On 24/01/18 21:10, Jann Horn wrote:

> I'm not entirely convinced by the approach of marking small parts of
> kernel memory as readonly for hardening.

Because of the physmap you mention later?

Regarding small parts vs big parts (what is big enough?) I did propose
the use of a custom zone at the very beginning, however I met 2 objections:

1. It's not a special case and there was no will to reserve another zone
   This might be mitigated by aliasing with a zone that is already
   defined, but not in use. For example DMA or DMA32.
   But it looks like a good way to replicate the confusion that is page
   struct. Anyway, I found the next objection more convincing.

2. What would be the size of this zone? It would become something that
   is really application specific. At the very least it should become a
   command line parameter. A distro would have to allocate a lot of
   memory for it, because it cannot really know upfront what its users
   will do. But, most likely, the vast majority of users would never
   need that much.

If you have some idea of how to address these objections without using
vmalloc, or at least without using the same page provider that vmalloc
is using now, I'd be interested to hear it.

Besides the double mapping problem, the major benefit I can see from
having a contiguous area is that it simplifies the hardened user copy
verification, because there is a fixed range to test for overlap.

> Comments on some details are inline.

thank you

>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 1e5d8c3..116d280 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -20,6 +20,7 @@ struct notifier_block;                /* in notifier.h */
>>  #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not fully initialized */
>>  #define VM_NO_GUARD            0x00000040      /* don't add guard page */
>>  #define VM_KASAN               0x00000080      /* has allocated kasan shadow memory */
>> +#define VM_PMALLOC             0x00000100      /* pmalloc area - see docs */
> 
> Is "see docs" specific enough to actually guide the reader to the
> right documentation?

The doc file is named pmalloc.txt, but I can be more explicit.

>> +#define pmalloc_attr_init(data, attr_name) \
>> +do { \
>> +       sysfs_attr_init(&data->attr_##attr_name.attr); \
>> +       data->attr_##attr_name.attr.name = #attr_name; \
>> +       data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0444); \
>> +       data->attr_##attr_name.show = pmalloc_pool_show_##attr_name; \
>> +} while (0)
> 
> Is there a good reason for making all these files mode 0444 (as
> opposed to setting them to 0400 and then allowing userspace to make
> them accessible if desired)? /proc/slabinfo contains vaguely similar
> data and is mode 0400 (or mode 0600, depending on the kernel config)
> AFAICS.

ok, you do have a point, so far I have been mostly focusing on the

"drop-in replacement for kmalloc" aspect.

>> +void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
>> +{
> [...]
>> +       /* Expand pool */
>> +       chunk_size = roundup(size, PAGE_SIZE);
>> +       chunk = vmalloc(chunk_size);
> 
> You're allocating with vmalloc(), which, as far as I know, establishes
> a second mapping in the vmalloc area for pages that are already mapped
> as RW through the physmap. AFAICS, later, when you're trying to make
> pages readonly, you're only changing the protections on the second
> mapping in the vmalloc area, therefore leaving the memory writable
> through the physmap. Is that correct? If so, please either document
> the reasoning why this is okay or change it.

About why vmalloc as backend for pmalloc, please refer to this:

http://www.openwall.com/lists/kernel-hardening/2018/01/24/11

I tried to give a short summary of what took me toward vmalloc.
vmalloc is also a convenient way of obtaining arbitrarily (within
reason) large amounts of virtually contiguous memory.

Your objection is toward the unprotected access, through the alternate
mapping, rather than to the idea of having pools that can be protected
individually, right?

In the mail I linked, I explained that I could not use kmalloc because
of the problem of splitting huge pages on ARM.

kmalloc does require the physmap, for performance reason.

However, vmalloc is already doing mapping of individual pages, because
it must ensure that they are virtually contiguous, so would it be
possible to have vmalloc _always_ outside of the physmap?

If I have understood correctly, the actual extension of physmap is
highly architecture and platform dependant, so it might be (but I have
not checked) that in some cases (like some 32bit systems) vmalloc is
typically outside of physmap, but probably that is not the case on 64bit?

Also, I need to understand how physmap works against vmalloc vs how it
works against kernel text and const/__ro_after_init sections.

Can they also be accessed (and written?) through the physmap?

But, to take a different angle: if an attacker knows where kernel
symbols are and has gained capability to write at arbitrary location(s)
in kernel data, what prevents a modification of mappings and permissions?

What is considered robust enough?

I have the impression that, without support from HW, to have some
one-way mechanism that protects some page permanently, it's always
possible to undo the various protections we are talking about, only harder.

>From the perspective of protecting against accidental overwrites,
instead, the current implementation should be ok, since it's less likely
that some stray pointer happens to assume a value that goes through the
physmap.

But I'm interested to hear, if you have some suggestion about how to
prevent the side access through the physmap.

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
