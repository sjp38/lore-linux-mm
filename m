Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF0C06B0038
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 18:08:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so71181951pgc.2
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 15:08:54 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id f5si35532275plm.37.2016.12.09.15.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Dec 2016 15:08:53 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id c4so1692843pfb.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 15:08:53 -0800 (PST)
Date: Fri, 9 Dec 2016 15:08:51 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161209230851.GB64048@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-crypto@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Herbert Xu <herbert@gondor.apana.org.au>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

In the 4.9 kernel, virtually-mapped stacks will be supported and enabled by
default on x86_64.  This has been exposing a number of problems in which
on-stack buffers are being passed into the crypto API, which to support crypto
accelerators operates on 'struct page' rather than on virtual memory.

Some of these problems have already been fixed, but I was wondering how many
problems remain, so I briefly looked through all the callers of sg_set_buf() and
sg_init_one().  Overall I found quite a few remaining problems, detailed below.

The following crypto drivers initialize a scatterlist to point into an
ahash_request, which may have been allocated on the stack with
AHASH_REQUEST_ON_STACK():

	drivers/crypto/bfin_crc.c:351
	drivers/crypto/qce/sha.c:299
	drivers/crypto/sahara.c:973,988
	drivers/crypto/talitos.c:1910
	drivers/crypto/ccp/ccp-crypto-aes-cmac.c:105,119,142
	drivers/crypto/ccp/ccp-crypto-sha.c:95,109,124
	drivers/crypto/qce/sha.c:325

The following crypto drivers initialize a scatterlist to point into an
ablkcipher_request, which may have been allocated on the stack with
SKCIPHER_REQUEST_ON_STACK():

	drivers/crypto/ccp/ccp-crypto-aes-xts.c:162
	drivers/crypto/ccp/ccp-crypto-aes.c:94

And these other places do crypto operations on buffers clearly on the stack:

	drivers/net/wireless/intersil/orinoco/mic.c:72
	drivers/usb/wusbcore/crypto.c:264
	net/ceph/crypto.c:182
	net/rxrpc/rxkad.c:737,1000
	security/keys/encrypted-keys/encrypted.c:500
	fs/cifs/smbencrypt.c:96

Note: I almost certainly missed some, since I excluded places where the use of a
stack buffer was not obvious to me.  I also excluded AEAD algorithms since there
isn't an AEAD_REQUEST_ON_STACK() macro (yet).

The "good" news with these bugs is that on x86_64 without CONFIG_DEBUG_SG=y or
CONFIG_DEBUG_VIRTUAL=y, you can still do virt_to_page() and then page_address()
on a vmalloc address and get back the same address, even though you aren't
*supposed* to be able to do this.  This will make things still work for most
people.  The bad news is that if you happen to have consumed just about 1 page
(or N pages) of your stack at the time you call the crypto API, your stack
buffer may actually span physically non-contiguous pages, so the crypto
algorithm will scribble over some unrelated page.  Also, hardware crypto drivers
which actually do operate on physical memory will break too.

So I am wondering: is the best solution really to make all these crypto API
algorithms and users use heap buffers, as opposed to something like maintaining
a lowmem alias for the stack, or introducing a more general function to convert
buffers (possibly in the vmalloc space) into scatterlists?  And if the current
solution is desired, who is going to fix all of these bugs and when?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
