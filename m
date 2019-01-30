Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9ED3C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2329D218AF
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:56:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="jxR8/Nh4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2329D218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB4228E0006; Wed, 30 Jan 2019 16:56:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3AC28E0001; Wed, 30 Jan 2019 16:56:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA2728E0006; Wed, 30 Jan 2019 16:56:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 532078E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:56:13 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so757322pfb.17
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:56:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=DH9QbLxwVDC3lKU4ALmY9v1jzZcQzQ7bYIMuaDI3+PQ=;
        b=GqvwkCS0b2dKPWEdPB13h9jr5c2LAibIAFIz77plrzFm7mBH24FTWIkKjuEwnXELUE
         2gOj3aMVbJEk93lhLVEwppziZphjHi77eDxNHsRJ/ppe33X05gu4Km9fKzkaFH1bi/I9
         iQL3f70C61aEOAI2zfwF+mk8aADkeQ/zOBduvBk9RNDdVtPV8Fb+naLTCmIYGSMLxkx8
         UOi5EHzaRlNNqAZs8ChRA3cWk95fuS4q0FW2pqSfHJ8zAwTSmluZU84gTKConDmEq3WF
         nnIozPFLbi3rAQH8S661y3HduGkHOf+KBoBOLZppmEFijosdKah6JGqHDv0FVLeWY/ss
         UaSg==
X-Gm-Message-State: AJcUukckmNZmSyOz6sxVdwQ0EqPnHDB8vf+sJry8dedX/G0jN/ycb986
	UUMgp79PfXzv+LzBivyASdcf/imksvcdaaQQXMLKFkZh1suFWzxzn9X1V6aOiDVDy+flLqfYyHR
	EHh3IheJqNqzcw1MNjHO3ux0j7IkA5ARsTVkzTEMIlfUwVQ2ej1KMMnJCCYBPJFRCYQ==
X-Received: by 2002:a17:902:2a0a:: with SMTP id i10mr31702907plb.323.1548885372866;
        Wed, 30 Jan 2019 13:56:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4DS7u/ndT4skLBcLhcmFjhgDxDTxF2wCZSg/sQChTkj9TCqY0AfzS49ACUWUz8So/2uGlP
