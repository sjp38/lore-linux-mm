Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72266C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:46:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C0A721473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:46:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="F2NGmmF8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C0A721473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B36E08E0002; Thu, 13 Jun 2019 14:46:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABEBA8E0001; Thu, 13 Jun 2019 14:46:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 937A48E0002; Thu, 13 Jun 2019 14:46:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40AB78E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:46:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s5so43115eda.10
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:46:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=4XcQHmpnLa8Ccm8n/NNb6h6pJP/b83WvVwKH4dVjrGI=;
        b=fkl2xQbmX18ZSj5rL055Ah6L/d84OT95p0lluC6c3BUjh86IKDsRzn0gePOifx5+j5
         Z2qBa91vXMjdKIsNBu7RmjIE4entHyatXt9VOR+ejvbAE+vSeOpjQERoYjbH6CxuaLlh
         OXBTU3WIfCkSalD5PnydGLwPol137j8BG18KeFvWmglkRCz97r74MTNQ+SxDowjoj5rI
         d4nPorvP0J+cx2nY2bITMN3mtjqFlV9JJNXn8Df7yVAz+0h172+UnG2ZUkkYdvHWtzUO
         Ke5M0YGTsV9OgaluBF4UpO+upY8RPp3XqwkBzwSaNYKVDnCeFEjtImUvZtp2q2nQiIGL
         7NHw==
X-Gm-Message-State: APjAAAWf87NtGJk5l0lJ+PVka4uJgrVawmXsnIA0umRaaiFaEgXLI+rn
	NMVy2OHVs1y8LcN+Bo6uWFljuUc9Oc8TdB2l4nBK2szuaQee1xc7idveFqU1GFXm289dIaOlrJY
	lPBv9s5UtTSyTgDAShIW57fatbmeeMSsUDidYv+8liuZf+7jpCN7KFE3RJ1RpZ4+zJA==
X-Received: by 2002:a17:906:c4f:: with SMTP id t15mr34211549ejf.190.1560451598798;
        Thu, 13 Jun 2019 11:46:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvmnumGmoBYJE/sSrtWI+VyMNkY3QXLbTXKMZWJUI9n6TNl8j5soSGzdsDKHD+6+ZT3sSP
