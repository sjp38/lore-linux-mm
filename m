Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01A5E6B0689
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 06:13:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z53so1357936wrz.10
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 03:13:10 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m128si1093258wmd.77.2017.08.03.03.13.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 03:13:09 -0700 (PDT)
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
References: <07063abd-2f5d-20d9-a182-8ae9ead26c3c@huawei.com>
 <20170802170848.GA3240@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
Date: Thu, 3 Aug 2017 13:11:45 +0300
MIME-Version: 1.0
In-Reply-To: <20170802170848.GA3240@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@google.com>

On 02/08/17 20:08, Jerome Glisse wrote:
> On Wed, Aug 02, 2017 at 06:14:28PM +0300, Igor Stoppa wrote:

[...]

>> +			set_page_private(page, 1);
> 
> Above line is pointless you overwrite value right below

yes ...
> 
>> +			page->private = pmalloc_signature;
>> +		} else {
>> +			BUG_ON(!(page_private(page) &&
>> +				 page->private == pmalloc_signature));
>> +			set_page_private(page, 0);
> 
> Same as above

... and yes

>> +			page->private = 0;
>> +		}
>> +		base += PAGE_SIZE;
>> +	} while ((PAGE_MASK & (unsigned long)base) <=
>> +		 (PAGE_MASK & (unsigned long)end));
>> +	return 0;
>> +}
>>
>> ...
>>
>> +static const char msg[] = "Not a valid Pmalloc object.";
>> +const char *pmalloc_check_range(const void *ptr, unsigned long n)
>> +{
>> +	unsigned long p;
>> +
>> +	p = (unsigned long)ptr;
>> +	n = p + n - 1;
>> +	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
>> +		struct page *page;
>> +
>> +		if (!is_vmalloc_addr((void *)p))
>> +			return msg;
>> +		page = vmalloc_to_page((void *)p);
>> +		if (!(page && page_private(page) &&
>> +		      page->private == pmalloc_signature))
>> +			return msg;
>> +	}
>> +	return NULL;
>> +}
>>
>>
>> The problem here comes from the way I am using page->private:
>> the fact that the page is marked as private means only that someone is
>> using it, and the way it is used could create (spoiler: it happens) a
>> collision with pmalloc_signature, which can generate false positives.
> 
> Is page->private use for vmalloc memory ? If so then pick another field.

No, it is not in use by vmalloc, as far as I can tell, by both reading
the code and empirically printing out its value in few cases.

> Thought i doubt it is use i would need to check. What was the exact
> objection made ?

The objection made is what I tried to explain below, that the comment
besides the declaration of the private field says:
"Mapping-private opaque data: ..."

I'll reply to your answer there.

>> A way to ensure that the address really belongs to pmalloc would be to
>> pre-screen it, against either the signature or some magic number and,
>> if such test is passed, then compare the address against those really
>> available in the pmalloc pools.
>>
>> This would be slower, but it would be limited only to those cases where
>> the signature/magic number matches and the answer is likely to be true.
>>
>> 2) However, both the current (incorrect) implementation and the one I am
>> considering, are abusing something that should be used otherwise (see
>> the following snippet):
>>
>> from include/linux/mm_types.h:
>>
>> struct page {
>> ...
>>   union {
>>     unsigned long private;		/* Mapping-private opaque data:
>> 				 	 * usually used for buffer_heads
>> 					 * if PagePrivate set; used for
>> 					 * swp_entry_t if PageSwapCache;
>> 					 * indicates order in the buddy
>> 					 * system if PG_buddy is set.
>> 					 */
>> #if USE_SPLIT_PTE_PTLOCKS
>> #if ALLOC_SPLIT_PTLOCKS
>> 		spinlock_t *ptl;
>> #else
>> 		spinlock_t ptl;
>> #endif
>> #endif
>> 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
>> 	};
>> ...
>> }
>>
>>
>> The "private" field is meant for mapping-private opaque data, which is
>> not how I am using it.
> 
> As you can see this is an union and thus the meaning of that field depends
> on how the page is use. The private comment you see is only meaningfull for
> page that are in the page cache and are coming from a file system ie when
> a process does an mmap of a file. When page is use by sl[au]b the slab_cache
> field is how it is interpreted ... Context in which a page is use do matter.

I am not native English speaker, but the comment seems to imply that, no
matter what, it's Mapping-private.

If the "Mapping-private" was dropped or somehow connected exclusively to
the cases listed in the comment, then I think it would be more clear
that the comment needs to be intended as related to mapping in certain
cases only.
But it is otherwise ok to use the "private" field for whatever purpose
it might be suitable, as long as it is not already in use.

> Here we are talking about memory that is allocated to back vmalloc area so
> the private field is unuse AFAICR and it is safe to use it while the page
> is use for vmalloc.

Yes, my experience seems to confirm that.

> Note that i don't think anyone is doing vmap() of pages that are in the page
> cache that would seem wrong from my point of view but maybe some one is.
> Thought someone might be doing vmap() of pages in which the private field is
> use for something (like a device driver private field) in which case you might
> still have false positive. You might want to simply add something either to
> vm_struct or vmap_area to know if a range of vmalloc area has been created
> by pmalloc or not. Maybe you don't even need to tag page and storing flag
> in vmap_area or vm_struct would be enough.

This last suggestion gives me a feeling of unease: it seems that each
user of the private field has its own way to indicate that the field is
in use (see the comment beside the declaration of the field).

Wouldn't it make more sense to have one (sub)field, somewhere in the
page structure, that would contain an unique signature (an enum?)
stating who is the user?

This might make the field slightly less opaque, but easier to infer its
content, when it is not possible to rely on the context (like for
hardened usercopy case).

But, to reply more specifically to your advice, yes, I think I could add
a flag to vm_struct and then retrieve its value, for the address being
processed, by passing through find_vm_area().

I will try going down this path, thank you.


--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