X-Received: by 2002:a17:902:2a0a:: with SMTP id i10mr31702878plb.323.1548885372114;
        Wed, 30 Jan 2019 13:56:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548885372; cv=none;
        d=google.com; s=arc-20160816;
        b=jCkQJEudgvsyGpi5dxFvkphnwKsUym01SxX3Wwu+ecBoUuABOUiZIVAnQ1Pm2l9yVA
         2M9N0lOr7IB9I1wz4BUV/qJBYleMdzoWUTsVQZiaompgnrW6cXZn4gxlKJpLZZu9cKhn
         VcmFGONsBTpSKDaOoZ/IQXvDA7QTP4V04yPs0pD5//fFFaJY8H1CnUyCkfZhwajKZrsG
         ptMRon4CmLV7xkAtZAYiaQbXohLn6t5vlMFMl+JzqJ8hh0rMXNZ2CLr04+M14IVfpo5V
         owNfn4RqoFbNQGA49IxNn7HW0xtRx99+SOBDZI97gY7y4dpxa1Is//BOQYIABbZiBCtK
         cnpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=DH9QbLxwVDC3lKU4ALmY9v1jzZcQzQ7bYIMuaDI3+PQ=;
        b=pj6fLjXmedsEdGryxp16R11ImdE/YqzPTOompXNaloldab8SgFBr+bYT3PnKdETo+S
         tdd4WFTKaU9S4cFO0mK/HSOIuHWJ+IGgU4b9vgXpVsYBdFQrckwEx/tajq51mtlWh3vz
         mrvhzIj2pJuK61lbxoRF51DqEg8IdrzvrRb7AWao3O++RP+YcDZKxGX/sMbercX8MtLY
         xOoT4zAPwjMammAenLtTJQlGg+pahEOo5/EDoK0HmZD7IqHUlqtHg9X1Da6l/gy/aCtX
         HbGONLxztzpIwKdHq3ErGox5YSXTmQreHGrn9cKcgsfBgj5yYBcUZwdDmAaC4pXnOXdq
         vXhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="jxR8/Nh4";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.84 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150084.outbound.protection.outlook.com. [40.107.15.84])
        by mx.google.com with ESMTPS id j1si2431024plk.342.2019.01.30.13.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 13:56:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.84 as permitted sender) client-ip=40.107.15.84;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="jxR8/Nh4";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.84 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DH9QbLxwVDC3lKU4ALmY9v1jzZcQzQ7bYIMuaDI3+PQ=;
 b=jxR8/Nh4I9+OXE0rn/dfLUIEJWHMRzDahtSpakjKJ+FqVD4PmNmrBc1mmxSySRBx9+4Mbw/H0DK02lbGUNopdmlfWAH08qAOTw86Co1PcIfTMlm3eBIkGBe/jZzsXBG6WNN7G8zSwR62D7HeAEkaZArtpVE0y0aWNAeIOkwSZFs=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6554.eurprd05.prod.outlook.com (20.179.44.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.18; Wed, 30 Jan 2019 21:56:07 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 21:56:07 +0000
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAANmWgIAAG8YAgAAHLwCAAAROgIAABioAgAADIQCAAAkGAIAAAccAgAAPg4CAAAL1AA==
Date: Wed, 30 Jan 2019 21:56:07 +0000
Message-ID: <20190130215600.GM17080@mellanox.com>
References: <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com> <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com> <20190130204332.GF5061@redhat.com>
 <20190130204954.GI17080@mellanox.com> <20190130214525.GG5061@redhat.com>
In-Reply-To: <20190130214525.GG5061@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR13CA0040.namprd13.prod.outlook.com
 (2603:10b6:300:95::26) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6554;6:+izlU54WZ3KrKVzWpy50cyp/ECQz10kd1axKRwCA1xfTpqs0z0DIoLXt2n0bSaW67aSqZrVDhV4DxLuz4W5l81BpD7XOzx96H+3RalGnUFh8lDQMqBmGtz1If54olG/qiFmrm8rCssmot42dhd5magJY0RLbMgLuRyGukNqd8n6oaAwkJ7LtUMzL55vmQd38VJyGp2+o7CZUyfHzFrA1Ah8AXOwZ0XF6snQuHsjNTkX0S43OzExrIlHvsVOLmsCvkee+droa6/delwAkqigNQ0gYLrjCGhSuwGTS8YE5Uzq4PM0f5GGO6stMi2OUaIjlt1Dlkj8R9VyT24JRY1B3CcJynYu/GfoEiJwbwG2MbM2gV3yo09x2+FvG6MdOGckUdPSF2i4esyYkMzetyOgZcyPfzOQAaL9mXB7BJhltvE1S1zaxumYZW7uBpoa0VM6NTlFjNo0RI3JLsH6TH94vdw==;5:Fke16lsK549e585FTfjKRFSCzMIzJAjEqdcGWOd54T3yNF8ryTjOWSVO6hqws99ywzeb8rDDhs9P3CYc2hCTvFBi5rIasX74IGAh0gn5162ij43xj/QbOscygB0ccwl3Hfls0jTz1DsI1oun+Hdnzl8mnRsIiSGTXtGQhwt27pBF3l1NcxbuSdR59TLtbXYw9Eyfnx5IQhnT3NzbssBokA==;7:vSikcgNx6GES6C25Ckuqa2iSjqTpqZ3ex6nJRv6n5p9FuliH1ROi2s8GBiDxQ2AQiILL5n155GEyt20tP0+ZrErKKlN9LzUC92+lTxNNpBQTOZdrdnUbigoPq6WXiT63+TssdZm/IYBZux7TQYGn2A==
x-ms-office365-filtering-correlation-id: f62297f3-a06c-4313-f5ff-08d686fdbcbc
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6554;
x-ms-traffictypediagnostic: DBBPR05MB6554:
x-microsoft-antispam-prvs:
 <DBBPR05MB655400BFC19B440692896879CF900@DBBPR05MB6554.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(376002)(39860400002)(366004)(136003)(189003)(199004)(36756003)(4326008)(305945005)(33656002)(186003)(71190400001)(71200400001)(217873002)(93886005)(3846002)(6116002)(7736002)(14444005)(86362001)(8936002)(229853002)(66066001)(6436002)(6486002)(1076003)(256004)(2616005)(81166006)(81156014)(11346002)(8676002)(99286004)(6916009)(446003)(105586002)(97736004)(6512007)(106356001)(25786009)(7416002)(478600001)(14454004)(68736007)(386003)(316002)(6506007)(76176011)(26005)(102836004)(6246003)(52116002)(53936002)(486006)(476003)(2906002)(54906003);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6554;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 uJVj9sbc21+JmGfQR6CXGZyh1riNgZNik7R8qC9/uuuORd1KcCTHSPJ8i8NiCXFhRKe2egcFTOe6KUTBGTrFs9JDTUHunq55dqxFOyvPuxyuihKfKyuxnDzoj5Bd9nx3pKY8aT51/Jd5n2pXkg7VXKdt0ROljwh25TVoW3LKzMr00mAXPGE6jiIEBnqmVl506MDvM5WlqRZxnR44BJ6Y6ZCJLa3N5LZHzhWhQTTxYY4aWjzJZGFdBfEnVxVhYJjrgUN8mRnPCQVNtCKNJ10b/B9lTILQdS6aZmROOtgXiATHVogwq4xbj/EfQ+pyAChdFD7dhl+nsBJYUKtzrbGfhJwaZDgQdJoIjbFU6hQ4GKnm9wD4JQNsp3oJ9l0OMHVPdnL0D1OKHoZt+LSKMJHtCWnkl91BdMxAJaw598B3668=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C7D277F6F0DABE4DB953023632447B07@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f62297f3-a06c-4313-f5ff-08d686fdbcbc
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 21:56:07.0832
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6554
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 04:45:25PM -0500, Jerome Glisse wrote:
> On Wed, Jan 30, 2019 at 08:50:00PM +0000, Jason Gunthorpe wrote:
> > On Wed, Jan 30, 2019 at 03:43:32PM -0500, Jerome Glisse wrote:
> > > On Wed, Jan 30, 2019 at 08:11:19PM +0000, Jason Gunthorpe wrote:
> > > > On Wed, Jan 30, 2019 at 01:00:02PM -0700, Logan Gunthorpe wrote:
> > > >=20
> > > > > We never changed SGLs. We still use them to pass p2pdma pages, on=
ly we
> > > > > need to be a bit careful where we send the entire SGL. I see no r=
eason
> > > > > why we can't continue to be careful once their in userspace if th=
ere's
> > > > > something in GUP to deny them.
> > > > >=20
> > > > > It would be nice to have heterogeneous SGLs and it is something w=
e
> > > > > should work toward but in practice they aren't really necessary a=
t the
> > > > > moment.
> > > >=20
> > > > RDMA generally cannot cope well with an API that requires homogeneo=
us
> > > > SGLs.. User space can construct complex MRs (particularly with the
> > > > proposed SGL MR flow) and we must marshal that into a single SGL or
> > > > the drivers fall apart.
> > > >=20
> > > > Jerome explained that GPU is worse, a single VMA may have a random =
mix
> > > > of CPU or device pages..
> > > >=20
> > > > This is a pretty big blocker that would have to somehow be fixed.
> > >=20
> > > Note that HMM takes care of that RDMA ODP with my ODP to HMM patch,
> > > so what you get for an ODP umem is just a list of dma address you
> > > can program your device to. The aim is to avoid the driver to care
> > > about that. The access policy when the UMEM object is created by
> > > userspace through verbs API should however ascertain that for mmap
> > > of device file it is only creating a UMEM that is fully covered by
> > > one and only one vma. GPU device driver will have one vma per logical
> > > GPU object. I expect other kind of device do that same so that they
> > > can match a vma to a unique object in their driver.
> >=20
> > A one VMA rule is not really workable.
> >=20
> > With ODP VMA boundaries can move around across the lifetime of the MR
> > and we have no obvious way to fail anything if userpace puts a VMA
> > boundary in the middle of an existing ODP MR address range.
>=20
> This is true only for vma that are not mmap of a device file. This is
> what i was trying to get accross. An mmap of a file is never merge
> so it can only get split/butcher by munmap/mremap but when that happen
> you also need to reflect the virtual address space change to the
> device ie any access to a now invalid range must trigger error.

Why is it invalid? The address range still has valid process memory?

What is the problem in the HMM mirror that it needs this restriction?

There is also the situation where we create an ODP MR that spans 0 ->
U64_MAX in the process address space. In this case there are lots of
different VMAs it covers and we expect it to fully track all changes
to all VMAs.

So we have to spin up dedicated umem_odps that carefully span single
VMAs, and somehow track changes to VMA ?

mlx5 odp does some of this already.. But yikes, this needs some pretty
careful testing in all these situations.

> > I think the HMM mirror API really needs to deal with this for the
> > driver somehow.
>=20
> Yes the HMM does deal with this for you, you do not have to worry about
> it. Sorry if that was not clear. I just wanted to stress that vma that
> are mmap of a file do not behave like other vma hence when you create
> the UMEM you can check for those if you feel the need.

What properties do we get from HMM mirror? Will it tell us when to
create more umems to cover VMA seams or will it just cause undesired
no-mapped failures in some cases?

Jason

