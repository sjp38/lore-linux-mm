Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCFA86B0010
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:12:17 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w6-v6so22373296qka.15
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:12:17 -0800 (PST)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id k5-v6si1163415qte.125.2018.11.05.08.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:12:17 -0800 (PST)
Received: from mr2.cc.vt.edu (mr2.cc.ipv6.vt.edu [IPv6:2607:b400:92:8400:0:90:e077:bf22])
	by omr1.cc.vt.edu (8.14.4/8.14.4) with ESMTP id wA5GCG8f013174
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:12:16 -0500
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by mr2.cc.vt.edu (8.14.7/8.14.7) with ESMTP id wA5GCB83012377
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:12:16 -0500
Received: by mail-qk1-f200.google.com with SMTP id 80so22562883qkd.0
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:12:16 -0800 (PST)
From: valdis.kletnieks@vt.edu
Subject: Re: Creating compressed backing_store as swapfile
In-Reply-To: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1541434328_4003P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 05 Nov 2018 11:12:08 -0500
Message-ID: <40880.1541434328@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu.ping@gmail.com>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

--==_Exmh_1541434328_4003P
Content-Type: text/plain; charset=us-ascii

On Mon, 05 Nov 2018 20:31:46 +0530, Pintu Agarwal said:
> I wanted to have a swapfile (64MB to 256MB) on my system.
> But I wanted the data to be compressed and stored on the disk in my swapfile.
> [Similar to zram, but compressed data should be moved to disk, instead of RAM].

What platform are you on that you're both storage constrained enough to need
swap, and also so short on disk space that compressing it makes sense?
Understanding the hardware constraints here would help in advising you.

> Note: I wanted to optimize RAM space, so performance is not important
> right now for our requirement.
>
> So, what are the options available, to perform this in 4.x kernel version.
> My Kernel: 4.9.x

Given that this is a greenfield development, why are you picking a kernel
that's 2 years out of date?  You *do* realize that 4.9.135 does *not* contain
all the bugfixes since then, only that relatively small subset that qualify for
'stable' (see Documentation/process/stable-kernel-rules.rst for the gory
details).

One possible total hack would be to simply use a file-based swap area,
but put the file on a filesystem that supports automatic inline compression.

Note that this will probably *totally* suck on performance, because there's
no good way to find where 4K block 11,493 starts inside the compressed
file, so it would have to read/decompress from the file beginning.  Also,
if you write data to a previously unused location (or even a previously used
spot that compressed the 4K page to a different length), you have a bad time
inserting it.  (Note that zram can avoid most of this because it can (a) keep
a table of pointers to where each page starts and (b) it isn't constrained to
writing to 4K blocks on disk, so if the current compression takes a 4K page down
to 1,283 bytes, it doesn't have to care *too* much if it stores that someplace
that crosses a page boundary.

Another thing that you will need to worry about is what happens in low-memory
situations - the time you *most* need to do a swap operation, you may not have
enough memory to do the I/O.  zram basically makes sure it *has* the memory
needed beforehand, and swap directly to pre-allocated disk doesn't need much
additional memory.

--==_Exmh_1541434328_4003P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBW+Br2I0DS38y7CIcAQJnHwf/Qs6+ukFbpph4XreLTFTClbciDiZRmurD
2m4lrYl698x3E1MfatqrWUgVyjv6hSrfja1rlxHboSEwxhQu5tCXIyTZhMf3JUi8
UYZeuHBA+2tTr8WCqje9zUAIk4L/fKWFcv6KWJMxXSYQVQsHhFG/zXOMAn7EieDH
xRGECm7Uv4BQJ20S6krgYLEvAPVOBBwXQzFHGUfuNZ6AwjGMGBGlAN92xCg/Ojao
aVU/qGXtjcCsnv3+iEY/ZKN4RqTgE3F0OH+D3UKY7FsT1hXNdGcQTltXQ8CZ7Se+
ZE7RurVFEKvoxdIFswYqwwrD4a+g9mwevwvzt5vRAJE4cimwfwxHWA==
=ThRu
-----END PGP SIGNATURE-----

--==_Exmh_1541434328_4003P--
