Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75C9BC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:56:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ABBD2239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:56:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="YkSM2M1b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ABBD2239F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF7AA8E0005; Tue, 23 Jul 2019 10:56:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA7C18E0002; Tue, 23 Jul 2019 10:56:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6F608E0005; Tue, 23 Jul 2019 10:56:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67E7C8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:56:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so28402103edr.8
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:56:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=UKLrYPXEShueXftdvrzxZO5snWp5SaalgZzsLn2a6wg=;
        b=CzYjabCdNkb8lZkIg3L+dNJ22h+2pLr13ETeqao7sOgiFBsTH7deQatFmayrs0xPRI
         QOFwlvAKJA4ja6M2UL0vlw6kdfwyLnhiFsulXyH01TmSUCRIyIhhf3loHAQ+QfFfRa+/
         57AJePNw1XKG4VwQNKNw/8LCKQS3uKSMwb/4Gj6LrnkQEnJjo+iL5x+WmyyQf/93IK7n
         KWQxazuBWqiFG2PwegLHpFVECbw40Vc5yoCn43UFasj8iKukDKp6y645keJ2jiwSdFza
         jLlSLlSefXJ8LihSfGuMu/snbKAc36Q8oJfaqqYiZzA4JRmvENKIpuUsuDlZ0hKOzJsh
         PKNQ==
X-Gm-Message-State: APjAAAWqPDRocrFV4sBhen208nR0QRhjFKTedvgMW1kEBGVNorhuITkq
	T5l7S0EsTznKV5EUHqpR5mcYcipY6nQCp1tRW9WUj7F2+gRtHkxJ5RfzXBSkTjlsFzxCItk5Fx7
	RDDN/WJCCM5xkVIfUu3nEGqeJ6Sv+mb1uUcZij/H039PApL8emSDdmZHh67voFWkNlg==
X-Received: by 2002:a50:a5e3:: with SMTP id b32mr64323092edc.169.1563893785981;
        Tue, 23 Jul 2019 07:56:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywV0Qey2L5DQMZXhTShTeUFtbi106tTpygak3DVHPwAGI3OV/YI7pUW+ueHXoyFTIEAflT
X-Received: by 2002:a50:a5e3:: with SMTP id b32mr64323050edc.169.1563893785444;
        Tue, 23 Jul 2019 07:56:25 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563893785; cv=pass;
        d=google.com; s=arc-20160816;
        b=d9uFzME64fCF50SwBjoDy/sJjkLM3bvqh8woYk9F2uJuTlgrIHCkIRZ8NzB/eTRVve
         clGGJJOka3kmtxNUBHTowSn+uQJtPU5TPChm4FkQysjoSPgU8HFtClyCRJlqXyd7VVtq
         rM4T3qD9ZQTeEB1OzA3F4L/KO6nApWZFWyW/kQTpCL8cCFifUjxiIFZmn9luGOluhQwo
         6IozbZQ/BuX6mNbNrckWUHRcH+BmdeA3BdB31rcDXz6tlxamxHcaBHwzHcY8b97OcPoC
         /oiqh4SSptbXatNm282iuPsN9QJzg2WoThoRLcVl9sNuNO9iF1aEH5PhjovJa3/vsOUw
         7HSw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=UKLrYPXEShueXftdvrzxZO5snWp5SaalgZzsLn2a6wg=;
        b=Wsekv74wrhgq+M0Qzv0o7+Y6yZ2Y/Eh5OlBeJL3STcVTzOdxkmvJ69yrrYXPK3h4Sp
         tmvNKbDZCR5MjDJEVIzVKY/1F7fYGxZj39vATrCGk4ZnAGTBkywGrl1ZgD0/YGjuY1TE
         cNwNHbfWw+stQqHdjYrg1t1NSokftHg2S7hO9QSPkby6pEoU5dRcaHsx/ExbKJ6NEK+f
         LBiEvKtM8aMmVuOiyyk2fa+xdaoUy+lX54VrLLEqB3QbMEekxu7OoJqo/Fd+EZHpQFxB
         myrlp+Icd82yGtRwTi9Vw0xmimamHaWOOQHLUy1/3e2ySoFD47ocYbFJ/0rU6WDKRBCI
         ba0g==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=YkSM2M1b;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.48 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140048.outbound.protection.outlook.com. [40.107.14.48])
        by mx.google.com with ESMTPS id c50si7905004edc.412.2019.07.23.07.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 23 Jul 2019 07:56:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.48 as permitted sender) client-ip=40.107.14.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=YkSM2M1b;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.48 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=KZ3ey2P0e5y8aqgx77XnaU/MNUPRQT3bxmxAw+9xfOLkMJcfBytL2RGjpIpGZKkjWtf23LJamsT6pTWN9MFkGquWbD59eN5unxPASFSx4e7Z92dL4YYU/x3OHBG16lqqsYP0U0FqZ+j7Jbg4c1t2/Sm/e3WnP5Gan27JO0ljyiEX9JG6HhLkYeFl7Uxc4tADq25DttekUKXeWxRSYMWJun1ys5twf1LiImg/EwQkx52j6LnawJ2bUaZufIZCI1qAevMdyr5uhRzLL9FUvJcGHy0ccX1zSzpNwhwg6T2dPAepgb+EMVAhRwVTqjPq5ZYf6pRBadFPQFOzz8ci0dWuRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UKLrYPXEShueXftdvrzxZO5snWp5SaalgZzsLn2a6wg=;
 b=IhfYwTxhkl2RP3qTK0JtOROjLPAZbvXtVqDw95kt91WMXUgfJUBn3Xe93VUq5vMuOQjmum+Aa07wGvAJeUHKWNISM4QmYv9/lsicJFv3u0aaW687gDz2ZgSw+r2kGLUZ6VjX2Mxrem+BNM1SGpndpk1ac8ekejEhtjJQBC5lfIa5c8GI10xcPeFnYYjPirs5O6hZlUY3Doe3TRUbeYO1wraGeEAyNCbUXEiQ1JuJzI685AnZhIwFMW/dRrkhd5yG5C3H5S8AAvxM+4cZUFJXxTtm3FhH4ze4yqIC+g2XcnEKNXQ8oS8+5+ZqZeqDlRnQcKT0rdn2P9Xst/7lib0HIw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UKLrYPXEShueXftdvrzxZO5snWp5SaalgZzsLn2a6wg=;
 b=YkSM2M1bv+3btw+oF362T2E6s62dPdvex+P8nuOttQESkWjgQFqHXE5UKI5j8qO7HLAwIJh7Bos5DE1qiFFnWBjLLeDOjeqwbojFNWgFjKlsO5qOXJ7KlPJikBJv2S08V30MK2Z59FPYs3qgAJSw9G1kCxdShvQdzyNo+eEmpa4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3311.eurprd05.prod.outlook.com (10.170.238.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.10; Tue, 23 Jul 2019 14:56:24 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2094.013; Tue, 23 Jul 2019
 14:56:24 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/6] nouveau: remove the block parameter to
 nouveau_range_fault
