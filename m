Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96298C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:12:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 444112133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:12:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Z1jEVJMZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 444112133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8B558E0007; Mon, 24 Jun 2019 09:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D14E58E0002; Mon, 24 Jun 2019 09:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB5ED8E0007; Mon, 24 Jun 2019 09:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0088E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:12:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so20457574edb.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:12:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=bJKNsiWuopGsFiwJtfSmHwT6t9upZDeCWjBmCmeA7XQ=;
        b=eHsjLpAf8nMpBiDVoQIxSaEzfd23giCguIM/idBI3FpUZQ4D4/DIEnNlj6q4gXgkb3
         jM/cOSfBoPcqVtIrAGGFlTsMtf1CjlIj7KDZ2hqEiLosfsE6iNUZAxWcosWWMmg5lf5/
         re8QlDv5w5H233c/3ecYOv8pH0xLneT5rN0L/ecj7BecB24keSdAmGQtdDEo9H/eG9ME
         v1ysE8w7i6FMlYJ31VXlHHD7niW9/gTd7PcfBPu6Jl+aX76waSIkdxOv2uy0Zg4ut1Lq
         SloMqTjA9978OYnThMLf2pBQD8lGhmHu5vPVHhspZgZqXZv+E5euI26Eys5aoHLZnwhd
         mh6w==
X-Gm-Message-State: APjAAAXOMW55nAJsxGN7CHnGZPDYBINFWCeiZL1DPcWLu0riyakCPU+J
	vJxbx//0VGYJlT29MOnmpNKAVWSj/a0UXLVlyuv8CaBUmc+G4mPWc63Wu57K8iVOEadN0Xq16PM
	l/In4uKfkgk5JsFvL6Dx5dQPk8tRE6Skd2/pAxcV9ablPzl/TootxHwca1HR9Pi2PLQ==
X-Received: by 2002:a17:906:948c:: with SMTP id t12mr14395751ejx.222.1561381955026;
        Mon, 24 Jun 2019 06:12:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJ7SyZqAZkwho5MCfIqiA3uIYmeI67yNPGOTGefGuDkfnJWaHufUsCY+8qjct5Yqj3UGQP
