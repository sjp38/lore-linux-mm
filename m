Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DB67C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA08320B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:44:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Ed2cJ/+Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA08320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 625BC8E0002; Thu, 13 Jun 2019 15:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D6548E0001; Thu, 13 Jun 2019 15:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EBB48E0002; Thu, 13 Jun 2019 15:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F36028E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:44:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so232575edv.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:44:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=OvLGFdjYPSk5owAJMGCDMH03XFP7/53cVwVq6hBPuFo=;
        b=tZgzpkWQh47lkkKMq1vPElAT99g8SNysO07I8l17JNUMRakdux0i9+1etdcuHfo2hx
         RuczPtZdwzvd7lQ4LWKhP0ZZG1HFsO3ewCKDqrOWsOjf+u8l0WrIDGkejVHLedCxB3GB
         bEucIlhXFwF3KDAiMbYDbUPhwwZfPDqaVASh44uNWTmoHVabx/2i68C+HkBD1tUug2DT
         LldZriiEcxEuna5L0ixOZiotJvbenYPW3Ijmm63HcdhvqD5EcxdcZ28lHHAzHF5+z/Aa
         pwKYn24HuFckt0bk7uJkoq7gD0Pp/CYutBIcJ8R1rwkCtGImJH5Iy9bnq1waGIqjGUXq
         EVLA==
