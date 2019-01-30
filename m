Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 196EFC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:52:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92B0A218D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Qkgm03hH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92B0A218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 681C78E0003; Wed, 30 Jan 2019 17:51:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 630858E0001; Wed, 30 Jan 2019 17:51:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D3098E0003; Wed, 30 Jan 2019 17:51:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E41D28E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:51:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so414218eda.12
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:51:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=FJd4xUozB+7alcoxw8jbCUD16duz5AkzXpB6eFOXgcA=;
        b=M+L3WJXf03vDhoQgeUM8TJU2ZkhXUEaJ7jNiOSMsk0KL3UwvIT8+JnTQVa4lhP/Vo5
         HQhe7WqVWqlJdI19+gxI52vAl46b3PUWv1DmHwrRWoMxOFy4fsWB3q6eUhM5astcj5AL
         NZ1ER0PxoTM2FVvzicmqSZwwR5Vr4LnlD3FiO1D4p/ASxqHJvX08ms1NHhVLTXQq7H+D
         6GsJgyDIVUhZ4r+8CU8muV7P4REIBVfLKNlnTjKexzFf0dPwXzA3oqr4mkiMcZf1FGAk
         GGZnVZ3VgtYiQHAQEIg/9b9QJdNrY09j87K7DpUu1vdvht3v4daMnTg04E0QRmzGYh74
         iguA==
X-Gm-Message-State: AJcUukerWs3twzhNIYp1UrPizH/E/t8xmS+YM5oPeX9Y5rjmSh+mUCSe
	nsIcjg1qWtiq9sSzqSg/GbF0GJSup6Itp6aGT0j+40esaoUwf8mldS8V1nOY9GOI13sKDIKZ/nY
	95ztYqW2QFVDBfpd2mO7nVOpeCSYTcrTyTKmVJJda6hzXGkW/rFkiRpZVa8TOqcrEag==
X-Received: by 2002:a50:ab5a:: with SMTP id t26mr31504436edc.293.1548888718482;
        Wed, 30 Jan 2019 14:51:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5U6wImyF/xGleEo7W17wVE8PEsFDcMEesLVkCia3ZE5jqsV5YFKxZT5LEgA17MQ8HrFhX/
X-Received: by 2002:a50:ab5a:: with SMTP id t26mr31504401edc.293.1548888717645;
        Wed, 30 Jan 2019 14:51:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548888717; cv=none;
        d=google.com; s=arc-20160816;
        b=qI83Ofo9O25bVx1P0axluCQPvS6oztNGZJ/PjbSVLALMHPgM/9l6g9siXK7/rm/pS+
         2hoRPNh4WlDJilyLABHU9Y2dC5/JgYYMn+rC91oGyDJwg0PXXQJoHtznpSJEQX8SKtuE
         bmUOdlQhSk4mQWNpl2taI8ZGYzdVOC7Dtt6w2z0omg6TkKmC7zkTP/GVhTbw8mc4WuCW
         u0zwZq56xuY7Z88vhXDXZel7+dZX6rk/RLO09wuU76ybzyr38GSg/+NUii+AvFtk/bAY
         04965I50GThE9QV2t9uMc6YTUMFd9D5Cat5RrUnMl245FJgZy5v7oXYnmCN3WsyUvTen
         VnGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=FJd4xUozB+7alcoxw8jbCUD16duz5AkzXpB6eFOXgcA=;
        b=XxcFYwB99VV0VpjJcvdMtWlgOMuGW7dUaoxosLFaiX6RC4+mr7pYXUWyMiLKppxaKJ
         RxPBnBD3BweWcyrE5/PUEn53MpPRWUGFU3aQnWcPHehbmMdVfYKmLkvGQ23rxMLfUyw3
         2Bd8v4SJLYEUpARKggY6T6TDZ6qKDca0vCln0/f6O77eooHTL7tlEPmbp4jZnchtbIb8
         EBmyS9JCqWKMOJFO9bj+X7LfyNnv5vS1sArDThOafxH/MOKp+J0RPEylDjZhnXrF4n8b
         BTiKTXkIbkerYvZ9muRRrbDQOftiR4ZDhIGSt7uPEw8a/rKZ4NwDn+lg9+DgeZzQ2Ecl
         tLPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Qkgm03hH;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.48 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140048.outbound.protection.outlook.com. [40.107.14.48])
        by mx.google.com with ESMTPS id o6si1406428ejs.115.2019.01.30.14.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 14:51:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.48 as permitted sender) client-ip=40.107.14.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Qkgm03hH;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.48 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FJd4xUozB+7alcoxw8jbCUD16duz5AkzXpB6eFOXgcA=;
 b=Qkgm03hHl6K7CLlq4yQKkprpUrxBViHzIgHcb7GRHn3/CFxCLuwf6a3kHlqK3sjLUerdmDPDd4jmv4I+K9uz/zGf/Dg2cmjzohSwoB6PgE7WjbJGpbpwwpGfvycRREInvzJuU5G978+jxJZyMQe4lfUe0Xs4pbP6Q0oqhVmRcyo=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6571.eurprd05.prod.outlook.com (20.179.44.82) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.17; Wed, 30 Jan 2019 22:51:55 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 22:51:55 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Logan Gunthorpe <logang@deltatee.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, Christoph Hellwig <hch@lst.de>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAANmWgIAAG8YAgAAHLwCAAAROgIAABioAgAADIQCAAAkGAIAAAccAgAAPg4CAAAL1AIAACaCAgAAAtACAAAPygIAAAVEA
