Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5575DC5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:29:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 072F7208CB
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:29:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="i/sq3VFp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 072F7208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 818C58E0003; Fri, 28 Jun 2019 14:29:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C9938E0002; Fri, 28 Jun 2019 14:29:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66A678E0003; Fri, 28 Jun 2019 14:29:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 176658E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:29:34 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id b3so10091699edd.22
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:29:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=aW+4ZnzFUxI2thr+G8Np8e2Oaw4bAbhf7CTAtwXVS7w=;
        b=Qssx6y6YCksBLl6bWICDFcLH3w2aAGavmqWaUom08Ojd//JWeSdzcWv07eoX4gdTw7
         NOJOuDxr0rIbAw6BgjBMx//7+a9KE6nJE4Is5TzYz8M1d4mamhn/igBU8VldIkg3/wX5
         ibNCxdDxZoq21gnajM+u+3hiEkrUM3fhMiKABYyUyh1PcWFxeQGabk2XwTD25SwVGlnO
         mYxaIul2Z2uHUA9wUL6YE3V1o4uo1iBq+m/JbMuHKIlQutx2IiZh7dk8U3B9zRbEJNf6
         szNP1kVTA7AhSLpSPbF4udcvFh+LFpxy8cyvVg7pEv/rmW9c00W91IOH9mPJJfWVY8ZR
         zhDA==
X-Gm-Message-State: APjAAAUzmYCczfJjpCD3Yef48SAtjo7nXoyUb2qL8IvAFN788P36jqrd
	d+0cpcLLOruxRDPS5KpVean9qDd/QKGcpOBEeOfOQsEjkQ85trgkd2T/sIwrE19Rw+xY1Xjllqd
	y1qi+8aMmn2fvgWmBoayhoLpHWfhnhtLOCUVX4mEdusbntZgYgb9d9ci56allj3iVew==
X-Received: by 2002:a17:906:a308:: with SMTP id j8mr10225492ejz.167.1561746573476;
        Fri, 28 Jun 2019 11:29:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/RhACEdSIWco8gB5zo5Ad8KE/10CZ9ZLQJGJK0Z4GbHZ6UK1xHHqvX28hSPJ9FDzYYc1x
X-Received: by 2002:a17:906:a308:: with SMTP id j8mr10225424ejz.167.1561746572525;
        Fri, 28 Jun 2019 11:29:32 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30065.outbound.protection.outlook.com. [40.107.3.65])
        by mx.google.com with ESMTPS id g2si2569816edh.299.2019.06.28.11.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Jun 2019 11:29:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.65 as permitted sender) client-ip=40.107.3.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="i/sq3VFp";
       arc=fail (signature failed);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.65 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=SMGjLKbDUPfnf9EYwqTLq1tumGoualfPfZcFgUBrEzxzlqL/SVk3jtE5n9dT2tOgXbmj9lBwtsvItQONYVwwr5YfzL8oruGtdHK8n1yZklIdQeNlQZ01vC9+f3RSEKPH/fr3Re4hHu0z8fC0KIRg7c9+19rrwDox0/hNIeYC3b8=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aW+4ZnzFUxI2thr+G8Np8e2Oaw4bAbhf7CTAtwXVS7w=;
 b=XA9ftZejVn45JWnTwlvetjfcxwbhqKfzuI3izLVSnEYc9VQemMGteuUAyAVrpeKuLkJIT302YxzUg27XJQW/0988mEqMEeO0tQmLJrfKXyD4vaqSjxdd9qbfNfrlYTolHJ4xLjagtiu9BgCJ2iyCHiqF3okOMTCvJM0pprTAjp0=
