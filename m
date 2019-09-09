Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B00DC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 19:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F3C721A4A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 19:33:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="hMUpmG5b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F3C721A4A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D17C6B0007; Mon,  9 Sep 2019 15:33:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8706B0008; Mon,  9 Sep 2019 15:33:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396946B000A; Mon,  9 Sep 2019 15:33:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 16E546B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:33:59 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A1D9D181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:33:58 +0000 (UTC)
X-FDA: 75916382556.23.feet27_5cd2176b04521
X-HE-Tag: feet27_5cd2176b04521
X-Filterd-Recvd-Size: 5995
Received: from mout.gmx.net (mout.gmx.net [212.227.17.20])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:33:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1568057627;
	bh=d4t6NvwMQ9YTypUWgwkNC+7VlgA/JtZpt8GrsPSKCHs=;
	h=X-UI-Sender-Class:Subject:To:Cc:References:From:Date:In-Reply-To;
	b=hMUpmG5bI7Ecc5qn5YxStKIYidbTDxDpIrG5t0X1WwthOKMSGEFnXbVwz2DSNffOa
	 Sv8dyTkSeSeYMwFeuT2tmsZhrWzWS2lNLvaSMgvZ+8LtrhLlXGqZKkb/ZXcVFVfPAl
	 e1W0am+4D0QCIP+kg00x2jQkHxmtfpcqdGHHqP+w=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [192.168.1.162] ([37.4.249.90]) by mail.gmx.com (mrgmx102
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0MfjJY-1hkOv10G4S-00NDN8; Mon, 09
 Sep 2019 21:33:47 +0200
Subject: Re: [PATCH v5 0/4] Raspberry Pi 4 DMA addressing support
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>, catalin.marinas@arm.com,
 hch@lst.de, marc.zyngier@arm.com, robh+dt@kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-riscv@lists.infradead.org
Cc: f.fainelli@gmail.com, will@kernel.org, linux-kernel@vger.kernel.org,
 mbrugger@suse.com, linux-rpi-kernel@lists.infradead.org,
 phill@raspberrypi.org, robin.murphy@arm.com, m.szyprowski@samsung.com
References: <20190909095807.18709-1-nsaenzjulienne@suse.de>
From: Stefan Wahren <wahrenst@gmx.net>
Message-ID: <5a8af6e9-6b90-ce26-ebd7-9ee626c9fa0e@gmx.net>
Date: Mon, 9 Sep 2019 21:33:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190909095807.18709-1-nsaenzjulienne@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Provags-ID: V03:K1:LS01oHKQzcvClmAtuMiV35GzDWGQjl4TMocrZcQk6DA6HAVrjMq
 joLIBQ7XFMXVpIeH/MS6IOvr05uJoNzY1DAliZFeoVMG1Smed9yI3/EPqAlOvnZYq+y4ifa
 1I+hzKfFlkjxIEeh48LA8fJ8+IW5/n72kNXSELzZybJBa7s3kQ74+muskUQhSuquNeriMTy
 XJfBatyvN85xpY5hnhDdQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:8DJJrmG3oug=:r20bBXJ9yriqQL0K7dlYtr
 3D5nkd2eNwi/fPIc7nA/XReM5DD2ystesZjI9WG/JWxtWZdVDqHxCXgsdG9upl0LqHxhPRWl2
 IoruO8dbxq2k9VpIfNo6q4WCvXtkCGKKsw3sH6oNySDjjYT6mZusv7UXmfHa0ovSI12/tyJNF
 OOZEkPvsa0wmVJ0R9v1XPZRNqH1eASiHW+iVlt/tB8NniA3l5NBhPYbYb9A3RtBjKmbDLZ2fh
 8+Kl9rh8JTvTgYcYKvF7i6fvXP9dJGs3ngxG+VI6VNtd1UsjcOj6HWI15CHZAaI0355vx7e+W
 ilwfYTgk0Ma1/6qI0EfInxLskbi5eBScqF0zN/rnknI20HdCFwethoNTw0+IwAybm5l3UwXAO
 AM9wUDmOGpXmAZFJhwHv0AW19s5t/ls0/XSr5XFmSl+urCrBLgkPcZ9BpUqXVF61h7a0IJ9c3
 vTmEd8/Wqk3gPrHkAulh/i0IDJfnrBYJFMu5cBLFIRU9L712b3+pkTe5wa2p7jKYvOUwH1R8C
 ALrokkoKreKkpotBT1Wsvgt+zLiHVr5Qu6134HCzGxj/jFln7a38J15ryJlaoEWj6xlXJaY5Y
 CpuXNF2mIRbRPoTDFkejvgHl/XDalzWfCh7pHDsl/wiBfUZAl6CNPHfjYKlxwQtU0DksbtlgK
 PP0UCzTwxEz0y/6CC+wlQfzGLv+iciCgw/bh6P54tMKmlxcIORsIiwzp0WsfICSPiSNNRA7b+
 gJImh/7edE5WeVs3jHJmk0zNCAljed+Y6pkB60wOgaQmFDoWHoJgUc6T/RRfIrjVpFD4f7ESQ
 NFIdgmkZ+ewXmvphXZpkC/kQ+b5umYYh8LAAu2IjmAC+NpVd2uqKGicmytJkmOl222yRcvS/i
 KxTvBPrPPOk8/UOGm74aUUxwB/WppNLQ/4sofAEQ53FOsXJ68c9YKnSwZKpUj3/ALYd22bFGN
 JM1GFT7CylIv1mlwb0SbD6PVHtccl4U7LVjkAh/OzirSupflS+QcIPLiDDdmWW7hsXYU2+bwk
 DkkoVrlTPhN4e3autQhPV2XrcsKf4pJePsFukIGhvvClKgUYrNQ2kyEwUV0mt2JiS5Gz0n6WZ
 pbUk1x1giL3IYcwkMwR3QV1KowVLihGeVN7uJ6LB+yEHapvBIqAHAxh4rEyq6qZ0wluGpNfAM
 RCCSySDoWoGQs49i1yGfO0WkT+22+w6nWSaDNcr32p+OEUFCd2Yvrc+Mfa6zY2E7Efv3o=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nicolas,

Am 09.09.19 um 11:58 schrieb Nicolas Saenz Julienne:
> Hi all,
> this series attempts to address some issues we found while bringing up
> the new Raspberry Pi 4 in arm64 and it's intended to serve as a follow
> up of these discussions:
> v4: https://lkml.org/lkml/2019/9/6/352
> v3: https://lkml.org/lkml/2019/9/2/589
> v2: https://lkml.org/lkml/2019/8/20/767
> v1: https://lkml.org/lkml/2019/7/31/922
> RFC: https://lkml.org/lkml/2019/7/17/476
>
> The new Raspberry Pi 4 has up to 4GB of memory but most peripherals can
> only address the first GB: their DMA address range is
> 0xc0000000-0xfc000000 which is aliased to the first GB of physical
> memory 0x00000000-0x3c000000. Note that only some peripherals have these
> limitations: the PCIe, V3D, GENET, and 40-bit DMA channels have a wider
> view of the address space by virtue of being hooked up trough a second
> interconnect.
>
> Part of this is solved on arm32 by setting up the machine specific
> '.dma_zone_size = SZ_1G', which takes care of reserving the coherent
> memory area at the right spot. That said no buffer bouncing (needed for
> dma streaming) is available at the moment, but that's a story for
> another series.
>
> Unfortunately there is no such thing as 'dma_zone_size' in arm64. Only
> ZONE_DMA32 is created which is interpreted by dma-direct and the arm64
> arch code as if all peripherals where be able to address the first 4GB
> of memory.
>
> In the light of this, the series implements the following changes:
>
> - Create both DMA zones in arm64, ZONE_DMA will contain the first 1G
>   area and ZONE_DMA32 the rest of the 32 bit addressable memory. So far
>   the RPi4 is the only arm64 device with such DMA addressing limitations
>   so this hardcoded solution was deemed preferable.
>
> - Properly set ARCH_ZONE_DMA_BITS.
>
> - Reserve the CMA area in a place suitable for all peripherals.
>
> This series has been tested on multiple devices both by checking the
> zones setup matches the expectations and by double-checking physical
> addresses on pages allocated on the three relevant areas GFP_DMA,
> GFP_DMA32, GFP_KERNEL:
>
> - On an RPi4 with variations on the ram memory size. But also forcing
>   the situation where all three memory zones are nonempty by setting a 3G
>   ZONE_DMA32 ceiling on a 4G setup. Both with and without NUMA support.
>
i like to test this series on Raspberry Pi 4 and i have some questions
to get arm64 running:

Do you use U-Boot? Which tree?
Are there any config.txt tweaks necessary?