Date: Wed, 30 Jan 2019 22:51:55 +0000
Message-ID: <20190130225148.GC25486@mellanox.com>
References: <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com> <20190130204332.GF5061@redhat.com>
 <20190130204954.GI17080@mellanox.com> <20190130214525.GG5061@redhat.com>
 <20190130215600.GM17080@mellanox.com> <20190130223027.GH5061@redhat.com>
 <20190130223258.GB25486@mellanox.com> <20190130224705.GI5061@redhat.com>
In-Reply-To: <20190130224705.GI5061@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CO2PR04CA0064.namprd04.prod.outlook.com
 (2603:10b6:102:1::32) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6571;6:tcUhX8ThEQ1aqoCcrz7tThKNVH24ni6UrZhdSi0v60Pq98v/yXy46EAPtW2KlrtjHXuTNFdfXCgaxTB3wj17J7n9Swd4VmasEMxjEBMR+h1wOfpP0D4cN1GFPWM4niWKCXnC7dVpXz9tGyQ3W34BwM+S9+DA0L8Ev7Z3vQ86Tlm7V4blhaAr3z//0ueKcXI+D3qpXX94XqLs9FjW3Mz5PRxZQpQcyhHNA0JxXe3g0hmcvyGNtK9xQu+qqYV/CSiXfbevbl0j3Lmaq0AzagJSMG/YkDRQvmQL7xjWqbWVc5IWngCalniZnDBQL6CX/p5Ggip6K6pKkM4bVUWQu+Y9nQlxc2y7Y90yMu8+mllCci/9W3QJXr6FRS0aChrq02ftEtSK7rCrhHRkt78CN8wrpWOj/S6vIYJRbMjU4p2K5DM+9u9k+hDg33BD+CMeNexmLLY7hYrSk2Q8pBHGZqTDzA==;5:/YsijxgDm4VbarTBUVZLw2K8snPVd220AJ/HMlLhL3GS5/6iN3k5N8IoW2X51YAa+eNRSDnuIyo92yFNrM+paRr8tsH9uqv5kNgwzZ9LyOtfliBzRTFBDnGlHYLdZuc4Ld+e3GQEnmwG3b/jLZ+J2O6nUR1XA6cz+NvhgxVE0e4ysaulKdZSOKL0wKkSuD/3VtSZIC3Q35+W8Zj1Rozw7A==;7:yg7K6I68IbX3Gy3rz3nuhBl/liRC2PBP+HjTsTdticSf09NwUuPnHW9mX+iTw7ti0lGgTvDvICXAFBX5SvWZi0xBw0rjIz2z4IcQRYOp8VzPZOcw2OCHpTHcwxITRNg5ZqnMcegH3/iR2uppKsM5Eg==
