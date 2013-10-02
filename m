Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CA0C76B0070
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 11:33:52 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1176889pab.6
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 08:33:52 -0700 (PDT)
From: "Bird, Tim" <Tim.Bird@sonymobile.com>
Date: Wed, 2 Oct 2013 17:33:47 +0200
Subject: RE: [PATCH] slub: Proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
Message-ID: <F5184659D418E34EA12B1903EE5EF5FD8538E86615@seldmbx02.corpusers.net>
References: <5245ECC3.8070200@gmail.com>,<00000141799dd4b3-f6df96c0-1003-427d-9bd8-f6455622f4ea-000000@email.amazonses.com>
In-Reply-To: <00000141799dd4b3-f6df96c0-1003-427d-9bd8-f6455622f4ea-000000@email.amazonses.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Frank Rowand <frowand.list@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>, =?iso-8859-1?Q?=22Andersson=2C_Bj=F6rn=22?= <Bjorn.Andersson@sonymobile.com>

On Wednesday, October 02, 2013 7:41 AM, Christoph Lameter [cl@linux.com] wr=
ote:
>
>On Fri, 27 Sep 2013, Frank Rowand wrote:
>
>> Move the kmemleak code for small block allocation out from
>> under CONFIG_SLUB_DEBUG.
>
>Well in that case it may be better to move the hooks as a whole out of
>the CONFIG_SLUB_DEBUG section. Do the #ifdeffering for each call from the
>hooks instead.
>
>The point of the hook functions is to separate the hooks out of the
>functions so taht they do not accumulate in the main code.
>
>The patch moves one hook back into the main code. Please keep the checks
>in the hooks.

Thanks for the feedback.  Roman's first patch, which we discussed internall=
y
before sending this one, did exactly that.  I guess Roman gets to say "I to=
ld
you so." :-)  My bad for telling him to change it.

We'll refactor along the lines that you describe, and send another one.

The problem child is actually the unconditional call to kmemleak_alloc()
in kmalloc_large_node() (in slub.c).  The problem comes because that call
is unconditional on CONFIG_SLUB_DEBUG but the kmemleak
calls in the hook routines are conditional on CONFIG_SLUB_DEBUG.
So if you have CONFIG_SLUB_DEBUG=3Dn but CONFIG_DEBUG_KMEMLEAK=3Dy,
you get the false reports.

Now, there are kmemleak calls in kmalloc_large_node() and kfree() that don'=
t
follow the "hook" pattern.  Should these be moved to 'hook' routines, to ke=
ep
all the checks in the hooks?

Personally, I like the idea of keeping bookeeping/tracing/debug stuff in ho=
ok
routines.  I also like de-coupling CONFIG_SLUB_DEBUG and CONFIG_DEBUG_KMEML=
EAK,
but maybe others have a different opinon.  Unless someone speaks up, we'll
move the the currently in-function kmemleak calls into hooks, and all of th=
e
kmemleak stuff out from under CONFIG_SLUB_DEBUG.
We'll have to see if the ifdefs get a little messy.
  -- Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
