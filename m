Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3902C4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 12:32:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7369D21850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 12:32:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="l3gKmVto"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7369D21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AC706B0003; Fri,  5 Jul 2019 08:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05E3D8E0003; Fri,  5 Jul 2019 08:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E69238E0001; Fri,  5 Jul 2019 08:32:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 994846B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 08:32:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so5550615ede.23
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 05:32:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=x1qiAtEBlZpCHtJkwG4q444YGHPJFnGegofN5yJ+9dQ=;
        b=J+O6eSt7tOGgipTHuuSf/4uN917a6c0Fw2FhNSJ87xM4CiDknDPN3pdzQjYzy1lKyu
         JR52EXUSo4BJhMiX2u3btKizK+VBsPj4PPRnhO23ySu4Xym1cw57vRy1BP1nSN4Bw6Nz
         Zp3atBGV1fp9siRRCOr+Dx2ZZmUWtGwn6nsJDi+sm8B4jzJujVeOsdAivZG35lYEz2k4
         f6H7XCnl6mvaT0WM4FSZFh7PGk/J2/ux93eueRZ9efIG/iSbvL9HZoT6csnixKXvh39k
         A00kx7M0iEiOHfmC8Vl8Tiic4sbwXCtHZeQpNYuNhRokb9e4GOEijDmdHsjMj52WZm4j
         muLA==
X-Gm-Message-State: APjAAAWxT/PYMAMs5FP0FiXJGt+55ORKLXT2/6+XKSl9xopG3uK4SipM
	vKAzIJ7MeuZtZuICx7XuZcyf5FwalOvjqgUiCMUj1UftkhJSnJm6Zkzdfiryj0iXot1a5VOsPVS
	jbgrjjL7gPGaEMYYByjB6RSIzk3YJhIABIyQEkkKbmJcghBCxXynAuByWtmlRaOt7nw==
X-Received: by 2002:a50:aa14:: with SMTP id o20mr4208169edc.165.1562329939208;
        Fri, 05 Jul 2019 05:32:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn6AfFCYYpOkht4ia3CD2qvc6ingpmxh+/dle34R3pGJ8xNqvg9UJqE8fQmnv07QFLupwp
