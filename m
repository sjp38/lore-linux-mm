Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F78C6B0261
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 00:55:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so88187375pgq.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 21:55:34 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id r21si36412426pgg.64.2016.12.09.21.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 21:55:33 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id x23so4427002pgx.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 21:55:33 -0800 (PST)
Date: Fri, 9 Dec 2016 21:55:31 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161210055531.GB6846@zzz>
References: <20161209230851.GB64048@google.com>
 <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Herbert Xu <herbert@gondor.apana.org.au>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Fri, Dec 09, 2016 at 09:25:38PM -0800, Andy Lutomirski wrote:
> > The following crypto drivers initialize a scatterlist to point into an
> > ahash_request, which may have been allocated on the stack with
> > AHASH_REQUEST_ON_STACK():
> >
> >         drivers/crypto/bfin_crc.c:351
> >         drivers/crypto/qce/sha.c:299
> >         drivers/crypto/sahara.c:973,988
> >         drivers/crypto/talitos.c:1910
> 
> This are impossible or highly unlikely on x86.
> 
> >         drivers/crypto/ccp/ccp-crypto-aes-cmac.c:105,119,142
> >         drivers/crypto/ccp/ccp-crypto-sha.c:95,109,124
> 
> These
> 
> >         drivers/crypto/qce/sha.c:325
> 
> This is impossible on x86.
> 

Thanks for looking into these.  I didn't investigate who/what is likely to be
using each driver.

Of course I would not be surprised to see people want to start supporting
virtually mapped stacks on other architectures too.

> >
> > The "good" news with these bugs is that on x86_64 without CONFIG_DEBUG_SG=y or
> > CONFIG_DEBUG_VIRTUAL=y, you can still do virt_to_page() and then page_address()
> > on a vmalloc address and get back the same address, even though you aren't
> > *supposed* to be able to do this.  This will make things still work for most
> > people.  The bad news is that if you happen to have consumed just about 1 page
> > (or N pages) of your stack at the time you call the crypto API, your stack
> > buffer may actually span physically non-contiguous pages, so the crypto
> > algorithm will scribble over some unrelated page.
> 
> Are you sure?  If it round-trips to the same virtual address, it
> doesn't matter if the buffer is contiguous.

You may be right, I didn't test this.  The hash_walk and blkcipher_walk code do
go page by page, but I suppose on x86_64 it would just step from one bogus
"struct page" to the adjacent one and still map it to the original virtual
address.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
