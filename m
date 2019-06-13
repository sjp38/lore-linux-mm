Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0575EC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADED42133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:04:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="tDnFxoEo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADED42133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B85F8E0001; Thu, 13 Jun 2019 16:04:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4433A6B000C; Thu, 13 Jun 2019 16:04:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E22B8E0001; Thu, 13 Jun 2019 16:04:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D21F06B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:04:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so342648edt.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:04:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=YnyCRHhq6our3JahOP7YUJnCatYmzhQnh3SEMqGi3dI=;
        b=DEAyFfr7Ht7NPHQZC6oZbMfUowFSn/easdtrxE4HG/E1FAwMM71tctUHBYS2F8/D/q
         5RHVJfu3JrUQWKpQEtll2nt4n2GexrJ8vw8AC9WMntBVObELXiiq5Fk6uN0VLiM95wkv
         MLa5NNFI4hLgvC2Re3SOKFbZYG8E/uFZRtD5uxhbb6QV/g9SNMRZyx9mzw1gZTDwFb2E
         iSzVtFicyDakgEWik3xVFEf80HIawgIof9lWQyyUww0hA7tmeKtTRsKGhM3VsaRmECEi
         +5HmMFPdxkGlWakqj3zmw6rBDQqnRDwMeJopcrvCaJFIQmRCKIdajqg1sy+8L8bXNHt+
         Vohw==
X-Gm-Message-State: APjAAAVoVzAlTP8GuzL8QF2U39p0xhz0YpBUDFOYnLE0KfzjbaBUzGqt
	ubuvTo+mzsHnABBeZ3VD7ABxScKhxXcfVbLeGrEyW5V+hSXSNkaOvSa0ZXcEsBT1rUDnpTyMAb/
	I56TIIkaEl3J2sRhIJ1g+W9j2o9oCrSB++54ez6J4pxYK2GMjnbchqsaO83NlBt1AcQ==
X-Received: by 2002:a17:906:d6a:: with SMTP id s10mr41384571ejh.180.1560456246404;
        Thu, 13 Jun 2019 13:04:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf67T1pDDPdoh3c8166hnnh8QC0A2qLnhSRDemdBstwzDFtpoZYJhv32qCJTfC460O+sBr
