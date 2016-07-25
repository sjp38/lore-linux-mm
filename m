Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0F6A6B0253
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 16:45:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so125531380lfw.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 13:45:53 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id xq6si16456001wjb.273.2016.07.25.13.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 13:45:51 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id q128so149067543wma.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 13:45:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0f980e84-b587-3d9e-3c26-ad57f947c08b@redhat.com>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
 <1469046427-12696-13-git-send-email-keescook@chromium.org> <0f980e84-b587-3d9e-3c26-ad57f947c08b@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 25 Jul 2016 13:45:50 -0700
Message-ID: <CAGXu5jJQQNDMK7vxKqhwQukL771uOT-2No7fnNreQVLWs8UBMA@mail.gmail.com>
Subject: Re: [PATCH v4 12/12] mm: SLUB hardened usercopy support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 25, 2016 at 12:16 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 07/20/2016 01:27 PM, Kees Cook wrote:
>>
>> Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
>> SLUB allocator to catch any copies that may span objects. Includes a
>> redzone handling fix discovered by Michael Ellerman.
>>
>> Based on code from PaX and grsecurity.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Tested-by: Michael Ellerman <mpe@ellerman.id.au>
>> ---
>>  init/Kconfig |  1 +
>>  mm/slub.c    | 36 ++++++++++++++++++++++++++++++++++++
>>  2 files changed, 37 insertions(+)
>>
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 798c2020ee7c..1c4711819dfd 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -1765,6 +1765,7 @@ config SLAB
>>
>>  config SLUB
>>         bool "SLUB (Unqueued Allocator)"
>> +       select HAVE_HARDENED_USERCOPY_ALLOCATOR
>>         help
>>            SLUB is a slab allocator that minimizes cache line usage
>>            instead of managing queues of cached objects (SLAB approach).
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 825ff4505336..7dee3d9a5843 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3614,6 +3614,42 @@ void *__kmalloc_node(size_t size, gfp_t flags, int
>> node)
>>  EXPORT_SYMBOL(__kmalloc_node);
>>  #endif
>>
>> +#ifdef CONFIG_HARDENED_USERCOPY
>> +/*
>> + * Rejects objects that are incorrectly sized.
>> + *
>> + * Returns NULL if check passes, otherwise const char * to name of cache
>> + * to indicate an error.
>> + */
>> +const char *__check_heap_object(const void *ptr, unsigned long n,
>> +                               struct page *page)
>> +{
>> +       struct kmem_cache *s;
>> +       unsigned long offset;
>> +       size_t object_size;
>> +
>> +       /* Find object and usable object size. */
>> +       s = page->slab_cache;
>> +       object_size = slab_ksize(s);
>> +
>> +       /* Find offset within object. */
>> +       offset = (ptr - page_address(page)) % s->size;
>> +
>> +       /* Adjust for redzone and reject if within the redzone. */
>> +       if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
>> +               if (offset < s->red_left_pad)
>> +                       return s->name;
>> +               offset -= s->red_left_pad;
>> +       }
>> +
>> +       /* Allow address range falling entirely within object size. */
>> +       if (offset <= object_size && n <= object_size - offset)
>> +               return NULL;
>> +
>> +       return s->name;
>> +}
>> +#endif /* CONFIG_HARDENED_USERCOPY */
>> +
>
>
> I compared this against what check_valid_pointer does for SLUB_DEBUG
> checking. I was hoping we could utilize that function to avoid
> duplication but a) __check_heap_object needs to allow accesses anywhere
> in the object, not just the beginning b) accessing page->objects
> is racy without the addition of locking in SLUB_DEBUG.
>
> Still, the ptr < page_address(page) check from __check_heap_object would
> be good to add to avoid generating garbage large offsets and trying to
> infer C math.
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 7dee3d9..5370e4f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3632,6 +3632,9 @@ const char *__check_heap_object(const void *ptr,
> unsigned long n,
>         s = page->slab_cache;
>         object_size = slab_ksize(s);
>  +       if (ptr < page_address(page))
> +               return s->name;
> +
>         /* Find offset within object. */
>         offset = (ptr - page_address(page)) % s->size;
>
> With that, you can add
>
> Reviwed-by: Laura Abbott <labbott@redhat.com>

Cool, I'll add that.

Should I add your reviewed-by for this patch only or for the whole series?

Thanks!

-Kees

>
>>  static size_t __ksize(const void *object)
>>  {
>>         struct page *page;
>>
>
> Thanks,
> Laura



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
