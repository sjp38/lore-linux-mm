Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 617FC6B0038
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 00:26:00 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id p9so16344040vkd.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 21:26:00 -0800 (PST)
Received: from mail-vk0-x234.google.com (mail-vk0-x234.google.com. [2607:f8b0:400c:c05::234])
        by mx.google.com with ESMTPS id p124si9087235vkg.235.2016.12.09.21.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 21:25:59 -0800 (PST)
Received: by mail-vk0-x234.google.com with SMTP id p9so18786536vkd.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 21:25:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161209230851.GB64048@google.com>
References: <20161209230851.GB64048@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 9 Dec 2016 21:25:38 -0800
Message-ID: <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Herbert Xu <herbert@gondor.apana.org.au>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Fri, Dec 9, 2016 at 3:08 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> In the 4.9 kernel, virtually-mapped stacks will be supported and enabled by
> default on x86_64.  This has been exposing a number of problems in which
> on-stack buffers are being passed into the crypto API, which to support crypto
> accelerators operates on 'struct page' rather than on virtual memory.
>
> Some of these problems have already been fixed, but I was wondering how many
> problems remain, so I briefly looked through all the callers of sg_set_buf() and
> sg_init_one().  Overall I found quite a few remaining problems, detailed below.
>
> The following crypto drivers initialize a scatterlist to point into an
> ahash_request, which may have been allocated on the stack with
> AHASH_REQUEST_ON_STACK():
>
>         drivers/crypto/bfin_crc.c:351
>         drivers/crypto/qce/sha.c:299
>         drivers/crypto/sahara.c:973,988
>         drivers/crypto/talitos.c:1910

This are impossible or highly unlikely on x86.

>         drivers/crypto/ccp/ccp-crypto-aes-cmac.c:105,119,142
>         drivers/crypto/ccp/ccp-crypto-sha.c:95,109,124

These

>         drivers/crypto/qce/sha.c:325

This is impossible on x86.

>
> The following crypto drivers initialize a scatterlist to point into an
> ablkcipher_request, which may have been allocated on the stack with
> SKCIPHER_REQUEST_ON_STACK():
>
>         drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
>         drivers/crypto/ccp/ccp-crypto-aes.c:94

These are real, and I wish I'd known about them sooner.

>
> And these other places do crypto operations on buffers clearly on the stack:
>
>         drivers/net/wireless/intersil/orinoco/mic.c:72

Ick.

>         drivers/usb/wusbcore/crypto.c:264

Well, crud.  I thought I had fixed this driver but I missed one case.
Will send a fix tomorrow.  But I'm still unconvinced that this
hardware ever shipped.

>         net/ceph/crypto.c:182

Ick.

>         net/rxrpc/rxkad.c:737,1000

Well, crud.  This was supposed to have been fixed in:

commit a263629da519b2064588377416e067727e2cbdf9
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sun Jun 26 14:55:24 2016 -0700

    rxrpc: Avoid using stack memory in SG lists in rxkad


>         security/keys/encrypted-keys/encrypted.c:500

That's a trivial one-liner.  Patch coming tomorrow.

>         fs/cifs/smbencrypt.c:96

Ick.

>
> Note: I almost certainly missed some, since I excluded places where the use of a
> stack buffer was not obvious to me.  I also excluded AEAD algorithms since there
> isn't an AEAD_REQUEST_ON_STACK() macro (yet).
>
> The "good" news with these bugs is that on x86_64 without CONFIG_DEBUG_SG=y or
> CONFIG_DEBUG_VIRTUAL=y, you can still do virt_to_page() and then page_address()
> on a vmalloc address and get back the same address, even though you aren't
> *supposed* to be able to do this.  This will make things still work for most
> people.  The bad news is that if you happen to have consumed just about 1 page
> (or N pages) of your stack at the time you call the crypto API, your stack
> buffer may actually span physically non-contiguous pages, so the crypto
> algorithm will scribble over some unrelated page.

Are you sure?  If it round-trips to the same virtual address, it
doesn't matter if the buffer is contiguous.

>  Also, hardware crypto drivers
> which actually do operate on physical memory will break too.

Those were already broken.  DMA has been illegal on the stack for
years and DMA debugging would have caught it.

>
> So I am wondering: is the best solution really to make all these crypto API
> algorithms and users use heap buffers, as opposed to something like maintaining
> a lowmem alias for the stack, or introducing a more general function to convert
> buffers (possibly in the vmalloc space) into scatterlists?  And if the current
> solution is desired, who is going to fix all of these bugs and when?

The *right* solution IMO is to fix crypto to stop using scatterlists.
Scatterlists are for DMA using physical addresses, and they're
inappropriate almost every user of them that's using them for crypto.
kiov would be much better -- it would make sense and it would be
faster.

I have a hack to make scatterlists pointing to the stack work (as long
as they're only one element), but that's seriously gross.

Herbert, how hard would it be to teach the crypto code to use a more
sensible data structure than scatterlist and to use coccinelle fix
this stuff for real?

In the mean time, we should patch the handful of drivers that matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
