Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DCEAC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:30:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 313D7218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:30:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="O9hWpCDR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 313D7218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A60D18E0009; Tue, 23 Jul 2019 13:30:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A117E8E0002; Tue, 23 Jul 2019 13:30:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B2358E0009; Tue, 23 Jul 2019 13:30:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 643688E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:30:34 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id v9so11669214vsq.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:30:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RbhpiDasw1Ewe5g+7weE9TXbMjL8KAWk+B3qwXxWc/M=;
        b=LrYHnubuNqH7D+F9kXiV42Pax0X7ynzTxH6CdUJeDpWMJvfW3gwRXmgEnW5sLzBDlr
         NANjpdoIlB7brc5GEN7PK/BZ6BbM8GGlQ+BztcsKlvr4XhRpALJqGCP49dR9GQhcYWpu
         e9M8Z5k7Z+CzYEWKMf8EkQq8RbT8Zpk+UmOo7vNVH80wBDLBb40PVHP+Qky5iZ/KrPQC
         2/U+vYKc3BaMdxpAPV7+S701MgrSiX3JZIw9FGCEdbTgBwz+MENQnRe2GWJIJ1E0VUWK
         wv9TeobhuPSjiEL85UrCgVoONrZ4rtI7EnCuXEmzVRdJC/1KxTT+6/J+y4hcao00oLyz
         fLDw==
X-Gm-Message-State: APjAAAVHoboy7d4OYGYiqT6HmmPAKnl4PI3OJXJ1AT6lQs8zeT8dmaNu
	FHrD40OvSJ6aJPH2OcbbnNDLRfs0PCQl2iAkZRrg57G2XMgRd8ytzhRq27TJLmnVQSAi4N+Gd1G
	UbC6HhOHOUa5q/kITF23NGF8WaqvKWdKY1zZ6OERq+hUpnkyaLxJRaepJksuRrqxQvA==
X-Received: by 2002:ab0:36:: with SMTP id 51mr50010526uai.105.1563903034128;
        Tue, 23 Jul 2019 10:30:34 -0700 (PDT)
X-Received: by 2002:ab0:36:: with SMTP id 51mr50010436uai.105.1563903033588;
        Tue, 23 Jul 2019 10:30:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563903033; cv=none;
        d=google.com; s=arc-20160816;
        b=C95zhJtRzerQKjXP7gz2n96vm78OajVXKGsgguSa/dWmA0Ulyb1zLeVM6mezsAA000
         XrVWUWymjSyEx7jILlCKGfIlrXB+FWTq96kJxZaZGgVSHHwmAHMmHtEk+xdSzZIwlb8v
         1Z2FyVkiabIcKZNOT0fQb3YrDm+or6eljeZxpKYfsiTNv+UdCh/MFqSIBY4TzLXRVCTZ
         O2hB/HW8AdxFqDhaG+aAmBS0EK3pSWOMcVgloa0okrdSyiwXtk//S8rNvH8bAbkyWIv8
         k74dI8kN8Ay2Leeyfa+gBrTLjA0YIxsB3NBVvPhXRkw2PO+RmjCdh1ciHF9p2HexzlY3
         TauQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RbhpiDasw1Ewe5g+7weE9TXbMjL8KAWk+B3qwXxWc/M=;
        b=m5lVZ3Cv1sqy+JqOrvWdGUJG368+9mgzdDAGrV5SPE6O5Vj/JKjSmeJzQcjugx5Lhw
         BD/Oggn40OBSMB1xO0Lx9Oe+vvatpYAPHbLuC3uM3mBNA87txRzZQI+gqr9fiGIXHOIr
         2MtHXjjIwHbqEebnMzJzIf1ENbKdRHjYbbUthii3YuI7YW8hr+lDnRKfqyGXwcncHvqk
         0KhwrPDsfiKSGvKjaOTvb9ZTugfYBCo5gJEI2tlf//g0WIwqYvccVkjH1UNFU1nCDCHf
         mgkTMtGcP9LoRwfCtrS2u0xil83gfv0IdILo9diDV52OHSBG5HKZnwO2qWfNFo5naphB
         3KpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O9hWpCDR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor21370069uap.25.2019.07.23.10.30.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:30:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O9hWpCDR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=RbhpiDasw1Ewe5g+7weE9TXbMjL8KAWk+B3qwXxWc/M=;
        b=O9hWpCDR380rbhw90TNwrzp28pNffEoS4Us5UckcJaWEOyzBJaUbrQSE98N+ymjxQW
         oiBk973xZ6ORiEBiV9Zx6YM5f6Q32IYj0/SyGtmDoGFY8uMFYwt3mdlZ97s5C49fnMui
         2OTpVNIjIGGJAlPoeE+X847UupJo0ZA8rnMsUoH0URd6UnZ19b2YDamDSx3OJSe3EMOb
         Kt2uJ7zSPkpnVExd29sGDon2CJhSCEdXgWKiUUomK2L0M/1EIgZbY6L4agXTd7JVcj3V
         AkElcQgYYmWIkQrV6d6fmuAyO9EgG8sewHhTtRGw4oqVCiwsjjyyZ/Ue6PsPkX8h/K78
         iXYw==
X-Google-Smtp-Source: APXvYqwgXpmyPlVv/AMR8i5yc7RI1B7//ksxiY/lelX41GFnDNSTYMBLZpaY2My1r5ik6s2sxtfhhQ==
X-Received: by 2002:ab0:60ad:: with SMTP id f13mr37669182uam.129.1563903033250;
        Tue, 23 Jul 2019 10:30:33 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id d3sm4771548uaq.20.2019.07.23.10.30.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 10:30:32 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpycS-0002gy-4J; Tue, 23 Jul 2019 14:30:32 -0300
Date: Tue, 23 Jul 2019 14:30:32 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 4/6] nouveau: unlock mmap_sem on all errors from
 nouveau_range_fault
Message-ID: <20190723173032.GF15357@ziepe.ca>
References: <20190722094426.18563-1-hch@lst.de>
 <20190722094426.18563-5-hch@lst.de>
 <20190723151824.GL15331@mellanox.com>
 <20190723163048.GD1655@lst.de>
 <20190723171731.GD15357@ziepe.ca>
 <20190723172335.GA2846@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723172335.GA2846@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 07:23:35PM +0200, Christoph Hellwig wrote:
> On Tue, Jul 23, 2019 at 02:17:31PM -0300, Jason Gunthorpe wrote:
> > That reminds me, this code is also leaking hmm_range_unregister() in
> > the success path, right?
> 
> No, that is done by hmm_vma_range_done / nouveau_range_done for the
> success path.

.. which is done with the mmap_sem held :(

> > I think the right way to structure this is to move the goto again and
> > related into the nouveau_range_fault() so the whole retry algorithm is
> > sensibly self contained.
> 
> Then we'd take svmm->mutex inside the helper and let the caller
> unlock that.  Either way it is a bit of a mess, and I'd rather prefer
> if someone has the hardware would do a grand rewrite of this path
> eventually.  Alternatively if no one signs up to mainain this code
> we should eventually drop it given the staging status.

I tend to agree with the sentiment, it just makes me sad that all the
examples we have of these APIs are so troubled.

Jason

