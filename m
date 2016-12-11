Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E54C76B0038
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 18:31:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so99674026pfg.0
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 15:31:34 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id b61si41465800plc.299.2016.12.11.15.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 15:31:33 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id e9so8915162pgc.1
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 15:31:33 -0800 (PST)
Date: Sun, 11 Dec 2016 15:31:31 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: Remaining crypto API regressions with CONFIG_VMAP_STACK
Message-ID: <20161211233131.GA1210@zzz>
References: <20161209230851.GB64048@google.com>
 <CALCETrVBGPijiacbY-trdbgRPYC8grNrGA7TVu0xvxUaqud08w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVBGPijiacbY-trdbgRPYC8grNrGA7TVu0xvxUaqud08w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-crypto@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Herbert Xu <herbert@gondor.apana.org.au>, Andrew Lutomirski <luto@kernel.org>, Stephan Mueller <smueller@chronox.de>

On Sun, Dec 11, 2016 at 11:13:55AM -0800, Andy Lutomirski wrote:
> On Fri, Dec 9, 2016 at 3:08 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > In the 4.9 kernel, virtually-mapped stacks will be supported and enabled by
> > default on x86_64.  This has been exposing a number of problems in which
> > on-stack buffers are being passed into the crypto API, which to support crypto
> > accelerators operates on 'struct page' rather than on virtual memory.
> >
> 
> >         fs/cifs/smbencrypt.c:96
> 
> This should use crypto_cipher_encrypt_one(), I think.
> 
> --Andy

Yes, I believe that's correct.  It encrypts 8 bytes with ecb(des) which is
equivalent to simply encrypting one block with DES.  Maybe try the following
(untested):

static int
smbhash(unsigned char *out, const unsigned char *in, unsigned char *key)
{
	unsigned char key2[8];
	struct crypto_cipher *cipher;

	str_to_key(key, key2);

	cipher = crypto_alloc_cipher("des", 0, 0);
	if (IS_ERR(cipher)) {
		cifs_dbg(VFS, "could not allocate des cipher\n");
		return PTR_ERR(cipher);
	}

	crypto_cipher_setkey(cipher, key2, 8);

	crypto_cipher_encrypt_one(cipher, out, in);

	crypto_free_cipher(cipher);
	return 0;
}

- Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