X-Received: by 2002:a17:906:c4f:: with SMTP id t15mr34211471ejf.190.1560451597823;
        Thu, 13 Jun 2019 11:46:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560451597; cv=none;
        d=google.com; s=arc-20160816;
        b=i03mfvqG2HOOkE0AA1HyVNFOSb9qJrRlDevl8PFiGNC2LuV6bC3jXW5hC2nbfWtl8V
         Nc6UnOKn8pK/pVX7guG5Xb+y9xmfoqh2+qwxKEZJuUy9tYp9cgeiYS89TgWRLpd3iC6b
         R58U0TzmHhoFtKezbDpjG54ZESBednpUAjXSd0Je9XdMYnap+IRJJmAxZ7Az4AcUxX8L
         25/Nn6kYrnN5r9UBU1K9nJajMAiPPtB4EcqMb1/oG578aZsXhg3v2SOBQXh36Ar7TlC0
         OVjbllrb8KmF8GWq/xR25l5MRnKGtBHnB7vaYJKcCXsRlliv5K0lek//9Kt0cC2JgsZj
         GHWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=4XcQHmpnLa8Ccm8n/NNb6h6pJP/b83WvVwKH4dVjrGI=;
        b=q23pGXnoSW2WGBeDxPbdTMfzkX4PlDn+j9Nw4Dt4XIldU0wNVJbmT80m9msW8FkcrH
         Fd8zonln3CUyU2GFLwKTOLEFB0nMA1lG8ksl0UCAvj8kmiHZiruay3YWS+W1O8xe0FLk
         YvfY0qn76oeljc47m7aLSAu0ogcRct4lJwcJBzK93HyNotYH3wF03lFj7X4r33IfWvq+
         MZL2UeRY2ljjMamM0Uzxw7R2N3jUS0dw/hp6OD3eA3Lx/x4QpYOPmpDeyNGTP/z3kCTf
         Qy4ITa6npmw3tk0VFcUb1soY0JaidkYod2dB+mkjbnEBT2Ja7aPHReX8LCgGJDtI7b7O
         JdjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=F2NGmmF8;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.71 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150071.outbound.protection.outlook.com. [40.107.15.71])
        by mx.google.com with ESMTPS id q1si492284ejx.296.2019.06.13.11.46.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 11:46:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.71 as permitted sender) client-ip=40.107.15.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=F2NGmmF8;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.71 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4XcQHmpnLa8Ccm8n/NNb6h6pJP/b83WvVwKH4dVjrGI=;
 b=F2NGmmF8PcrSuKqYHZP/ltHNtTQ/3yXA1jxUOAv6zBo/PQnSoylORIuCAGTEg5bTKk5lnKFf0as+54Ck2eM3roPqwxGi69XuGjJnNgJRRGrex66U663ag2Zr/ob/qEYj8FEiAsc/evMyyzj2t89jw53MYPv/cMAfHehUy/IDIXc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4701.eurprd05.prod.outlook.com (20.176.4.10) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 13 Jun 2019 18:46:36 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 18:46:36 +0000
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
Subject: Re: [PATCH 02/22] mm: remove the struct hmm_device infrastructure
Thread-Topic: [PATCH 02/22] mm: remove the struct hmm_device infrastructure
Thread-Index: AQHVIcx635NBB7Z8DkeP0aiwq2XU+KaZ7QiA
Date: Thu, 13 Jun 2019 18:46:36 +0000
Message-ID: <20190613184631.GO22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-3-hch@lst.de>
In-Reply-To: <20190613094326.24093-3-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0010.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::23) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7e748266-6013-44cb-2451-08d6f02f765a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4701;
x-ms-traffictypediagnostic: VI1PR05MB4701:
x-microsoft-antispam-prvs:
 <VI1PR05MB47013CC710784AD316D44798CFEF0@VI1PR05MB4701.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(136003)(346002)(376002)(39860400002)(396003)(199004)(189003)(66556008)(305945005)(2616005)(476003)(54906003)(11346002)(8676002)(486006)(446003)(5660300002)(1076003)(64756008)(66476007)(66946007)(66446008)(86362001)(8936002)(36756003)(66066001)(81166006)(81156014)(73956011)(99286004)(229853002)(6512007)(4326008)(6916009)(386003)(478600001)(256004)(71190400001)(3846002)(2906002)(76176011)(14454004)(52116002)(102836004)(6116002)(6506007)(33656002)(186003)(26005)(6486002)(68736007)(7416002)(6246003)(25786009)(6436002)(7736002)(316002)(71200400001)(53936002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4701;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 G88QnbZ36FCyyTJ2ZfcHbffJ0GQh3bFvTCHaf2zR8pqVCi1LDB7+CL+El3nvKWgdu/iFQUyD78uJpeXN9987OemXcoF9Er8/LcElZsIfVhfRwVbjccuVRaIeehvTxYRLMWVEzcR/o4e4FldKcOVc9poTQwNp/jgyZ0HfEL8IsrNXDvJ7XIhkevcrwbqRj7kuwVCvuTW66hAIBhvfRIOpa3dfb6FLbY8YbDNh5d8jNlav9LNBhDjbZeXTuTf8PG1Rosp0LWh8hbbamrA77AxkORqOVq7tTqVoj4mQgrjouT6rGBIN4qYXzHUwO4LQxsNf+BJ09t6EfH+ysIufgj77LIZqcfVV+WVqIMB57vcvkp1AQQZ6mvkBdKGgK7F2LbCGmXi/3jDxfkSb6BPFgvpMWezYAqEUoFTQNnMxHT81ydY=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <547A0314023A5340818D48E18E9DA700@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7e748266-6013-44cb-2451-08d6f02f765a
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 18:46:36.2740
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4701
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:05AM +0200, Christoph Hellwig wrote:
> This code is a trivial wrapper around device model helpers, which
> should have been integrated into the driver device model usage from
> the start.  Assuming it actually had users, which it never had since
> the code was added more than 1 1/2 years ago.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/hmm.h | 20 ------------
>  mm/hmm.c            | 80 ---------------------------------------------
>  2 files changed, 100 deletions(-)

I haven't looked in detail at this device memory stuff.. But I did
check a bit through the mailing list archives for some clue what this
was supposed to be for (wow, this is from 2016!)

The commit that added this says:
  This introduce a dummy HMM device class so device driver can use it to
  create hmm_device for the sole purpose of registering device memory.

Which I just can't understand at all.=20

If we need a 'struct device' for some 'device memory' purpose then it
probably ought to be the 'struct pci_device' holding the BAR, not a
fake device.

I also can't comprehend why a supposed fake device would need a
chardev, with a stanadrd 'hmm_deviceX' name, without also defining a
core kernel ABI for that char dev..

If this comes back it needs a proper explanation and review, with a
user.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

