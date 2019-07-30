Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A69FDC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50458206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:53:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="N4HQWp2c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50458206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D96ED8E000B; Tue, 30 Jul 2019 13:53:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D45B98E0001; Tue, 30 Jul 2019 13:53:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFED8E000B; Tue, 30 Jul 2019 13:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 677C98E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:53:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so29663065edv.18
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=svBQypctoSakaJxDr/47kKSOg5ovdqk45jRwEu4qKbc=;
        b=Fd0jOqG0+AjitZAoILU28ThhGMekn0osuiiYfa1pkVt3yG0ueGmFnR0te0mWK1zRLm
         MojzCLYKq+AriIf3PL7aJAzo+W4DA3CTXVyOJCbjA4+UADx48O7G54q79D6FmGfI0VNb
         mdk4MONsG82NEDoSgMMy0r/cmzLim5AzNlAMwmlYn4wwOwhM/R5MlkqH/vhy6LV1GD8M
         AvKymOv7RzSBQ0uow8NYXn588RtJbeIzr2Q+O9hDB/gTTZinyuBqJUXtgaTasqq5RNw/
         CTC/hVeoM/aIH1L1jIJkktzPty2afaHiqXGzxyXChHKvZGioijZ0HMTc3DbnA6CBJSae
         u9xA==
X-Gm-Message-State: APjAAAWeZ8oHskLXvAnYxVWhcxT5mRr7yy9FChLDHtWVBhSP1re5wUUB
	Sc4KNt4yoACT1yD+MRlxIf3x7j19fiGQgJVZUXaSwE9FQRruajw7atNNtIyD2+Ce6EmTTm8u6Ee
	MiV8WelpCClEUYTMinpDJUSJM7JshblCi6egYCAMNaTpvJbgfmrTRtBZdlrG6VbamVQ==
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr55902985edo.239.1564509197008;
        Tue, 30 Jul 2019 10:53:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNxmpTEelaZ50q5+Cel4jG010ktE+6WYhJtqZdSCjh2XWKFV+JanTnM4plMRChXbRpnKcB
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr55902939edo.239.1564509196367;
        Tue, 30 Jul 2019 10:53:16 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564509196; cv=pass;
        d=google.com; s=arc-20160816;
        b=aeH0SMlF0EOiXHWK5p0btC1UbUwRBE0sAebZLAxKLEDQaYyCEauZ3N0Tj06SbUKedO
         j4b2Xoz0onPW22/lE5PBlNKTXcKh785sagZaabTXBT4fAEoYIn7e09LnzVL4yRcHLep+
         VA9LkHMb9/qC+uiHq5La7nJx0nrgdzx0bIiC+0YSl56sJ2hlGpuEX8jMzrre8zf1iJnG
         7bRvjWWX1bzfTelCaW5MSBcswVbDzXlhTx7fbgTrWCgLecRODmKHNwO/9nnsFyd5jfUr
         juUr1Xlj1piVrIBiwTC7lgxLXGY+mHpwAg8+Z6NVTe62rbvXWwdbt7hw2Do8gx0Wej3I
         A7Qw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=svBQypctoSakaJxDr/47kKSOg5ovdqk45jRwEu4qKbc=;
        b=SBN6Gcl48oTeq/+UseM6jgvFOS8BmP0/w+WyQ5M/K+dMmNLgQwrVqb+6Xmobk0IQgo
         3cbWbYXt74SjL6g/tp/PBAjQxEiByY6C8logHPPNQxS1eU2LqgYOLjrSd3LS0Y3AdpLm
         4nuNIeEPx0cE9mjWZX35T3pUMn/Pb0OjbpKQwQjZ7zV093toasSMOKwEnvfMjrWNE1gx
         SSBXFPuaGQBucRReM+f8ymu1KudtdSBTaxgBTLKGGly1GKJeX0f4tQQsAkvShTdB1cHF
         pxYHhWGuoGxZtn74sLGBS3ATxTRsthY6wL4TlqHVUH0CnqhxurgzewZgvMEuV90Kruwx
         HmmA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=N4HQWp2c;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80085.outbound.protection.outlook.com. [40.107.8.85])
        by mx.google.com with ESMTPS id b38si19913683edb.341.2019.07.30.10.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 10:53:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.8.85 as permitted sender) client-ip=40.107.8.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=N4HQWp2c;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CT806lH3GJFKccQD1MdEtYa59TfzKVZas0pBNefAL7MGwFs+IXfUKXWKfKiEUqG2IWFORXEEHhkcN80KYnMtpN4PZdLMJLelcQm/22Wc1+Pv1m3t/694c47Zjv2XYweXeTPEuG4eOn/Cp1ltLvC0FfQwh9FmW0vWC9XuzohqNdIuMECDei/XMjbOUIDyYZV0i6mv/MUqtYOwz/LKkQKfudSTNHcKQVgpthC5W0FmrSxrWivuC93ebpE40hRE/wmsN0fYkiKMZEPLuj2Xmetrdw9JDp4BwdnB9BHOkgGa0HfK0qikdDCMmWavw0ycDVieML3IUUzT1EL6tnDWe0glAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=svBQypctoSakaJxDr/47kKSOg5ovdqk45jRwEu4qKbc=;
 b=Xyl0QzWvTn9K/PgDrSnOfnN1Metsv/zKFRdDxdgrdjkWfLJ4EFSyhkswpi6g0ctqWd3cJa12jhmb8DUxktP2tWvG2x728v7zgldFnE/NYyVuZ8yUWkpXKU/ijijO4YKNkSvLVR17pE54eTZbHqrEoU8DgJ6Wvdmo5bLdSihDUx55RD/eKn+DJMUY9Ze24WPPZNM9nb/vhzHwI41ereDwiABixOtmZF9itGrDHrlBe1N35Y+MDiQrlv/aQyeOhj055449iQEb6HLVRhXH5RChz61652KK+9b6R7C6qAs94zbXEXu1tW+wqIwJu/b+kDyTDmI7ehZi3aqrfs13n124kg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=svBQypctoSakaJxDr/47kKSOg5ovdqk45jRwEu4qKbc=;
 b=N4HQWp2clWmIY6kC/cFpcFbUva8KgFw4ye84Wigpj6+tFdnR44iE6vUc97vpPTw0gNAMhO6TKu2UHXIYadMNudLiWkw9h6pMFARZIi4KlWYs8iNlOrEDoDb9hg0cbwupovJeYsHloI8yDlUXblEr2rTUGR7jgjp+iPiwqE09S5E=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6127.eurprd05.prod.outlook.com (20.178.205.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.13; Tue, 30 Jul 2019 17:53:14 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 17:53:14 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 11/13] mm: cleanup the hmm_vma_handle_pmd stub
