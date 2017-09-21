Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B88A96B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 14:26:46 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u2so11343084itb.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 11:26:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l143sor892768iol.273.2017.09.21.11.26.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 11:26:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1709211102320.14742@nuc-kabylake>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-4-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1709211024120.14427@nuc-kabylake>
 <CAGXu5j+X6dWCGocG=P7pszTY-5OZ6Jmp-RsnDKox75M5rmVe4g@mail.gmail.com> <alpine.DEB.2.20.1709211102320.14742@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 21 Sep 2017 11:26:43 -0700
Message-ID: <CAGXu5jKqWShVMqm6-moqgO7JUaJuFxw-9mMKak+WG1HgNJqc1Q@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH v3 03/31] usercopy: Mark kmalloc
 caches as usercopy caches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-xfs@vger.kernel.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Sep 21, 2017 at 9:04 AM, Christopher Lameter <cl@linux.com> wrote:
> On Thu, 21 Sep 2017, Kees Cook wrote:
>
>> > So what is the point of this patch?
>>
>> The DMA kmalloc caches are not whitelisted:
>
> The DMA kmalloc caches are pretty obsolete and mostly there for obscure
> drivers.
>
> ??

They may be obsolete, but they're still in the kernel, and they aren't
copied to userspace, so we can mark them.

>> >>                         kmalloc_dma_caches[i] = create_kmalloc_cache(n,
>> >> -                               size, SLAB_CACHE_DMA | flags);
>> >> +                               size, SLAB_CACHE_DMA | flags, 0, 0);
>>
>> So this is creating the distinction between the kmallocs that go to
>> userspace and those that don't. The expectation is that future work
>> can start to distinguish between "for userspace" and "only kernel"
>> kmalloc allocations, as is already done here for DMA.
>
> The creation of the kmalloc caches in earlier patches already setup the
> "whitelisting". Why do it twice?

Patch 1 is to allow for things to mark their whitelists. Patch 30
disables the full whitelisting, since then we've defined them all, so
the kmalloc caches need to mark themselves as whitelisted.

Patch 1 leaves unmarked things whitelisted so we can progressively
tighten the restriction and have a bisectable series. (i.e. if there
is something wrong with one of the whitelists in the series, it will
bisect to that one, not the one that removes the global whitelist from
patch 1.)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
