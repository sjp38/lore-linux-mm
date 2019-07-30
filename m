Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A579C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:55:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF1362087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:55:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="NzmrYNyZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF1362087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D9F48E0006; Tue, 30 Jul 2019 08:55:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 488B28E0001; Tue, 30 Jul 2019 08:55:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32A248E0006; Tue, 30 Jul 2019 08:55:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC9F88E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:55:19 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p13so31748509wru.17
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:55:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=idycEckcr4oa7t42lFd2XxOLcI8deGKjkgpKUBigHj0=;
        b=cZZxBbw9O4RR0j985UdGZUUoO2JXhn0LtZMdFjXQtgh0W4bAB7aJQI0EGtqDLrQnKx
         eyqwLm7+h53yLscuiCypCZ0rJB/7W1b8tDM/I5LlsA1LjPbinQSU/kaZsauLWGDXExVK
         9q5muzUjRehOpr5CvU808xdcET9B5zJcuJOcMou5XhMTLUgNwpQ809EAVtM0qssOIedW
         dmm7egFVBttN6R2r9+l+7+8v9fG3jDX/WN+6V8QBEvPSLhnQ5lFazwVsMDjGu2NuXXep
         WWwn3YRLDj3fDactuP1mONHJcrFGU3MclhYAu+5HCFdS2ElD+Qv5fi8iAsWl26KAa0cQ
         JXnA==
X-Gm-Message-State: APjAAAXdwFT4DmzfN7iWEA7eJdbEDchCshG9ubtdTsYBRQn8Jrqj2uDb
	q+sHQPACfkHH0GxWKYATPGhbpLXJ368z9uYrUw+G1RHmtHMsaQcWrQ/evPOc74c7/nYHz6HqGfp
	P/gmBjMKZSryhROJREF0Y4tMUJAsa4bFEBoNXnh1/GDt4LfpNDBCKVRmg0msDzy6ZSw==
X-Received: by 2002:a5d:5303:: with SMTP id e3mr47476798wrv.239.1564491319485;
        Tue, 30 Jul 2019 05:55:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXWYQ5c8M9QJWyO56481EdIgHK+2LoraV2pGDd74a8+Ep8BDl8cq4fjM0j/vuXQK9M8MUx
X-Received: by 2002:a5d:5303:: with SMTP id e3mr47476764wrv.239.1564491318876;
        Tue, 30 Jul 2019 05:55:18 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564491318; cv=pass;
        d=google.com; s=arc-20160816;
        b=k2PJqdbYcO9Zx4+KbWmsZxGm8MKX9CpZNmd2VucBTn2CsB2IQLs1XBlOYLdPIpdyVT
         Ju8tt4RusVm2lHVLWtYNJeZTNcyDuWSrTxXhmszI+VkQoh/mEIvmJutt7RoH1Qs+cQq5
         RJu4tgalksOsYU3FKhgFjvNKqrd4GeQT/5JUWJd8qwuL+biKCqVE4h/NtNdQZYp4y2eK
         pO6zciwOmttqhQqT1qAzDChVhi/40SbYypzg9gPy2lePSF/ncgr7kgGlr61wFaTzHsGj
         8TqqQxy13/+bmGBihsmy5V/L103Pu1hRmv6TnOcM97j6iJPhidjkqWUlFsyUDL3kMgyM
         wBJg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=idycEckcr4oa7t42lFd2XxOLcI8deGKjkgpKUBigHj0=;
        b=yTSFUpIX09hAcFXRp/6tp2MWSrWUC89HpVoreb364Q1eFfV/uGoNmJf4FmSkO7Kd/c
         RNemw0peM67pbxw+grU/2knJEXF6PXOqyMa5gIohyeDOe0Xcw68NYrA321bnQArcWrHR
         XkBMEzgCn5ZqfjnY85O9fxkz1DZ5Di2mnOpVC5vRCwrH2avaPddHsILgHYLQX60IVYms
         nYiuzNmavdo7nuIOzj8LdU8eAldHz6/JhVLXlKb0UZUJJZhPvf8HcGLT7QAexbEBPZPY
         ZisjnZTNNQ+8IKpR44fxvKdJWkcD4BpcblU3P8Z+N2l9z4BHZY9haHkXpG0HVVX1n3wM
         NYFw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=NzmrYNyZ;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.49 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150049.outbound.protection.outlook.com. [40.107.15.49])
        by mx.google.com with ESMTPS id q4si62564345wrn.99.2019.07.30.05.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 05:55:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.49 as permitted sender) client-ip=40.107.15.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=NzmrYNyZ;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.49 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=RnKo7LYrKDZ71MuqMXvk6l1xyYiPKBod/kJ+4AdTkgXuos50numeugypZ4UU4SWo7C3zZGDLTEboOPPWuC1LG2GhTA1D67tIVf9TotFR7AqM3RhXYNdII0+AKUE53CDWu6/J05NGQIMpQGKL2506KA/D8H5MRNq2kXt7AW4mkGfq5Fo6ADAsyrUlpwQpR79uF7bK+K0HmSV4++Zc2O+nfzWNBaVbUJkLCWN/nVu3GLLHwbygclAmWfRavRXUPhFcyXIH4zox6ZmSqjn9QVgaGMbYTwGA7Zigdj07Amu7KRk1jzb/hbbw7ESy2r5gTgQ7sHkeLBo7tR6oYNSss4IN4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=idycEckcr4oa7t42lFd2XxOLcI8deGKjkgpKUBigHj0=;
 b=Sk0oQlKLzA1ZIQq0Ib38IiL4e/iLmkd4i19SJ0NbxBSoAFeu+yC5vWIHkyx217RmFKR0LhIjpfMKUY0ttwNTU8v1n0zPQVbBphaqjNOyJK9+MPIDr8tNu27WN3xALz7gYGZm4DXJvjJn8LFYOZjgeDjot+IhfKuWR0xP3eXxjcpI1QtAHn9CjIb2xzvjItsO0lGX+6AFNCCaO+KwmpTKDa/JvBx7Gp6YOMeGrKsK8j4L6ac2AgXAQz0aHqdc0v5TrG69IMTh6WwoaOfgnaWrD8RicBariwBPe4LdYSiEL+ttDq11ccabVQt2IIrH+gPaw2RzwG4Le2LKX290koQGhg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=idycEckcr4oa7t42lFd2XxOLcI8deGKjkgpKUBigHj0=;
 b=NzmrYNyZQrwD0nVDLtn3wIwZLHyWy/U7WzosHfXNY1L/eskmnwY2Ok/Ak3ArYv/l1/pbX02PcrcLFXBArFKfRbT/H5Y0mh+6rrdSrqwY5zg/WT77gpJCqpYYmTCThgHPtDgEJ9wEI4S+K3Xau9JUJCMsTMvh+ir/48W9/aCKc8A=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5024.eurprd05.prod.outlook.com (20.177.52.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 12:55:17 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 12:55:17 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/13] mm: remove the page_shift member from struct
 hmm_range