Thread-Topic: [PATCH 11/13] mm: cleanup the hmm_vma_handle_pmd stub
Thread-Index: AQHVRpsFqcopldMqYEmw+Nzxjc71m6bjchWA
Date: Tue, 30 Jul 2019 17:53:14 +0000
Message-ID: <20190730175309.GN24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-12-hch@lst.de>
In-Reply-To: <20190730055203.28467-12-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0034.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::47) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a86e21db-ce58-4552-20a6-08d71516cb53
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6127;
x-ms-traffictypediagnostic: VI1PR05MB6127:
x-microsoft-antispam-prvs:
 <VI1PR05MB6127DF35F7C611722F89A276CFDC0@VI1PR05MB6127.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1850;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(136003)(39860400002)(376002)(366004)(396003)(199004)(189003)(6506007)(6486002)(2906002)(256004)(476003)(11346002)(229853002)(66066001)(446003)(6436002)(25786009)(486006)(2616005)(86362001)(6916009)(305945005)(7416002)(81166006)(8676002)(81156014)(316002)(99286004)(1076003)(7736002)(8936002)(4326008)(54906003)(386003)(33656002)(6512007)(71200400001)(71190400001)(5660300002)(6116002)(3846002)(6246003)(186003)(478600001)(76176011)(68736007)(52116002)(14454004)(36756003)(66446008)(53936002)(64756008)(66556008)(66476007)(26005)(102836004)(66946007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6127;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 eMqyxStZBZXBfI7QOYbRdCnQWZbklIeusgJmFjsEOIO5UawNseLehFkPAB+PnBPfGkBQoOyco5nEy+/0Bb1opqHO3IPX6n2Wx1gjcMjXSMMWaWCQX9u6fdGZ+XR2QGrqiwR7ipGZxNYBiqIsxkVKeXtnRnLdwkTWwIeKnTUAI88LJ7gGpii6LuqBceQu51tTKFHLDsAl/K2pVhyKp+1tNNvN2RNv+syEoL0XlZ1tGjtz4YJ+jEEM+lexqBmMSTAR1LqM0Z8fX9kYXouHw0M7BK7hC2uAoCPZ8ky13fy7a9bHhps2QjrPbqZ8X/NPkNN7Lkve+zgWk7cT1tylCHPSg+G4Ips+UH5tDuIwU+op8H/wlrD5Jzh1vah+ik6M3rNSf8ZxuTE43QEHJiGAVWCvJTY+amLgF0/Bg/rQuojOfrA=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <EC3900854AA3CC4983AC1C9EED4B06BC@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a86e21db-ce58-4552-20a6-08d71516cb53
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 17:53:14.2580
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6127
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:52:01AM +0300, Christoph Hellwig wrote:
> Stub out the whole function when CONFIG_TRANSPARENT_HUGEPAGE is not set
> to make the function easier to read.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  mm/hmm.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 4d3bd41b6522..f4e90ea5779f 100644
> +++ b/mm/hmm.c
> @@ -455,13 +455,10 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct =
hmm_range *range, pmd_t pmd)
>  				range->flags[HMM_PFN_VALID];
>  }
> =20
> -static int hmm_vma_handle_pmd(struct mm_walk *walk,
> -			      unsigned long addr,
> -			      unsigned long end,
> -			      uint64_t *pfns,
> -			      pmd_t pmd)
> -{
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
> +		unsigned long end, uint64_t *pfns, pmd_t pmd)
> +{
>  	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
>  	struct hmm_range *range =3D hmm_vma_walk->range;
>  	struct dev_pagemap *pgmap =3D NULL;
> @@ -490,11 +487,14 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
>  		put_dev_pagemap(pgmap);
>  	hmm_vma_walk->last =3D end;
>  	return 0;
> -#else
> -	/* If THP is not enabled then we should never reach this=20

This old comment says we should never get here

> +}
> +#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> +static int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
> +		unsigned long end, uint64_t *pfns, pmd_t pmd)
> +{
>  	return -EINVAL;

So could we just do
   #define hmm_vma_handle_pmd NULL

?

At the very least this seems like a WARN_ON too?

Jason

