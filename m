Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 025846B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 12:44:15 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p135so46612662ita.11
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:44:14 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id y199si1845168iod.0.2017.06.28.09.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 09:44:14 -0700 (PDT)
Received: by mail-io0-x236.google.com with SMTP id r36so39049233ioi.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:44:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170620040834.GB610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-18-git-send-email-keescook@chromium.org> <20170620040834.GB610@zzz.localdomain>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 28 Jun 2017 09:44:13 -0700
Message-ID: <CAGXu5jJyyO8CmukmmZdfmt34pubr8EzRJ4H2AMjc15UpLzrGcQ@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 17/23] dcache: define usercopy region
 in dentry_cache slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 19, 2017 at 9:08 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> On Mon, Jun 19, 2017 at 04:36:31PM -0700, Kees Cook wrote:
>> From: David Windsor <dave@nullcore.net>
>>
>> When a dentry name is short enough, it can be stored directly in
>> the dentry itself.  These dentry short names, stored in struct
>> dentry.d_iname and therefore contained in the dentry_cache slab cache,
>> need to be coped to/from userspace.
>>
>> In support of usercopy hardening, this patch defines a region in
>> the dentry_cache slab cache in which userspace copy operations
>> are allowed.
>>
>> This region is known as the slab cache's usercopy region.  Slab
>> caches can now check that each copy operation involving cache-managed
>> memory falls entirely within the slab's usercopy region.
>>
>> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
>> whitelisting code in the last public patch of grsecurity/PaX based on my
>> understanding of the code. Changes or omissions from the original code are
>> mine and don't reflect the original grsecurity/PaX code.
>>
>
> For all these patches please mention *where* the data is being copied to/from
> userspace.

Can you explain what you mean here? The field being copied is already
mentioned in the commit log; do you mean where in the kernel source
does the copy happen?

>
>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index a48f54238273..97f4a0117b3b 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -151,6 +151,11 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *);
>>               sizeof(struct __struct), __alignof__(struct __struct),\
>>               (__flags), NULL)
>>
>> +#define KMEM_CACHE_USERCOPY(__struct, __flags, __field) kmem_cache_create_usercopy(#__struct,\
>> +             sizeof(struct __struct), __alignof__(struct __struct),\
>> +             (__flags), offsetof(struct __struct, __field),\
>> +             sizeof_field(struct __struct, __field), NULL)
>> +
>
> This helper macro should be added in the patch which adds
> kmem_cache_create_usercopy(), not in this one.

It got moved here since this was the only user of this function and
there was already enough happening in the first patch. But yes,
probably it should stay with the first patch. It can be moved.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
