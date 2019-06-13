Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BD50C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53DBA20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:42:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="WPGGb8xO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53DBA20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B57C18E0002; Thu, 13 Jun 2019 15:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B06EA8E0001; Thu, 13 Jun 2019 15:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CF488E0002; Thu, 13 Jun 2019 15:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 51B708E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:42:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so218241edm.21
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=/NiBEz4ijO+lxSyXpK7Yl0ytQfTsISKxzcr0SCPm6JE=;
        b=tM3QBonvHt1dj+wAcbMAH1caNRAScB33E6ghg4I1T/z3aI4K/Y+8jiORCEToUdMOVA
         SGl6ddnL1bswNzziDuFLwcTkwGyfLM199eb1FsnOlMEBx9TUtJXKG1H2AwlSnjbmY+AL
         u3rIrGVHP0grumi6KZdEkfI/PSD+1XA5B9iN/ekup//wzrszINtyvqFrAjbOmJHEsurc
         lnwFSFsp37yqrpk30RxuYjOqnB/MivT8au96BLd3KsJzUJ4T8ObOkbspAWxc5Bfgia7x
         CPQvjUlBAtzgw+QGsanjfHw7+6Vgc9UTZSOShwZqJiG0JWzDyJnpui1Z8bNTQANfVOoc
         nfsA==
X-Gm-Message-State: APjAAAXA+T73PeJGJkaye6bVFfoolWqRV76rlRtQlYCFkx0QacC2uQ3s
	U2iY7KT7sdzsU0H5ArAR1NkhQWeS5AWdu/cuhAQ/kKai6VD1at+nEYTSEvd2JfxsmU0dy1Qjmjo
	isMowjyHE9GQMBeaS2/LjBg1VMHvB+WTnYFtlBLtamp2tpnwuRgq4jAeajTx47LT8KQ==
X-Received: by 2002:a17:906:308b:: with SMTP id 11mr18165800ejv.39.1560454965908;
        Thu, 13 Jun 2019 12:42:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmM/RBEKuio+Lx2Eie3rDpJBNAWVUPdQCdhEvVIX3KBNpfCqotKAUA0ADRSmavjiXEwlzK
