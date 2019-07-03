Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553C8C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 19:00:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 028672189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 19:00:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="qCfJh6wt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 028672189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F8FF8E001B; Wed,  3 Jul 2019 15:00:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A8ED8E0019; Wed,  3 Jul 2019 15:00:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6224C8E001B; Wed,  3 Jul 2019 15:00:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11D4A8E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 15:00:54 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so2298044edc.17
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 12:00:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=jW1QLqG0Yl8+6QA1y0hpQO2CW7YVwBm9xRUpZgg5RV8=;
        b=NhBueOv4EtXiDr0U7KSwIHaLJ3lG43wFZQkizJrmGMWs3gkJwtY1oOBzPX1tIjyaDt
         qMGBmpo22BkJmmmHWjrJOWSOfaylGEuzcIyq73QKdstW/pXBp1AOoIuPsU/molKmbYD1
         n9s9zMN0nHIbop6kjcZt0ynMcqa2oC0AI+lc38bbM1dybgce8P0D9Whvj5A01ei9e6bh
         pOzY3ttbl/OHOq0P+32UYUaeN3QKWlh+yI45jG2GeWbftYn79GJws6SgGW4j7U6SqIV4
         xRxzHTTOruq7vgYEijoY16LQ9qEYCFIfOhQXDckHgN1Wj0ikT9XlIE4gml7jQAYoUYNB
         BNdg==
X-Gm-Message-State: APjAAAUVmx2vew9UGPSJ7fjOQhVFO/myJOqJAp++dXnfUVVFFOAxo2KO
	ppu/ZpYAQXfC3Wtxoykw4H6dI7XChfF+Khn3BF3bkE34gWoGFQaVhfIz6bk1994MmYOsNFH6Xmw
	4V9DDgcp0fht9ds3tDpAqsiA1MGNwtNRsNzPDHuv38NCiZDSgYXfHMDMbSH/rnSGM5Q==
X-Received: by 2002:a17:906:8048:: with SMTP id x8mr28971315ejw.87.1562180453531;
        Wed, 03 Jul 2019 12:00:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVcYY530YI4WMB7xXUNuCVyqO/bvKUoWSY6Q6wDiAZzl81b55lvyr+9msueEt2AB9kd11k
