Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06F77C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0B5D21852
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:59:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="qW39W5DO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0B5D21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F5226B0003; Thu,  4 Jul 2019 15:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A6168E0003; Thu,  4 Jul 2019 15:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345BA8E0001; Thu,  4 Jul 2019 15:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1AAC6B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 15:59:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so4343791edp.11
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 12:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=CVGOHmLSP/JIZtqpwRtiDiY1SzX40ljEnPrYndO1vII=;
        b=k/G15PXZK0400ax8Stysiuz9h/6Nxn13lpBvMlRwN9ipV9sDajcNd37oxS8yyzJQgO
         mkdxuRLC3lZWzHJt5TFG/wxab2/YCy2XmWIkiHBluolJ+i5+3TyW4bd/Y25DtjaIhZ9v
         yjw9/KcfbgPYj02p1KnegElX8iY0IlENvvuA79sdKYMIujXWsYSNoSQUPQqch2QZq0MD
         BMHH10hQzy7RLwg8UHtdXcYlbK3wa9Tey9skI28qblFG+0/lc5ndflMUVhV8Ph6nc9M0
         hmKdoiA0aYwkPqPygzoyztlwyBN47wJSJgKe9rm7sGzlAL0/+Cp7wBNHT6LTGQtaMnX8
         iYsQ==
X-Gm-Message-State: APjAAAU2+gxhW0+eerZlHX+cTr6Mjo/dvuXlIWk1u/TgGxjbj/15bn0P
	NMUQbF3BOAHssZGGRSFJcNeeFbr6BhNUR2UCRJ+dEuUs+XS0EErmSfsAJhPl+J0f2u+90UEyR74
	WtH63mm4C8+UO1Z2nhH5KVnyssWMz00lBrrEEQuKz43BCVZQpigHBc9IHADSSb5ddTQ==
X-Received: by 2002:a17:906:3948:: with SMTP id g8mr54674eje.240.1562270381298;
        Thu, 04 Jul 2019 12:59:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaccehpoQU6D/Qy35kTG9pJ6577vM6amroklG+pEQkk3nTTcufAvjIGtlbqzkvDut+4a41