Thread-Topic: [PATCH 3/6] nouveau: remove the block parameter to
 nouveau_range_fault
Thread-Index: AQHVQHIUDnMs0tk2hUuxzK+Cwn7RDqbYTK4A
Date: Tue, 23 Jul 2019 14:56:24 +0000
Message-ID: <20190723145620.GK15331@mellanox.com>
References: <20190722094426.18563-1-hch@lst.de>
 <20190722094426.18563-4-hch@lst.de>
In-Reply-To: <20190722094426.18563-4-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR1501CA0028.namprd15.prod.outlook.com
 (2603:10b6:207:17::41) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 810b1f00-33f4-4691-d9a2-08d70f7dee7a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3311;
x-ms-traffictypediagnostic: VI1PR05MB3311:
x-microsoft-antispam-prvs:
 <VI1PR05MB331121DA3B64641E5898ED65CFC70@VI1PR05MB3311.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2887;
x-forefront-prvs: 0107098B6C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(366004)(136003)(346002)(396003)(39860400002)(189003)(199004)(71200400001)(71190400001)(256004)(8676002)(6116002)(3846002)(64756008)(76176011)(14454004)(6916009)(316002)(6506007)(86362001)(478600001)(6436002)(229853002)(5660300002)(6486002)(386003)(4744005)(99286004)(11346002)(25786009)(446003)(66066001)(1076003)(54906003)(7736002)(102836004)(52116002)(53936002)(305945005)(4326008)(476003)(2616005)(68736007)(66556008)(66476007)(8936002)(66946007)(81156014)(81166006)(33656002)(6512007)(486006)(2906002)(26005)(186003)(66446008)(36756003)(6246003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3311;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 +U+aQ9ComUdtSu5ma3e9h0cA3v0Z+i4Ee4yWxNU9q57Aj8iNOVN5W+O/yavFbFty802oEecHj6JNe0y7xZrs7dikmR04JIGHQmoEK1afW5M869ko9msrOFp/eTkEv/tF2cJcXs77Q5XTboBjZMFEJ1GPGJHS1cw1R5tY1pe4XouRCABfWc7F135bNO+dJd1PDazO+KFAn7aT+bIJUQEcCs/zyaeiPLbCL8TZzcyp7J4Kj5dUoWrHwd5VTGQ6IVGFdtdRjb6WDD6E6Q1agtW14naa1yly6nNZLze+nrc7+q0vq9bA7WpfvFp6+N9O2FlSTcuX2dXrL828wT1edJ2L2CKXRo7cPPW4s2WIKaILS/K6z8XyrTF2FfjcWkwRnKzzwNlDQFZzvH4b0KukKVRZEy/FeXVN3ogGqpWDRpVrPaA=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <DF48CC2DF2A4274387A23969DFE1D1B1@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 810b1f00-33f4-4691-d9a2-08d70f7dee7a
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jul 2019 14:56:24.3381
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3311
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 11:44:23AM +0200, Christoph Hellwig wrote:
> The parameter is always false, so remove it as well as the -EAGAIN
> handling that can only happen for the non-blocking case.

? Did the EAGAIN handling get removed in this patch?

> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  drivers/gpu/drm/nouveau/nouveau_svm.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)

Code seems fine

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

