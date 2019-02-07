Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C064DC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 04:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7DFF2175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 04:34:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="Hc+skVA+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7DFF2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D5428E0015; Wed,  6 Feb 2019 23:34:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4836F8E0002; Wed,  6 Feb 2019 23:34:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 372FA8E0015; Wed,  6 Feb 2019 23:34:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8ACA8E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 23:34:57 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d11so3199363wrq.18
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 20:34:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=4RCZJtim6FzAWTAE5STy48t7VfnqZ8YM7yrGj0CnzHY=;
        b=HOGE89+6wgOJBQohoihq3jjvAoAJdjDENVVIdOepP0wKwhJsGIJAcnWIytGAotxs85
         TMjGARDDlHEJKSxweU0jptPfG4lKR14waQE++dRhWNDmlj9RNbfrmzFjwJ3bmbvZuH30
         TotNZzrz8WGNPVjNMwm90Q3st1nVxkHUCAkOcnJfQ1Z8+QY+GG7TwPBe2sb6cwPFc685
         25VGFJETYd8Kd7luea2ezO1Lm8Qn2qPjIuDa/FK3NnnX/tdp02+JjRfcCSJnlt7gSq9Z
         6v9GR147VxqJuEeRz4ISVu8CE2r8yt9+KWB2Q9QuUsJQJIqoBLTcAcuXg8fz8JMDLVH7
         QfuQ==
X-Gm-Message-State: AHQUAubi186o4DgBCMO0Izzc3UPE0EPGpSm6+BxSs+iVlv2sVddI0238
	fDSAR21FEZiXXo2nmAMgz1M63tqRl96y70q6PZaZbDo+eaKfj5w/MfvOj0WUVm6VBKiKazT1JIQ
	WdVV1W94nd6XOHR3pQ35kEQpIGEASzNl8horKp/yTk/roLUeuKFyjRzpu7naC0JsKaQ==
X-Received: by 2002:a1c:5dce:: with SMTP id r197mr5206370wmb.130.1549514097292;
        Wed, 06 Feb 2019 20:34:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib/fB9eamGpHL8MeBO/VPydf/bqOT0gBGCN/fATTy0sg421bUjNap8pK6EBakhARRkOBLjW