x-ms-office365-filtering-correlation-id: 078e7a37-f6da-4fe8-93e9-08d687058822
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6571;
x-ms-traffictypediagnostic: DBBPR05MB6571:
x-microsoft-antispam-prvs:
 <DBBPR05MB6571E973DC7AFBD367E865A1CF900@DBBPR05MB6571.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(376002)(39860400002)(366004)(346002)(199004)(189003)(36756003)(3846002)(33656002)(186003)(76176011)(6916009)(106356001)(71190400001)(71200400001)(53936002)(26005)(52116002)(105586002)(25786009)(8676002)(54906003)(6116002)(7416002)(8936002)(1076003)(81156014)(81166006)(229853002)(4326008)(6436002)(2906002)(305945005)(6486002)(93886005)(66066001)(11346002)(446003)(217873002)(6506007)(386003)(99286004)(476003)(2616005)(97736004)(478600001)(316002)(6512007)(7736002)(14444005)(256004)(68736007)(86362001)(6246003)(14454004)(102836004)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6571;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Ox6/vquQvZO3t8TlBC23AglV3FJLS2Y2rhSWx6Nhy+V/0jPESVFPDmbyho2z+q2Ky6qaRUuTTyRaEksTtDWDFl1T+V5RRKx047iOpnCEmqcuCkFxbVjnM0oct6DvQrREihZTv5lx2KyeJBUI0SuaMFIy1g6hkrf5awwlJ8m0T6qE04BLqmaKTzBON7HrvPaW35XczB0Eah8BId/U1svGjIAdfIz/Fq7yAUndzbQh4WVNbgBWGxeyWwsO2JceE8mAi1ccdMz4jbw7dT3zSPYeD7AfWor/LdWFd29C438G9DfvkBG0bs1Y+eTGvB4uFCiHjUI7p3YP5+hd0NJOee5XZXS6+DWiU0vzAJVfLDDyfNwFVHSHVLaYJi9C8KyzC1ArDCJamS6ycxY96Z3X3kLFq7U9/BeFwnCBUOyRybacKMk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <35A69DD96A70BF4186715D7C3E6F4417@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 078e7a37-f6da-4fe8-93e9-08d687058822
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 22:51:54.8037
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6571
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 05:47:05PM -0500, Jerome Glisse wrote:
> On Wed, Jan 30, 2019 at 10:33:04PM +0000, Jason Gunthorpe wrote:
> > On Wed, Jan 30, 2019 at 05:30:27PM -0500, Jerome Glisse wrote:
> >=20
> > > > What is the problem in the HMM mirror that it needs this restrictio=
n?
> > >=20
> > > No restriction at all here. I think i just wasn't understood.
> >=20
> > Are you are talking about from the exporting side - where the thing
> > creating the VMA can really only put one distinct object into it?
>=20
> The message i was trying to get accross is that HMM mirror will
> always succeed for everything* except for special vma ie mmap of
> device file. For those it can only succeed if a p2p_map() call
> succeed.
>=20
> So any user of HMM mirror might to know why the mirroring fail ie
> was it because something exceptional is happening ? Or is it because
> i was trying to map a special vma which can be forbiden.
>=20
> Hence why i assume that you might want to know about such p2p_map
> failure at the time you create the umem odp object as it might be
> some failure you might want to report differently and handle
> differently. If you do not care about differentiating OOM or
> exceptional failure from p2p_map failure than you have nothing to
> worry about you will get the same error from HMM for both.

I think my hope here was that we could have some kind of 'trial'
interface where very eary users can call
'hmm_mirror_is_maybe_supported(dev, user_ptr, len)' and get a failure
indication.

We probably wouldn't call this on the full address space though

Beyond that it is just inevitable there can be problems faulting if
the memory map is messed with after MR is created.

And here again, I don't want to worry about any particular VMA
boundaries..

Jason

