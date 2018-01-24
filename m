Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD46800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:11:16 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id f62so3149430otf.3
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:11:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21sor1548151otj.140.2018.01.24.11.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 11:11:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180124175631.22925-5-igor.stoppa@huawei.com>
References: <20180124175631.22925-1-igor.stoppa@huawei.com> <20180124175631.22925-5-igor.stoppa@huawei.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 24 Jan 2018 20:10:53 +0100
Message-ID: <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Jan 24, 2018 at 6:56 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> The MMU available in many systems running Linux can often provide R/O
> protection to the memory pages it handles.
>
> However, the MMU-based protection works efficiently only when said pages
> contain exclusively data that will not need further modifications.
>
> Statically allocated variables can be segregated into a dedicated
> section, but this does not sit very well with dynamically allocated
> ones.
>
> Dynamic allocation does not provide, currently, any means for grouping
> variables in memory pages that would contain exclusively data suitable
> for conversion to read only access mode.
>
> The allocator here provided (pmalloc - protectable memory allocator)
> introduces the concept of pools of protectable memory.
>
> A module can request a pool and then refer any allocation request to the
> pool handler it has received.
>
> Once all the chunks of memory associated to a specific pool are
> initialized, the pool can be protected.

I'm not entirely convinced by the approach of marking small parts of
kernel memory as readonly for hardening.
Comments on some details are inline.

> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 1e5d8c3..116d280 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -20,6 +20,7 @@ struct notifier_block;                /* in notifier.h */
>  #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not fully initialized */
>  #define VM_NO_GUARD            0x00000040      /* don't add guard page */
>  #define VM_KASAN               0x00000080      /* has allocated kasan shadow memory */
> +#define VM_PMALLOC             0x00000100      /* pmalloc area - see docs */

Is "see docs" specific enough to actually guide the reader to the
right documentation?


> +#define pmalloc_attr_init(data, attr_name) \
> +do { \
> +       sysfs_attr_init(&data->attr_##attr_name.attr); \
> +       data->attr_##attr_name.attr.name = #attr_name; \
> +       data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0444); \
> +       data->attr_##attr_name.show = pmalloc_pool_show_##attr_name; \
> +} while (0)

Is there a good reason for making all these files mode 0444 (as
opposed to setting them to 0400 and then allowing userspace to make
them accessible if desired)? /proc/slabinfo contains vaguely similar
data and is mode 0400 (or mode 0600, depending on the kernel config)
AFAICS.


> +void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
> +{
[...]
> +       /* Expand pool */
> +       chunk_size = roundup(size, PAGE_SIZE);
> +       chunk = vmalloc(chunk_size);

You're allocating with vmalloc(), which, as far as I know, establishes
a second mapping in the vmalloc area for pages that are already mapped
as RW through the physmap. AFAICS, later, when you're trying to make
pages readonly, you're only changing the protections on the second
mapping in the vmalloc area, therefore leaving the memory writable
through the physmap. Is that correct? If so, please either document
the reasoning why this is okay or change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
