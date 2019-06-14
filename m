Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BAE0C31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:01:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6FE521721
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:01:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6FE521721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CD3C6B0007; Fri, 14 Jun 2019 11:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77EA86B0008; Fri, 14 Jun 2019 11:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6203E6B000A; Fri, 14 Jun 2019 11:01:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 136856B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:01:28 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id o18so1164734wrm.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:01:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:mime-version
         :content-transfer-encoding;
        bh=dqTKuHpooSHSGlyJuSJtYDPC3QEghi4cEDvbTL78Hus=;
        b=g6Oaj4XuxkyOwrrTyYKCHJiwsmdEcqt4BOSJdfl0CBueEZy7vWe1JnKs/BDP4M1AQ0
         bC35tKqMfPfPiMWtp6yFBhcGPoQuU7v9eO1qrFjwcw4ebbg369x2O170iAOqJvty74SS
         3j0x2tHgz+J6sTsfgzT099xHXbijQ0Ro89W4cTn99spEY+JOG7Swi9kPMrsYeHpDZZJw
         Wkz4Iaj9b9C4jxqd0v7F1mZGRez7o8cG3VAu5dRchZeIqfbOYNCvaeeNIQUo6imnqBkl
         anAKA4vYJEBEqVeEsK7cJutY8Cm0kHSWFQhHwyGfc4/38cmtL9takjPjKQQGGjmrwQ0S
         zLDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
X-Gm-Message-State: APjAAAUKQNdle6avF0uXXmSLsRLnTdn+BislXc1rvx5wLYLeBSPrRfzJ
	yenN7YzkEurvuNrbxIyK0mwzrP6dNmxnlXEMrwkEnPIQ0irwl6kfx9ButCueCXgd5qV7d8+ybw+
	JjM/n9iQA4JZviZkZNn3OXsb/MZgX3sqiUeIteCQ0FDkM1NoObOXY9pYl2ELER8qG4g==
X-Received: by 2002:adf:e3cc:: with SMTP id k12mr8183068wrm.159.1560524487483;
        Fri, 14 Jun 2019 08:01:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQbY1W/Ewlproa2i3xUf6amC/rRB5tPUuAVAC5IGsNzdeZWfoz4eLogXfT/GMiAjNEBdGS
X-Received: by 2002:adf:e3cc:: with SMTP id k12mr8183024wrm.159.1560524486839;
        Fri, 14 Jun 2019 08:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560524486; cv=none;
        d=google.com; s=arc-20160816;
        b=rOKGWYePJt0okMeUhtqk9SLHof6UMSBypnveWGVRzPzL2DqvL05yBtReiNGFFowZGv
         K5EX08LdjxEuVQYtjYMZiAs8gQh9USwbhHpPmNWZkJsDYEZX8/FILFFF+z4/oB3n0b4h
         kTNAtiWgq1a0Blxbo8JyOG3MLLCkZ9uoBTsw3fKcazOf/eBWIqwYkLLWD8dINAzhkjwR
         c8/RMzUkzRSAOoJlhfGi0MZluOX0Fpio5dRH1ksVQ+CNCsKyHVbXKT+EPDyoK01mzL2S
         ev0Wk94qidX4hBU2RGrebt9fh/SvBg0qRyfveW6EQARK4FjNNOrNdXuI/+E5PjKfxCne
         Ud+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=dqTKuHpooSHSGlyJuSJtYDPC3QEghi4cEDvbTL78Hus=;
        b=ZQyagoukRI+e3LBELY1aEZ1nKBXLW9oxPw2iszkTBx84xl7JGQrXprsoBPWfmeKdtX
         Vmf5D+B2As6f9WGBz8cSMt5Zhe3/NiDSlw3V3z3oULSyJSrKOY/nGaR9EfGsdGAo+PA+
         /TsZEwSrVAdoQ3Hqd+To9Fb+G23/usT+o9TU+ccqVxvC0gh5VLT8frRhP+CP33nZMwno
         /0yRAO9tD+ePGNK79G66sIvPrdIHOzQTVXi/5pyeRL+ppiCFFIFnHpGINF7xYE6zmqDb
         AL5LEPjAjSayXw1QRKWXhny1wr55tnwUEoO+2+6zqr/6BlcRW/6rJN9LKaOTrmlJ+o8/
         qRPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id u12si2673420wrw.29.2019.06.14.08.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:01:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) client-ip=207.82.80.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id uk-mta-6-Ae-vvi9EMKOPr28p6sbQQA-1;
 Fri, 14 Jun 2019 16:01:23 +0100
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b::d117) by AcuMS.aculab.com
 (fd9f:af1c:a25b::d117) with Microsoft SMTP Server (TLS) id 15.0.1347.2; Fri,
 14 Jun 2019 16:01:22 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000;
 Fri, 14 Jun 2019 16:01:22 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'Christoph Hellwig' <hch@lst.de>
CC: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Maxime Ripard
	<maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>, David Airlie
	<airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, Jani Nikula
	<jani.nikula@linux.intel.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
	"Ian Abbott" <abbotti@mev.co.uk>, H Hartley Sweeten
	<hsweeten@visionengravers.com>, Intel Linux Wireless <linuxwifi@intel.com>,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Thread-Topic: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Thread-Index: AQHVIrfpTFjppS25RkWUhwqPPyqZ4qabLzdw///7eICAABIeYA==
Date: Fri, 14 Jun 2019 15:01:22 +0000
Message-ID: <d93fd4c2c1584d92a05dd641929f6d63@AcuMS.aculab.com>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-17-hch@lst.de>
 <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com>
 <20190614145001.GB9088@lst.de>
In-Reply-To: <20190614145001.GB9088@lst.de>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
MIME-Version: 1.0
X-MC-Unique: Ae-vvi9EMKOPr28p6sbQQA-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: 'Christoph Hellwig'
> Sent: 14 June 2019 15:50
> To: David Laight
> On Fri, Jun 14, 2019 at 02:15:44PM +0000, David Laight wrote:
> > Does this still guarantee that requests for 16k will not cross a 16k bo=
undary?
> > It looks like you are losing the alignment parameter.
>=20
> The DMA API never gave you alignment guarantees to start with,
> and you can get not naturally aligned memory from many of our
> current implementations.

Hmmm...
I thought that was even documented.

I'm pretty sure there is a lot of code out there that makes that assumption=
.
Without it many drivers will have to allocate almost double the
amount of memory they actually need in order to get the required alignment.
So instead of saving memory you'll actually make more be used.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)