X-Received: by 2002:a17:906:8048:: with SMTP id x8mr28971245ejw.87.1562180452734;
        Wed, 03 Jul 2019 12:00:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562180452; cv=none;
        d=google.com; s=arc-20160816;
        b=P+OdsgPdWelHPH31sk+xkFwyEHE0D6FanGuihRVJpUSM0uoqRDiVZ26cuOWy86zIxP
         Mhze+loR4rnJc0FdDiuYrXyd9Vg/pP2qUlsXY3MS9U9n9/Ne/sZEbX3paGKNW0s7lusI
         LJQrgfIIdgSsmXOhiAbH8KMd4/cx6618U0OeC0pV0MMl+5RK4MNFEcUmsV9T5FXeEsuy
         Z2APuF9HCOGXAWu6EGCbidosIZsC0MOCdLoTRVZ0jDMwYl+vAPrGBMxfeoZxMj6BvaiF
         HgjH2tg4bxis9OBDoqtbTopws78Bh4+VUpXhTlxkQlWtOx2n00Lb2UXj//diw/Pb9nps
         bF4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jW1QLqG0Yl8+6QA1y0hpQO2CW7YVwBm9xRUpZgg5RV8=;
        b=jCq9nz3F2GJaBVckFr6JhJPR56IbT5fDy+tgPAgjGVl1apG2p1e9T5B+UDr/e4rOA8
         G6ZxC2rEBySl2EcZAdZciE8SO5V+F1B3sQN2FC6mI3vvCmMlpKvL0bFg6MfcKyCySUbO
         8In+Ooq6y9tcxrd5Le7u+pBXqB/IoHqtdcAvaOcP2UjzAZL+N0ll6zU4XU1na2AVFDGu
         PwOfmVBzRvjiVOUWQKy4VsWytEvuPiqYmEX20F7Pfrui1nTk9md68XaHrpeL7x6D4Dwt
         XDzKP5m2LWZYGwrdGCGmvIb1gxReXcyBaRw2MFWhYt2EkLcmpSPq17cRXD28qBs4iHAh
         4Rvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=qCfJh6wt;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.70 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50070.outbound.protection.outlook.com. [40.107.5.70])
        by mx.google.com with ESMTPS id f22si2221307eje.19.2019.07.03.12.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 12:00:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.70 as permitted sender) client-ip=40.107.5.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=qCfJh6wt;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.70 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jW1QLqG0Yl8+6QA1y0hpQO2CW7YVwBm9xRUpZgg5RV8=;
 b=qCfJh6wtkaqMswWFwHSQZb4Z/kbjELjDI12Ai5aNxFMY7TXtie2JJdRuFId4OaJZbyNV9KI5zcICr+uBShl1DpHfsSe/jRb3b2mOxRKuBi7M4jMhTj9uPZj2VEb+9KLsMewYy1GIqsiltXHOOVmoloXhd95CwvPjfZxYkVR1/DE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6032.eurprd05.prod.outlook.com (20.178.127.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Wed, 3 Jul 2019 19:00:50 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Wed, 3 Jul 2019
 19:00:50 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralph Campbell
	<rcampbell@nvidia.com>
Subject: Re: [PATCH 1/5] mm: return valid info from hmm_range_unregister
Thread-Topic: [PATCH 1/5] mm: return valid info from hmm_range_unregister
Thread-Index: AQHVMc9vbnYVs0S/206V41dM/fYuDaa5P52A
Date: Wed, 3 Jul 2019 19:00:50 +0000
Message-ID: <20190703190045.GN18688@mellanox.com>
References: <20190703184502.16234-1-hch@lst.de>
 <20190703184502.16234-2-hch@lst.de>
In-Reply-To: <20190703184502.16234-2-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0052.namprd02.prod.outlook.com
 (2603:10b6:207:3d::29) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e5c54ad6-e426-42ce-989f-08d6ffe8c394
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6032;
x-ms-traffictypediagnostic: VI1PR05MB6032:
x-microsoft-antispam-prvs:
 <VI1PR05MB6032B3B10FE9F9E9C6D63DB5CFFB0@VI1PR05MB6032.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(346002)(39860400002)(376002)(136003)(396003)(199004)(189003)(33656002)(26005)(81156014)(316002)(2616005)(36756003)(4326008)(6486002)(86362001)(386003)(81166006)(6506007)(53936002)(186003)(486006)(102836004)(14454004)(8936002)(6916009)(8676002)(305945005)(68736007)(11346002)(478600001)(476003)(446003)(54906003)(66476007)(52116002)(6246003)(5660300002)(2906002)(64756008)(66946007)(6512007)(66446008)(25786009)(73956011)(66556008)(1076003)(6436002)(3846002)(229853002)(99286004)(7736002)(76176011)(71190400001)(14444005)(66066001)(256004)(6116002)(71200400001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6032;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 tGLXfkxhn4UMvbBsaWRxIq0U0KZWaqqcr+rFSUIlHqJy9FP57IS59e+yPBehjk1jXreBrmMYaZKLDwE60fBKQncizWEKCVlj7f2vVm63/bzW05sS2PMhxm398RP5Hmv/P590lkCoPjMQRKB24p2IP8a8x3NPijoeN+P04YH6/1QVAa/Ik/7e6apiSgb6jpe142Ul4RF7XDbGN/OnPmjZDxet9AOe/f9F5VOtiFbKUcS7Djs89CW1B8IWygw8aQIjhFsM8y5zg6F8pwjrSjrILw1s2W+pW5X1P2ryJv8DOc4BKwt08BVubCP3a7kICP9tfw2lv58U0FlYDvtPxJanewqzVQN4kT2YfhNa4uNVh1wxPLzIUsEU7SwYel5Y7gnz2MQiytuGVMkswgQbJ2vsnwFMaFQae/LCLEwwjkolSqs=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9EED1B508716C14685B4671208A7B4A6@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e5c54ad6-e426-42ce-989f-08d6ffe8c394
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 19:00:50.2152
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

On Wed, Jul 03, 2019 at 11:44:58AM -0700, Christoph Hellwig wrote:
> Checking range->valid is trivial and has no meaningful cost, but
> nicely simplifies the fastpath in typical callers. =20

It should not be the typical caller..

> hmm_vma_range_done function, which now is a trivial wrapper around
> hmm_range_unregister.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
>  drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
>  include/linux/hmm.h                   | 11 +----------
>  mm/hmm.c                              |  7 ++++++-
>  3 files changed, 8 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouv=
eau/nouveau_svm.c
> index 8c92374afcf2..9d40114d7949 100644
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -652,7 +652,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
>  		ret =3D hmm_vma_fault(&svmm->mirror, &range, true);
>  		if (ret =3D=3D 0) {
>  			mutex_lock(&svmm->mutex);
> -			if (!hmm_vma_range_done(&range)) {
> +			if (!hmm_range_unregister(&range)) {
>  				mutex_unlock(&svmm->mutex);
>  				goto again;
>  			}

In this case if we take the 'goto again' then we are pointlessly
removing and re-adding the range.

The pattern is supposed to be:

    hmm_range_register()
again:
    .. read page tables ..
    lock
    if (!hmm_range_valid())
        unlock
        goto again
    .. setup device ..
    unlock
    hmm_range_unregister()

I don't think the API should be encouraging some shortcut here..

We can't do the above pattern because the old hmm_vma API didn't allow
it, which is presumably a reason why it is obsolete.

I'd rather see drivers move to a consistent pattern so we can then
easily hoist the seqcount lock scheme into some common mmu notifier
code, as discussed.

Jason

