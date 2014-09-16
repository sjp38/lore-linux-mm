Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCD06B0068
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 21:54:20 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so7481866pdb.0
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:54:19 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id fk1si26254304pab.220.2014.09.15.18.54.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 18:54:18 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 16 Sep 2014 09:53:55 +0800
Subject: RE: [PATCH] arm64:free_initrd_mem should also free the memblock
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49160C@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net>
 <20140915183334.GA30737@arm.com>
 <20140915184023.GF12361@n2100.arm.linux.org.uk>
 <20140915185027.GC30737@arm.com>
In-Reply-To: <20140915185027.GC30737@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

Hi

The reason that a want merge this patch is that
It confuse me when I debug memory issue by=20
/sys/kernel/debug/memblock/reserved  debug file,
It show lots of un-correct reserved memory.
In fact, I also send a patch to cma driver part
For this issue too:
http://ozlabs.org/~akpm/mmots/broken-out/free-the-reserved-memblock-when-fr=
ee-cma-pages.patch

I want to remove these un-correct memblock parts as much as possible,
so that I can see more correct info from /sys/kernel/debug/memblock/reserve=
d
debug file .

Thanks



-----Original Message-----

On Mon, Sep 15, 2014 at 07:40:23PM +0100, Russell King - ARM Linux wrote:
> On Mon, Sep 15, 2014 at 07:33:34PM +0100, Will Deacon wrote:
> > On Fri, Sep 12, 2014 at 11:17:18AM +0100, Wang, Yalin wrote:
> > > this patch fix the memblock statics for memblock in file=20
> > > /sys/kernel/debug/memblock/reserved
> > > if we don't call memblock_free the initrd will still be marked as=20
> > > reserved, even they are freed.
> > >=20
> > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > ---
> > >  arch/arm64/mm/init.c | 4 +++-
> > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > >=20
> > > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c index=20
> > > 5472c24..34605c8 100644
> > > --- a/arch/arm64/mm/init.c
> > > +++ b/arch/arm64/mm/init.c
> > > @@ -334,8 +334,10 @@ static int keep_initrd;
> > > =20
> > >  void free_initrd_mem(unsigned long start, unsigned long end)  {
> > > -	if (!keep_initrd)
> > > +	if (!keep_initrd) {
> > >  		free_reserved_area((void *)start, (void *)end, 0, "initrd");
> > > +		memblock_free(__pa(start), end - start);
> > > +	}
> >=20
> > I don't think it makes any technical difference, but doing the=20
> > memblock_free before the free_reserved_area makes more sense to me.
>=20
> A better question is... should we even be doing this.  The memblock=20
> information is used as a method to bring up the kernel and provide=20
> early allocation.  Once the memory is handed over from memblock to the=20
> normal kernel page allocators, we no longer care what happens to=20
> memblock.
>=20
> There is no need to free the initrd memory back into memblock.  In=20
> fact, seeing the initrd location in=20
> /sys/kernel/debug/memblock/reserved
> can be useful debug information in itself.

That's a fair point. Yang: do you have a specific use-case in mind for this=
?

I wondered if it might interact with our pfn_valid implementation, which us=
es memblock_is_memory, however memblock_free only deals with the reserved r=
egions, so I now I can't see why this change is required either.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