X-Received: by 2002:a17:906:308b:: with SMTP id 11mr18165766ejv.39.1560454965298;
        Thu, 13 Jun 2019 12:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560454965; cv=none;
        d=google.com; s=arc-20160816;
        b=zhFXKW5H7qFuF9z9Bs+qmewgABbGkMymPlYFQz63/G9rNbPRq1Ev5ncbjzRp5q6o5H
         iOgK9jRyeKIun7CwQBUwNUJHGR61g30YsRGFzlCL09kRkRKKUCZx3Ikpl/CbeTSM66hk
         cXOlMGVZhXtFDJ+4NPT044pRPypavOkYoBOry9o3aiKxBn9cEPAaaLhOHQsTBsxToQ8Q
         7ZHmsEgovqmDM1Ah1wbGDxH1wmCL7RWLwHzcFXFuG/ySbHVRuiPCRqOYTXIhQj13dm58
         LiXqV5a8K041Vsk3srtFLI3hKm7byhB0kiDQvrJ0Uht+OOxhcfXKIERGbjjjs9pS+ZeA
         YrWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=/NiBEz4ijO+lxSyXpK7Yl0ytQfTsISKxzcr0SCPm6JE=;
        b=EwTwDIGHZaA7Q4UqZe3qN1JGRu+43MB8p0yQSclmD1xe46vvelwxLrGnC2xdTGYRYz
         zoitatDONSNuqfBEzVdv3iVp2PNVMn6mMhHa5R0tsqVxyA/bvXHdJqlpyQLl/rL5yAbz
         zLJbUuZj5zAie1SJaoQg9Ce//f/bDY9LyWdC0DAGTuPahiFCSLqVOeRMOWaQU7qzIJML
         0ft9S0B4hYHFbgwvWogGg8jwZH43SUMl3KK0G4NyBXaQ+p3EPzRrHSMudnyxNg1+sN4v
         CsYcOiRi8/NuF9vz5F7Bw+zYSI4LbEOFT2skWLG/zy35Xvgm7iJXD3u3iid3OaYoD9f8
         0Arw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=WPGGb8xO;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.58 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80058.outbound.protection.outlook.com. [40.107.8.58])
        by mx.google.com with ESMTPS id q15si607054ejr.168.2019.06.13.12.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 12:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.8.58 as permitted sender) client-ip=40.107.8.58;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=WPGGb8xO;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.58 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/NiBEz4ijO+lxSyXpK7Yl0ytQfTsISKxzcr0SCPm6JE=;
 b=WPGGb8xOAp+UkRHD5UlkX2A3ttSqfhJeUF/W0UGsNyhrRpFFVUdOEYmRXw91pjffy9YmgsocweUK+R+oi10UC3Ffgy29CtibR3+2FP6J9n5l+eXR96WXyatq7wrBsVkpIZQvAc7UkRhqmai5cH8uqQ9IhBH0PDA+JO4E2vrVrHU=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5006.eurprd05.prod.outlook.com (20.177.52.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:42:43 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:42:43 +0000
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
Subject: Re: [PATCH 17/22] mm: remove hmm_devmem_add
Thread-Topic: [PATCH 17/22] mm: remove hmm_devmem_add
Thread-Index: AQHVIcyUgj3D92K/UEqq0wbnWDoM1aaZ/LeA
Date: Thu, 13 Jun 2019 19:42:43 +0000
Message-ID: <20190613194239.GX22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-18-hch@lst.de>
In-Reply-To: <20190613094326.24093-18-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR01CA0018.prod.exchangelabs.com (2603:10b6:208:10c::31)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ad0204ab-e9f3-41a8-358f-08d6f0374dad
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5006;
x-ms-traffictypediagnostic: VI1PR05MB5006:
x-microsoft-antispam-prvs:
 <VI1PR05MB5006C2D23554C23B116DFEE3CFEF0@VI1PR05MB5006.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:454;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(136003)(396003)(366004)(39860400002)(199004)(189003)(11346002)(33656002)(52116002)(486006)(99286004)(76176011)(7416002)(386003)(229853002)(2906002)(66066001)(102836004)(6506007)(54906003)(3846002)(6512007)(6916009)(6436002)(6486002)(186003)(26005)(476003)(446003)(2616005)(6116002)(36756003)(305945005)(64756008)(316002)(66446008)(8676002)(66556008)(66476007)(25786009)(68736007)(73956011)(5660300002)(66946007)(4326008)(81166006)(86362001)(7736002)(81156014)(14454004)(4744005)(6246003)(8936002)(71200400001)(53936002)(478600001)(71190400001)(256004)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5006;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 McGaOtbmZWACFWSvsDkXQQIGurm3RW/CW3fPYQ5QlYRTj3VHKVGzTNLVyjFiCL2tpCIQB6qnZzXK2qhRkaRpwHMICQyLJja3HA3B+rDSSEbpyab+P7f70du4JnGTvVMrnLmpV8bI0zX8Jsu7XGfT1rR8/0gToQfFkKP/c6pvA5ErS/Xp+yUb5gKEzSB9O8qNJVrV5MALF6U0uYSxd/1KyDpQPIctlIEUdL41q6/k7FO5Wr6ETTep7tzvy6FQLcwQ0QTcN/6KJhFQ2AoHKLxkiqUB9BlsSbkHDLFnueMjNRv7bvRIxryhT6ENwDcWmvGIhxle3r2U/w/AbnEkVdHPZqk3VFeuT5yawpumwi1hTJcovKSYCz8ZCTNA3PgcqA7ZkgrEyt/m/tMwUJHAIJSvY15//IfkasHvBAvHfJ5DqKs=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <4271DAA2E22D344AB96571BECBECE6B2@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ad0204ab-e9f3-41a8-358f-08d6f0374dad
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:42:43.8857
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

On Thu, Jun 13, 2019 at 11:43:20AM +0200, Christoph Hellwig wrote:
> There isn't really much value add in the hmm_devmem_add wrapper.  Just
> factor out a little helper to find the resource, and otherwise let the
> driver implement the dev_pagemap_ops directly.

Was this commit message written when other patches were squashed in
here? I think the helper this mentions was from an earlier patch

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/vm/hmm.rst |  26 --------
>  include/linux/hmm.h      | 129 ---------------------------------------
>  mm/hmm.c                 | 115 ----------------------------------
>  3 files changed, 270 deletions(-)

I looked for in-flight patches that might be using these APIs and
found nothing. To be sent patches can use the new API with no loss in
functionality...

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