X-Gm-Message-State: APjAAAWaMrRW+Uo01gLns83fo2IiKEVdFMI0ivfhEkAh2ee9hUMkZNTR
	ajan1Pp4GqNkd3R0oFjvsvbsa3X7wR3HZvP+uZ6By5X/o4XbUsCAN5nI4ROEJ2xqLVZ9q5sRd0W
	/7tvz06mLw0PaPfZXt49vp8bk+FjIVNXEou3Io3ydg6UzFeXZCDj4sLcloA0+UCggow==
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr37742543edb.43.1560455076573;
        Thu, 13 Jun 2019 12:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZYP2sThSBulb7w7hPzth6NDUBtKSVN94qCF2H/wzcmtxDLM5PZuY9z5HxwL746anpr+Ds
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr37742491edb.43.1560455075910;
        Thu, 13 Jun 2019 12:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560455075; cv=none;
        d=google.com; s=arc-20160816;
        b=G41gva0uwTgDobHVV8HjT9EK7D0li3MLifsh9u5AhqUWq7kCQs5bDQp+b9877b6m0x
         M7NbsG0kxyjOvOlcpUr74vvV8WsNxnK2hBU8f2LrReFRz7N4QYMjn35Mndmt+YqYzqr9
         Pg26ovVvLP9TV9Yg1LwArJz326ufGzfj2RjiVi+olTi07PkEiaMSdXHl8xcsqgUW21BG
         GMCNYE+sAqUsjVnkkgF0BUs/LGf7sPZfsWXNnTpmjmIllP4D9F+ViPOF3Kynggk40riZ
         8t1DFt8qC80oJJAhiFCwrxw427Ahqs0d8ETkx4zd2QEiNNWGJ3L2zsOelmS78DDLQjeg
         HN8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=OvLGFdjYPSk5owAJMGCDMH03XFP7/53cVwVq6hBPuFo=;
        b=KHGMcFjhEedL/AVlh/wE7kOj3EKePTN5E7UITd/MNEYGfZX9+i8SugXHWo/LkglAiU
         8yNju4GH2dU5TFlQqGNZKplo3Mnj/782HUaQzyqDridJDXeeqNKqGA2k5mwAidppl/yH
         xHT5l8My3bHbmJFrkqGJIoyup3cnkyZwgy7j0d/aI5Mg8NB0Z+sSAAZCSjdh4F0f4t1q
         VO5WEzNAaqQrYHNKpF419MzUvX73jRPHqQYbxjMu/tU1OavsR6mKJM7FDEG6oXNtqL+T
         AEo0lWnIc10dzvZ1zwMW4yaf9K6XV1HepJpyWaCIqw9NdkAySH4cdj1xCfwCQBfgDNZX
         t/ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="Ed2cJ/+Y";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.42 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20042.outbound.protection.outlook.com. [40.107.2.42])
        by mx.google.com with ESMTPS id d35si376511ede.271.2019.06.13.12.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:44:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.42 as permitted sender) client-ip=40.107.2.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="Ed2cJ/+Y";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.42 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OvLGFdjYPSk5owAJMGCDMH03XFP7/53cVwVq6hBPuFo=;
 b=Ed2cJ/+YMNQ3gMgiL3hYsSLPcHfBcQYG5pSN5f6NxLHXfl3Kshr/DJnditakIoT/ustedGYwn3//KKVkqICj+Pd0TRdwHct9MtBrzsWRsbfQawdAu8Kyy5FT+mgxeiSwElMrMLFDN0jKOqHS050xEntjV2cZiWJtmqmx4VPiS6s=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5006.eurprd05.prod.outlook.com (20.177.52.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:44:34 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:44:34 +0000
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
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Topic: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Index: AQHVIcyVeqgMzBs0VkumwilsEzSkhqaZ/TwA
Date: Thu, 13 Jun 2019 19:44:34 +0000
Message-ID: <20190613194430.GY22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de>
In-Reply-To: <20190613094326.24093-19-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR01CA0013.prod.exchangelabs.com (2603:10b6:208:10c::26)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7181fa22-98f5-48dc-e792-08d6f0378f5e
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5006;
x-ms-traffictypediagnostic: VI1PR05MB5006:
x-microsoft-antispam-prvs:
 <VI1PR05MB500620CDF68041957CED00D4CFEF0@VI1PR05MB5006.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(136003)(396003)(366004)(39860400002)(199004)(189003)(11346002)(33656002)(52116002)(486006)(99286004)(76176011)(7416002)(386003)(229853002)(2906002)(66066001)(102836004)(6506007)(54906003)(3846002)(6512007)(6916009)(6436002)(6486002)(186003)(26005)(476003)(446003)(2616005)(6116002)(36756003)(305945005)(64756008)(316002)(66446008)(8676002)(66556008)(66476007)(25786009)(68736007)(73956011)(5660300002)(66946007)(4326008)(81166006)(86362001)(7736002)(81156014)(14454004)(6246003)(8936002)(71200400001)(53936002)(478600001)(71190400001)(256004)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5006;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 8o9AX6DKSupLoEBQPmNIAeDs0XsDzxWMu1ammaJCRZ4m0UtQkAp+mB9y3YXFw/KeMRqnlGJbmEkNS4Y1L55k+k28Axlvfg0OrC4JK371fZPUrZryDeShbLSLDLA7Oc5N8TWLi5lVvi120e+sDYIcCAPG+nMAqZ6OU0JcG6hpi4WpHdKfyZGHr2AMLp6V4ujTgRGRdotEDx/rdKJ3YC3pPwR6003PEgwgxKGyhVRsc3am/dDh/AO1Sy9weZniqKAdm+jfIU1lCdDFZdZyt1n75f1xwPd0uxiB335X0DZ7IcVL5VXGr2wPd12e/cGHxrRzso9KQMQs5neAeUu0/EdtT471kVIGagmjFgO/zeNLmx4RLbLPtKJEniKqapVzgxA16XfDryJb8ZhUt+0n7Lz7IV9KbJik/jVSlbJOjAPSopg=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <D44695B53F740940B0050C945B58AD6F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7181fa22-98f5-48dc-e792-08d6f0378f5e
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:44:34.1111
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5006
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:21AM +0200, Christoph Hellwig wrote:
> The code hasn't been used since it was added to the tree, and doesn't
> appear to actually be usable.  Mark it as BROKEN until either a user
> comes along or we finally give up on it.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  mm/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 0d2ba7e1f43e..406fa45e9ecc 100644
> +++ b/mm/Kconfig
> @@ -721,6 +721,7 @@ config DEVICE_PRIVATE
>  config DEVICE_PUBLIC
>  	bool "Addressable device memory (like GPU memory)"
>  	depends on ARCH_HAS_HMM
> +	depends on BROKEN
>  	select HMM
>  	select DEV_PAGEMAP_OPS

This seems a bit harsh, we do have another kconfig that selects this
one today:

config DRM_NOUVEAU_SVM
        bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
        depends on ARCH_HAS_HMM
        depends on DRM_NOUVEAU
        depends on STAGING
        select HMM_MIRROR
        select DEVICE_PRIVATE
        default n
        help
          Say Y here if you want to enable experimental support for
          Shared Virtual Memory (SVM).

Maybe it should be depends on STAGING not broken?

or maybe nouveau_svm doesn't actually need DEVICE_PRIVATE?

Jason

