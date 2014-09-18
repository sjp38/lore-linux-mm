Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C48EA6B0081
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 05:39:01 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id fp1so1053825pdb.15
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 02:39:01 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id ua7si34642972pac.213.2014.09.18.02.38.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Sep 2014 02:39:00 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Thu, 18 Sep 2014 17:38:54 +0800
Subject: RE: [PATCH] arm64:free_initrd_mem should also free the memblock
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49161B@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net>
 <20140915183334.GA30737@arm.com>
 <20140915184023.GF12361@n2100.arm.linux.org.uk>
 <20140915185027.GC30737@arm.com>
 <35FD53F367049845BC99AC72306C23D103D6DB49160C@CNBJMBX05.corpusers.net>
 <20140917162822.GB15261@e104818-lin.cambridge.arm.com>
 <20140917181254.GW12361@n2100.arm.linux.org.uk>
In-Reply-To: <20140917181254.GW12361@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <Will.Deacon@arm.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

Hi Russell,

mm..
I see your meaning,
But how to debug reserved memory,
I mean how to know which physical memory are reserved in kernel if=20
Not use /sys/kernel/debug/memblock/reserved  debug file ?

I think memblock provides a debug interface, so it should keep it=20
Correct for debug .

For Catalin 's suggestion,
I am not sure if it is always true to call memblock_free() in
free_reserved_area() , maybe some caller don't want this
behaviors .
So maybe we can introduce another function like free_reserved_area_and_memb=
lock() to implement it.


-----Original Message-----
From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]=20
Sent: Thursday, September 18, 2014 2:13 AM
To: Catalin Marinas
Cc: Wang, Yalin; Will Deacon; 'linux-mm@kvack.org'; 'linux-kernel@vger.kern=
el.org'; 'linux-arm-kernel@lists.infradead.org'
Subject: Re: [PATCH] arm64:free_initrd_mem should also free the memblock

On Wed, Sep 17, 2014 at 05:28:23PM +0100, Catalin Marinas wrote:
> On Tue, Sep 16, 2014 at 02:53:55AM +0100, Wang, Yalin wrote:
> > The reason that a want merge this patch is that It confuse me when I=20
> > debug memory issue by /sys/kernel/debug/memblock/reserved  debug=20
> > file, It show lots of un-correct reserved memory.
> > In fact, I also send a patch to cma driver part For this issue too:
> > http://ozlabs.org/~akpm/mmots/broken-out/free-the-reserved-memblock-
> > when-free-cma-pages.patch
> >=20
> > I want to remove these un-correct memblock parts as much as=20
> > possible, so that I can see more correct info from=20
> > /sys/kernel/debug/memblock/reserved
> > debug file .
>=20
> Could we not always call memblock_free() from free_reserved_area()=20
> (with a dummy definition when !CONFIG_HAVE_MEMBLOCK)?

Why bother?

The next thing is that people will want to have memblock's reserved areas t=
rack whether the kernel allocates a page so that the memblock debugging fol=
lows the kernel's allocation state.

This is utterly rediculous.  Memblock is purely a method to get the system =
up and running.  Once it hands memory over to the normal kernel allocators,=
 the reservation information in memblock is no longer valid.

The /useful/ information that it provides is the state of memory passed ove=
r to the kernel allocators, which in itself is valuable information.
Destroying it by freeing stuff after that point is not useful.

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up accor=
ding to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
