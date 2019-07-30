Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC570C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:03:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 935AE206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:03:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="HTE7x31h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 935AE206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 416E28E0003; Tue, 30 Jul 2019 14:03:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C7828E0001; Tue, 30 Jul 2019 14:03:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290258E0003; Tue, 30 Jul 2019 14:03:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEC118E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:03:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so40783420edr.8
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:03:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=xe6eJ2krxq6gY9cV8D0PGtTCTRLtX31xUVU26+G/yF0=;
        b=ipluVGC8iWErCIwc6C4GGgZTWSnf0UolbvXcqGXBW/uDqEmrhH7sqojZTm2B9p7AOX
         L/R7fUhLYUx1CzLxpiACvsJrzdfrSIf/iT/zj7cPv3l2LWcRPlrpR8jaeExOee7nlKja
         RIxskfAe4ZiK/R3M9YmrtcxxlaNUSuF+ULIAHY0nsFyZBIW73SIecJ6f0AJ/Ny9rKuM5
         L9DSyp5ejJ+AboZJDt9EfZFxQXOF40bh/+kThyNjAbFMhg5rqEuBySAHggz4wVdLkLZK
         7/FWVQJ2GoDpHTAf6u7qWABpXHVRNz/rGDnw+VbNm5ww00JX8l+MB0CJO7zkIU5UAemI
         ycpw==
X-Gm-Message-State: APjAAAWFq1N6tsQmqC8kLJZo9IZZvznfeW3rLCTmrclJ9xCCsM38qi53
	D7Es2Sut008jesxh8n2/ZfUitd7hyNZTErVBTEL99/dElxwlWmCqZ77Yiblh9BnztedU0I5uro4
	bUwSouEceacbNPKzEO+rhFuBPt6GqQQRsTWz2d+Sqnw2Fm/hXkoVJ0WP9jl/W+uzzZA==
X-Received: by 2002:aa7:d68e:: with SMTP id d14mr102860431edr.253.1564509833420;
        Tue, 30 Jul 2019 11:03:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgyvvJq7ux3WKnh07u1L0mTN8HGWmtFYMguLAnN9PHpyIlqq35g9CKOi3MLTqfinj9XKqp
X-Received: by 2002:aa7:d68e:: with SMTP id d14mr102860357edr.253.1564509832681;
        Tue, 30 Jul 2019 11:03:52 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564509832; cv=pass;
        d=google.com; s=arc-20160816;
        b=mH/Gnti4rEf25Z2FlVyfIpGpnsnUA7Ap+IRNgQUd42WUQCRzukC4Q+ZQwuiiWeifwT
         2O3o1WiiVIN6MqSpUmDBTr9DjrRwhJD/f0UZgzeDducIVr2+Vo7QpHMETOnyDHKk8ZH9
         qGMZibrGzzhsOEzFvQL010fpikG2OemIvxUy2j6TPqEiDXyb7C2Iprj3fJ+Qwws+QYjJ
         BpHGDuj8coRjn53e54njMRnGs+v7JcEflxgLXqZ419WWls0Y7yIXV4ljc51WRQw2gcdT
         9vpR5xD6NEGiN4aJagF+vcEnTt6DUkjPuRvtf7MU9W74MHyxv1trQdFszWc+btUT7lFt
         YgYw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=xe6eJ2krxq6gY9cV8D0PGtTCTRLtX31xUVU26+G/yF0=;
        b=LrrwgoUWWy/Vq2NCdNcpyJZM7Wq0b5Yzb28MaiEu/O7+vycn0GMZmkhZUTePLn/Tm5
         i3bwSWhqh3hByl7JhT3rGBH0Q5NyHyHebxxy41t20HIXyFaPuV2g4txZ1m/3sFjKPd4N
         82T1Ywoup38WUKfmjw9MXCKmGIYyddHbaiumb0iY65sMbx+/jxZewG/nQZ/LFiAavFpU
         s/v/ZbuvDiOg1OtC08+iD3Cs1jpFKvglLerxaqui5EKyCist1VTXcVbFtovZ+uVhsBp+
         qm8+MXCezi1IgT20+RyMU48c6ydKbqS4acewcckHpHgcrJE0oqks6gGWggt6I0YYZ+Em
         0G1w==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=HTE7x31h;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.46 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20046.outbound.protection.outlook.com. [40.107.2.46])
        by mx.google.com with ESMTPS id e23si19092620edb.103.2019.07.30.11.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 11:03:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.46 as permitted sender) client-ip=40.107.2.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=HTE7x31h;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.46 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=jk0bVpZiIeNPTu0EyrrhRFLJcNWf4YDhhNeZ8X3Jywa4yU8jafq35yLEduNuf/4OCnYN5RVZhn0zZatcJkRHE8CBGDtaiu5w6SzFpEMwq0Z9rzxMmfyz7bxvqNER7b1Y5uHBD5VWtBXaTUHYmp0fUZNjnaEnGiOjrIiGph+Wb+56//se4vkx2ZSX+nSH4JiCJp8Zu1YTCnsQXCS/9BRo6yH54JCkX49ILapy90zQyDuafmX3ypTeujx4D5WhF0sROgOZil7/S+dpfeOVhu9jHvYceTUwwsS+jhzYyecDMrbhrsjU5oEXtFGV4BWoW8dNoTG6rf0QGLyASVtPYJ/9/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xe6eJ2krxq6gY9cV8D0PGtTCTRLtX31xUVU26+G/yF0=;
 b=NnZ3enlQmLx3U2OqvG9MmdLXhElOTKS4YnIU9qVT/6+RrsyXSOQ2Sb8UnfQKDgYkbplDtcyQnKVejGdqRw9lZlj38j8NaTvvnyoyO23t77vehtrrQJVF3q/23IVZEPMBrM7pDXjH1JQ9I/w6j8EFeY0nLRc6QR6bLa76trwkkKGvpbnHdo+cj9V9Ju3SRapoGRlTDKUajPMtzAUN7C6DyIq/2a9AGELfhzkQrPPjUDXrct/n3P9GngJ9DKW4SVcXnZ1x7KR0o7P9tdxY6HseJJnf8xOO4iS3xbyy9uPD7Ssl7+KTNzhHVVbxAowF9EDpdH0CScURx/nHnRI987UH6g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xe6eJ2krxq6gY9cV8D0PGtTCTRLtX31xUVU26+G/yF0=;
 b=HTE7x31h+0FTE57z7CvH0ButSvGq5gxxVbbgAz78qZGH7x4T281JeDV77tBrEnCRmG0GUy/Ng4EbWHXw/XF2AKtQEN4csbHGn4INBv5lJveUfVCKKSNt2MTWWB58T/ou8qZiRi7mGxkKUPOqpzbke66FLjvWeTIC6EuKJ9B85SI=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5728.eurprd05.prod.outlook.com (20.178.121.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 18:03:51 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 18:03:51 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 13/13] mm: allow HMM_MIRROR on all architectures with MMU
