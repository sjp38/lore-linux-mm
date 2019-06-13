Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A19DBC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:39:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A91421721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:39:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="ieCtWqkW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A91421721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA3DA8E0002; Thu, 13 Jun 2019 15:39:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54A08E0001; Thu, 13 Jun 2019 15:39:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1D788E0002; Thu, 13 Jun 2019 15:39:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 702CC8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:39:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so214457edv.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:39:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=kynqoWA1ZTWnY9VFOPXvMf/AcdQpgMQDiT/cVThh9kM=;
        b=hc3sMM3k47uLEYO+AHpbyNuniScgLjOMmtJMvHkL7OTWG+2XzNPSOGEf1I34UyeXRx
         FYOeDHnb9GYkmKcodBCA/mkXxbYigdCTx+r4X62UwmQqOMvxSFANxGAdzWX8I39bPlCW
         1enujHTknyrMLH2uul8k+7k8M7FhS5avUohGUZ0g9SdcMba005UNdRYd4ROU63/L3p/x
         /x2+EeLJZJPQs1ZKr+XFWF+ghJyjwdR+/xD3gpFPrBX+vfRWib+4Kf2ptjnDXKgKtFLk
         81/P+K06N7NSiLLyUam0k87/o6c8Reb8XaKZSmFRRJqlU0YQ6BE6f+akM258xQY+opLz
         VSOQ==
X-Gm-Message-State: APjAAAWlf0CJCxa5IWVOdRplfdXdEwoaWN21lt4k/nBhBNzVisQWnGEr
	mSRNyG+UEjXLx2OqLRmd29606nGZkm5yat0E+RhOVC3H+9W0d3wro2MT4hnmvKGfer1tPMiSr5W
	FBxVyYIhfT+wDuVn++t23AamaDqOiU/Pk8tnp5LFjSHU2B9JvujrhLJTjol5zoYnX8A==
X-Received: by 2002:a17:906:85d4:: with SMTP id i20mr63954817ejy.256.1560454752033;
        Thu, 13 Jun 2019 12:39:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwso7r/SO0eSsHJI2eC80oq8KTE6hyXjMJvkrlBHbRFdZ0rbYj00M+GvkBqNo949eCgy6w4
