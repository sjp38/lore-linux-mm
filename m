Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 136CCC06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:10:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A59E1218A4
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:10:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="KIinKYDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A59E1218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3A086B0005; Wed,  3 Jul 2019 10:10:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE9F88E0005; Wed,  3 Jul 2019 10:10:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD96D8E0003; Wed,  3 Jul 2019 10:10:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 924256B0005
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 10:10:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so1772608ede.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 07:10:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=9xyphrNP6oUvQK08UnO2NmYiuMrL0TD3/l2pKs8GPgc=;
        b=ONrbugWih84bZc/5GxiQnTG86eRfPr+lc10EADIYvkXeL1NFwcDrcxqYc4Dg649buL
         4UXRL64DtqMOL26H1p/0BbA3Vx5u2oxVmQcUEaq+4sb3AIk1ex/WWToCQA4ysPARIrOD
         vcQtoO7b1kD6mm4FhpBLibOiQETrVKJa3mGiKEFv/GmBQIubIpNBBlMSGS6JpEeyd/Sq
         kjS2JrnIZeGidGUtv2dETDmPh+KHZDtOlJPmY/xdOKDgEdRLjOnmOb1H+PRlCvhb9uRy
         kCNTlq7etV8cQ1a/pCTjN0bxOn8+VuwxaqXoJB+6Gy2kejCR1own5QhCZT7J8OiUdFAQ
         yANA==
X-Gm-Message-State: APjAAAXToA6KJpxn2+gy7k5cVwkC9mMzbAWO/uSitj8/zba2eiS6xL5k
	/vAOpcjSc7V9b7jWqDg+9fL51SUX5eNEVKmzPyswDdq2Fqh5V5jDq9EiY140e5O68kdNCseMOll
	egZ+YxvAKJmKfDW8c4u+ewoDo5iV1B6+0Nck5xuk3op31wiBTv+Y2pSiw5F7nCayvEQ==
X-Received: by 2002:a50:ac46:: with SMTP id w6mr44380915edc.238.1562163008026;
        Wed, 03 Jul 2019 07:10:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtbADk/jBcdoZBLuQHmj7Q8r17pQ6uPS8h7ZZKV7tSAUphmC2Q74JzMARvn6aYLOX8XMmx
