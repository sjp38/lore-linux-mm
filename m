Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2E726B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 08:43:28 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o194-v6so4182976iod.21
        for <linux-mm@kvack.org>; Fri, 25 May 2018 05:43:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6-v6sor2283060iog.149.2018.05.25.05.43.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 05:43:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f86e7172-023d-b381-64f0-6039ae1b1dce@virtuozzo.com>
References: <cover.1525798753.git.andreyknvl@google.com> <5dddd7d6f18927de291e7b09e1ff45190dd6d361.1525798754.git.andreyknvl@google.com>
 <f86e7172-023d-b381-64f0-6039ae1b1dce@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 25 May 2018 14:43:22 +0200
Message-ID: <CAAeHK+zdOwBvjRnT6pUd_nPAo5tY8qYr9Z9MF27AzYE1ybw2-w@mail.gmail.com>
Subject: Re: [PATCH v1 13/16] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Tue, May 15, 2018 at 3:13 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
> Using variable to store untagged_object pointer, instead of tagging/untagging back and forth would make the
> code easier to follow.

> static bool inline shadow_ivalid(u8 tag, s8 shadow_byte)
> {
>         if (IS_ENABLED(CONFIG_KASAN_GENERIC))
>                 return shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE;
>         else
>                 return tag != (u8)shadow_byte;
> }
>
>
> static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>
> ...
>         if (shadow_invalid(tag, shadow_byte)) {
>                 kasan_report_invalid_free(object, ip);
>                 return true;
>         }
>

> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 7cd4a4e8c3be..f11d6059fc06 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -404,12 +404,9 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>         redzone_end = round_up((unsigned long)object + cache->object_size,
>                                 KASAN_SHADOW_SCALE_SIZE);
>
> -#ifdef CONFIG_KASAN_GENERIC
> -       kasan_unpoison_shadow(object, size);
> -#else
>         tag = random_tag();
> -       kasan_poison_shadow(object, redzone_start - (unsigned long)object, tag);
> -#endif
> +       kasan_unpoison_shadow(set_tag(object, tag), size);
> +
>         kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>                 KASAN_KMALLOC_REDZONE);

> kasan_kmalloc_large() should be left untouched. It works correctly as is in both cases.
> ptr comes from page allocator already already tagged at this point.

Will fix all in v2, thanks!
