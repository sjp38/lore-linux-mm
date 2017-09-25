Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28BBA6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 03:37:38 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id c27so6269935uah.1
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 00:37:38 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id s78si1966928vkf.330.2017.09.25.00.37.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 00:37:36 -0700 (PDT)
Date: Mon, 25 Sep 2017 02:37:21 -0500
From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was not read only"
Message-ID: <20170925073721.GM8421@gate.crashing.org>
References: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr> <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, Michael Ellerman <mpe@ellerman.id.au>, Jinbum Park <jinb.park7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, Sep 24, 2017 at 12:17:51PM -0700, Kees Cook wrote:
> On Thu, Sep 21, 2017 at 2:37 AM, Christophe Leroy
> <christophe.leroy@c-s.fr> wrote:
> > On powerpc, RODATA_TEST fails with message the following messages:
> >
> > [    6.199505] Freeing unused kernel memory: 528K
> > [    6.203935] rodata_test: test data was not read only
> >
> > This is because GCC allocates it to .data section:
> >
> > c0695034 g     O .data  00000004 rodata_test_data
> 
> Uuuh... that seems like a compiler bug. It's marked "const" -- it
> should never end up in .data. I would argue that this has done exactly
> what it was supposed to do, and shows that something has gone wrong.
> It should always be const. Adding "static" should just change
> visibility. (I'm not opposed to the static change, but it seems to
> paper over a problem with the compiler...)

The compiler puts this item in .sdata, for 32-bit.  There is no .srodata,
so if it wants to use a small data section, it must use .sdata .

Non-external, non-referenced symbols are not put in .sdata, that is the
difference you see with the "static".

I don't think there is a bug here.  If you think there is, please open
a GCC bug.


Segher

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
