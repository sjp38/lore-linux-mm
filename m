Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id DB6266B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 14:40:44 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id ex7so4851446wid.3
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 11:40:44 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id qn9si17313619wjc.37.2014.09.15.11.40.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 11:40:37 -0700 (PDT)
Date: Mon, 15 Sep 2014 19:40:23 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] arm64:free_initrd_mem should also free the memblock
Message-ID: <20140915184023.GF12361@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net> <20140915183334.GA30737@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140915183334.GA30737@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

On Mon, Sep 15, 2014 at 07:33:34PM +0100, Will Deacon wrote:
> On Fri, Sep 12, 2014 at 11:17:18AM +0100, Wang, Yalin wrote:
> > this patch fix the memblock statics for memblock
> > in file /sys/kernel/debug/memblock/reserved
> > if we don't call memblock_free the initrd will still
> > be marked as reserved, even they are freed.
> > 
> > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > ---
> >  arch/arm64/mm/init.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index 5472c24..34605c8 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -334,8 +334,10 @@ static int keep_initrd;
> >  
> >  void free_initrd_mem(unsigned long start, unsigned long end)
> >  {
> > -	if (!keep_initrd)
> > +	if (!keep_initrd) {
> >  		free_reserved_area((void *)start, (void *)end, 0, "initrd");
> > +		memblock_free(__pa(start), end - start);
> > +	}
> 
> I don't think it makes any technical difference, but doing the memblock_free
> before the free_reserved_area makes more sense to me.

A better question is... should we even be doing this.  The memblock
information is used as a method to bring up the kernel and provide
early allocation.  Once the memory is handed over from memblock to
the normal kernel page allocators, we no longer care what happens to
memblock.

There is no need to free the initrd memory back into memblock.  In
fact, seeing the initrd location in /sys/kernel/debug/memblock/reserved
can be useful debug information in itself.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
