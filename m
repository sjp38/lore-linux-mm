Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 154876B038E
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:55:26 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a6so27993745lfa.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:55:26 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id h22si1317435ljb.140.2017.03.16.08.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:55:24 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id y193so3713251lfd.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:55:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170309093954.GA6567@gondor.apana.org.au>
References: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487952313-22381-2-git-send-email-Mahipal.Challa@cavium.com>
 <CALZtONBeS7bAjxpbLDdQj=y_tsXUX5TVCFdqbQ3LccTSa6kfnw@mail.gmail.com>
 <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
 <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com> <20170309093954.GA6567@gondor.apana.org.au>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 16 Mar 2017 11:54:43 -0400
Message-ID: <CALZtONDmZ0PVHaRt5nX1Zipx0poMLiHCcmUq4wRbWW77ptHoWQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] mm: zswap - Add crypto acomp/scomp framework support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Mahipal Reddy <mahipalreddy2006@gmail.com>, Mahipal Challa <Mahipal.Challa@cavium.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, pathreya@cavium.com, Vishnu Nair <Vishnu.Nair@cavium.com>

On Thu, Mar 9, 2017 at 4:39 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Mar 08, 2017 at 12:38:40PM -0500, Dan Streetman wrote:
>>
>> It looks like the crypto_scomp interface is buried under
>> include/crypto/internal/scompress.h, however that's exactly what zswap
>> should be using.  We don't need to switch to an asynchronous interface
>> that's rather significantly more complicated, and then use it in a
>> synchronous way.  The crypto_scomp interface should probably be made
>> public, not an implementation internal.
>
> No scomp is not meant to be used externally.  We provide exactly
> one compression interface and it's acomp.  acomp can be used
> synchronously by setting the CRYPTO_ALG_ASYNC bit in the mask
> field when allocating the algorithm.

setting the ASYNC bit makes it synchronous?  that seems backwards...?

Anyway, I have a few concerns about moving over to using that first,
specifically:

- no docs on acomp in Documentation/crypto/ that I can see
- no place in the crypto code that I can see that parses ALG_ASYNC to
make the crypto_acomp_compress() call synchronous
- no synchronous test in crypto/testmgr.c

Maybe I'm reading the code wrong, but it looks like any compression
backend that is actually scomp, actually does the (de)compression
synchronously.  In crypto_acomp_init_tfm(), if the tfm is not
crypto_acomp_type (and I assume because all the current
implementations register as scomp, they aren't acomp_type) it calls
crypto_init_scomp_ops_async(), which then sets ->compress to
scomp_acomp_compress() and that function appears to directly call the
scomp compression function.  This is just after a very quick look, so
maybe I'm reading it wrong.  I'll look some more, and also add a
synchronous testmgr test so i can understand how it works better.

Is the acomp interface fully ready for use?

>
> The existing compression interface will be phased out.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
