Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF346B025E
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 12:48:47 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id 19so21621881vko.0
        for <linux-mm@kvack.org>; Sat, 10 Dec 2016 09:48:47 -0800 (PST)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id 11si9469640vko.136.2016.12.10.09.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Dec 2016 09:48:45 -0800 (PST)
Received: by mail-vk0-x22b.google.com with SMTP id p9so23621620vkd.3
        for <linux-mm@kvack.org>; Sat, 10 Dec 2016 09:48:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHmME9pzT=bxuEVVGDOJkm2PaEAVjbo=8na7URy=g-1sKvv0yw@mail.gmail.com>
References: <20161209230851.GB64048@google.com> <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
 <20161210053711.GB27951@gondor.apana.org.au> <CAHmME9pzT=bxuEVVGDOJkm2PaEAVjbo=8na7URy=g-1sKvv0yw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 10 Dec 2016 09:48:24 -0800
Message-ID: <CALCETrXhT=nm2o0yAzrKborYuaGZ7FD7MXh9UK=VHUa50PauEg@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Eric Biggers <ebiggers3@gmail.com>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

cc: Viro because I'm talking about iov_iter.

On Sat, Dec 10, 2016 at 6:45 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hi Herbert,
>
> On Sat, Dec 10, 2016 at 6:37 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> As for AEAD we never had a sync interface to begin with and I
>> don't think I'm going to add one.
>
> That's too bad to hear. I hope you'll reconsider. Modern cryptographic
> design is heading more and more in the direction of using AEADs for
> interesting things, and having a sync interface would be a lot easier
> for implementing these protocols. In the same way many protocols need
> a hash of some data, now protocols often want some particular data
> encrypted with an AEAD using a particular key and nonce and AD. One
> protocol that comes to mind is Noise [1].
>

I think that sync vs async has gotten conflated with
vectored-vs-nonvectored and the results are unfortunate.

There are a lot of users in the tree that are trying to do crypto on
very small pieces of data and want to have that data consist of the
concatenation of two small buffers and/or want to use primitives that
don't have "sync" interfaces.  These users are stuck using async
interfaces even though using async implementations makes no sense for
them.

I'd love to see the API restructured a bit to decouple all of these
considerations.  One approach might be to teach iov_iter about
scatterlists.  Then, for each primitive, there could be two entry
points:

1. A simplified and lower-overhead entry.  You pass it an iov_iter
(and, depending on what the operation is, an output iov_iter), it does
the crypto synchronously, and returns.  Operating in-place might be
permitted for some primitives.

2. A full-featured async entry.  You pass it iov_iters and it requires
that the iov_iters be backed by scatterlists in order to operate
asynchronously.

I see no reason that the decisions to use virtual vs physical
addressing or to do vectored vs non-vectored IO should be tied up with
asynchronicity.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