Thread-Topic: [PATCH 07/13] mm: remove the page_shift member from struct
 hmm_range
Thread-Index: AQHVRpr/I9wxeKeChkuG0OEJhB2jNabjHtYA
Date: Tue, 30 Jul 2019 12:55:17 +0000
Message-ID: <20190730125512.GF24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-8-hch@lst.de>
In-Reply-To: <20190730055203.28467-8-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YT1PR01CA0003.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::16)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b4bc70a7-fe8e-45cc-c196-08d714ed2be5
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5024;
x-ms-traffictypediagnostic: VI1PR05MB5024:
x-microsoft-antispam-prvs:
 <VI1PR05MB50244A1B80DB3F5AEDC14A54CFDC0@VI1PR05MB5024.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(346002)(376002)(39860400002)(396003)(189003)(199004)(7416002)(478600001)(66946007)(6512007)(25786009)(6436002)(4326008)(36756003)(6916009)(6246003)(64756008)(66446008)(229853002)(81156014)(81166006)(8676002)(53936002)(8936002)(66476007)(66556008)(316002)(1076003)(6486002)(54906003)(33656002)(6506007)(102836004)(386003)(186003)(26005)(14454004)(446003)(305945005)(3846002)(52116002)(6116002)(68736007)(71200400001)(71190400001)(2616005)(2906002)(11346002)(76176011)(7736002)(99286004)(14444005)(486006)(256004)(476003)(66066001)(86362001)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5024;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 seS7Jwz+4z32gUu+IFL61rNNu+NyGMH2Zs2Rf82smPQvpQy9H0CfZVaRqXr2MNgzZLbpq/INxATsAMro+lA6s8JjXpPAml31L1SEoBtlYsMF2hB0rurCA1Wuz1vuR9LNXV0fcdanov+QuCkhbWRE+KKVf2ZesEStQf9a30+mO7U60dImwGOKZgGK3l8ojvmVuMiNkfPTAzzips9kGS/xb17byj4kxFARlPPRKTKBZxeeKotyP4FZAzRdzK9eo2ahoclqaKRWatS0N60FENE9LENjgj8qHzrUXvuqN2uNKcRjmbm11ORk2bGCnV+vAqNx+XlfIjhroVYnOn7VhJrINfjkbDt0x/77qru4+FoynSAef7UYQp5oI/AAOeLuyyFaKzupYGwVOUqvm87oo50MdiGU0K/f5M7hdp0YmDndQ+s=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <B20876FFD0ED7E4A83072CECCE1E8BF0@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b4bc70a7-fe8e-45cc-c196-08d714ed2be5
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 12:55:17.4155
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5024
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:51:57AM +0300, Christoph Hellwig wrote:
> All users pass PAGE_SIZE here, and if we wanted to support single
> entries for huge pages we should really just add a HMM_FAULT_HUGEPAGE
> flag instead that uses the huge page size instead of having the
> caller calculate that size once, just for the hmm code to verify it.

I suspect this was added for the ODP conversion that does use both
page sizes. I think the ODP code for this is kind of broken, but I
haven't delved into that..

The challenge is that the driver needs to know what page size to
configure the hardware before it does any range stuff.

The other challenge is that the HW is configured to do only one page
size, and if the underlying CPU page side changes it goes south.

What I would prefer is if the driver could somehow dynamically adjust
the the page size after each dma map, but I don't know if ODP HW can
do that.

Since this is all driving toward making ODP use this maybe we should
keep this API?=20

I'm not sure I can loose the crappy huge page support in ODP.

Jason

