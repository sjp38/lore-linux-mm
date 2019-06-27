Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C174C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCE832146E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="FCgEsLal"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCE832146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 754238E0007; Thu, 27 Jun 2019 12:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 705218E0002; Thu, 27 Jun 2019 12:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A61A8E0007; Thu, 27 Jun 2019 12:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6268E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:30:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c27so6398233edn.8
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:30:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=wUTlgfdID2iRtFCZgVweDp5Qtf+mItNdaN0x/fMGgZs=;
        b=RWqxJXK+RKjmCxzOzDkOkiputMN1p/W942IVoeWXIbnUOeoCeFs/VPYz5WmKwyHW8i
         BbFFwgRXnaKI5VrONlxGHB+gD2H/Sc3w4KV8TCjz0bwah6xTADVEs68tmJeBnNNEfptm
         NjZ/+8omceSLb0gSBlgyu2SZMMtvjYLo/Wm5ON3dBbm9tB57VqQLjD6pVmqUHfs+8pDx
         6erJ6lVcHqycV2woweLrptgPADvHH1fbIbZ9NBi8LU4qTDr+Q+Y6J+DkG9X+fl1E0TDV
         peeXFypjldw1VdprO4SD5MOFxOEhLVGKPTElulwb7KLIg2AH6Evl7Abim2vKRNtFqWVj
         xS7Q==
X-Gm-Message-State: APjAAAXHjJgvB8ByFK2+upg3yVJ9jsmKviSytgdo+cilW5Qnhvknd9kW
	yeuoqM+0TEC5VaQKRr2XWYpu7WzKK5pt2T4sLNsFqTEuLg4oknLeM5A7xHqBpei2vWbp1kP780r
	u+TR4H9kB01+bsaApGHib5o+dpzzOCls0BAHd6URANAGsfYgBvm/m1KAib4vixXVv9w==
X-Received: by 2002:a50:b68f:: with SMTP id d15mr5422497ede.39.1561653001641;
        Thu, 27 Jun 2019 09:30:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzHYyMAY2QVF+pzH/xqgeLMUZbrCzjLe6fMWfGEFO4Jc0sM5AqWr2owBxCPifINkCHfAgb
X-Received: by 2002:a50:b68f:: with SMTP id d15mr5422443ede.39.1561653001039;
        Thu, 27 Jun 2019 09:30:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561653001; cv=none;
        d=google.com; s=arc-20160816;
        b=dvAFpkJpl+py9tVEWLJ16T4UPklShvD7/3qGMH8RSPjgxRzLxXVOSa6BvCb+yovoNL
         ZOFYkb3kz7gPl6OMJxRrAGqW1T/PHqLO59HOgx267mGrmksQf9bicwYLrVrk9c/+3jtb
         nWKcwZlfsHGU0Wuk/15+DcUWQ84ZxWbqGuSElAKb4054nle1CWa9Pyv9VbKdOG65wh25
         wiTSCVbnEZAJOsRhA5M6sCtUGMdl5pPMUtoeCfItftOXNSaNzxU22OxW6j7lVor6XArQ
         noauQMtxDYmdomElR5Acm567nWKJYZkRr0tHgUBHTORpm0yH21LOiVnk7r4auE5doLgy
         FKEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=wUTlgfdID2iRtFCZgVweDp5Qtf+mItNdaN0x/fMGgZs=;
        b=DZZtv8zl/8oH0O49wVQk9UHn082t9cbL5X9k2xCuAkbvm4/BwDP4e6yEkm6zT/8YbF
         VyYmUUgJ2B9pHhqbxMjmrpffTJ7xCe53okPVNuXa6xA8f7M5cHhsVoyBonW/1aWDgkPk
         EdJBtnr8HtqA3eQa41dtvjyG+6tN0matvjzNJC6PCRqJpTma+Ye2NAd7Is/Vzr7dUv61
         qyM4VBFuf0U2XDs/1txrMoVQfDnA6jZLwmzoOSkjSXjnRMgU4TaH/glNkk7BDbvpwFMQ
         IGu+rSJtujdqx1PKvMWFDLI72oY/IVNtDBdvm88QMSNEkhYss355PFU5mpaRQHJ+zQS3
         6p/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=FCgEsLal;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.49 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10049.outbound.protection.outlook.com. [40.107.1.49])
        by mx.google.com with ESMTPS id h3si1825573ejd.287.2019.06.27.09.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jun 2019 09:30:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.49 as permitted sender) client-ip=40.107.1.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=FCgEsLal;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.49 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wUTlgfdID2iRtFCZgVweDp5Qtf+mItNdaN0x/fMGgZs=;
 b=FCgEsLalfRXB4rv9hD0QxS/nthmGlfplI0uu4eJ3CMBFkQ2Bd7YzkRdW+p8gRpkMeGC6OBSQ+POJ9MTepzuc/+EAKH5OnVqI+whx+h24Qw+Rid2rrtIUW6utO9CLzdEdxlI04SsmqIMg8KUBIH0lq9fYbPyWXqFd7/WcsOHb/Fc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6032.eurprd05.prod.outlook.com (20.178.127.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Thu, 27 Jun 2019 16:29:59 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Thu, 27 Jun 2019
 16:29:59 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 24/25] mm: remove the HMM config option
