Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0D176B026A
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 13:05:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i88so22081218pfk.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 10:05:25 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id vt3si14653666pab.236.2016.11.04.10.05.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 10:05:24 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id 189so54899672pfz.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 10:05:24 -0700 (PDT)
Date: Fri, 4 Nov 2016 10:05:21 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: vmalloced stacks and scatterwalk_map_and_copy()
Message-ID: <20161104170521.GA34176@google.com>
References: <20161103181624.GA63852@google.com>
 <CALCETrUPuunBT1Zo25wyOwqaWJ=rm9R-WMZGN-7u4-dsdokAnQ@mail.gmail.com>
 <20161103211207.GB63852@google.com>
 <20161103231018.GA85121@google.com>
 <CALCETrV=9vXDyQ5F5-bFD4YCn5P_j7jmYj2Tv+DXWH43m31NzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV=9vXDyQ5F5-bFD4YCn5P_j7jmYj2Tv+DXWH43m31NzA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Lutomirski <luto@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Nov 03, 2016 at 08:57:49PM -0700, Andy Lutomirski wrote:
> 
> The crypto request objects can live on the stack just fine.  It's the
> request buffers that need to live elsewhere (or the alternative
> interfaces can be used, or the crypto core code can start using
> something other than scatterlists).
> 

There are cases where a crypto operation is done on a buffer embedded in a
request object.  The example I'm aware of is in the GCM implementation
(crypto/gcm.c).  Basically it needs to encrypt 16 zero bytes prepended with the
actual data, so it fills a buffer in the request object
(crypto_gcm_req_priv_ctx.auth_tag) with zeroes and builds a new scatterlist
which covers both this buffer and the original data scatterlist.

Granted, GCM provides the aead interface not the skcipher interface, and
currently there is no AEAD_REQUEST_ON_STACK() macro like there is a
SKCIPHER_REQUEST_ON_STACK() macro.  So maybe no one is creating aead requests on
the stack right now.  But it's something to watch out for.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
