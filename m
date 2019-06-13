Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6953BC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:30:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B85220866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:30:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="monCWH28"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B85220866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D17348E0002; Thu, 13 Jun 2019 14:30:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEDED8E0001; Thu, 13 Jun 2019 14:30:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDDCD8E0002; Thu, 13 Jun 2019 14:30:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5864F8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:30:32 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id a19so1641ljk.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:30:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=r0d+YLFD8dGkAwiCYZAtPwS2G6Ds7zR/M3jKY4RPVuk=;
        b=irNepImwQUCeLtYL2crIYCS6721OkFOCM/n4ayPvpF9CVUAtz2Yhp5UUl4Qd+XdjUF
         14XgLTu9tDbVjw7YPabDPkD1IL2BebDegRD7fKzxj7UE6g1xh2zFxc5WQDfzHsnfqueC
         4PbDCDn+eeON974TikLYpkRT2cNw9xE85lAVcu7QmZW0AgAyUPIvbW463LhJNxt6nir4
         MeR7Sv6NQWojgPN1zalgIBaxYCI9cGRIvfAswg/umVvdPBOmgXU9JTe62RR0NaZ7tlKH
         9PPZBtDdQY+95dhDyfwYyQTpTRD8G+IyBJqeWnYEY5r6miL4/7bKLcO5S3xGNI028mim
         UFHg==
X-Gm-Message-State: APjAAAU+cBXLSJcnMkf+O+jRvcC+cfdGHMNzkbFtmiv62womXY7mi5c2
	pAAtf0YEzOsoKhZixbh6v5AyvqHWuw+IST45UJKKWLMXOYxeL2q9CtqSQ1g0Vd9IgoXTTqa9Hsc
	ccc3SNl7W9YQgbWwa5sx8//vpPyI3I23GvlCa1Gihk0hj405aYMd6PGXuy2/SulsZqw==
X-Received: by 2002:a2e:9b57:: with SMTP id o23mr6566222ljj.67.1560450631513;
        Thu, 13 Jun 2019 11:30:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwL6aKVWSmRa3xei7qAdcH09R6WXjfui+Cs5gapJcSSPqmOQWJ1OJdOfx50WVS8Fjm0/Kqe