ARC-Authentication-Results: i=1; test.office365.com
 1;spf=none;dmarc=none;dkim=none;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aW+4ZnzFUxI2thr+G8Np8e2Oaw4bAbhf7CTAtwXVS7w=;
 b=i/sq3VFp3C08XaTuKwHLxcVYHPXIaNzhEuu3F3FguK6s4f+v0TYSCoJH2ugmmoXVU6n5/DNhHQNaWKQmEIMLgq5RWK0e1Er/GxWZs+smSRYlWXAF/zxXR48Wo9swMfK8cs9srf9qNSeH2CyPNtX0djywJbltIyU2UZb4thfbaC4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4365.eurprd05.prod.outlook.com (52.133.12.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Fri, 28 Jun 2019 18:29:30 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Fri, 28 Jun 2019
 18:29:30 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Thread-Topic: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Thread-Index:
 AQHVLBqgvimki3zmIk2l4xtSxGbkyKaxNtmAgAANxQCAAAmqgIAAAboAgAAAeQCAABYfAA==
Date: Fri, 28 Jun 2019 18:29:29 +0000
Message-ID: <20190628182922.GA15242@mellanox.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-17-hch@lst.de> <20190628153827.GA5373@mellanox.com>
 <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
 <20190628170219.GA3608@mellanox.com>
 <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
 <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com>
In-Reply-To:
 <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR08CA0008.namprd08.prod.outlook.com
 (2603:10b6:a03:100::21) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [76.14.1.154]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 92287021-7090-4314-de00-08d6fbf68ed6
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4365;
x-ms-traffictypediagnostic: VI1PR05MB4365:
x-microsoft-antispam-prvs:
 <VI1PR05MB43657FBDB1EA58C053C63BC0CFFC0@VI1PR05MB4365.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 00826B6158
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(396003)(346002)(39840400004)(376002)(136003)(199004)(189003)(66476007)(486006)(6512007)(33656002)(66946007)(7416002)(6916009)(71200400001)(2906002)(73956011)(64756008)(36756003)(66556008)(71190400001)(68736007)(66066001)(1076003)(305945005)(99286004)(7736002)(6506007)(102836004)(53546011)(6116002)(66446008)(316002)(81156014)(52116002)(54906003)(8936002)(14454004)(5660300002)(2616005)(476003)(386003)(26005)(6246003)(53936002)(25786009)(86362001)(76176011)(6486002)(4326008)(229853002)(14444005)(3846002)(186003)(11346002)(6436002)(81166006)(446003)(478600001)(256004)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4365;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 NndW95S8YhHhIuIPXgE6DJ7FFQ7Wi7Qv94ks4fGecraJJl1kl/B/OiUhXXk9d64RAObNBGQNxj/+Dsy5mCDDXsBwBDTWMuw3tjOuwTSgwG5PzhEEsvNDJf9XW+MPpKaSIsZv/rs4/U1oe22/ThS4DnCfmYBIFdhumeofar4MDc1jemYw0XIYXX8bU9TB+TOtLL3E7d3f4yPyOPANELn3trWurneIuwVvOkzGEBz4dpp7ebk/fyq+oyUj00Dl1Sgj+X8NHddMhnD3WgJiL9qTBSapgYgKOkVLUcxF56u40YYlfwNZXXBi5FOP0gnYxu24VP8w25yfd0HTdOMjiy1SlXg4j33ovwiSGHGgr9YOfs+e/FuwerlAr0ZU/nj91QnAncOQQTkPfIx9yX5IeyPw9IJWGZeEyz3r0NamJ8DV4Fo=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <14F6B0C5B925FB4B8ECAEFC2C0B435B0@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 92287021-7090-4314-de00-08d6fbf68ed6
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jun 2019 18:29:30.0154
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4365
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:10:12AM -0700, Dan Williams wrote:
> On Fri, Jun 28, 2019 at 10:08 AM Dan Williams <dan.j.williams@intel.com> =
wrote:
> >
> > On Fri, Jun 28, 2019 at 10:02 AM Jason Gunthorpe <jgg@mellanox.com> wro=
te:
> > >
> > > On Fri, Jun 28, 2019 at 09:27:44AM -0700, Dan Williams wrote:
> > > > On Fri, Jun 28, 2019 at 8:39 AM Jason Gunthorpe <jgg@mellanox.com> =
wrote:
> > > > >
> > > > > On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote=
:
> > > > > > The functionality is identical to the one currently open coded =
in
> > > > > > device-dax.
> > > > > >
> > > > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > > > >  drivers/dax/dax-private.h |  4 ----
> > > > > >  drivers/dax/device.c      | 43 -------------------------------=
--------
> > > > > >  2 files changed, 47 deletions(-)
> > > > >
> > > > > DanW: I think this series has reached enough review, did you want
> > > > > to ack/test any further?
> > > > >
> > > > > This needs to land in hmm.git soon to make the merge window.
> > > >
> > > > I was awaiting a decision about resolving the collision with Ira's
> > > > patch before testing the final result again [1]. You can go ahead a=
nd
> > > > add my reviewed-by for the series, but my tested-by should be on th=
e
> > > > final state of the series.
> > >
> > > The conflict looks OK to me, I think we can let Andrew and Linus
> > > resolve it.
> >
> > Andrew's tree effectively always rebases since it's a quilt series.
> > I'd recommend pulling Ira's patch out of -mm and applying it with the
> > rest of hmm reworks. Any other git tree I'd agree with just doing the
> > late conflict resolution, but I'm not clear on what's the best
> > practice when conflicting with -mm.

What happens depends on timing as things arrive to Linus. I promised
to send hmm.git early, so I understand that Andrew will quilt rebase
his tree to Linus's and fix the conflict in Ira's patch before he
sends it.

> Regardless the patch is buggy. If you want to do the conflict
> resolution it should be because the DEVICE_PUBLIC removal effectively
> does the same fix otherwise we're knowingly leaving a broken point in
> the history.

I'm not sure I understand your concern, is there something wrong with
CH's series as it stands? hmm is a non-rebasing git tree, so as long
as the series is correct *when I apply it* there is no broken history.

I assumed the conflict resolution for Ira's patch was to simply take
the deletion of the if block from CH's series - right?

If we do need to take Ira's patch into hmm.git it will go after CH's
series (and Ira will have to rebase/repost it), so I think there is
nothing to do at this moment - unless you are saying there is a
problem with the series in CH's git tree?

Regards,
Jason

