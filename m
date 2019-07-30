Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B56EC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:45:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10BB920693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:45:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="lDS1eMZ7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10BB920693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B23028E0006; Tue, 30 Jul 2019 08:45:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD22A8E0001; Tue, 30 Jul 2019 08:45:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 973368E0006; Tue, 30 Jul 2019 08:45:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9888E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:45:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so40237792edu.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:45:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Y/7vNZNyn0FFqNh/w4tptPQMmYuaBbYryJLl0cm5OSs=;
        b=affqS7G0HG7MhF/b68uFFsjL59dt8nI7jVKkYvHlRL1WOBuoVYmZMkQBwF3DXycTLI
         XtoPOHBp8h6vZNGyzNwEFw3Zcq5iCeY4y6hbPrkPHq+re51DR7LiafY73PfbJdAGFCav
         D/kIyMq1YUPpCp8PtMPSYycl4DDfPtmKc1/zwuq2igbOGDj3dCLqn1SyRuENh7HJybWW
         gdFXP40HYb+2T6JmGUxyd/yY6D4W0Wk1ydWeIDMLY8xf7kOHjC87IYBtYZwWdwT4eNT+
         /+eIkfb0SdW5OCu9+6ueg8ckHabwtVTz0flF2hzhjfss2nHF5UHSXV3EHU7H5UHYGCEv
         FC6w==
X-Gm-Message-State: APjAAAXcG9mGIbnuSURRycYm0Dmc4DiUosLGYwANNQcjga4ihKWGho6L
	lU3Tl7iaFmqOLro/nLIGap4SZwBts50TkZk0TG5WwG16HtPjDOglg0yhKL4WpvcprsecHiNZUAd
	zUu8VipKvHi0b6k42OfWfCTCkD3i84EjWqWH6NP04LyvYXLLQkaW5KCKT+fSBQl4nNQ==
X-Received: by 2002:a50:982a:: with SMTP id g39mr100610913edb.88.1564490725876;
        Tue, 30 Jul 2019 05:45:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXs2+diinZCBE1oHkOozU4BHYZkeZ957EScOytyzVsbe2PuEDPUgA6UHiDx91Cm6cDy0ak
X-Received: by 2002:a50:982a:: with SMTP id g39mr100610816edb.88.1564490724643;
        Tue, 30 Jul 2019 05:45:24 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564490724; cv=pass;
        d=google.com; s=arc-20160816;
        b=m0o2j9xn34shkk8+KHg0FXQIK4mo98ZUOaHzdMix8FrY3ulELg79EAkD/Gwdtt3olg
         b9ukxvek8dKI/BTMVE2OXmbYkJlojMEULfHbEx5RMAwsi4NFXyhXtHRWIlPIfYVz5RZ9
         DNIOJ6NsVXsp6BWc1x2HRR5Fz0164T4qOTDFgKpcXRZ853vnR8L8SbN6+BBHIR6cfgpZ
         Ztg9Y5/j/fxatlNz9OXc+IQqc4s+FCdfbdepgMYsOBkGoa1FoYGSh7LaZNgRvjjY2aUs
         q3fvVqt5ZS5y7RL2wRnDh+0Q/ZU8vwE9+fhRhjfvZl1ZqIc5r4m9EqUw6EVnIjrJ0jeT
         ZLwA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Y/7vNZNyn0FFqNh/w4tptPQMmYuaBbYryJLl0cm5OSs=;
        b=0WjqD1L3FCc4LImIpNurVsLBU5ryE43n3KcmzLuLpM70hqOi8CZcZt2u+mpQhGzm7h
         mGQvecm1B3f2x/TYSbIwsPdqB+MvPQhBLELXqJzIFTKYwkGYXce9kH0d0SxnO8dfykul
         xP+w2+XW7igpIEMvZ4SAGr8UkbwhyYaCV8VuzmLNHiWxSvZM6DtDoatLo7sz+dHbjtwx
         4uyct/zdJq7vsEjcizu1itZkUSOa2rkPBm2aO5Z3gVRcDv8VORBIJGov9pUh+ERD2dqN
         p/VYvNLwkirbMK38iof8/gkCUfBYZ+S3kuGB+eyDIoDs9DegWV0ECspApqGG3UJIercL
         rRiw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=lDS1eMZ7;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.52 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10052.outbound.protection.outlook.com. [40.107.1.52])
        by mx.google.com with ESMTPS id qc1si16405608ejb.59.2019.07.30.05.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 05:45:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.52 as permitted sender) client-ip=40.107.1.52;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=lDS1eMZ7;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.52 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=hnipSeZ1TwdqRUp/Ibef4dS5jP4UljSoyudXEEnO5tgaImHr5lHsIyRedQcyMBX4XFrMqlQiyFUI00wVe9BAzpPYSlT088BMtOdnd1SkKYI+OsrUYrqtVj7z463YpjoRkuFVlo4JMhhweqRD0o7dNbT5ZoKWqa/uncOmFLsKglUlhcJTTRsDD4pgxVaSzZ+H7ZWTfj6/zEHjwBugMFTYhuB89Luxl0Hvcybx5u34w7FxpS8RhR5yIvWgdLwuRPVeD0d7jc96nX93WBdFwjMvARTSdCUsSuY3s8XAj6xfkpLKVsN+R7oTMp+rsLJb9hHTLsGvlxNHPH4hcAgiR16qqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Y/7vNZNyn0FFqNh/w4tptPQMmYuaBbYryJLl0cm5OSs=;
 b=GR8k4UpgU3efvLqhu8oP2HbayFELnTVwG7NIIG4dElgbsIoYa1tcvM4x6Lx1X075HaBcnh16C/BJJBVERtyA0WueBSugC+NiIy5jSz3ahY2cPKPEMZPBUo8FOdc0T1zLnz7Rgc2Z8gJAhWyiVPhUxkgmO3T1m2onejKS35fizhpwlJ4U4i71dItCrpFQm43u5is+XeMS0lM16Y6DdMraawirimrv6Pbny0quyLzBc42YqaX31CI3KPQGfKobZzlNbXdKZNK62Mj+a0dUpgRr6qUNMGMTJzoasPcPJLhLbpIVqR3Bwgo+pj7G6w3oRUtav2sfiPnIN1UOtnUAvMPCAg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Y/7vNZNyn0FFqNh/w4tptPQMmYuaBbYryJLl0cm5OSs=;
 b=lDS1eMZ7JgJr9CBXo7YnbnVEURymCctyuXe0JKzpRumJW0NXHHTTxukdVIGpzSWATMvA0ypSfms9Q9IPzQ23oN7kLO0PZ6/cGnDzfL+wFUBX1YXHvEgE6fsN9eZ/hx8sKbKpSrzJho6j/VQIiU4YaXW4iMjJnmNaPiso+y9hQM0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6079.eurprd05.prod.outlook.com (20.178.204.93) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 12:45:22 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 12:45:22 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/13] mm: remove the unused vma argument to
 hmm_range_dma_unmap