X-Received: by 2002:a17:906:85d4:: with SMTP id i20mr63954777ejy.256.1560454751412;
        Thu, 13 Jun 2019 12:39:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560454751; cv=none;
        d=google.com; s=arc-20160816;
        b=inx8OmrqHFWMAVcbY0lHoO5dOzQ8JV+4YFYNcuLFID2gEomNIzF/urcibe5WICqRkk
         lyXYjjVvmoZPBVswth/0x9w87Z+ExF8Qi8C06vi9LxM5nS4AQF+NL5ooBPeyK1m58g0m
         OZDbuxXD5pGzNI/EWHsVOCVqbGEEsCTT1fLa644ih93gqWRoFSr7cXGLuT0JCpH/GLYc
         Cp3Wkdfs97EF7Mw13zhwlzW4zlQX+whrrEqZ01mQu1NztKmNWiN1H0wWVoFgUsvADj+j
         T1luFvIN/MZvGFFBnzt5cJ5xdeoJC5EXhSD3m00DcSP8fdkd7yZcCB7eGDBv2HUBqUGn
         xyAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=kynqoWA1ZTWnY9VFOPXvMf/AcdQpgMQDiT/cVThh9kM=;
        b=PBEVCHew4kTHRmPReEsAe3fwp75vFBRHMT2JdUVI+dKzYd2tEgTKTrma/ZbusWX/Oa
         AspLibjC837UyIRy4BHUB48um+cvW4Uy8uJFMBblKxknDCSVCBX0G9bIq+NxHp2fNu+u
         WqQZlSEw8pvpjqYisMUIEPQz5R1CLXidxizdVV9+yj+BxrrZMUqhVZWQ4i4dWMhJOpao
         EwkkOONq1iRn9zkuBOUQAFLjKT6r+865te+eEYsVL0hcmgPWTuFhBBY8D35rQbKBDZ/f
         NKy+QO5xituY3tl3NxsAHg3M4Fix08HqSMkCBE0NukSSZELNpLCT3bvZfEktHNsUzaWn
         Kn0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=ieCtWqkW;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.78 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80078.outbound.protection.outlook.com. [40.107.8.78])
        by mx.google.com with ESMTPS id z11si336960edh.378.2019.06.13.12.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 12:39:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.8.78 as permitted sender) client-ip=40.107.8.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=ieCtWqkW;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.78 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kynqoWA1ZTWnY9VFOPXvMf/AcdQpgMQDiT/cVThh9kM=;
 b=ieCtWqkWrx4Ap+H1W7y2YcH2DPeDbFBIsA/cSDxRf5I6afMVyMS7Q0xUURicnSoBdNudME6QcTBsiy+81C3IbMWz1lTHh6gNKB+VRaz/0N9rsmAoTojsjpo3H2HaONgV9lNjMgmE63w9uTjfjbiJbhvFs+L4QsFWunybTSDmVSI=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5006.eurprd05.prod.outlook.com (20.177.52.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:39:09 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:39:09 +0000
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
Subject: Re: [PATCH 14/22] nouveau: use alloc_page_vma directly
Thread-Topic: [PATCH 14/22] nouveau: use alloc_page_vma directly
Thread-Index: AQHVIcyOHaopcwSxm0ibFlXFitCRUaaZ+7iA
Date: Thu, 13 Jun 2019 19:39:09 +0000
Message-ID: <20190613193905.GW22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-15-hch@lst.de>
In-Reply-To: <20190613094326.24093-15-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0138.namprd02.prod.outlook.com
 (2603:10b6:208:35::43) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b8abe11b-1e47-4154-4922-08d6f036cd7c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5006;
x-ms-traffictypediagnostic: VI1PR05MB5006:
x-microsoft-antispam-prvs:
 <VI1PR05MB500624416AC3B3A1B5C8E2F6CFEF0@VI1PR05MB5006.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:541;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(136003)(396003)(366004)(39860400002)(199004)(189003)(11346002)(33656002)(52116002)(486006)(99286004)(76176011)(7416002)(386003)(229853002)(2906002)(66066001)(102836004)(6506007)(54906003)(3846002)(6512007)(6916009)(6436002)(6486002)(186003)(26005)(476003)(446003)(2616005)(6116002)(36756003)(305945005)(64756008)(316002)(66446008)(8676002)(14444005)(66556008)(66476007)(25786009)(68736007)(73956011)(5660300002)(66946007)(4326008)(81166006)(86362001)(7736002)(81156014)(14454004)(4744005)(6246003)(8936002)(71200400001)(53936002)(478600001)(71190400001)(256004)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5006;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 YSP7XrTOSi8fUyoaKByWR58FatUSy2ppLe9VhcSpPwu/wfB8XDF8r0oHaqPYSG9NWIgAkTMgAZi+ezOPH5w7TGwVfD102STiXwTJ21mHpP1UydPE8LZuWkAixhMnczpX46wzVnsV52eiIZX6dwcE3hxweW7Br1G/mt9wQXjZqNbaYHs40BTr4i/AfAKdH/enSRIAwZQnN0uZ3sc2Ne6NiDpwggxYvPDCJq4sbrk7Olkv3LCwSnb6lvrPjgermYp/bmm3NczcubPkbJnNP2sz/GS1nvijscZP7ArQAyAwaOTSzObWCoCjHijINdKUtfXp+Hu0Nv4X/FhfcfSdYVXgwAYSHTwX8fruI3xVLq2oJ+f7Ioo2Vp/IFt6juTU4cgYJxJIgJ8jUfsumZNL1JpDHVcDcGBvoaHB35bSi0MwaH2g=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <CA662AD9B612344580205C283CE6481B@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b8abe11b-1e47-4154-4922-08d6f036cd7c
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:39:09.3344
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

On Thu, Jun 13, 2019 at 11:43:17AM +0200, Christoph Hellwig wrote:
> hmm_vma_alloc_locked_page is scheduled to go away, use the proper
> mm function directly.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