X-Received: by 2002:a17:906:d6a:: with SMTP id s10mr41384496ejh.180.1560456245613;
        Thu, 13 Jun 2019 13:04:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456245; cv=none;
        d=google.com; s=arc-20160816;
        b=qJrGl8IkCHoYlPxjzDoVgviE2FcEh2ud1606cpoXu90d4tBriybQeLqT7RNtnwGbrj
         BOQd5fTzriGR56SfeyVDnc99L6ZP928WlAYtMhHd29cfAmhIFV2evRiejvEl9jTKWucW
         rzse/YSWeclf+URi4hMSOFROsDC3bbDjDwoAzE/60QcS1JBQYexY9ljIXh6P7E1yq4Sk
         0d5E0fOI8p1D4bNW76+vPcAfrYgaWkywzutNySurvZc8iy1McyJGZwE7DO7qEIIHz3qP
         kGLtYskzybO/dMuWGBSAaH3Felk456xsBqQ2gIju26qKEWa4dPFrWnowHIcTM9dD2mVt
         RRmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=YnyCRHhq6our3JahOP7YUJnCatYmzhQnh3SEMqGi3dI=;
        b=owUGeo93A085z3eaeDzll8zUih/RwH48lr3OBa0f68smc6sWFuqn007WI7OJGt+Efs
         VzQazDGXPCrvdaOaaEqxknHzvQMpJI1m/+6C3Vd4s/vYkZcJ5WETSCDtNHzNA8vGepJf
         Z5ojtBAZS+lLuvbILFhByz32KEgsHjgas7aE+2pOZq0Ni9TjNRRL8LHJrd9Io/CkFkgb
         qZrPxu8Cdn/BTootmpOX2WPdFqnMtKHfOeTx/u8lwXCz3XuB2ZaXzqfOI8Rz8td4hOf7
         TptUHrrLfl80FUWsGJZkJ92Atw1LHxi1YYiWsM6h/a6k5UZknut9mBRgjom/OW3cgJr9
         Rnpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=tDnFxoEo;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.63 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20063.outbound.protection.outlook.com. [40.107.2.63])
        by mx.google.com with ESMTPS id d4si676602ejb.119.2019.06.13.13.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:04:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.63 as permitted sender) client-ip=40.107.2.63;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=tDnFxoEo;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.63 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YnyCRHhq6our3JahOP7YUJnCatYmzhQnh3SEMqGi3dI=;
 b=tDnFxoEoVdJBSN3ifgsVF1zVBJV+F7fIQFERH6l2SFzpul7cbtTkMS4MxC6YxRlST4jOSZUB3kCC8MnSqhwbNgP97LvBIHKqZn3DwjpIUiqGNULbal9I3/wQPE+1k7Qa4APNV7lQY7PyLFlmnfI34vV38Sl/Z5PjU8dXF8PeMCk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4381.eurprd05.prod.outlook.com (52.133.13.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.13; Thu, 13 Jun 2019 20:04:03 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 20:04:03 +0000
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
Subject: Re: [PATCH 22/22] mm: don't select MIGRATE_VMA_HELPER from HMM_MIRROR
Thread-Topic: [PATCH 22/22] mm: don't select MIGRATE_VMA_HELPER from
 HMM_MIRROR
Thread-Index: AQHVIcyc3r2YZSS3CUapXwnP1XJouKaaAquA
Date: Thu, 13 Jun 2019 20:04:03 +0000
Message-ID: <20190613200357.GC22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-23-hch@lst.de>
In-Reply-To: <20190613094326.24093-23-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0086.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::15) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a348214a-681a-493b-a591-08d6f03a4842
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4381;
x-ms-traffictypediagnostic: VI1PR05MB4381:
x-microsoft-antispam-prvs:
 <VI1PR05MB43813927D62479F9D88EF8ABCFEF0@VI1PR05MB4381.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:765;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(346002)(39860400002)(376002)(136003)(396003)(199004)(189003)(446003)(476003)(14454004)(8936002)(6512007)(186003)(2616005)(11346002)(7736002)(3846002)(386003)(6116002)(76176011)(6506007)(316002)(7416002)(8676002)(4744005)(256004)(66946007)(66476007)(25786009)(73956011)(478600001)(14444005)(4326008)(64756008)(66446008)(66556008)(305945005)(486006)(66066001)(81166006)(36756003)(81156014)(68736007)(53936002)(52116002)(71190400001)(26005)(71200400001)(6246003)(2906002)(6486002)(99286004)(86362001)(229853002)(6916009)(33656002)(54906003)(5660300002)(1076003)(102836004)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4381;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 wHlkn2ZfV9rDati83SasESQC5vPO5aAUc6haeZsc3mf5YMTqR0rvPOwQ/jmHjydNylEIBAbQSsIpA4xlWwWWmXVcbjuSbBG89xPpjgnzFAY9/pNQ0MevcNaLFvKVwmaofHBRX3U80+m+n/XNiTHFh4Dkr1Y8xUBqXH3Bm7kLAGqZNIa80R9+gfK1I/ojwlmseAk+31Z3tJJsHWoHjogYiG/BUrdnA2YRRv//z4Yoth+w2fzdP6j9E9OO8whiiJCjw7AHM2LJhRP1YU7SSXS5ASCcA0Aa7Ja/kHzVKJHzFIDfaLy7RBoiCbsIbgGKzVoRMwiljvO9aMLS2+LOzhiT2/5Ldlmi0pcEr629xNZ/eEkITnDNP+wcG4JcSreBI0wnIMLHZJIO86ajMA/D9QjQnb+9FjlgsHFbbVB1Rjgz34U=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <DC6C94E2B8591541A7B0CC844A612312@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a348214a-681a-493b-a591-08d6f03a4842
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 20:04:03.4038
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4381
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:25AM +0200, Christoph Hellwig wrote:
> The migrate_vma helper is only used by noveau to migrate device private
> pages around.  Other HMM_MIRROR users like amdgpu or infiniband don't
> need it.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/Kconfig | 1 +
>  mm/Kconfig                      | 1 -
>  2 files changed, 1 insertion(+), 1 deletion(-)

Yes, the thing that calls migrate_vma() should be the thing that has
the kconfig stuff.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

