Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EBDEC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:33:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F415B208E3
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:33:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="L+PD0lzO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F415B208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92FBE8E0006; Tue, 30 Jul 2019 08:33:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E0728E0001; Tue, 30 Jul 2019 08:33:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A8428E0006; Tue, 30 Jul 2019 08:33:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D67E8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:33:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so40266652edv.16
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:33:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=dIh+Bg+Y7JR5zJCYaI23CwB6oXfe2ZfSo9J/94dn2C0=;
        b=Qt7mYiifKWo9F/sNMM8P/2uRi/KIr99jcxzXfTF/RFJtK92c4PyPF0vmFoqEg5LOTv
         Fw30JIPaH3rEqBbpmONWAe5zuX7xljzk6wWSngxU8SlrEWqwH7l9DB3q8VVnhgWX2VzJ
         uUxvItQlCPkawCSWMo3z7+uU2jXgFyOqZ5lhBAsJfiCI1d5LLAa+Y8DRMQxMvMiPVuSd
         zPxS1AjcPFwb2+zircuoEwkXC+gyEHb8G+sAmkPy1+XKVqnOWjDM/yoOYM7IJxaO4oHn
         /CpiU547l/0PVa7bS+pDmryOQMV5JutzYmgCRsVIdbJkiCdIycqqS86P60FO34hGjz+Y
         5p5g==
X-Gm-Message-State: APjAAAXqqHw4gJb17102YxRl86vzcPJv4jQ23yJl4avyuwdqqaD0NMlE
	jS3iPOdKwDEjHveYx6vgZSYoCMstaIrFx84ACzLWCg2d+1PNCkQpCHFyT579m8tDJNm1W8nfIcS
	7UMMz9ZPftQW3DlRasoHhK4z4EB3EIwVEQa3YSSMxCwi/RnYMl7SNpyJn7RxaQoailw==
X-Received: by 2002:a50:974b:: with SMTP id d11mr101075824edb.24.1564489985725;
        Tue, 30 Jul 2019 05:33:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTSHfgWUY39hyXKO7Q1h4fs5A6H0BUeX/AFEZIGMMs7meZWQUC0fln3v05XlbVdNoCLwf6
X-Received: by 2002:a50:974b:: with SMTP id d11mr101075776edb.24.1564489985120;
        Tue, 30 Jul 2019 05:33:05 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564489985; cv=pass;
        d=google.com; s=arc-20160816;
        b=jUXBZWmTPu+mzjlKuToqyAC2435osEU0g6yuUimspdQ1EQKecKGFuCHa9EWlFgo4oq
         ajjSqZrIk27uGQhaPJTX7t0JQb3dgPo0FoFnO1P1ap1DTsf8yhXf4aRZmvmKrHi5EH+L
         ciBYkJxBAY1infPx8tHFeEzMwc7JdAf0NnQM6TYyAyvWiZG03NtuWPK5bWCLVFzp7OUC
         MiHFOuv2fRR/vsQlR4LqpQ5/V+mNsaTEdGP+IvB7W7IL3ztivBCD8OVJDKc1OcXE8XqO
         kdv7Hx7HA3J8CTjTitWHdPlcEfvxl/tJQlHF+VAVl6Y53mpX+zVllYTGyKIw4Ce2nfdL
         xg8Q==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=dIh+Bg+Y7JR5zJCYaI23CwB6oXfe2ZfSo9J/94dn2C0=;
        b=MqYpKN7PFExXDCURGeoFpLgnJaB6KQl2skicWyjPM4izo635YB2MHq285AXjsV8ubx
         yGFrmlx1bKg9+LVlVMg11dL6bJEHZ0yKkFZMXiNQsR81WMJI9VG9FDMrwkaAEni+ELwo
         BfF+ITlHj9zrdPhXELMFlKRqSXzoarCdIVQIwklmYNIw1P9Z0e2DlxGOa8a95zTzBNsi
         xw1WpPFM39UMRWbdtqtgA+JM/cHVTj6vjj7z/PjSFaA1WQY/pkaEq/YJnpWh6di4rS7X
         LX4ML8MtiyXNvEoBuSCy5b7eovQwdPNfoOt0GzN1px7W/FAP3YCub4YZwy7MY/qsyzns
         nwOg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=L+PD0lzO;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.42 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70042.outbound.protection.outlook.com. [40.107.7.42])
        by mx.google.com with ESMTPS id z53si19365451edb.422.2019.07.30.05.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 05:33:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.42 as permitted sender) client-ip=40.107.7.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=L+PD0lzO;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.42 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=NriWVhBq1EG/g+8owiD7Blh8mf7cOyWhr6jR2/J76XU5sOSJOO9TrdAGlqTkI52AZB1/HyLG9RIF+98+G2LPE2ihiHcrio9ltSSRNveWGb5vFq0WqXKXy1YwQeTpgFolhyb108LqhlX2+eEYIdtDozcQ9pM9QRo8SgmFD7k46lfbj7ZVuXMmjd0bF3COl6Quydn2ZAjoQN7bu6eGZ0ex5w0q+XknqR8H6OGvzVxgH7ADc1ZVuTyCCaLXKFEMF7dPQ3PVuEy8AeLwPhJoKcEOCms4RLnuUL4l67za1smof3oCsA7u4ChmpeGb215NzQInrk1GEFlIBgkjxVc5rVIL2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dIh+Bg+Y7JR5zJCYaI23CwB6oXfe2ZfSo9J/94dn2C0=;
 b=ImLL72JQq6nLdR4wnlre96u8+YI8B++NaXIW+HIlB9bUElqtvs3F0hGsZ9dXt1LPqHHO+I2xDmz1nvE1tm4EmblSd55F+I6Gn32FUq75u9Xu+lxL54pbs61JoGXsSrou+XJmYrpSrmioFSoA8WIE7WtRY3iCBrN2EEJpDV81AIa4GW4JuAXvVoaT0ZnqB+3aS9CwQaPpzl5kBu+rNMMBQuN8MM0TmjQsJRbdNOdUP1UrnSVq6IQSxvwQn/mnXOaGETHMgASjgsJn+h9x0qUQ7/wOEH+4nSUhDDCyVj2ROin+K72UyaMsxP177N0Iq0wm1UU2uYUUupCuI1//iSkbgA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dIh+Bg+Y7JR5zJCYaI23CwB6oXfe2ZfSo9J/94dn2C0=;
 b=L+PD0lzOlrIv+mTDx/nh9p6/H5db2n3sbrfekUrPBizneQi/ck1kAaq8qKUn6stJjJEkBmx6nOMdHq1j1ayzMucOsxY+LX/FP2qpRYKtelys4vS4Sz8lldxLibXLLby6sfLeCy7jt+WpGDc1Y579+1VUwY406YTCy/0zeE4PKdE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5568.eurprd05.prod.outlook.com (20.177.202.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.13; Tue, 30 Jul 2019 12:33:02 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 12:33:02 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 01/13] amdgpu: remove -EAGAIN handling for hmm_range_fault
