Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8355CC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F8592184C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:53:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="TzITFv+4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F8592184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74ECC6B0003; Tue,  2 Jul 2019 15:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FFB08E0005; Tue,  2 Jul 2019 15:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A0118E0001; Tue,  2 Jul 2019 15:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB796B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 15:53:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so31991edw.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 12:53:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Ux79kayW2/oD3UIytvFEMfepSZQDjLhXcIU5Az4AZnY=;
        b=AhnGRRvf/983dBzmK7EM1SkV4JJx30O7Az/YxkTn5RjMKaJ6IiV/II7ltzdmJTR1+M
         4uVV6eehHk5Ebd7EeYFOiJa3vVYA4kbrO051Ndvcq/IhE2cibQHFW8fLVMBdqS1wZmdf
         DbXR7EiKKk3VaDR3gGQTishUu84S/AnyG0q59H24C6YA5ndz4kKXx64Y6QYcG58nQCWw
         IkGob11lwOSSwAEtN6ilwMtpjs4UhnM5hx5W2Wx/naozGRCKt0Epk5wXJrJbhJtKSsHN
         InV1Vwr3T/prgqKySJzMtczRH3fT/1Ib4z+UyXCpqVqj1DL9NroW8AsU/rrh0bh4hdh3
         bydQ==
X-Gm-Message-State: APjAAAWoBY/wvtFlnFch7VgS/cvvZdO30h51H7NN0WvX5bl+zuhYBXIp
	6ckvLV4YzjY9FG3JaY9z29Uv4BB1YSEPW51snE8NDR7JJg/zskWI29SYlazOBpFqVnSfLEkz/F3
	KK3BbxtEK4udHO1VMoUjGDxWJg5tQLqKLqbYhpQ5L2zTFEZWVohRgEz2i7B9PFvfyVg==
X-Received: by 2002:a17:906:418:: with SMTP id d24mr30601700eja.258.1562097206387;
        Tue, 02 Jul 2019 12:53:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywpK7YENQv0/5aHNJDmTTJ/OYK7c4uDrmZ2GNwoS2HQZKURC/OK7V9aSyruyNx+1Isl61P