X-Received: by 2002:a17:906:3948:: with SMTP id g8mr54631eje.240.1562270380374;
        Thu, 04 Jul 2019 12:59:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562270380; cv=none;
        d=google.com; s=arc-20160816;
        b=WSHcZcBqzoI4+qVWqlzBQGzuT9xj92hHA/Go2PUuL1SgjYNiR/Ckyyoze4o8dwH2xE
         MRyRT41a9aDKh0UC2YZ4Y0YeyvAYNn7/NdzBzFh/rxvuKxqnAvRb46zzuRELLOjVr7CR
         2i1KLdle/4CBIOC9HrEf1XNjzsvGTvoCtS+okvv7ucSHp/dIjeNCsXdl0Tf7WyC2sZqa
         40zSXVEBFedoWUSCgIUxYIQbCQwxnO26crYxdzJ0S0RjNX2ZAnot7DntdOQ8r5jQAxeC
         AteHswHt7C0YKcgERxAeF+pP1mMNTeu5cKmePhaoRojEcU1nlu660b3UmqvijMFthrnS
         sDtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=CVGOHmLSP/JIZtqpwRtiDiY1SzX40ljEnPrYndO1vII=;
        b=aG6x6bCWa1eP1CY4RIbBxIUn7oJR/0E+hGWZHD3EP/yHX2y+dGoXtOv8Tu/ChrF9GC
         5aDyJUm1lSplcStU7LzkWoDaskPPVn/qnXuGPelimUK0mYOLhZtv2nKUH+/MZLA9PRlf
         EU7bIdEa8IYJNvAegrc6pdGNItX8hGKYEuiiw1bZeo0eroZqLSAdesOhnoqzvVMEo43e
         mUm0KWk97bV0XtA5jUsOnHjGJDjCGDYRPw1fbH465ZVMKuCpVTRoLD7P8yTvXL0qVPsR
         K3UV6b8hdlCPLLQpMwFw7bxgmNmAD9ynmP9uL1UMvbGEKSaF0nhcxs9e6g5xENVimxcI
         DzrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=qW39W5DO;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.45 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40045.outbound.protection.outlook.com. [40.107.4.45])
        by mx.google.com with ESMTPS id l8si5356730eda.181.2019.07.04.12.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 12:59:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.45 as permitted sender) client-ip=40.107.4.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=qW39W5DO;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.45 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CVGOHmLSP/JIZtqpwRtiDiY1SzX40ljEnPrYndO1vII=;
 b=qW39W5DO8ZPjCLawPUoIOl9ykwyA1mN7FyeohBoGboPGP2l/bY/S9IYz7YJPOEnYAeDnIhKv7geh+kz412/1TQEbzeWJ7ckn7uS8K6tcIr0CYWWeGuE0PtMOvXJ80wYt9KK6oWUQ0z0Boy5eAYLKBjuDuNE/Yi2gZXFsKj3xNrw=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3167.eurprd05.prod.outlook.com (10.170.237.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Thu, 4 Jul 2019 19:59:39 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Thu, 4 Jul 2019
 19:59:39 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Mark Rutland
	<mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com"
	<will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
	"anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams
	<dan.j.williams@intel.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Thread-Topic: [PATCH v3 0/4] Devmap cleanups + arm64 support
Thread-Index:
 AQHVK/HAM2r3dJ5EjUuvQfApLyHQmKat3lEAgAA0MoCAAAH5AIAAxnaAgAwArgCAABJ8AA==
Date: Thu, 4 Jul 2019 19:59:38 +0000
Message-ID: <20190704195934.GA23542@mellanox.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
 <20190626123139.GB20635@lakrids.cambridge.arm.com>
 <20190626153829.GA22138@infradead.org> <20190626154532.GA3088@mellanox.com>
 <20190626203551.4612e12be27be3458801703b@linux-foundation.org>
 <20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
In-Reply-To: <20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR01CA0017.prod.exchangelabs.com (2603:10b6:208:10c::30)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5bcf9b6e-f6b5-43f1-0787-08d700ba2543
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3167;
x-ms-traffictypediagnostic: VI1PR05MB3167:
x-microsoft-antispam-prvs:
 <VI1PR05MB31673E959366D797D0F55226CFFA0@VI1PR05MB3167.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1051;
x-forefront-prvs: 0088C92887
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(39860400002)(376002)(366004)(136003)(396003)(189003)(199004)(54906003)(476003)(2616005)(7736002)(305945005)(186003)(446003)(11346002)(7416002)(53936002)(478600001)(6512007)(6246003)(229853002)(316002)(6436002)(14454004)(33656002)(6486002)(2906002)(256004)(99286004)(76176011)(8936002)(1076003)(36756003)(68736007)(386003)(6506007)(66066001)(71200400001)(102836004)(25786009)(86362001)(26005)(66446008)(71190400001)(64756008)(66476007)(486006)(66556008)(81156014)(4326008)(81166006)(6916009)(8676002)(3846002)(52116002)(66946007)(5660300002)(73956011)(6116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3167;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 5FQR5yQC+//7srTU9m1LCNnAMEM/TLHDdkInE9OLvXRPtlk4D5Qp6NyskQNYKVt/RsRSFT8bGxMLNwfaRainxw4PKuFQCbyW6wzGMJmdh3B+wkTxyGFaPPUhr5O0niY3+hOpmgrSOqjP1gwjRYrxdadYKB1rRzhT8wzIkwJZl4FRhmDdO1nMXLvWqsrqFOZySjGgN8X9d1rwtGw0ujeLfj9SdVCKukEToOXli0J1redwycxy31Zerk0EqSfU8sk1PP00V7QLcyjzmsUp8BAjCT9fqdK8/VG5J+WTlmob3rLQrLoO/ycv/Rv2IZIcoFsH8Q5xhlKDSDOnhGPKFC70p3Xkj1anqobtgSg1IBYxDpzUjJoDsLgmCYS9HF/Qq0ngmXdTPJZqChFCg1Bu/cGnh+rid/d1ox7nYJpPbJV9aqg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E7B95E329110B24BA206433070923C07@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5bcf9b6e-f6b5-43f1-0787-08d700ba2543
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jul 2019 19:59:38.9039
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3167
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2019 at 11:53:24AM -0700, Andrew Morton wrote:
> On Wed, 26 Jun 2019 20:35:51 -0700 Andrew Morton <akpm@linux-foundation.o=
rg> wrote:
>=20
> > > Let me know and I can help orchestate this.
> >=20
> > Well.  Whatever works.  In this situation I'd stage the patches after
> > linux-next and would merge them up after the prereq patches have been
> > merged into mainline.  Easy.
>=20
> All right, what the hell just happened?=20

Christoph's patch series for the devmap & hmm rework finally made it
into linux-next, sorry, it took quite a few iterations on the list to
get all the reviews and tests, and figure out how to resolve some
other conflicting things. So it just made it this week.

Recall, this is the patch series I asked you about routing a few weeks
ago, as it really exceeded the small area that hmm.git was supposed to
cover. I think we are both caught off guard how big the conflict is!

> A bunch of new material has just been introduced into linux-next.
> I've partially unpicked the resulting mess, haven't dared trying to
> compile it yet.  To get this far I'll need to drop two patch series
> and one individual patch:
 =20
> mm-clean-up-is_device__page-definitions.patch
> mm-introduce-arch_has_pte_devmap.patch
> arm64-mm-implement-pte_devmap-support.patch
> arm64-mm-implement-pte_devmap-support-fix.patch

This one we discussed, and I thought we agreed would go to your 'stage
after linux-next' flow (see above). I think the conflict was minor
here.

> mm-sparsemem-introduce-struct-mem_section_usage.patch
> mm-sparsemem-introduce-a-section_is_early-flag.patch
> mm-sparsemem-add-helpers-track-active-portions-of-a-section-at-boot.patch
> mm-hotplug-prepare-shrink_zone-pgdat_span-for-sub-section-removal.patch
> mm-sparsemem-convert-kmalloc_section_memmap-to-populate_section_memmap.pa=
tch
> mm-hotplug-kill-is_dev_zone-usage-in-__remove_pages.patch
> mm-kill-is_dev_zone-helper.patch
> mm-sparsemem-prepare-for-sub-section-ranges.patch
> mm-sparsemem-support-sub-section-hotplug.patch
> mm-document-zone_device-memory-model-implications.patch
> mm-document-zone_device-memory-model-implications-fix.patch
> mm-devm_memremap_pages-enable-sub-section-remap.patch
> libnvdimm-pfn-fix-fsdax-mode-namespace-info-block-zero-fields.patch
> libnvdimm-pfn-stop-padding-pmem-namespaces-to-section-alignment.patch

Dan pointed to this while reviewing CH's series and said the conflicts
would be manageable, but they are certainly larger than I expected!

This series is the one that seems to be the really big trouble. I
already checked all the other stuff that Stephen resolved, and it
looks OK and managable. Just this one conflict with kernel/memremap.c
is beyond me.=20

What approach do you want to take to go forward? Here are some thoughts:

CH has said he is away for the long weekend, so the path that involves
the fewest people is if Dan respins the above on linux-next and it
goes later with the arm patches above, assuming defering it for now
has no other adverse effects on -mm.

Pushing CH's series to -mm would need a respin on top of Dan's series
above and would need to carry along the whole hmm.git (about 44
patches). Signs are that this could be managed with the code currently
in the GPU trees.

If we give up on CH's series the hmm.git will not have conflicts,
however we just kick the can to the next merge window where we will be
back to having to co-ordinate amd/nouveau/rdma git trees and -mm's
patch workflow - and I think we will be worse off as we will have
totally given up on a git based work flow for this. :(

> mm-sparsemem-cleanup-section-number-data-types.patch
> mm-sparsemem-cleanup-section-number-data-types-fix.patch

Stephen used a minor conflict resolution for this one, I checked it
carefully and it looked OK.

> I thought you were just going to move material out of -mm and into
> hmm.git. =20

Dan brought up a patch from Ira conflicting with CH's work and we did
handle that by moving a single patch, as well I moved several hmm
specific patches early in the cycle.

> Didn't begin to suspect that new and quite disruptive material would
> be introduced late in -rc7!!

Unfortunately a non-rebasing tree like hmm.git should only get patches
into linux-next once they are fully reviewed and done on the list. I
did not attempt to run separately patches 'under review' into
linux-next as you do.=20

Actually I didn't even know this would benefit your workflow, rebasing
patches on top of linux-next is not part of the git based workflow I'm
using :(

AFAIK Dan and CH were both tracking conflicts with linux-next, so I'd
like to hear from Dan what he thinks about his series, maybe the
rebase is simple & safe for him? Dan and CH were working pretty
closely on CH's series.

Jason

