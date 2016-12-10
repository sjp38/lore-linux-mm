Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 888C26B0038
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 01:03:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so47684160pfx.1
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 22:03:19 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id d9si36444841pge.35.2016.12.09.22.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 22:03:18 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id x23so4447979pgx.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 22:03:18 -0800 (PST)
Date: Fri, 9 Dec 2016 22:03:16 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [kernel-hardening] Re: Remaining crypto API regressions with
 CONFIG_VMAP_STACK
Message-ID: <20161210060316.GC6846@zzz>
References: <20161209230851.GB64048@google.com>
 <CALCETrW=+3u3P8Xva+0ck9=fr-mD6azPtTkOQ3uQO+GoOA6FcQ@mail.gmail.com>
 <20161210053208.GA27951@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161210053208.GA27951@gondor.apana.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Andy Lutomirski <luto@amacapital.net>, linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Sat, Dec 10, 2016 at 01:32:08PM +0800, Herbert Xu wrote:
> On Fri, Dec 09, 2016 at 09:25:38PM -0800, Andy Lutomirski wrote:
> >
> > > The following crypto drivers initialize a scatterlist to point into an
> > > ablkcipher_request, which may have been allocated on the stack with
> > > SKCIPHER_REQUEST_ON_STACK():
> > >
> > >         drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
> > >         drivers/crypto/ccp/ccp-crypto-aes.c:94
> > 
> > These are real, and I wish I'd known about them sooner.
> 
> Are you sure? Any instance of *_ON_STACK must only be used with
> sync algorithms and most drivers under drivers/crypto declare
> themselves as async.
> 

Why exactly is that?  Obviously, it wouldn't work if you returned from the stack
frame before the request completed, but does anything stop someone from using an
*_ON_STACK() request and then waiting for the request to complete before
returning from the stack frame?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