X-Received: by 2002:a17:906:418:: with SMTP id d24mr30601653eja.258.1562097205589;
        Tue, 02 Jul 2019 12:53:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562097205; cv=none;
        d=google.com; s=arc-20160816;
        b=lscUeLU0YbCgohQY9Mtw3TDAPhpFP7Zhy3IkjCzUZkgK79NxtTSE3XPLtHOBwjnYxT
         Po5uz4AmtXr4v3bjC8Qt/Ndnl5gx+QV6PbUKlZJYCRzcwuBYO1QJTqZLUlt8OuF7QcrL
         iqLcAmzxwQbzm1EaEXeoRD//lQdgJccN6qvKl95THDGE2Pc4oJ6DYKaw3zyVCi6+33XO
         lgTmX/g7lqQqxpBK7gE24humBUQZuwVpuQTrleF5mT/3xcn0KHquwztOxrLcqAlNEp4i
         sR8TZn3ddDBl4DTnmWlu1O/J4mSieZDBztSq5xWmoRxWHSbXdrDIy2I3fruvwlwCVXuc
         cr3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Ux79kayW2/oD3UIytvFEMfepSZQDjLhXcIU5Az4AZnY=;
        b=fJfHoGT3eqXpuyNsqMPBAfImyrJFDdd+EUG0+tArlA63XwM6/YGIKGP12IsZOX5XEV
         9gHGwgSNzecrFNrpjnE5iSha10lTPnJgZ3NZP/RHW8PAZBJVscJY0SpuOUEmmewM5wjr
         CFAkZulloFu1P6AsURhnSjWvy3ZptUFuF8K+rLuYT1TPk6JV3l+XSxjQQ4xsCkoEgrmQ
         Fk2OPo9nBe4vqVl5qXddB7JHTNIsLBWDH5pKbPv7B3i/59+JFp8D3Waa2ppVAHeSSM1K
         AOr45k6m3M+0lqeC3W/8iGrk/jjsB8VUTITbcxoXuEX129HPoG+IuzejGdJsb1t1VWua
         k06A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=TzITFv+4;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.71 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70071.outbound.protection.outlook.com. [40.107.7.71])
        by mx.google.com with ESMTPS id n17si9321854ejb.18.2019.07.02.12.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Jul 2019 12:53:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.71 as permitted sender) client-ip=40.107.7.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=TzITFv+4;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.71 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ux79kayW2/oD3UIytvFEMfepSZQDjLhXcIU5Az4AZnY=;
 b=TzITFv+4DyhvRhIxaLQQBj41KHoDH5qvHNYfiLEhRPXbOsbprQQ4S62EFM+WOzO4Ty2BHdG2weYdRAMWeNzIdjud2VGBYREm2sDpStENTFwTmDcEJS8fTFsNf4Tgt7XVX1aKfj6z7thdXDGP/zqmlDm5A8gAIgPWFw3AVWI8+LM=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3407.eurprd05.prod.outlook.com (10.170.238.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Tue, 2 Jul 2019 19:53:23 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Tue, 2 Jul 2019
 19:53:23 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>, Christoph Hellwig <hch@lst.de>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Topic: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Index: AQHVHY87cnj6rYaF00uB6DOqwK5J5aa35HaA
Date: Tue, 2 Jul 2019 19:53:23 +0000
Message-ID: <20190702195317.GT31718@mellanox.com>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
In-Reply-To: <20190608001452.7922-1-rcampbell@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0044.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:1::21) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 91a8010a-9074-49f6-5f3f-08d6ff26f0c7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3407;
x-ms-traffictypediagnostic: VI1PR05MB3407:
x-microsoft-antispam-prvs:
 <VI1PR05MB3407FA9099031BFAF148D2AACFF80@VI1PR05MB3407.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 008663486A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(136003)(346002)(376002)(366004)(39860400002)(199004)(189003)(5660300002)(64756008)(99286004)(186003)(4326008)(14444005)(6116002)(446003)(486006)(3846002)(11346002)(256004)(2616005)(476003)(66556008)(66446008)(66066001)(66946007)(86362001)(478600001)(73956011)(66476007)(25786009)(33656002)(81166006)(81156014)(8676002)(71200400001)(36756003)(316002)(8936002)(68736007)(1076003)(14454004)(76176011)(2906002)(6486002)(7416002)(4744005)(102836004)(6506007)(229853002)(386003)(6246003)(6512007)(6436002)(305945005)(7736002)(71190400001)(53936002)(26005)(54906003)(110136005)(52116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3407;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 zBxzoHUx6jbzlZVkFi+e9m2ovvrNdaF57cJAmrQAUvgjIc6VJWidnpqjL4pG/tkQmzUsCr7Mq9zVT7UzNR3O2N6Nv3Yf/MjW7a8oJzadNJSd4AUiEHBtZblxxiz5C/sRvynk8tL8tF1ZsHnezKa/o5OlHLwVbKgTMd7q39KsEwv4ydwePbs9Y8eKhKkFEy9N8YSK5zOzEYuQ3WPQwt90wpHla8W8GVTj49LdyWlW5e5GCY25ZluCcCc8SgyivlZOwZBnf8sVRvyEWcEgiEAgpf2EWgFtDcmcZFb9DTMRqowHqVXg6D5JHn9S7KkpJJC9YoL0SDrfVxhT4n8w3YnRqkOLzq4t90pVh07KsDZm0QPQV6v+/qm3NtjE3lcMLAsAm5TiWNJVSJXEL1Q/bsj04Xqw5jdAWprPdD2oBSedE+E=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9EEF795A80FA1D4D8BB871FDEA45923F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 91a8010a-9074-49f6-5f3f-08d6ff26f0c7
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Jul 2019 19:53:23.5960
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3407
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
> HMM defines its own struct hmm_update which is passed to the
> sync_cpu_device_pagetables() callback function. This is
> sufficient when the only action is to invalidate. However,
> a device may want to know the reason for the invalidation and
> be able to see the new permissions on a range, update device access
> rights or range statistics. Since sync_cpu_device_pagetables()
> can be called from try_to_unmap(), the mmap_sem may not be held
> and find_vma() is not safe to be called.
> Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
> to allow the full invalidation information to be used.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
>=20
> I'm sending this out now since we are updating many of the HMM APIs
> and I think it will be useful.

This make so much sense, I'd like to apply this in hmm.git, is there
any objection?

Jason

