Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C30D0C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 12:38:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84A29205C9
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 12:38:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84A29205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 192B68E0041; Mon,  4 Feb 2019 07:38:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11BE48E001C; Mon,  4 Feb 2019 07:38:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25D08E0041; Mon,  4 Feb 2019 07:38:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 990FC8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 07:38:54 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id h11so4581565wrs.2
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 04:38:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Hk9Yqi/v8tadcsmQgJMrDRiyrSRSUZPX8uc0xnZJkrs=;
        b=jESPq7aa4hvjmKTanOssZ9ojjUt93KAuga5Kp/rKRgQX/3GAKCLgI20uOsCFNPWTKs
         7Q8Meq2sD+yWOeACkk0Uposa+HaAOXOvWj2MrVjwLrizcsR7Y+Fsmxh28DxGQk4ZehRv
         kYRNbNdPVDnOhcokK7WXdwCr6i0jqz2km2BjVpK00kLEw+v4oq4/ZqtJ9YQ5HrODeMQr
         8kMxrttiTysykWOtofYhT4kFxtmJxMZTAhKapoPFyBeBdPklwNPHWuHfEQ2jlDYjud5Q
         5094zLOWFGQNaqzrjLOO+Y4JmsmbgDtVE2FTbgSnY6AUIzqfgRSLZzcHRF4W0pB+SpqU
         dnsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukdcp7G8gSurah02Gzn51PKMuO6C5SVjc/5tNrapCkujQHn1T0ob
	F/55aTTgkKzvtNu0qHLVuLmlILGHbTdtmTOciyvHxERbIf1CaM52Nbn3x0eeviPdv6i/Icgpn03
	EsXdP+FqFOvxF6P9HrVU7IMVlrbyuHauG/tmXjT8lETUj4ZItFxoNqFQFPJqGEEumVA==
X-Received: by 2002:adf:84e4:: with SMTP id 91mr48751693wrg.237.1549283934146;
        Mon, 04 Feb 2019 04:38:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4fMcw3eJU13559gjuzEIGhz5TVlq1A3t71+Lt8V27Zkh4uMgk/oG1ZotYijX4N0QCP3eJD
X-Received: by 2002:adf:84e4:: with SMTP id 91mr48751646wrg.237.1549283933208;
        Mon, 04 Feb 2019 04:38:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549283933; cv=none;
        d=google.com; s=arc-20160816;
        b=BKMyyW2nN6MVcFEDR1oFTEAkT/XKtZSzaIGWBKXcUCKSPpY7RXYxx8X9+HVfOv+dq1
         s4a/07aakoxBJoXDny8YsHsrLGx+MJhQ9vGPJ1/Mv4K+9TCe8VvPKRFLlpvmSqvF/tGw
         iCiGIHqbMFHfD8bGpasAKKvws7JBcn152AvU5T6ibmbYLx69iFHWVJBVNP5YdBjYabvJ
         aIiAcx0knlUqRvtRyRnDb2KRw0KplZ8I6MplK/ZGuxJPvDGuPioGEIRFxB6NAEtv4hgw
         E6exE8YM7xe5AJ1XPc7j/Ro5vIxlE4n1yzkQxsNfUasHQDlZvj6wJEZlb91gIe0wWo4l
         vEVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Hk9Yqi/v8tadcsmQgJMrDRiyrSRSUZPX8uc0xnZJkrs=;
        b=bx5lXGCrEl22NV/PejOSZWlPQHOQROe7pdFRapL2mXgQefpA2SqcvWDzHBmaLtUxct
         CUvl7Vlrb241Tz2qc8Tz2ua+eTt9NjL6M+sdJROJXng79GgVE7H35stbfFYTdT1R6Ixi
         wyAJL2qj+EtGWWPPhMVBIqewdvKq+5h+BwUVHnHNZ/WC4q6YoYbKkpZ9Be6ZVAwgl+Pe
         RzKh9gEbFr5urrTbPVhVjihKkdqdGsGelFp7U6504VN2LUoYG0Cg+Lz6qKC1hAFpGCwY
         3rooYJgDaEBBIIjewqqIe/lQKTls7O7qrtLtJlcuYl33KlRag7J3mZCqK8Pv5lGmUCnd
         XWgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d69si7755459wmd.74.2019.02.04.04.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 04:38:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 839C668D93; Mon,  4 Feb 2019 13:38:52 +0100 (CET)
Date: Mon, 4 Feb 2019 13:38:52 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>,
	Olof Johansson <olof@lixom.net>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190204123852.GA10428@lst.de>
References: <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de> <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de> <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de> <20190201080456.GA15456@lst.de> <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 01:13:54PM +0100, Christian Zigotzky wrote:
>>> Results: The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet
>>> doesn't work.
>> Are there any interesting messages in the boot log?  Can you send me
>> the dmesg?
>>
> Here you are: http://www.xenosoft.de/dmesg_X1000_with_DMA_updates.txt

It seems like the pasemi driver fails to set a DMA mask, but seems
otherwise 64-bit DMA capable.  The old PPC code didn't verify the
dma mask during the map operations, but the x86-derived generic
code does.

This patch just sets the DMA mask.

Olof: does this look ok?  The DMA device seems to not directly
bound by the net driver, but not really used by anything else in tree
either..

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index d21041554507..d98bd447c536 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1716,6 +1716,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -ENODEV;
 		goto out;
 	}
+	dma_set_mask(&mac->dma_pdev->dev, DMA_BIT_MASK(32));
 
 	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
 	if (!mac->iob_pdev) {

