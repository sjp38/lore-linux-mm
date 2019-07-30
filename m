Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07C10C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:36:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1E39206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:36:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="cC9lMLgm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1E39206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D67C8E0006; Tue, 30 Jul 2019 08:36:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 386F88E0001; Tue, 30 Jul 2019 08:36:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24EF28E0006; Tue, 30 Jul 2019 08:36:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6D4D8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:36:02 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u19so12186375wmj.0
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:36:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=O4TVTJA+gABdiNdlWD+jMmeLLVFPhepHDShRadvZNbo=;
        b=VBJFkPMEbRMHaojZoGDGXrDO9zn3rG6e1keVnAeAURnNbfC+N07j6OXSXxcm8NavQd
         wd5zU2/bvWP08eCLj4tzqn7RY43tjLl7lWlvqNIhxPvTVjalFxNdhBwoeWB9wf9nfqAk
         yeEXKyCxlew0yxSfiFOVz+cbIo7BD3JbS2GgGPj2wbTQ9XaQxRP5Tr8QffiscAP3uijG
         FIKXjH0RaCwHhM50uJZibMwE3cUa6fynkKIIQErtnHNqxiG9GbInJy87+xkJu2Z0o/Iu
         oKShhdFfThyFztj2GxUITf+fOXVrtNOTzCOZglNnlqzed/zhNLCIQAxzZ0O9rk2YMKCf
         ooGQ==
X-Gm-Message-State: APjAAAXNfXt5VgTS4+ub2FD7nubm+lWOSCcFoa3HToJX1LPSvLTr6L6X
	J4nTrWkDxYvS5UnBcYWYecn724/YfLmvsp6Av8EiUAZYtuKgYC/GoG0RMSmbjJL0o2TWNxuO2Ez
	Ba/Nmvj6MLA69BBqA8BjvEOBvVLxtx4CAKwiGtWwqV2SgSu7WrmtLAXWqdtg/dPPgng==
X-Received: by 2002:adf:cc85:: with SMTP id p5mr120328567wrj.47.1564490162344;
        Tue, 30 Jul 2019 05:36:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwLPvSKu2b6zU+oEmy9yTX1sLIYCYdPG/HLaXIdqDblB4DqW3feCDdfC8//sFUw72XYXPr
X-Received: by 2002:adf:cc85:: with SMTP id p5mr120328541wrj.47.1564490161767;
        Tue, 30 Jul 2019 05:36:01 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564490161; cv=pass;
        d=google.com; s=arc-20160816;
        b=eKOrgxDO3yTm1pFWo/JJ/u7OGLsPH/6AnsNPV9z36lIZumewktRNha/O8EoPneKG2R
         tfDzm2vid7NssgQCUIHn6J6xgenda4MJfofg7eW9abvum9INl2+Bbmt/qNol1Nj86Bz8
         pGEdjFd9+dWjUjlUFc2NOd9U4DWP7r00j3G4ni5wu4CjA6fOs1xVYtE62m+onnV837rl
         SHwvf2vF5mmptN92Yhv1S2YJHUQnjFqUvouocSb/ZKuCl4Ji10cQw89YrOgVHHNxLPVg
         aD6jHHs1/QOB8e6UkDfE9BWVZOicgbszbzSU6LRCdntR4czWn0Bgx+nsYdHxCopbf3pE
         6xoQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=O4TVTJA+gABdiNdlWD+jMmeLLVFPhepHDShRadvZNbo=;
        b=o/jCXpiV9ltFs1HU2dR2eceLGZHBUncYKR1BGF63q7ZRWyN+axI8HOTYtUAw1nzQKX
         LOu/ZVxSMZBlD/xxgYiahjl5qyAbQJIc9S5Ope0wItdmJuDDPhAHdS9Myipvpl9kRIlq
         Ymi26GV7+076PYw6EKiwwBp8dVpCb9Pva3HHGvwMn7s00Syje4DZoZJ4gs75jftReaL9
         XfJ0WS8VUwp1SImcef/D0Zs8k3qz11xajoX8NdQDlOGHActi841NoI9uu/cME6F7tM3p
         GH17TlUF/1jgMM87g+3Tf8DsdkPrDePVpho5M9HD21FHVU9Poz9cW5KIym1hg2i7LHN8
         RM0Q==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=cC9lMLgm;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.72 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150072.outbound.protection.outlook.com. [40.107.15.72])
        by mx.google.com with ESMTPS id a21si41420924wmg.101.2019.07.30.05.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 05:36:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.72 as permitted sender) client-ip=40.107.15.72;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=cC9lMLgm;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.72 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=jI5SRYAnYIijNuRmwtKcwNBZkTDnhieVRH34qMcZ4WzTdo7uUpXyMnuqnfI68UqSEyg+KZPCNP2z0TYFYNotnapVNhSpbN7iq2/D2GCXJutL0A0DDOI8dZsWyXVb0zAeQcAlOyca/sTgdW5NWkAdEVufCa6xa+b3tjliS0Z1btqZL2lGOW+U9B3LkYnRicQ+S80Q21FAMgKHUObOKakMlF5iTNZo4MKtRy3FLrmd6cwcynFRG/Ww2pJACJw0NayEdPeUybuZ+4fDSVMcr1fBu+d3Wk2JHMmZP+zqZFJ0B6EIp0u9zG9V9kGtiXRry2uLdtJm+fwKrkYlagHHP6Nq/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=O4TVTJA+gABdiNdlWD+jMmeLLVFPhepHDShRadvZNbo=;
 b=nUqBXkJuK6v7z+Hu5fwJcW8E60lrTQ/0sUegpfW9vJrGszv6eh8e6JYw5SXdDxYuApK7gzGlwqTPwuLHA0T+UF6xE6ebVpBLZHb/GIUOh7t2InSHvZd18OIDxfJU+99yrdRd2KtAt+qkRJkhyqVIky4Mlw1SM6wpcFQLG/Oe2d1BAQSZpJ2GHa7nVTUURnPkZQFtkEbQA02AMuDebI9y7kVU50LCHDiIP6LyPpcMGzimXhAwNBG3Pu5uVT7b5F3HGyCLwH9t9zpURAB9hvTQYRnv1nt7Z3QV6pyhoqE4Pb0lLsEwNF2GGR3dnpKuyAxMmqXi0/Qta61gb0Kmp1V+iQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=O4TVTJA+gABdiNdlWD+jMmeLLVFPhepHDShRadvZNbo=;
 b=cC9lMLgmA4esewA20G85rm4Y8IYUa7nrfI0s7JgmMJITmXpDAShtXEkBgfdEUgaBYJij/9Y27e/EG6Uo4FQM4wYAJouNjl62YsgvIc1qjnPH2yKu5VMsN08jcLcM52CxmVGoR1MGxZcSsQKyU2aPAhLwWI8kP8B7kIZ+myrcB2s=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4285.eurprd05.prod.outlook.com (52.133.12.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 12:36:00 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 12:36:00 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/13] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Thread-Topic: [PATCH 03/13] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Thread-Index: AQHVRpr4kL6aKlcudUqEUBBy4/lXjabjGXIA