X-Received: by 2002:a50:aa14:: with SMTP id o20mr4208106edc.165.1562329938515;
        Fri, 05 Jul 2019 05:32:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562329938; cv=none;
        d=google.com; s=arc-20160816;
        b=MHCqmUPRNwFyi/fihcaElzobAMJzDmY8Wbeq/2rLHhffipPeubuhLO0G02U062m2zb
         Sha7c+X6W+l9eGHtUlQS5AQK5mVvpxilhbWrfukZGH5eoNOXVHThXZ2UEVx4C1ecF/I1
         TPZvkuMf4k3Z+ZeDe1lynVef0sW/DAZEmYO0GuqGGoIstx1QaRwA2XrTcIz0O2ntC3wR
         Ehmp77PhV+vLjR7PCJe8W+vqZkOJL5dGf8rhTNBdhwuJKu9pgmaoY0Pd78uY5UZLdYaB
         OKXISuC4aIc5/Gj+TWhvVHQEBE98bVoC6hD3nI41itBLehUJtD+85kEbnjb/9c8Gfgbz
         0L6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=x1qiAtEBlZpCHtJkwG4q444YGHPJFnGegofN5yJ+9dQ=;
        b=H0S+LF57+Ny+17VonZ3DzdlsvPTLXHrieoinWzc0wk9pCF7fBjyHKpFh9KQRk4RoZG
         qKYO653cD/zvrBb0+otYMp7tjQJBbCBNfJQ/vE1npU7w8/LnVlzK5JFSrUMydQjhGTg7
         z3Cvlhl2gl86b60766uubg870caa/8ZAex7U8p9WJZq6FnLjgGm1BX9eYL9vts6EoNxB
         Uf4EQp/O4XbsQSjWdlUqsNbvLzZDF+NmHi2lf671mRDLDJGq8tlglG/4G4KS+ZAvM2hZ
         9yfn/xORTvzRFk4d11I30cvZhCv9KaRGN5O3vJTSN5QV/268QQLox1WtradjL969tiGA
         lyzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=l3gKmVto;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.77 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80077.outbound.protection.outlook.com. [40.107.8.77])
        by mx.google.com with ESMTPS id 12si5470306ejx.123.2019.07.05.05.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Jul 2019 05:32:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.8.77 as permitted sender) client-ip=40.107.8.77;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=l3gKmVto;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.77 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=x1qiAtEBlZpCHtJkwG4q444YGHPJFnGegofN5yJ+9dQ=;
 b=l3gKmVtoz6OdRC28gy3OMrlE+3SDnu7rUq4g6kY0hhX9a6+0yTQYtEI5toAod0PkSHX3+RDMRMS3ub/FBULCiMqQffpYZITcMa9M06amka8BlbLHZs4OAEVD+CCVy71cPx2EpWNy+lBLSQ9oc41NI0HAN9MCjrc+skUxyAKtjMc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3213.eurprd05.prod.outlook.com (10.170.237.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Fri, 5 Jul 2019 12:32:15 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2052.019; Fri, 5 Jul 2019
 12:32:15 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy
	<robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com"
	<catalin.marinas@arm.com>, "anshuman.khandual@arm.com"
	<anshuman.khandual@arm.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Thread-Topic: [PATCH v3 0/4] Devmap cleanups + arm64 support
Thread-Index:
 AQHVK/HAM2r3dJ5EjUuvQfApLyHQmKat3lEAgAA0MoCAAAH5AIAAxnaAgAwArgCAABJ8AIAAPP2AgADYVwA=
Date: Fri, 5 Jul 2019 12:32:15 +0000
Message-ID: <20190705123210.GB31525@mellanox.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
 <20190626123139.GB20635@lakrids.cambridge.arm.com>
 <20190626153829.GA22138@infradead.org> <20190626154532.GA3088@mellanox.com>
 <20190626203551.4612e12be27be3458801703b@linux-foundation.org>
 <20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
 <20190704195934.GA23542@mellanox.com>
 <CAPcyv4iSviwyAPBnw5zDu_Ks0Ty0sFZ6QbEtVVU0PRd=ReRZNg@mail.gmail.com>
In-Reply-To:
 <CAPcyv4iSviwyAPBnw5zDu_Ks0Ty0sFZ6QbEtVVU0PRd=ReRZNg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0085.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::14) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 23bec929-a95f-47dd-ac5d-08d70144d011
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3213;
x-ms-traffictypediagnostic: VI1PR05MB3213:
x-microsoft-antispam-prvs:
 <VI1PR05MB3213C8464D7D5409E5085C9CCFF50@VI1PR05MB3213.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 008960E8EC
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(39860400002)(396003)(376002)(136003)(346002)(199004)(189003)(86362001)(305945005)(316002)(2616005)(186003)(7736002)(52116002)(33656002)(66066001)(81156014)(446003)(11346002)(26005)(386003)(8676002)(8936002)(256004)(6116002)(76176011)(36756003)(81166006)(476003)(102836004)(3846002)(486006)(25786009)(2906002)(66556008)(6512007)(6486002)(71190400001)(478600001)(6436002)(6246003)(6506007)(68736007)(5660300002)(6916009)(1076003)(4326008)(73956011)(66946007)(71200400001)(14454004)(229853002)(4744005)(7416002)(66476007)(53936002)(99286004)(54906003)(64756008)(66446008);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3213;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 OXHySS3kGXYFoR8fTp+EyL12yec2p3+BOM6aFore+Im3pyKi5P4GtmIqsv6ZKrzbWKyVp7hdy+8p0je8/r1W7hUP7D7by6lBbUIb6GLoX2xItuS21StUv12Q1Of7kBobFyZJ63Q46bNFRcD2BF2a7t/iA5orFG8cWOxHG2SYbBRih0htRMPVNEdJKr+ve07BItNjDLnJxRPU1RUVWndRSyl6rhpPYrWMxd6Kv+2HB/RtqRkdAMzwcWQyoDIDrfj1Z40MbewF4k3d7N9YDWPePTuoHw3D7OpIUn+OM4+xJ+UGUSinXEWzDZ8w8SUI09HXOgZaORl1UnDUqYJEpuOIYLZX6I93yIb3KQosKLcUpb1OtRoKtgBkbSw1DUvv8Gi8KRT2ZSLBsqpxFQiKOTmNXtcstwPZMUKyY7IWByj/k20=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6156315727C54B41AAC7D7197EE2B4AA@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 23bec929-a95f-47dd-ac5d-08d70144d011
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Jul 2019 12:32:15.8846
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3213
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2019 at 04:37:51PM -0700, Dan Williams wrote:

> > If we give up on CH's series the hmm.git will not have conflicts,
> > however we just kick the can to the next merge window where we will be
> > back to having to co-ordinate amd/nouveau/rdma git trees and -mm's
> > patch workflow - and I think we will be worse off as we will have
> > totally given up on a git based work flow for this. :(
>=20
> I think the problem would be resolved going forward post-v5.3 since we
> won't have two tress managing kernel/memremap.c. This cycle however
> there is a backlog of kernel/memremap.c changes in -mm.

IHMO there is always something :(=20

CH's series had something like 5 different collisions already, and I
think we did a good job of with everything but your subsection
patches.

Jason