Thread-Topic: [PATCH 05/13] mm: remove the unused vma argument to
 hmm_range_dma_unmap
Thread-Index: AQHVRpr6u0kOQaNySU6qr8LRJOBbn6bjHBGA
Date: Tue, 30 Jul 2019 12:45:22 +0000
Message-ID: <20190730124517.GE24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-6-hch@lst.de>
In-Reply-To: <20190730055203.28467-6-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0059.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::36) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 55501426-92a3-498b-08b1-08d714ebc934
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6079;
x-ms-traffictypediagnostic: VI1PR05MB6079:
x-microsoft-antispam-prvs:
 <VI1PR05MB60795EB36AC26291165643D4CFDC0@VI1PR05MB6079.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(376002)(366004)(346002)(136003)(396003)(199004)(189003)(36756003)(3846002)(6116002)(305945005)(7736002)(76176011)(2906002)(4326008)(102836004)(6436002)(186003)(6916009)(478600001)(7416002)(316002)(71190400001)(229853002)(71200400001)(26005)(14454004)(446003)(11346002)(52116002)(25786009)(54906003)(6506007)(6486002)(256004)(6512007)(33656002)(53936002)(6246003)(66946007)(66556008)(64756008)(81166006)(81156014)(8936002)(1076003)(8676002)(476003)(386003)(486006)(2616005)(5660300002)(4744005)(66476007)(66446008)(99286004)(68736007)(66066001)(86362001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6079;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 wApwXHSaZLo6Bej8GHUpHxofhQJqUdBaqEIIrGPYuB4TX/9bwFevZGwg5WoGakIPJh2DRaQCY1+1pqemO6g8GWj/tAV9n5OGoC65RJjgsVDRpPnMZH9FzvjI575dntSPJnyBeeAqfrsR6xbzD4DI+JYRT0jjZO511rYBO1tkL4YspouD3qDdhfzELBOdpYwc6vfJzQkP06xwQATk/C/D0MkCzu6cG9CP/Livzu7o6kHh85TvZoY/t55fuMCj3g5fWbKnLToGhgTcO4LfEJlJYRp5H8Grim9/eSB53A+OzJIHXP0C8BRmOGvAHJNBmvdEyChJgb2EvTzCmtrygnOPu2OJfclfnxZBR5JSRgcxEdH8V+wjL87n9hhnV4n/BM5kzUyUPwdZmIZLvA5idTQgmnk/2w+FJSehxJc1TEG0IK8=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <5AEF0910AD27734B9CD8F3EB448FDE35@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 55501426-92a3-498b-08b1-08d714ebc934
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 12:45:22.3504
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:51:55AM +0300, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  include/linux/hmm.h | 1 -
>  mm/hmm.c            | 2 --
>  2 files changed, 3 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Unclear what this was intended for, but I think if we need to carry
information from the dma_map to unmap it should be done in some opaque
way.

The driver should not have to care about VMAs, beyond perhaps using
VMAs to guide what VA ranges to mirror.

Jason

