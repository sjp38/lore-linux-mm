Received: from localhost (ioe@localhost)
          by nightmaster.csn.tu-chemnitz.de (8.9.1/8.9.1) with ESMTP
          id NAA25248 for <linux-mm@kvack.org>; Mon, 22 May 2000 13:43:53 +0200
Date: Mon, 22 May 2000 13:43:53 +0200 (CEST)
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Questions about page IO of swapping
Message-ID: <Pine.LNX.4.10.10005221323490.21738-100000@nightmaster.csn.tu-chemnitz.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I tried to implement encrypted swap and couldn't find the right
places for encryption and decryption.

I thought encryption should be done before calling brw_page() in 
mm/page_io.c:rw_swap_page_base()
and decryption in fs/buffer.c:after_unlock_page(), if the
page->count is >0 after passing every other of the tests in this
function.

But obviosly I was wrong, because I got oopses and later a
reboot, as soon as I touched swap.

So when is a page actually considered written to disk and when is
it accessed first after this? 

These would be the points for my very lightwight encrypted swap
layer.

The data can be cached, but may not be accessed
before decryption and should not go to swap (file or device)
without being encrypted. Caching should be avoided as much as
possible by calling crypto-stuff as late as possible (in the
lowest layer).

All of this is meant for kernel 2.2.15 (+kernel-int-patch[1], but
this is only used for the crypto-API).

I would like to know the entry points for 2.3.x too, but cannot
really test it, because kernel-int-patch is only for 2.2.x

If you guys have no idea, I'll try implementing a pseudo block
device, but this will restrict it to swap-devices and omits
swap-files (which could of course simulated with loopback).

I have also problems tracking reads vs. writes, because this
information is somehow lost due to generalization after a page
has been read/written ;-)

Thanks and Regards

Ingo Oeser

[1] International Kernel Patch -> Crypto stuff developed outside
   USA and outside other countries that have weird crypto laws.
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
