Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id F30866B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 20:47:33 -0400 (EDT)
Received: by yenl1 with SMTP id l1so1453339yen.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 17:47:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120815002536.GC747@harshnoise.musicnaut.iki.fi>
References: <CAMW5UfZ_kVz_b4_98zPdY2RFjTMN9H2OzjYcRQrCTgA1xqdmPw@mail.gmail.com>
	<20120815002536.GC747@harshnoise.musicnaut.iki.fi>
Date: Tue, 14 Aug 2012 20:47:32 -0400
Message-ID: <CAMW5Ufa8YwhVbCtQwswVBi8VXiTDWFPz9Kfj3NYxF7VrWz5t=w@mail.gmail.com>
Subject: Re: Potential Regression in 3.6-rc1 - Kirkwood SATA
From: Josh Coombs <josh.coombs@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: linux ARM <linux-arm-kernel@lists.infradead.org>, Andrew Lunn <andrew@lunn.ch>, m.szyprowski@samsung.com, linux-mm@kvack.org

On Tue, Aug 14, 2012 at 8:25 PM, Aaro Koskinen <aaro.koskinen@iki.fi> wrote=
:
> Him
>
> On Tue, Aug 14, 2012 at 07:59:00PM -0400, Josh Coombs wrote:
>> I finally got a chance to test 3.6-rc1 after having my GoFlex Net
>> support patch accepted for the 3.6 release train.  Included in 3.6-rc1
>> was an update for Kirkwoods switching SATA to DT which was not part of
>> my original testing.  It seems something with this change has
>> partially broken the GoFlex and a couple other Kirkwood based devices.
>>
>> The key factor is the number of SATA ports defined in the dts:
>>
>>               sata@80000 {
>>                       status =3D "okay";
>>                       nr-ports =3D <2>;
>>               };
>>
>> If set at the correct number for my device, 2, my GFN does not
>> complete kernel init, hanging here:
>>
>> <SNIP>
>> [   15.287832] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes=
)
>> [   15.296545] jffs2: version 2.2. (NAND) ?=A9 2001-2006 Red Hat, Inc.
>> [   15.303202] msgmni has been set to 240
>> [   15.308503] Block layer SCSI generic (bsg) driver version 0.4 loaded =
(major )
>> [   15.316021] io scheduler noop registered
>> [   15.320149] io scheduler deadline registered
>> [   15.324558] io scheduler cfq registered (default)
>> [   15.329462] mv_xor_shared mv_xor_shared.0: Marvell shared XOR driver
>> [   15.335962] mv_xor_shared mv_xor_shared.1: Marvell shared XOR driver
>> [   15.376751] mv_xor mv_xor.0: Marvell XOR: ( xor cpy )
>> [   15.416736] mv_xor mv_xor.1: Marvell XOR: ( xor fill cpy )
>> [   15.456735] mv_xor mv_xor.2: Marvell XOR: ( xor cpy )
>> [   15.496734] mv_xor mv_xor.3: Marvell XOR: ( xor fill cpy )
>> [   15.506309] Serial: 8250/16550 driver, 2 ports, IRQ sharing disabled
>> [   15.509111] serial8250.0: ttyS0 at MMIO 0xf1012000 (irq =3D 33) is a =
16550A
>> [   15.509141] console [ttyS0] enabled, bootconsole disabled
>> [   15.518967] brd: module loaded
>> [   15.524991] loop: module loaded
>> [   15.528584] sata_mv sata_mv.0: cannot get optional clkdev
>> [   15.534180] sata_mv sata_mv.0: slots 32 ports 2
>>
>> If you set nr-ports to 1 the unit boots cleanly, save for only
>> detecting one functional SATA port.  Another user has confirmed this
>> behavior on an Iomega IX2-200.
>
> Try booting with "coherent_pool=3D1M" (or bigger) kernel parameter. I thi=
nk
> with the recent DMA mapping changes, the default 256 KB coherent pool may
> be too small, mv_xor and sata_mv together needs more. (I'm not sure how
> it actually worked before commit e9da6e9905e639b0f842a244bc770b48ad0523e9=
,
> but it seems this is the cuase).
>
> It should be noted that dma_pool_alloc() uses GFP_ATOMIC always, and if
> drivers exhaust the coherent pool already during the boot that function
> just keeps looping forever. Users only see boot hanging with no clue
> what to do. I would say it's quite a poor error handling...
>
> A.

I can confirm that fixes my GoFlex.  Would this justify raising the
default for Kirkwoods, or just for specific devices within the family?

Josh C

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
