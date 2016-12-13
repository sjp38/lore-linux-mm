Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 548D76B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 22:39:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so296583258pgd.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 19:39:46 -0800 (PST)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id f12si46325355plm.169.2016.12.12.19.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 19:39:45 -0800 (PST)
Date: Tue, 13 Dec 2016 11:39:28 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161213033928.GB5601@gondor.apana.org.au>
References: <20161209230851.GB64048@google.com>
 <CALCETrWfa5VJQNu3XjeFhF0cDFWF+M-dPwsT_7dzO5YSxsneGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWfa5VJQNu3XjeFhF0cDFWF+M-dPwsT_7dzO5YSxsneGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Mon, Dec 12, 2016 at 10:34:10AM -0800, Andy Lutomirski wrote:
>
> Here's my status.
> 
> >         drivers/crypto/bfin_crc.c:351
> >         drivers/crypto/qce/sha.c:299
> >         drivers/crypto/sahara.c:973,988
> >         drivers/crypto/talitos.c:1910
> >         drivers/crypto/qce/sha.c:325
> 
> I have a patch to make these depend on !VMAP_STACK.

Why? They're all marked as ASYNC AFAIK.

> I have a patch to convert this to, drumroll please:
> 
>     priv->tx_tfm_mic = crypto_alloc_shash("michael_mic", 0,
>                           CRYPTO_ALG_ASYNC);
> 
> Herbert, I'm at a loss as what a "shash" that's "ASYNC" even means.

Having 0 as type and CRYPTO_ALG_ASYNC as mask in general means
that we're requesting a sync algorithm (i.e., ASYNC bit off).

However, it is completely unnecessary for shash as they can never
be async.  So this could be changed to just ("michael_mic", 0, 0).

> >         net/ceph/crypto.c:182
> 
> This:
> 
> size_t zero_padding = (0x10 - (src_len & 0x0f));
> 
> is an amazing line of code...
> 
> But this driver uses cbc and wants to do synchronous crypto, and I
> don't think that the crypto API supports real synchronous crypto using
> CBC, so I'm going to let someone else fix this.

It does through skcipher if you allocate with (0, CRYPTO_ALG_ASYNC).

I'll try to fix this.

> >         net/rxrpc/rxkad.c:737,1000
> 
> Herbert, can you fix this?

Sure I'll take a look.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
