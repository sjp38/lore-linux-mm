Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04C6A6B0069
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:34:33 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 20so109151928uak.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:34:33 -0800 (PST)
Received: from mail-ua0-x234.google.com (mail-ua0-x234.google.com. [2607:f8b0:400c:c08::234])
        by mx.google.com with ESMTPS id m6si11595236uam.7.2016.12.12.10.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 10:34:31 -0800 (PST)
Received: by mail-ua0-x234.google.com with SMTP id b35so89521192uaa.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:34:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161209230851.GB64048@google.com>
References: <20161209230851.GB64048@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 12 Dec 2016 10:34:10 -0800
Message-ID: <CALCETrWfa5VJQNu3XjeFhF0cDFWF+M-dPwsT_7dzO5YSxsneGg@mail.gmail.com>
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

Here's my status.

>         drivers/crypto/bfin_crc.c:351
>         drivers/crypto/qce/sha.c:299
>         drivers/crypto/sahara.c:973,988
>         drivers/crypto/talitos.c:1910
>         drivers/crypto/qce/sha.c:325

I have a patch to make these depend on !VMAP_STACK.

>         drivers/crypto/ccp/ccp-crypto-aes-cmac.c:105,119,142
>         drivers/crypto/ccp/ccp-crypto-sha.c:95,109,124
>         drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
>         drivers/crypto/ccp/ccp-crypto-aes.c:94

According to Herbert, these are fine.  I'm personally less convinced
since I'm very confused as to what "async" means in the crypto code,
but I'm going to leave these alone.

>
> And these other places do crypto operations on buffers clearly on the stack:
>
>         drivers/usb/wusbcore/crypto.c:264
>         security/keys/encrypted-keys/encrypted.c:500

I have a patch.

>         drivers/net/wireless/intersil/orinoco/mic.c:72

I have a patch to convert this to, drumroll please:

    priv->tx_tfm_mic = crypto_alloc_shash("michael_mic", 0,
                          CRYPTO_ALG_ASYNC);

Herbert, I'm at a loss as what a "shash" that's "ASYNC" even means.

>         net/ceph/crypto.c:182

This:

size_t zero_padding = (0x10 - (src_len & 0x0f));

is an amazing line of code...

But this driver uses cbc and wants to do synchronous crypto, and I
don't think that the crypto API supports real synchronous crypto using
CBC, so I'm going to let someone else fix this.

>         net/rxrpc/rxkad.c:737,1000

Herbert, can you fix this?

>         fs/cifs/smbencrypt.c:96

I have a patch.


My pile is here:

https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=crypto

I'll send out the patches soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
