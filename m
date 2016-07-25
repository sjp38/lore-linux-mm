Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16AD96B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 19:29:58 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u186so367829330ita.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 16:29:58 -0700 (PDT)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com. [209.85.214.50])
        by mx.google.com with ESMTPS id p202si22417496iod.63.2016.07.25.16.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 16:29:57 -0700 (PDT)
Received: by mail-it0-f50.google.com with SMTP id f6so97692359ith.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 16:29:57 -0700 (PDT)
Subject: Re: [PATCH v4 12/12] mm: SLUB hardened usercopy support
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
 <1469046427-12696-13-git-send-email-keescook@chromium.org>
 <0f980e84-b587-3d9e-3c26-ad57f947c08b@redhat.com>
 <1469482923.30053.122.camel@redhat.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <9fca8a3c-da82-d609-79bb-4f5a779cbc1b@redhat.com>
Date: Mon, 25 Jul 2016 16:29:51 -0700
MIME-Version: 1.0
In-Reply-To: <1469482923.30053.122.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/25/2016 02:42 PM, Rik van Riel wrote:
> On Mon, 2016-07-25 at 12:16 -0700, Laura Abbott wrote:
>> On 07/20/2016 01:27 PM, Kees Cook wrote:
>>> Under CONFIG_HARDENED_USERCOPY, this adds object size checking to
>>> the
>>> SLUB allocator to catch any copies that may span objects. Includes
>>> a
>>> redzone handling fix discovered by Michael Ellerman.
>>>
>>> Based on code from PaX and grsecurity.
>>>
>>> Signed-off-by: Kees Cook <keescook@chromium.org>
>>> Tested-by: Michael Ellerman <mpe@ellerman.id.au>
>>> ---
>>>  init/Kconfig |  1 +
>>>  mm/slub.c    | 36 ++++++++++++++++++++++++++++++++++++
>>>  2 files changed, 37 insertions(+)
>>>
>>> diff --git a/init/Kconfig b/init/Kconfig
>>> index 798c2020ee7c..1c4711819dfd 100644
>>> --- a/init/Kconfig
>>> +++ b/init/Kconfig
>>> @@ -1765,6 +1765,7 @@ config SLAB
>>>
>>>  config SLUB
>>>  	bool "SLUB (Unqueued Allocator)"
>>> +	select HAVE_HARDENED_USERCOPY_ALLOCATOR
>>>  	help
>>>  	   SLUB is a slab allocator that minimizes cache line
>>> usage
>>>  	   instead of managing queues of cached objects (SLAB
>>> approach).
>>> diff --git a/mm/slub.c b/mm/slub.c
>>> index 825ff4505336..7dee3d9a5843 100644
>>> --- a/mm/slub.c
>>> +++ b/mm/slub.c
>>> @@ -3614,6 +3614,42 @@ void *__kmalloc_node(size_t size, gfp_t
>>> flags, int node)
>>>  EXPORT_SYMBOL(__kmalloc_node);
>>>  #endif
>>>
>>> +#ifdef CONFIG_HARDENED_USERCOPY
>>> +/*
>>> + * Rejects objects that are incorrectly sized.
>>> + *
>>> + * Returns NULL if check passes, otherwise const char * to name of
>>> cache
>>> + * to indicate an error.
>>> + */
>>> +const char *__check_heap_object(const void *ptr, unsigned long n,
>>> +				struct page *page)
>>> +{
>>> +	struct kmem_cache *s;
>>> +	unsigned long offset;
>>> +	size_t object_size;
>>> +
>>> +	/* Find object and usable object size. */
>>> +	s = page->slab_cache;
>>> +	object_size = slab_ksize(s);
>>> +
>>> +	/* Find offset within object. */
>>> +	offset = (ptr - page_address(page)) % s->size;
>>> +
>>> +	/* Adjust for redzone and reject if within the redzone. */
>>> +	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
>>> +		if (offset < s->red_left_pad)
>>> +			return s->name;
>>> +		offset -= s->red_left_pad;
>>> +	}
>>> +
>>> +	/* Allow address range falling entirely within object
>>> size. */
>>> +	if (offset <= object_size && n <= object_size - offset)
>>> +		return NULL;
>>> +
>>> +	return s->name;
>>> +}
>>> +#endif /* CONFIG_HARDENED_USERCOPY */
>>> +
>>
>> I compared this against what check_valid_pointer does for SLUB_DEBUG
>> checking. I was hoping we could utilize that function to avoid
>> duplication but a) __check_heap_object needs to allow accesses
>> anywhere
>> in the object, not just the beginning b) accessing page->objects
>> is racy without the addition of locking in SLUB_DEBUG.
>>
>> Still, the ptr < page_address(page) check from __check_heap_object
>> would
>> be good to add to avoid generating garbage large offsets and trying
>> to
>> infer C math.
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 7dee3d9..5370e4f 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3632,6 +3632,9 @@ const char *__check_heap_object(const void
>> *ptr, unsigned long n,
>>          s = page->slab_cache;
>>          object_size = slab_ksize(s);
>>
>> +       if (ptr < page_address(page))
>> +               return s->name;
>> +
>>          /* Find offset within object. */
>>          offset = (ptr - page_address(page)) % s->size;
>>
>
> I don't get it, isn't that already guaranteed because we
> look for the page that ptr is in, before __check_heap_object
> is called?
>
> Specifically, in patch 3/12:
>
> +       page = virt_to_head_page(ptr);
> +
> +       /* Check slab allocator for flags and size. */
> +       if (PageSlab(page))
> +               return __check_heap_object(ptr, n, page);
>
> How can that generate a ptr that is not inside the page?
>
> What am I overlooking?  And, should it be in the changelog or
> a comment? :)
>


I ran into the subtraction issue when the vmalloc detection wasn't
working on ARM64, somehow virt_to_head_page turned into a page
that happened to have PageSlab set. I agree if everything is working
properly this is redundant but given the type of feature this is, a
little bit of redundancy against a system running off into the weeds
or bad patches might be warranted.

I'm not super attached to the check if other maintainers think it
is redundant. Updating the __check_heap_object header comment
with a note of what we are assuming could work

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