Date: Tue, 30 Jul 2019 12:35:59 +0000
Message-ID: <20190730123554.GD24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-4-hch@lst.de>
In-Reply-To: <20190730055203.28467-4-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0034.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::47) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bcaac139-dd9c-43d2-96c3-08d714ea79eb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4285;
x-ms-traffictypediagnostic: VI1PR05MB4285:
x-microsoft-antispam-prvs:
 <VI1PR05MB4285D71442379CCEE6F90061CFDC0@VI1PR05MB4285.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4303;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(396003)(136003)(366004)(39860400002)(199004)(189003)(4744005)(186003)(66066001)(36756003)(1076003)(7736002)(52116002)(446003)(26005)(66946007)(305945005)(6246003)(102836004)(6486002)(54906003)(486006)(386003)(6506007)(76176011)(11346002)(66446008)(66556008)(64756008)(316002)(99286004)(4326008)(476003)(256004)(53936002)(2616005)(229853002)(33656002)(6116002)(8676002)(3846002)(71200400001)(6916009)(81156014)(5660300002)(66476007)(68736007)(6436002)(478600001)(6512007)(8936002)(86362001)(25786009)(7416002)(14454004)(81166006)(71190400001)(2906002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4285;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Q2KmhPGNj5HjLnOX9wOLnVhYsnoFZFzOMElEIQGQqevpRB/pG6O+y7IcfQYAN21ZMM1bvNXKsQo8PV/7BTUZMJt75GrDG8o8Ix76UrZiqRtxfcBTUTC9wdIsymwHmQfjHQz2YYg/0Me+wMfmRsKmCWZY7EwoIKoQIjfrwRLxA9XsMA35yxIOrZPa4Ire9MSa0jhyvbRoVB9eiKJzIAx2YfGX8m+K1RbnbHxOS4qGjEibdrG8gguS7MAIx4WH/gaVEusQ9tU+5RgSCggbBO/n/6YhMTOdoXZwlEC4Pr9yeto17BbWFFYb+DGnalIpxQjsozwl02R1hiyFH5G8U7as7+mTEB3A8dGF0rDFeclmJRnY2OKQMEuyJVlHS94c4zbt3l/0sWFdSDEGWh7kPK3HaFzr0ab5k65cT7g4AElZrSc=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <673CF3972C47014CA0CAB676E69F0322@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bcaac139-dd9c-43d2-96c3-08d714ea79eb
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 12:35:59.8778
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4285
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:51:53AM +0300, Christoph Hellwig wrote:
> This avoid having to abuse the vma field in struct hmm_range to unlock
> the mmap_sem.

I think the change inside hmm_range_fault got lost on rebase, it is
now using:

                up_read(&range->hmm->mm->mmap_sem);

But, yes, lets change it to use svmm->mm and try to keep struct hmm
opaque to drivers

Jason