X-Received: by 2002:a2e:9b57:: with SMTP id o23mr6566197ljj.67.1560450630819;
        Thu, 13 Jun 2019 11:30:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560450630; cv=none;
        d=google.com; s=arc-20160816;
        b=MQLQKblinx6GPMs1+nErs5xOVinXS++Czod/BRql/bGBH5ECkvEimAEUO2l+Um/ZR3
         CCLhq4CkAK0aGDORbWHbacxjeY5LSK1kdkA3aLvEXEsbLJNBByYqcK16H2cH3Q5tGJZj
         T8t9WU3olh4uceIWbvsZtj9kgu5/82nytLvjbP2oJDpsJMGAfCVKIudWU+mB4NYid4UG
         vRcL0ApQOUh62WSeoIOkV1WLEnDx1Nga82iklGxJ4XJRCt68ZLrExdC8ZxYfG9ofPOOw
         4LxI+kgIf8p7xyIQGUPNxL0IwZR8Y5Jy4ADV+CPRCXVgTNziwZs9KCNk+1kRHmmUcij3
         RLzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=r0d+YLFD8dGkAwiCYZAtPwS2G6Ds7zR/M3jKY4RPVuk=;
        b=gfVO9qwdNjLsaXH9buxF3ybsCK0/RmbO9sTFxvZYZMErB6dP2JVD29J9aOzNUKjQv7
         g7qyEBHov0uiAL5/nzWAqhwDaTKs7EG/VJP41j9h4hyIl83TRtA1+E5sjbA/bPqq7c2J
         HRoavlpMmeujhTg6diWAiGQPQHT5HzLgUv/MUVCve5w6huck7DItRP8EObMn5T31HxyD
         YtL1ihAtD3zAKy4U68wr+W/AafUlkO9mpcwkwJ33Ww9+Sx002Xqo37mEL/0vwefH8H2j
         ysflQklwITGpVoi/IRl4EP48+FNkFiRMGpg0Y2ewKLJH/kYn+VK27DN1n/msIxf8Pj3p
         bJvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=monCWH28;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.64 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50064.outbound.protection.outlook.com. [40.107.5.64])
        by mx.google.com with ESMTPS id z22si290115lfh.55.2019.06.13.11.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 11:30:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.64 as permitted sender) client-ip=40.107.5.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=monCWH28;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.64 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r0d+YLFD8dGkAwiCYZAtPwS2G6Ds7zR/M3jKY4RPVuk=;
 b=monCWH28lJ8KutFgYrbunH4n71O0rCyBxc5YAFfMijiC+36DWBjgRugr2jES4xlF5XZW4obgenyjgDDc9/IxSVr5yzCoI5cH1QauGF4qKClZYCrLY15EznN0ic2/4wRlPBtniXJKWIQFSIlRR23+0rxITpaOtgBm7uBPIcTdrA8=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5584.eurprd05.prod.outlook.com (20.177.203.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 13 Jun 2019 18:30:28 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 18:30:28 +0000
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
Subject: Re: [PATCH 01/22] mm: remove the unused ARCH_HAS_HMM_DEVICE Kconfig
 option
Thread-Topic: [PATCH 01/22] mm: remove the unused ARCH_HAS_HMM_DEVICE Kconfig
 option
Thread-Index: AQHVIcx6m7GApB2g2EOjqyqCTmZIFaaZ6IgA
Date: Thu, 13 Jun 2019 18:30:28 +0000
Message-ID: <20190613183024.GN22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-2-hch@lst.de>
In-Reply-To: <20190613094326.24093-2-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR02CA0032.namprd02.prod.outlook.com
 (2603:10b6:208:fc::45) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c1ee3c6a-1509-419a-74b4-08d6f02d35ac
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5584;
x-ms-traffictypediagnostic: VI1PR05MB5584:
x-microsoft-antispam-prvs:
 <VI1PR05MB558425A8B5EAF3873BF93F5BCFEF0@VI1PR05MB5584.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:923;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(39860400002)(396003)(346002)(376002)(366004)(189003)(199004)(11346002)(26005)(4326008)(8676002)(2906002)(446003)(73956011)(81166006)(81156014)(68736007)(316002)(8936002)(229853002)(66446008)(6512007)(6436002)(64756008)(25786009)(66946007)(66556008)(6486002)(66476007)(2616005)(476003)(7736002)(305945005)(186003)(53936002)(256004)(3846002)(1076003)(6116002)(6506007)(6246003)(33656002)(66066001)(386003)(14454004)(102836004)(4744005)(71190400001)(54906003)(86362001)(6916009)(71200400001)(36756003)(478600001)(486006)(5660300002)(99286004)(76176011)(7416002)(52116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5584;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 eb3KNKd+VDg3aMK8Xechk52gl84tRX+UWpHdsOLNOQzeiT28ESmFj2R4yKBmX+NPNaW6nZgyRfR3xgOTcaQ1b4lRWF6pQAbCHEkPttsEIW1r8cu28CXaD45UV36dQZIooipJbaFiZTzELlXICo9wDON3UG7aNvg+R+cWUXcYJie9pdMNgKX5v3lkEcBent4N1kyPRMafc480EDdxGF4aAAmP5ip0yM9nDnluL/fQCgq8GXOGX7b3kOgug3OKimrxKxX837QgZlGE2fpggJ/ZDicu4ctD5be9CWPG3TpqcjUCqzn1BV4UmOojvh+hKxZkl1v7Z0lpZ+RXvTN9QxS06jX1iWzwcH93SIz/BXEzE46Prkw1Id4bz6tQ0K79DZqnttQrzX5GmktcE0O6ji7z3ox0jb5Tt89CDTzrmvMVFN0=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <1C3FD7879859344FA6C6020F72EC479A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c1ee3c6a-1509-419a-74b4-08d6f02d35ac
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 18:30:28.7061
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5584
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:04AM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/Kconfig | 10 ----------
>  1 file changed, 10 deletions(-)

So long as we are willing to run a hmm.git we can merge only complete
features going forward.

Thus we don't need the crazy process described in the commit message
that (deliberately) introduced this unused kconfig.

I also tried to find something in-flight for 5.3 that would need this
and found nothing

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

