Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFF156B0006
	for <linux-mm@kvack.org>; Fri, 25 May 2018 08:44:31 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q24-v6so4278929iob.0
        for <linux-mm@kvack.org>; Fri, 25 May 2018 05:44:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x73-v6sor3438547ite.134.2018.05.25.05.44.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 05:44:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0043ffdf-4a75-d41c-966e-073eac3dc557@virtuozzo.com>
References: <cover.1525798753.git.andreyknvl@google.com> <52d2542323262ede3510754bb07cbc1ed8c347b0.1525798754.git.andreyknvl@google.com>
 <0043ffdf-4a75-d41c-966e-073eac3dc557@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 25 May 2018 14:44:28 +0200
Message-ID: <CAAeHK+xzYgtJNTs=z24uyuBWoLFyMAOZn9NuRFeHDgCTMse1AA@mail.gmail.com>
Subject: Re: [PATCH v1 15/16] khwasan, mm, arm64: tag non slab memory
 allocated via pagealloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Tue, May 15, 2018 at 4:06 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
> You could avoid 'if (!PageSlab())' check by adding page_kasan_tag_reset() into kasan_poison_slab().

>> @@ -526,6 +526,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
>>       }
>>
>>       trace_cma_alloc(pfn, page, count, align);
>> +     page_kasan_tag_reset(page);
>
>
> Why? Comment needed.

> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index b8e0a8215021..f9f2181164a2 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -207,18 +207,11 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
>
>  void kasan_alloc_pages(struct page *page, unsigned int order)
>  {
> -#ifdef CONFIG_KASAN_GENERIC
> -       if (likely(!PageHighMem(page)))
> -               kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
> -#else
> -       if (!PageSlab(page)) {
> -               u8 tag = random_tag();
> +       if (unlikely(PageHighMem(page)))
> +               return;
>
> -               kasan_poison_shadow(page_address(page), PAGE_SIZE << order,
> -                                       tag);
> -               page_kasan_tag_set(page, tag);
> -       }
> -#endif
> +       page_kasan_tag_set(page, random_tag());
> +       kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
>  }
>
>  void kasan_free_pages(struct page *page, unsigned int order)

> As already said before no changes needed in kasan_kmalloc_large. kasan_alloc_pages() alredy did tag_set().

Will fix all in v2, thanks!