Thread-Topic: [PATCH 01/13] amdgpu: remove -EAGAIN handling for
 hmm_range_fault
Thread-Index: AQHVRpr1y4W4rzsfOUifvYDU3qMetqbjGJ+A
Date: Tue, 30 Jul 2019 12:33:02 +0000
Message-ID: <20190730123257.GB24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-2-hch@lst.de>
In-Reply-To: <20190730055203.28467-2-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0037.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::14) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c63a4ff3-9a95-4980-1049-08d714ea101d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5568;
x-ms-traffictypediagnostic: VI1PR05MB5568:
x-microsoft-antispam-prvs:
 <VI1PR05MB5568EB5E95ABE2AB3D3859E7CFDC0@VI1PR05MB5568.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2733;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(39860400002)(136003)(346002)(376002)(396003)(199004)(189003)(446003)(11346002)(53936002)(486006)(5660300002)(2616005)(476003)(256004)(4744005)(6246003)(26005)(6436002)(6512007)(66946007)(6486002)(102836004)(305945005)(66476007)(68736007)(66446008)(64756008)(66556008)(33656002)(8936002)(186003)(1076003)(66066001)(71200400001)(7736002)(81156014)(81166006)(8676002)(229853002)(7416002)(99286004)(2906002)(6916009)(6116002)(54906003)(316002)(36756003)(3846002)(86362001)(478600001)(76176011)(6506007)(386003)(52116002)(14454004)(4326008)(25786009)(71190400001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5568;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 zmjHbdaV7n0oJaJsMCF4EFNWeB4AiV0cBG47yTB/uXEz0jC2vezO5Gmfz6/l8WPT4rmGJKyqMgmt0ZoQN8cysSTG4ldcq1gfGWib5l5fXUGScTd1yovF+XAYfQVU3wxD+D3JEBpzJBIXODRU1g86gPdjagbzV43xWQ/J43KxioZlzhuyGyiTVMh+AKUklu0DLv/DPBiTHW22Rif0yz4XpAX3doeicjvUkp9ex5TIIJ0dyRD7fCXTF7uvP72wQhNKg2JsUejBIKiFk4C2CTRt6UsWyckOZxJS81s/ALB8+Zm00MxHgsvvTWHZIgxOLo0YdXjwXeUfAsfPYSe4eeTTtMMsSJ3i6ijZQZSbbKS6wz96bUUizSNR2MIUfPHFpBszzGGHk/WgafoMQI4ayHXWkbH32S0JeX2NsVVVSnvNdY0=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <76FBA5B0F135514A885052AAEE17CDB6@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c63a4ff3-9a95-4980-1049-08d714ea101d
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 12:33:02.3076
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5568
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 08:51:51AM +0300, Christoph Hellwig wrote:
> hmm_range_fault can only return -EAGAIN if called with the block
> argument set to false, so remove the special handling for it.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 23 +++--------------------
>  1 file changed, 3 insertions(+), 20 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