X-Received: by 2002:a1c:5dce:: with SMTP id r197mr5206343wmb.130.1549514096131;
        Wed, 06 Feb 2019 20:34:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549514096; cv=none;
        d=google.com; s=arc-20160816;
        b=Cz7AcayE8pJBhQlZ1f6g30o99jdSmbM+msRzydJhkZbsFYJ1dWdBzAmo4FxY2oBsoe
         2KFDfks2VvHhiIlDkvz1H2+Je5ysTT30nFjQQkb7bQOnZOgsOG7S4jklejxBZN6XaEUj
         9YaF6XcNKS7y2xFowICgP3wteXScZGF7XYCuLtrMoycnE8/IQfghmk/qWon8nhrFj2W7
         30KNbAIOpcNpQNSJaV3IJvRZHIcYv8MEjLauSmDhgesaGW8B18dfLiKG4oVy3fsiiJu/
         rdZsYgal0P9ozkOibhfI6IyEUkjqs2udT7U3vFYaD11aVEmBuye0U0vRfgtA1F12XMjB
         9CMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=4RCZJtim6FzAWTAE5STy48t7VfnqZ8YM7yrGj0CnzHY=;
        b=jWz0TkB6j+xvTEQjbodODqSGgVGlpVwQfW0WDNuEABO8R/X7C18BMjUnaSxTxGa71Y
         UX7DvxBGpjRA8tnhEpu6QjDhz3hIQf8hxS/WrtrTxm47r3QrmKebIYBQSjhLrpZ+l+LD
         RvWW98O1720QPj4otmpR1OgLDO0ysiWXBOS5yFOC1GpwbKoJ6YLoNCkzsO9TzhCsuJna
         BuW9UqoMJFlacTDEgfAlJEB21Td26aFrGTCfKUWPACe5rrm/6z3/JNNsa21glXeCanO/
         LKfonXqQ4eHZLpT1A0dTCaO/GpHvMYV9al/xtHpEO4bW2LdV0z343ouNYFN40OHMgWdW
         awjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=Hc+skVA+;
       spf=neutral (google.com: 2a01:238:20a:202:5301::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::9])
        by mx.google.com with ESMTPS id r6si18829762wrg.298.2019.02.06.20.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 20:34:55 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=Hc+skVA+;
       spf=neutral (google.com: 2a01:238:20a:202:5301::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549514095;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=4RCZJtim6FzAWTAE5STy48t7VfnqZ8YM7yrGj0CnzHY=;
	b=Hc+skVA+3x8L6OOSGUSsKlrmPCbV70Ad0veY2OmlpiApiHoVtiZM8TiKDBTDcn5TJB
	E8bXMcLKt8+o9itPh9uPtgG6Ba3vHw1XKXgM8uNXmRSsluphk/kvt97V6ek8UO45qbzE
	8WU5MSKFvKCFLVBZ7Jnyb78SNZy+/ULcYgjR0C+ndJiH4Cmn0uQv/iAFolFqa49uvJMx
	QkWd9Jxdnh4tiY1sA8FBvBxpvI90dgh6B1pQc1QPBdbcCicMIuya9hqcFIMDP1Vciqr/
	BPM8h0UHpmfzz2jphD/frC+Ly9YFihLfghE6TzcP4e1m7Ri3X3D5PIUEmghdLvrGMJ3U
	PPCg==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6KxrfO5Oh7R7NWZ5irpilnQb0empL4BoZuMumiBlihp1rlLmzaQ="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a01:598:8181:7b2f:5890:9cb6:8e8:3292]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv174Yrxds
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Thu, 7 Feb 2019 05:34:53 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <20190206151655.GA31172@lst.de>
Date: Thu, 7 Feb 2019 05:34:52 +0100
Cc: Olof Johansson <olof@lixom.net>, linux-arch@vger.kernel.org,
 Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org,
 Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org,
 iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
References: <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de> <20190201080456.GA15456@lst.de> <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

I also didn=E2=80=99t notice the 32-bit DMA mask in your patch. I have to re=
ad your patches and descriptions carefully in the future. I will test your n=
ew patch at the weekend.

Thanks,
Christian

Sent from my iPhone

> On 6. Feb 2019, at 16:16, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Wed, Feb 06, 2019 at 04:15:05PM +0100, Christoph Hellwig wrote:
>> The last good one was 29e7e2287e196f48fe5d2a6e017617723ea979bf
>> ("dma-direct: we might need GFP_DMA for 32-bit dma masks"), if I
>> remember correctly.  powerpc/dma: use the dma_direct mapping routines
>> was the one that you said makes the pasemi ethernet stop working.
>>=20
>> Can you post the dmesg from the failing runs?
>=20
> But I just noticed I sent you a wrong patch - the pasemi ethernet
> should set a 64-bit DMA mask, not 32-bit.  Updated version below,
> 32-bit would just keep the previous status quo.
>=20
> commit 6c8f88045dee35933337b9ce2ea5371eee37073a
> Author: Christoph Hellwig <hch@lst.de>
> Date:   Mon Feb 4 13:38:22 2019 +0100
>=20
>    pasemi WIP
>=20
> diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethern=
et/pasemi/pasemi_mac.c
> index 8a31a02c9f47..2d7d1589490a 100644
> --- a/drivers/net/ethernet/pasemi/pasemi_mac.c
> +++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
> @@ -1716,6 +1716,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct p=
ci_device_id *ent)
>        err =3D -ENODEV;
>        goto out;
>    }
> +    dma_set_mask(&mac->dma_pdev->dev, DMA_BIT_MASK(64));
>=20
>    mac->iob_pdev =3D pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
>    if (!mac->iob_pdev) {

