Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 894356B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 08:47:02 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M8W004V2GUCT350@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Aug 2012 21:47:00 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M8W00F7XGU32A40@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 17 Aug 2012 21:47:00 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: 
 <CAMW5UfZ_kVz_b4_98zPdY2RFjTMN9H2OzjYcRQrCTgA1xqdmPw@mail.gmail.com>
 <20120815002536.GC747@harshnoise.musicnaut.iki.fi>
In-reply-to: <20120815002536.GC747@harshnoise.musicnaut.iki.fi>
Subject: RE: Potential Regression in 3.6-rc1 - Kirkwood SATA
Date: Fri, 17 Aug 2012 14:46:50 +0200
Message-id: <023801cd7c76$617b0610$24711230$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Aaro Koskinen' <aaro.koskinen@iki.fi>, 'Josh Coombs' <josh.coombs@gmail.com>
Cc: 'linux ARM' <linux-arm-kernel@lists.infradead.org>, 'Andrew Lunn' <andrew@lunn.ch>, linux-mm@kvack.org

Hi Aaro,

On Wednesday, August 15, 2012 2:26 AM Aaro Koskinen wrote:

> On Tue, Aug 14, 2012 at 07:59:00PM -0400, Josh Coombs wrote:
> > I finally got a chance to test 3.6-rc1 after having my GoFlex Net
> > support patch accepted for the 3.6 release train.  Included in 3.6-rc1
> > was an update for Kirkwoods switching SATA to DT which was not part of
> > my original testing.  It seems something with this change has
> > partially broken the GoFlex and a couple other Kirkwood based devices.
> >
> > The key factor is the number of SATA ports defined in the dts:
> >
> > 		sata@80000 {
> > 			status = "okay";
> > 			nr-ports = <2>;
> > 		};
> >
> > If set at the correct number for my device, 2, my GFN does not
> > complete kernel init, hanging here:
> >
> > <SNIP>
> > [   15.287832] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
> > [   15.296545] jffs2: version 2.2. (NAND) ?C 2001-2006 Red Hat, Inc.
> > [   15.303202] msgmni has been set to 240
> > [   15.308503] Block layer SCSI generic (bsg) driver version 0.4 loaded (major )
> > [   15.316021] io scheduler noop registered
> > [   15.320149] io scheduler deadline registered
> > [   15.324558] io scheduler cfq registered (default)
> > [   15.329462] mv_xor_shared mv_xor_shared.0: Marvell shared XOR driver
> > [   15.335962] mv_xor_shared mv_xor_shared.1: Marvell shared XOR driver
> > [   15.376751] mv_xor mv_xor.0: Marvell XOR: ( xor cpy )
> > [   15.416736] mv_xor mv_xor.1: Marvell XOR: ( xor fill cpy )
> > [   15.456735] mv_xor mv_xor.2: Marvell XOR: ( xor cpy )
> > [   15.496734] mv_xor mv_xor.3: Marvell XOR: ( xor fill cpy )
> > [   15.506309] Serial: 8250/16550 driver, 2 ports, IRQ sharing disabled
> > [   15.509111] serial8250.0: ttyS0 at MMIO 0xf1012000 (irq = 33) is a 16550A
> > [   15.509141] console [ttyS0] enabled, bootconsole disabled
> > [   15.518967] brd: module loaded
> > [   15.524991] loop: module loaded
> > [   15.528584] sata_mv sata_mv.0: cannot get optional clkdev
> > [   15.534180] sata_mv sata_mv.0: slots 32 ports 2
> >
> > If you set nr-ports to 1 the unit boots cleanly, save for only
> > detecting one functional SATA port.  Another user has confirmed this
> > behavior on an Iomega IX2-200.
> 
> Try booting with "coherent_pool=1M" (or bigger) kernel parameter. I think
> with the recent DMA mapping changes, the default 256 KB coherent pool may
> be too small, mv_xor and sata_mv together needs more. (I'm not sure how
> it actually worked before commit e9da6e9905e639b0f842a244bc770b48ad0523e9,
> but it seems this is the cuase).
> 
> It should be noted that dma_pool_alloc() uses GFP_ATOMIC always, and if
> drivers exhaust the coherent pool already during the boot that function
> just keeps looping forever. Users only see boot hanging with no clue
> what to do. I would say it's quite a poor error handling...

Thanks for the report, I will improve error handling and add a possibility for
setting the default pool size by platform/board setup code. I'm sorry for a late
response.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
