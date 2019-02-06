Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E88F1C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 15:16:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0921217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 15:16:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0921217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52FED8E00C7; Wed,  6 Feb 2019 10:16:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DC968E00B1; Wed,  6 Feb 2019 10:16:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CD858E00C7; Wed,  6 Feb 2019 10:16:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA5078E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 10:16:57 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id v7so1062026wme.9
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 07:16:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nYJdAt1bpCQZ+/cOdHZDT2KaGwiu6NTGMoOXA7EZqmI=;
        b=jQIwLz0BugzdStPfy9es9sZ9g71b/PQHl4KsNxx2ZmaRhUPMgW1wjO0JH8jf6UxELL
         2jvjVg3cBjGFy58TPGcMdufrM0ko6QIymBKpBqzd8XNQ8uXyz9NRXuMaS/vY6wbAozoj
         Sf+psMTDMMOu86dB354Brwq3gc3QvJx3cOuOS0uwhNABPMOb09RDL4WCrv/DJqbhzTCg
         3Vk/wApJZEOfUWTPJmmMqM3WDJrF8+Myj//avV2Dn6Bi8quPOrA/TS65Xz64278j5XMY
         kZANYRyh/UHWjeFZNB1lRacjDOueV6cNLcEjWKOSUY2+0INdtHamTxAWnd9PHzfU5wXP
         O5cA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYyu0iSnf2Mu6a7rcDvi6Z82ytWmFNP7jA5DBvdaY2zqEgKFkqj
	u5J7sWL/bGB9BtfnFmWEhqgxAfljn8s7L+xDD7z64RUrdO5ccqWJg53+MwGyZrLy+EsIt1PV9co
	Na8t1+HEiyRJfSsPltn7UkE6/s2MFU+wgnj7R89T8cHfVnN5wcffzfvDz+qnmqirk3g==
X-Received: by 2002:a7b:cd14:: with SMTP id f20mr3344067wmj.93.1549466217389;
        Wed, 06 Feb 2019 07:16:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7P/Lft8z7LPD+3o9eiV9iC1hZ7VgkFs6NbsEjjsPZHXOCUoanjFlsCak6oKO5+/oMRheb
X-Received: by 2002:a7b:cd14:: with SMTP id f20mr3343991wmj.93.1549466216028;
        Wed, 06 Feb 2019 07:16:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549466216; cv=none;
        d=google.com; s=arc-20160816;
        b=lucjj22SsYzmtDTpihYccVc1VTH8vuzX00wFr/kc60Ijt/xsY+zhEl+iOVwjee8n00
         JiPrd1VVYGMsgsu8HE5wRD4rlPHflXaJK8PtH3gQbrPMyQ77yvhGLUIV28JEKhIMJ5JC
         cD8czpr5HONlOFMShgHFfmeVecyPf8XJDSaB2DLHXPorrzs3xhKkRQ2xEg+Zb4pHTotg
         pCEwB7s1TBeeYbIlAI0JUhbt3GjlHmBxsGXoleQmQ53+yPAPWE8uoSOwHG3mxRi8f19S
         c9OcZUeTj5/TUm9r2kYF5/QN4+i3VTEfHdM+uG4LecDKZfMmR/WuQLYO4nOSsmyx/+Ez
         9Rtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nYJdAt1bpCQZ+/cOdHZDT2KaGwiu6NTGMoOXA7EZqmI=;
        b=fJNLAVjoJ9BBGzD20+IkSdO+DIe036nnAirVEiq0nUa+XNQZXynZcVw0PdW/jWjZr8
         1ENpMjvuAVwpu93G4Iwa216CS2IfhZ/2MO58p6/R2ccsrJYlvf0NPEn26pvYDqGg2vTu
         uq6s3i3UUYfNkNtydRToxHW8SXIxKjYFXKCkVRYLgxzGcferqsCakXZHaE1DQNl3mJer
         I0MKCiM4di3pTQ0x9nTI/udfiL0ELMuyiQdvX7H2La8+keKFzq9LdHPRnQBTMe7TeJvV
         hBFipZexWFBFhyfP/w4j6iQxbKy0I61KQUVvcx6FKTHIuTeTToyHVgWV9UMKYbaFAy0Y
         8C+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id a18si17532048wrr.297.2019.02.06.07.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 07:16:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 4EF4F68D93; Wed,  6 Feb 2019 16:16:55 +0100 (CET)
Date: Wed, 6 Feb 2019 16:16:55 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, Olof Johansson <olof@lixom.net>,
	linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190206151655.GA31172@lst.de>
References: <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de> <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de> <20190201080456.GA15456@lst.de> <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206151505.GA31065@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 04:15:05PM +0100, Christoph Hellwig wrote:
> The last good one was 29e7e2287e196f48fe5d2a6e017617723ea979bf
> ("dma-direct: we might need GFP_DMA for 32-bit dma masks"), if I
> remember correctly.  powerpc/dma: use the dma_direct mapping routines
> was the one that you said makes the pasemi ethernet stop working.
> 
> Can you post the dmesg from the failing runs?

But I just noticed I sent you a wrong patch - the pasemi ethernet
should set a 64-bit DMA mask, not 32-bit.  Updated version below,
32-bit would just keep the previous status quo.

commit 6c8f88045dee35933337b9ce2ea5371eee37073a
Author: Christoph Hellwig <hch@lst.de>
Date:   Mon Feb 4 13:38:22 2019 +0100

    pasemi WIP

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 8a31a02c9f47..2d7d1589490a 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1716,6 +1716,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -ENODEV;
 		goto out;
 	}
+	dma_set_mask(&mac->dma_pdev->dev, DMA_BIT_MASK(64));
 
 	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
 	if (!mac->iob_pdev) {