X-Received: by 2002:a17:906:948c:: with SMTP id t12mr14395688ejx.222.1561381954394;
        Mon, 24 Jun 2019 06:12:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381954; cv=none;
        d=google.com; s=arc-20160816;
        b=wIHcCWwxzam5Acu+MtBpXnk4RAlxNbkrkQK3mLzJG8/zE4DBjUfntHrR4SdFXiJwC5
         EY6vZPvurvvmWd17lK5bb+puFbn84Rw9YZf7WBQw+k3LnbeNodWagzLkzse2FTjcW23i
         8B46TCLBwfEdRNyVOlnEhtjVzyrTuH2IYHD2G2S0Lf26ozT1lzrULEBFVjIa6L6m5qOS
         nMzDGofOrF45vbwa8/jgKkbWFfMxJTs3ssmjR8CC0nqdyLJyIxEc2XFHXozb+zLz1SQ+
         HMja5K4mxqQ4As5PTMfq7bcUSRJj4J44Lp4flh1rbGaUF2/WnOZH8u1Qo5mNmPKP6Us+
         FJRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=bJKNsiWuopGsFiwJtfSmHwT6t9upZDeCWjBmCmeA7XQ=;
        b=lnFtnvBdYfb5kEZX7QAHvw93q7lZH6p6CxLE/B/xCQN3mVlqY2LnvvLkduS0fIC3+y
         eG9RCmP+sQyvoD5BeSfelK1fZYa4RjX3vNdGMES/DXgH1a4hbQ7DWza8MtwWf/0fq7a3
         5TaEh2tvKz07yf0KC0Bgj6X4rQDgw9sqAkvGPTlF/v2upkMMCeqhovl3kXmDx17xeo76
         2znICLBDBIV7amuiXG/+GOII6YXIGxA5jDC3LjI/Fu1fZXT0uNhWSUjz1meBPwVTI1jZ
         2klZODKqERL/ZX8SdUAG71Q7syjowWOLbPvfQM7c+1jYTnOo7saspjxaAEvFAeV+zJ8o
         wpfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=Z1jEVJMZ;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.65 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50065.outbound.protection.outlook.com. [40.107.5.65])
        by mx.google.com with ESMTPS id i45si9121841ede.94.2019.06.24.06.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 06:12:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.65 as permitted sender) client-ip=40.107.5.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=Z1jEVJMZ;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.65 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bJKNsiWuopGsFiwJtfSmHwT6t9upZDeCWjBmCmeA7XQ=;
 b=Z1jEVJMZeA2aVFeQjyVX7/o4DJ+7JCvRf4WB7j5DitZp9Eec4o34k6ZMPdBc8DRs9251E7fBsr40IgTR+/qGaLd5Ce2yN5fUuin90BVN/A4n61Dlhc8rIJpghdvWQbcEo+NvAKhD6BjynMtbuzDfvbufD3a3XZFwNSOsl4cwFyg=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5662.eurprd05.prod.outlook.com (20.178.120.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Mon, 24 Jun 2019 13:12:30 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 13:12:30 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ajay Kaher <akaher@vmware.com>
CC: "aarcange@redhat.com" <aarcange@redhat.com>, "jannh@google.com"
	<jannh@google.com>, "oleg@redhat.com" <oleg@redhat.com>, "peterx@redhat.com"
	<peterx@redhat.com>, "rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"mhocko@suse.com" <mhocko@suse.com>, "jglisse@redhat.com"
	<jglisse@redhat.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>, "viro@zeniv.linux.org.uk"
	<viro@zeniv.linux.org.uk>, "riandrews@android.com" <riandrews@android.com>,
	"arve@android.com" <arve@android.com>, Yishai Hadas <yishaih@mellanox.com>,
	"dledford@redhat.com" <dledford@redhat.com>, "sean.hefty@intel.com"
	<sean.hefty@intel.com>, "hal.rosenstock@gmail.com"
	<hal.rosenstock@gmail.com>, Matan Barak <matanb@mellanox.com>, Leon
 Romanovsky <leonro@mellanox.com>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, "srivatsab@vmware.com"
	<srivatsab@vmware.com>, "amakhalov@vmware.com" <amakhalov@vmware.com>
Subject: Re: [PATCH v4 2/3][v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Topic: [PATCH v4 2/3][v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Index: AQHVKo0oRBGkKYxOxkqZ7SBtAl/moqaqx9UA
Date: Mon, 24 Jun 2019 13:12:30 +0000
Message-ID: <20190624131226.GA7418@mellanox.com>
References: <1561410186-3919-1-git-send-email-akaher@vmware.com>
 <1561410186-3919-2-git-send-email-akaher@vmware.com>
In-Reply-To: <1561410186-3919-2-git-send-email-akaher@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: PR2P264CA0011.FRAP264.PROD.OUTLOOK.COM (2603:10a6:101::23)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [66.187.232.66]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1279592d-f3e3-4d7c-f79c-08d6f8a59cb2
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5662;
x-ms-traffictypediagnostic: VI1PR05MB5662:
x-ld-processed: a652971c-7d2e-4d9b-a6a4-d149256f461b,ExtAddr
x-microsoft-antispam-prvs:
 <VI1PR05MB5662688FC277DCA3E4A171D3CFE00@VI1PR05MB5662.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:407;
x-forefront-prvs: 007814487B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(376002)(346002)(136003)(396003)(366004)(199004)(189003)(5660300002)(478600001)(6506007)(53936002)(33656002)(2616005)(6486002)(81156014)(86362001)(14444005)(3846002)(256004)(8676002)(81166006)(7736002)(229853002)(2906002)(446003)(66446008)(11346002)(68736007)(6916009)(486006)(66556008)(66476007)(36756003)(71190400001)(71200400001)(476003)(73956011)(99286004)(64756008)(66946007)(54906003)(76176011)(6512007)(102836004)(1076003)(4744005)(52116002)(386003)(25786009)(6116002)(6246003)(6436002)(316002)(66066001)(14454004)(4326008)(7416002)(8936002)(186003)(26005)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5662;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 40jUzpU9CguJn2eIvgacEOcIi2CYrA0fIWmsrZEo49I+3EgVJp2pRrgkltjExJd0cjLBr/ZjZlNwxkj3odOMuDp291oxCEbrf3qoTyS3t50EwIjNffVdqGTeH6SCwGNP75qu35Wfr9Fgt5LrVmv2KNlC0hj671ZjeDtCZGFuGl7uZoYiJsrZdi4d6ionXc5Hiw4AyN1GqbfMpsRhTIk04KKLL4BQOMw0SERrzFPOOZ3ElIE3NiCP6fv0/k+bGED0ir5nSBe1nGavp8idteCEzizj2yiReEGiw+Jv1jpp3+eI21DhvKqarSVs8wjJQAGdjWFsi/LMX1xvw6PCN8mBZivSW/3TKHejjD7JWQl00Jp9rHUnCy4wwss0fSFbTacnV6ybN+BzydI38iRxeDsA2x+8r0/iw5rWc1H41b2zd7M=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <626B17CC09D07E449465C19358AB7DB5@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1279592d-f3e3-4d7c-f79c-08d6f8a59cb2
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 13:12:30.5998
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5662
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 02:33:04AM +0530, Ajay Kaher wrote:
> This patch is the extension of following upstream commit to fix
> the race condition between get_task_mm() and core dumping
> for IB->mlx4 and IB->mlx5 drivers:
>=20
> commit 04f5866e41fb ("coredump: fix race condition between
> mmget_not_zero()/get_task_mm() and core dumping")'
>=20
> Thanks to Jason for pointing this.
>=20
> Signed-off-by: Ajay Kaher <akaher@vmware.com>
> ---
>  drivers/infiniband/hw/mlx4/main.c | 4 +++-
>  drivers/infiniband/hw/mlx5/main.c | 3 +++
>  2 files changed, 6 insertions(+), 1 deletion(-)

Looks OK

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Thanks
Jason