Thread-Topic: [PATCH 24/25] mm: remove the HMM config option
Thread-Index: AQHVLBqsRKRxj5FxGkevpNmecZGFtKavsuOA
Date: Thu, 27 Jun 2019 16:29:59 +0000
Message-ID: <20190627162953.GF9499@mellanox.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-25-hch@lst.de>
In-Reply-To: <20190626122724.13313-25-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR21CA0024.namprd21.prod.outlook.com
 (2603:10b6:a03:114::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [12.199.206.50]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0151b4b8-c186-417a-5d94-08d6fb1cb28f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6032;
x-ms-traffictypediagnostic: VI1PR05MB6032:
x-microsoft-antispam-prvs:
 <VI1PR05MB603205C1A7792960EECA583DCFFD0@VI1PR05MB6032.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2657;
x-forefront-prvs: 008184426E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(396003)(346002)(39860400002)(376002)(136003)(199004)(189003)(6512007)(102836004)(5660300002)(7736002)(305945005)(6116002)(486006)(478600001)(476003)(81156014)(256004)(386003)(11346002)(53936002)(76176011)(3846002)(2616005)(52116002)(446003)(81166006)(6436002)(8936002)(68736007)(66066001)(6246003)(316002)(2906002)(54906003)(229853002)(99286004)(36756003)(6486002)(26005)(6506007)(186003)(64756008)(6916009)(8676002)(7416002)(66946007)(4744005)(1076003)(66476007)(14454004)(4326008)(86362001)(66556008)(66446008)(73956011)(71190400001)(71200400001)(25786009)(33656002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6032;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 9A6iNgq7ZRD14y7lsHP8UnKnqhIiFdeKgjWYA1jatzb8GnGnHiDhk19p0NkDyNq/Gcat5H/okmisOy6TJt9eUby66lOVVov9OqQOHhZrCb7iavtLvtwZQD9yD+Kc87mvHoGEH3mzdRnL4QVIJ2AUVshzNBbsSQNOFogrQebge8LavQESGjw8P2EBLmdflurGmw8JERlr2w/ZGRWw0QDUgxgBEMu+rk/mJEfk6O7kGOoQME52DOYMbaibXgt9vHEGeTbCa092EHjSVLfNGYpX0mRLb4w5ljwewWgyFyYANaYbtuj0yQaTgafTijlOAiwof9ioolGafwfyp901ymvyYNMoAOAHyLw1vTwe/ZKuE+qIso6zWpzkOzkrfPUJsDHzlwk3k7d35w08WNYILJzNFScDslN3Qm7b/nwPZmzkFUo=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <F6F5CD4C0A7BBA40A1967D61F8AD76F1@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0151b4b8-c186-417a-5d94-08d6fb1cb28f
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 16:29:59.6088
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:23PM +0200, Christoph Hellwig wrote:
> All the mm/hmm.c code is better keyed off HMM_MIRROR.  Also let nouveau
> depend on it instead of the mix of a dummy dependency symbol plus the
> actually selected one.  Drop various odd dependencies, as the code is
> pretty portable.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/Kconfig |  3 +--
>  include/linux/hmm.h             |  5 +----
>  include/linux/mm_types.h        |  2 +-
>  mm/Kconfig                      | 27 ++++-----------------------
>  mm/Makefile                     |  2 +-
>  mm/hmm.c                        |  2 --
>  6 files changed, 8 insertions(+), 33 deletions(-)

Makes more sense to me too

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