X-Received: by 2002:a50:ac46:: with SMTP id w6mr44380783edc.238.1562163007051;
        Wed, 03 Jul 2019 07:10:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562163007; cv=none;
        d=google.com; s=arc-20160816;
        b=dwMz36OpU5+I8sx3BcnwGvBi5SnJPRiGieNyjOTGHKIbPKfDwsJ8qoPElVrFNIptd2
         t5ISPjZN/AnHkzFVIpdj1TtPxzK8ykD9Inj4CH1MtAMvfY8qTpOs+/F1UIQyJMFrpMHX
         oryPFYrFU3BEHlg35gkzBkGNHbAjpQe6zOCEIbThzkcJSJvfL5mXy676LnnKz0y65Ek3
         TUqpt/IlecU+40EYnnLr7WRRIvGOJNcjO9/4V8O1TVh6ZDB7f/BKPiLSDF4lz/evEFjs
         FpQYZlHAP9n5Y61439MHdqLd24XBgAhfuIX1M4lKi9b/ZdnYMfBeUVKjgUuaBDTjtVwj
         PByA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=9xyphrNP6oUvQK08UnO2NmYiuMrL0TD3/l2pKs8GPgc=;
        b=Ry5ABvoo2JXRp7wtBDqUYqIX9E20ieE1V8km8IXjgVaTBJg9DJZpUrvldpNowKG8Kw
         vm5q1PEbMy61CQx0Uo97zSHvplAANx6PnJXJAEBiCt6CW0WGrD9bMr+LMntLeqMO2YEL
         t8plX5UtRYmI9du7oor4QM0RHgaMQbH9VN+iuhWBwOsF7y9QSbXrZKWG0nAxpFUNhUTO
         QFy7H3+ZXYJn46VfIt0W0j+afRy3nryCP9yHyLc2nmAWKEHmF0QueSdqozcdHoc9FNMt
         JsZuiZkPz/BHec2pOwaJsplFUgAjGUZTWi1RmkYW3zDejGBPYdtUS7wPWpjYvwyvVe5z
         QugA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=KIinKYDB;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150089.outbound.protection.outlook.com. [40.107.15.89])
        by mx.google.com with ESMTPS id p6si1666373eju.23.2019.07.03.07.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 07:10:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.89 as permitted sender) client-ip=40.107.15.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=KIinKYDB;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9xyphrNP6oUvQK08UnO2NmYiuMrL0TD3/l2pKs8GPgc=;
 b=KIinKYDBeRYg866u2b0gz16nlg6nMRMmFBQ+KAUUQ55aFT6GojM9e215r2Dp1C+/kBseDNlyrbmmt0ECxwbk1XQXI9bDy5WJa88lGiO+BMsqYfZ6CZwVgRC7ZEtegWS5Lw39d/IMM49DAZwtXoxNMjANkwQcSdUBcH3IPvXJypg=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6285.eurprd05.prod.outlook.com (20.179.24.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Wed, 3 Jul 2019 14:10:05 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Wed, 3 Jul 2019
 14:10:05 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
CC: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "Yang, Philip"
	<Philip.Yang@amd.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Dave Airlie
	<airlied@linux.ie>, "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Topic: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Index: AQHVMUJXWs8sf5cAOUS0d/4NvIH/Saa473yA
Date: Wed, 3 Jul 2019 14:10:04 +0000
Message-ID: <20190703141001.GH18688@mellanox.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
In-Reply-To: <20190703015442.11974-1-Felix.Kuehling@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0112.namprd02.prod.outlook.com
 (2603:10b6:208:35::17) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d6ffa8a7-727f-4983-2304-08d6ffc02576
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6285;
x-ms-traffictypediagnostic: VI1PR05MB6285:
x-microsoft-antispam-prvs:
 <VI1PR05MB6285C30CC9BD99FEDCA47DA6CFFB0@VI1PR05MB6285.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(396003)(39860400002)(136003)(366004)(376002)(199004)(189003)(3846002)(6116002)(99286004)(7736002)(25786009)(66556008)(52116002)(81156014)(81166006)(305945005)(64756008)(4326008)(66476007)(66446008)(8936002)(66946007)(478600001)(6916009)(71190400001)(1076003)(8676002)(73956011)(5660300002)(71200400001)(6506007)(6436002)(446003)(53936002)(2616005)(6486002)(36756003)(2906002)(256004)(6246003)(102836004)(14444005)(76176011)(386003)(86362001)(26005)(33656002)(186003)(14454004)(66066001)(54906003)(316002)(6512007)(229853002)(11346002)(476003)(486006)(68736007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6285;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 uB6dTC+NZ0Di8A5w1s0kCQKz7u2ggZEIgDQWpW0L4WsGLJ1uF/R9PlQFfFp4OoFpAFfWKbmgswgteQN0A4WaVqGQRxkkCd4oLx1abHjYVLovpP6xcbmPQ2tjbRh5vBJmsmrxof3OiAxeZb3WZrhSHAXbOsCoKvabSOM2Z3ZSS4smmkL/wQPZ07pJruuPUsE82PMUhxepsmIVv36gVCTfwwTl8lSfzT9KNRWn/Y9BRiFJj6YfyK14Ghw/ixgiRychZLaziOejH6OIKYAGfSYT433x/jiBaltK76lSzWVSDjnmXSPOPrlnUFtpyk5FjboUO0q0iPiwWF7FJHDysf5I+iORdrqZ8t/AW/t9Ua0/bVsJBTyvFnkp0uciSX2xmtXAeFqAMB6uTKrO/F7QAu7dxkqhLTtd3c2hCK6JXilwUDs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <17622BB336903649B6558468F65A4E0E@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d6ffa8a7-727f-4983-2304-08d6ffc02576
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 14:10:04.9785
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6285
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 01:55:08AM +0000, Kuehling, Felix wrote:
> From: Philip Yang <Philip.Yang@amd.com>
>=20
> In order to pass mirror instead of mm to hmm_range_register, we need
> pass bo instead of ttm to amdgpu_ttm_tt_get_user_pages because mirror
> is part of amdgpu_mn structure, which is accessible from bo.
>=20
> Signed-off-by: Philip Yang <Philip.Yang@amd.com>
> Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> CC: Jason Gunthorpe <jgg@mellanox.com>
> CC: Dave Airlie <airlied@linux.ie>
> CC: Alex Deucher <alexander.deucher@amd.com>
> ---
>  drivers/gpu/drm/Kconfig                          |  1 -
>  drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  5 ++---
>  drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c           |  2 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          |  3 +--
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  8 ++++++++
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h           |  5 +++++
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 12 ++++++++++--
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h          |  5 +++--
>  8 files changed, 30 insertions(+), 11 deletions(-)

This is too big to use as a conflict resolution, what you could do is
apply the majority of the patch on top of your tree as-is (ie keep
using the old hmm_range_register), then the conflict resolution for
the updated AMD GPU tree can be a simple one line change:

 -	hmm_range_register(range, mm, start,
 +	hmm_range_register(range, mirror, start,
  			   start + ttm->num_pages * PAGE_SIZE, PAGE_SHIFT);

Which is trivial for everone to deal with, and solves the problem.

This is probably a much better option than rebasing the AMD gpu tree.

> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd=
/amdgpu/amdgpu_mn.c
> index 623f56a1485f..80e40898a507 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -398,6 +398,14 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device=
 *adev,
>  	return ERR_PTR(r);
>  }
> =20
> +struct hmm_mirror *amdgpu_mn_get_mirror(struct amdgpu_mn *amn)
> +{
> +	if (!amn)
> +		return NULL;
> +
> +	return &amn->mirror;
> +}

I think it is better make the struct amdgpu_mn public rather than add
this wrapper.

Jason

