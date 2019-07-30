Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD019C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90FBB2171F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:51:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="IrvS59OJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90FBB2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30F658E000A; Tue, 30 Jul 2019 13:51:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E7F38E0001; Tue, 30 Jul 2019 13:51:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AFBE8E000A; Tue, 30 Jul 2019 13:51:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2FD68E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:51:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so40805109eda.2
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:51:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=/KjY/yC8kVyH+j5gcW/UHDvZ9CpGjyXs5jJmgc0/gx4=;
        b=CNyjl0+sKUbja3lIFXbImKLIESoMlXyNe1NXZ+ZDHTlUE3uZPCuFCrjQd2hgjAkgTL
         DaxVzoiW9wFsYSROAvoOv7O6cftYhX1s0yiSLBMAHitYEZLweC5TzC53rfZPSKCsUVZy
         flHLYJFLm61o2huYl4tVTupyQ+/xFz8OM4MWjcsVI55examcGL5kmPI33p4420wKYMNX
         XBcsQN5yXTlZtpY1YmW4Ge0afesPwuIGT3MKjtFCd3rsuR/hkYLditVjW4ox3laAyTWA
         57XeAmjT+//dU3KSZtJtFREG1ckj2kTtN85iViEXc1m4+WhnLbixuipyrqaZaZbJDrx3
         Yukw==
X-Gm-Message-State: APjAAAUUo1hjyijDj6C18GmBv1phkPVlbfeRmV2e85e4lrHAS1lxWZkw
	F8G+QhhGI6aKMqFETDLnF+Yfciv9oPJDJtW8eNggqWbTXBwmwVmM6TcDaQK1JZsu88TObahK39U
	uGcrEw6siXWMzeZvUy0X85lS5kLLqGUuWnDwk7xe2WOgs6ibBkLVA6amE5HhWdEo7fw==
X-Received: by 2002:a17:906:45cb:: with SMTP id z11mr91046254ejq.254.1564509063366;
        Tue, 30 Jul 2019 10:51:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdRUoHUVCg4R1xVqZvT6D+4mn/MQb7yoReBRgQcXx7u9ZKXG4wfaMFwCyrtyTxVITWGKAW
X-Received: by 2002:a17:906:45cb:: with SMTP id z11mr91046207ejq.254.1564509062592;
        Tue, 30 Jul 2019 10:51:02 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564509062; cv=pass;
        d=google.com; s=arc-20160816;
        b=oaQpAPpILlbe1jC8lP9UGZHXqHdW+/QFlRP+ChH4iElMUkWJlk5SaAEhwWcEORbjuF
         q3MU3NgS3HBBDkBQ6sofqErcr4nX/J6hj0pZi4o+MvGzJten1BOYDVpgzqHaS1NV+gCr
         nTRdH/33ZywcJUQSvDu+c+E7TAgNv4UuNsoPukTWekjfWejBeuoG2ydZiBAT9coHs2BI
         S9z5N+9mje5kL6R2RCobwdF7tyCwjFSB8PL1pGVzjjKPWhwdHg0z9reCfBCu2iBk4GLc
         HkAPLIKyqzZCtkarRTWk7pG1M9ZqLCRvdk9fLDmokUJ+GmkYJitbgcT4Z7/zAq84CcNe
         Wr+Q==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=/KjY/yC8kVyH+j5gcW/UHDvZ9CpGjyXs5jJmgc0/gx4=;
        b=RJmbp6ZVogqbnL2aDhDOdWZsdPkX4qwZxAcTfmsbWSKpVtw54gqqKtGT2tsz2U6rIS
         zUi97MxVDyqCFVYuJvUiP8mUH1MCtRg+KMQsuWnTKVO9xtoswoc0UX4NOwQmdMCK4i54
         SqqJsQCoD2B/Oix/HHnlhHJ4f1QKC9xe33hCuCbNCdZfv5P7daqqRi9oF9ZYTIHfqZaB
         OnlJljFooikhgIcE19iCqEgjC31ib6NZumherHPJemc7yTW5S+lN6qeKHjtKnUbyONgh
         mZWfifWe4Guu3ogbuZHeJCnpHdgvocsmHW+hM6JqgtXtfm1Em6vg83Do4tpcBbIQlgIq
         82Iw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=IrvS59OJ;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.50 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30050.outbound.protection.outlook.com. [40.107.3.50])
        by mx.google.com with ESMTPS id m12si19798289edm.38.2019.07.30.10.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 10:51:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.50 as permitted sender) client-ip=40.107.3.50;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=IrvS59OJ;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.50 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Q2QKTNnl160fMAn+A2zB8DLIAAPUharlccNW4clMV2xgW5EjuoAECBzKHtRIXDVlidkgVwnnriOuaBwJZTuBuX54ATVvsXysgscGXa8AZUnLRgTFD/MTWCZdG+anQJ23wDF9jGPZW0iAWr1P50vkj9rBHwzdk2trNfULuqyxvY0F2gm/e6MY7X2/JQqaCFXkFhsMshq7MrwYJlHp85vt9VDNNO4DpP3+eCYx9W8ZqDPPX1BJ0lToYkX4dIR0T+Kw/0DdXwUYIcINxTfNfyHKfENYd/fVvr8rmYbxoxvyP6Qb9u/QH1VvJmLDnFMNIe0f65LmWFpx/LXtMC4gvWRXdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/KjY/yC8kVyH+j5gcW/UHDvZ9CpGjyXs5jJmgc0/gx4=;
 b=TzW0KqiIJI33Al4SaibzPqZN3r8gSAnrkGx3Ii8RS0h68+a0SHDtH7pA4aKmLrv+kRr1GFsQk6t2NFOVvy984gYXZlW6+AQSU4InA7EFqNZqb+5yKqaTNYaNnGlbpsw5WbBiwhApyKtjNwcdNB7XBCwcj4l++hLHNt3yobJtjuu/+F+kfBcexG9kVBn2PL+PUZW3myhjp5tNCuYIrSQm9EGMXAqU0idbo6bvPfbzb4ss41kY3H8TO1bS6+o7Q+AFGE5qd2JswIPauVF5gO88ccAYDeSrCa5TBtX5wKsvFvbSk3uUGbShUXBdnu9VbnCos7fBkvH/jbqc+FTY3wOJrw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/KjY/yC8kVyH+j5gcW/UHDvZ9CpGjyXs5jJmgc0/gx4=;
 b=IrvS59OJ6+EU30qcaRHjPR14jlrmqJuU20QwskP/uboxi+KzHEOipU9ifbudSO7Ov8AQpZkGsdpnailxXllkxQ3PJ0zKpcABto7E/amxebA9z+DIhbqqGuXCLULPYvWQ+iytAhDv3WTmUaiabTfeVA/jxjFfBS4hbU51AgILEnk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6414.eurprd05.prod.outlook.com (20.179.27.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Tue, 30 Jul 2019 17:51:00 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 17:51:00 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/13] mm: remove superflous arguments from
 hmm_range_register