Thread-Topic: [PATCH 13/13] mm: allow HMM_MIRROR on all architectures with MMU
Thread-Index: AQHVRpsJa23GemswhU+gJVFr5hDTJqbjdQwA
Date: Tue, 30 Jul 2019 18:03:51 +0000
Message-ID: <20190730180346.GR24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-14-hch@lst.de>
In-Reply-To: <20190730055203.28467-14-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0085.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::14) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 085a24eb-2e30-4b11-f6ac-08d715184728
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5728;
x-ms-traffictypediagnostic: VI1PR05MB5728:
x-microsoft-antispam-prvs:
 <VI1PR05MB57281EA66ED36E4B6697FAFCCFDC0@VI1PR05MB5728.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5236;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(39860400002)(376002)(346002)(396003)(199004)(189003)(6116002)(3846002)(68736007)(2616005)(71200400001)(71190400001)(2906002)(11346002)(14454004)(386003)(102836004)(26005)(446003)(486006)(256004)(305945005)(6506007)(5660300002)(476003)(52116002)(186003)(76176011)(7736002)(66066001)(86362001)(81156014)(6916009)(6486002)(6512007)(6436002)(25786009)(4326008)(36756003)(7416002)(4744005)(99286004)(66946007)(478600001)(1076003)(8676002)(81166006)(8936002)(316002)(54906003)(66476007)(33656002)(66446008)(66556008)(64756008)(6246003)(53936002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5728;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Dl5OFmKR4GZLV8C0uAvDZAoziNdxhHyg4xcY8lGvTPBO5va7Xl90/JyOsSjIJI7vtEbOsCDgApn1DvvYg+Q5MKW/vMCbjCLzwlO3946LGu2vIMB8gQuJdCTgK7pcsFv/MS8LEFyfzFC9prjhZFcLNoMbsJFc1eLpkh8/C2iRnzMeMwm3hr0Td5xd2Wue+j/UhROameb0ZI1eS65K/vBfopXojSIId5z8e9UDw8XLpgBtBrepcRGtFvUEXyuSa22NWEM3hK2iASodMMPNdBcqIAfPBcZSvan6MhiEhu4kUK6gjoGpS3RH71GeuK5U5XtXdaEGD1IhzAMlQ7zW2O5ERMSoXR0YeSGhsvJ2Zvka1GfbHOcxVuIhqKq6MEfbpXEHmQ9HKDLxhyi4Lc7RAovc3XbxuZcB75KR4wFiQEo6RQY=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <99F74B5B1EA70C41A24AB791174D4BBD@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 085a24eb-2e30-4b11-f6ac-08d715184728
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 18:03:51.5098
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5728
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:52:03AM +0300, Christoph Hellwig wrote:
> There isn't really any architecture specific code in this page table
> walk implementation, so drop the dependencies.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  mm/Kconfig | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Happy to see it, lets try to get this patch + the required parts of
this series into linux-next to be really sure

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Thanks,
Jason