Thread-Topic: [PATCH 06/13] mm: remove superflous arguments from
 hmm_range_register
Thread-Index: AQHVRpr9/FZ6XgBWJE+8PzpxS1FzbKbjcXQA
Date: Tue, 30 Jul 2019 17:51:00 +0000
Message-ID: <20190730175054.GM24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-7-hch@lst.de>
In-Reply-To: <20190730055203.28467-7-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0113.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::42) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f2d7873e-cfc8-4307-a032-08d715167b62
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6414;
x-ms-traffictypediagnostic: VI1PR05MB6414:
x-microsoft-antispam-prvs:
 <VI1PR05MB6414E428DF939EAB5E7C56CACFDC0@VI1PR05MB6414.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3276;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(39860400002)(396003)(366004)(346002)(136003)(189003)(199004)(386003)(2906002)(4744005)(66556008)(66446008)(64756008)(76176011)(478600001)(486006)(1076003)(86362001)(66946007)(71190400001)(7416002)(446003)(305945005)(7736002)(68736007)(53936002)(66066001)(6512007)(2616005)(71200400001)(6506007)(11346002)(476003)(66476007)(5660300002)(81166006)(186003)(52116002)(6436002)(6246003)(256004)(8936002)(36756003)(6486002)(8676002)(3846002)(4326008)(102836004)(229853002)(25786009)(26005)(316002)(81156014)(6116002)(33656002)(54906003)(99286004)(6916009)(14454004);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6414;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 oGqTfihmFWyR6Jc7iEDNs/zpMBvNH5NewEEORd+ZwZvfR2usfjPIE/pPisx2SBbhRTFGTnOvVO/qZd6+3R50nJbDl1mscf5D0nT2lqedq976bYIQ37awGumYeyH3LBuWXxZuWf03EKAgU3Wqc4yofoo7d1A+QO9jKReeCIRCy1Iv7usEBjlhENqpjgosD0MrGnBFAfcFosi9sJ0d2Od0QCI4kjJnmkl4tnsmMU42CWj8M/Yk/silWrWgiJG6kzWw+Xep0zp1HgJ+CUtrgJt27TwaI3YE98POUAd1dvA9qlIpxvZ96VIZ1TpqrAbZuiIN/0gMg/3fs9uL1EXsuv44lxJ6sMv4y65mmhK5ESuFzD79YT2XXfWBRygyrIXvCdjzCB8tb4S4ceo9gYZpCcQ6lJVIb+r6gUA8ub8SojkfAws=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <2ED0ADD6FF332141A54123A43AF61452@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f2d7873e-cfc8-4307-a032-08d715167b62
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 17:51:00.1408
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6414
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:51:56AM +0300, Christoph Hellwig wrote:
> The start, end and page_shift values are all saved in the range
> structure, so we might as well use that for argument passing.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/vm/hmm.rst                |  2 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  7 +++++--
>  drivers/gpu/drm/nouveau/nouveau_svm.c   |  5 ++---
>  include/linux/hmm.h                     |  6 +-----
>  mm/hmm.c                                | 20 +++++---------------
>  5 files changed, 14 insertions(+), 26 deletions(-)

I also don't really like how the API sets up some things in the struct
and some things via arguments, so:

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

