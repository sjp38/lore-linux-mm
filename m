Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4A39C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:42:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 915F721721
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:42:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="I9ohJ6GN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 915F721721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 428CC8E0005; Tue,  2 Jul 2019 14:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B0ED8E0001; Tue,  2 Jul 2019 14:42:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 204C88E0005; Tue,  2 Jul 2019 14:42:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C158D8E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 14:42:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so19964244edw.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 11:42:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=t+FoI6vpCgiLSBqPMjFHBUD4fTkpXFG2F39LPBhxl74=;
        b=Zk0mqqK1EH+g6XOc8AKK8Lhuwx5Bb1A7lqpHzlwBIqvErY5HFLpMb+Lsaz6dZL2VIV
         vJWS55a47mHNdT3jEH11P+D41QkEPcFELaJBmGAiwTKW9ucRKobpu5OowxQ2TL5XRico
         drgXx5AsOvamduyrWsxkl95TMGedLQ0yZ+dimpF6JqnZqcrPy8/JkhXtfl+2qUeeAcKF
         nSurTXz/Os5Ln68ry7YS5CnYwP0y4fFwcdGd2wnUZ06A1tYF4JkJ1JaN7+MImLZH79Y2
         w02HfVv2Yrx5WogKBQ6JN4tvnpfdS44zVU5eEn03PB+QJi4Q3PUFFQlYwA7NSIGhxAur
         sfsg==
X-Gm-Message-State: APjAAAUb4tM5Qci+o5dzrVourvZtAP67byfHpt7xvTxOZVf2J6Y6QXra
	vgHHtZUc4PYIiw6boqMAgj81dZTnVpTnHOmJRk+KW6nXU+cSnAmWnjw390edkMfzv+ddRpmU7iA
	IYZ78XmdkVcvheTNuihvZdKRqgYOceXA1tfIvB+e5P8XOO4sT+n5G+MokAiBJIYVNeA==
X-Received: by 2002:a17:906:4ed8:: with SMTP id i24mr29526516ejv.118.1562092930345;
        Tue, 02 Jul 2019 11:42:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaQbghyBVAZCY1XzCzDDp4aCTHZsvX/jQ/whLz0UIcyOiFLR3bMGnH3ZES8CGjL0PCKk9O
X-Received: by 2002:a17:906:4ed8:: with SMTP id i24mr29526436ejv.118.1562092929207;
        Tue, 02 Jul 2019 11:42:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562092929; cv=none;
        d=google.com; s=arc-20160816;
        b=P8Hsc2uiX8va+AQDqc1YGNbXzc/Ysnz5xb93g/bn2RWJWTUeLJCEuuAfhwUcv8+suz
         KH1oKgcg6djWxhDLDtxVcyeKk64uTA5y+lyygtOPNbVPhdWAziZE014CoiXxVQUClxOK
         8vYgGbo21Vnwt5r+n3TvjE+/jsX/pzU/LbL0lxjnV7eMAyuvgT0/yN9+A/W86dQZxahS
         yrOWCQvoXCVpLvLz9etDn/1W2LJDHt0x4jBnWcJjqu5Cf2sJMFhgX6wynHiTOe2B5Ilx
         LYhZpzzqAwz5Bk2gPDYm1uJeAD5cwBBMVcaExxnMQpRXUDsPnRf7XS3S8uKLJgjD5bIh
         VGdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=t+FoI6vpCgiLSBqPMjFHBUD4fTkpXFG2F39LPBhxl74=;
        b=RInkfhgYGwcXEAeI+LsIEgphe5jGfcbv0tegaKKOW5iyKi7VsOwFsxhHpZ1auz0inT
         pJrMGs1eCcWjXMCfC3YIKnta5d2X5hSkS0Np3WuOXmeILU2N2SW/gXIp1RElXALIXfQs
         CmAYLaQhRFh8z4sc2M/jhKFcJnF0MNLRPKYtwH/6EQHIPXS9DRn+Tp8mJBCykXodRjzQ
         FvmvRP+16A5VNglGWlB0ONvXpe98UomXoyjvvATtfdpYXqj5YmQMo58IwTsGgl3wCyZe
         BhjoOzovHN3eif8qoYU3Ek1V/AJv3m5UpOlndrmZwlSq49xZ+5ce6Xmq8BIAZVsF0EOs
         4YTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=I9ohJ6GN;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.57 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80057.outbound.protection.outlook.com. [40.107.8.57])
        by mx.google.com with ESMTPS id g6si9168605ejb.140.2019.07.02.11.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Jul 2019 11:42:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.8.57 as permitted sender) client-ip=40.107.8.57;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=I9ohJ6GN;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.8.57 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=t+FoI6vpCgiLSBqPMjFHBUD4fTkpXFG2F39LPBhxl74=;
 b=I9ohJ6GNRLW+Zm+ooghClKVijPw+7yhdPymyZ9UYfnb4h8l6cgxmEgeOCdNbseE8x/L9Ge3wh5JFWVDJkBobwtg4AMDNxisbgOSckJW6DEFsDhCpj4Vvnc0r7ERyJeLyh4zmpM5zcIi36u7IFgX/RRdLh9hX6jYVNuPMYsv81uA=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5855.eurprd05.prod.outlook.com (20.178.125.84) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Tue, 2 Jul 2019 18:42:07 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Tue, 2 Jul 2019
 18:42:07 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups v4
Thread-Topic: dev_pagemap related cleanups v4
Thread-Index: AQHVL9UU5cGGdRKLlkyPcV6XfRMxZaa1bVyAgAI+pYA=
Date: Tue, 2 Jul 2019 18:42:07 +0000
Message-ID: <20190702184201.GO31718@mellanox.com>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701082517.GA22461@lst.de>
In-Reply-To: <20190701082517.GA22461@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0020.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::33) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f3e918f6-e7b1-45d3-220d-08d6ff1cfc06
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5855;
x-ms-traffictypediagnostic: VI1PR05MB5855:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB5855D9FC2C87AE8EDF4F3360CFF80@VI1PR05MB5855.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 008663486A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(396003)(346002)(136003)(39860400002)(376002)(189003)(199004)(36756003)(305945005)(7736002)(6246003)(2906002)(54906003)(64756008)(81156014)(8676002)(8936002)(86362001)(81166006)(53936002)(316002)(6916009)(68736007)(478600001)(7416002)(3846002)(229853002)(5660300002)(6486002)(66066001)(102836004)(6506007)(66446008)(6512007)(14444005)(26005)(4326008)(25786009)(99286004)(186003)(33656002)(14454004)(486006)(446003)(476003)(6116002)(256004)(6306002)(11346002)(1076003)(6436002)(66476007)(76176011)(73956011)(966005)(52116002)(71200400001)(66946007)(386003)(66556008)(71190400001)(2616005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5855;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 uxvz6FxwQNsbgdBscCEIRaUYaJ9Hx5UYarazHW+5NehM9eLqQYvVoI1KKwDxw/TefzXSdN5/4xxaq2D7Tani/hQ3Ba46KvDWFZX1MzCawz6jHovyW1WbVATRJPe/6oCfFCi3u7vgRuAnaIKDN7CqC0ljSMhNokZQnmPfYTlZjMpHjSkEb/fv3JDQ1CElySfqAL/l4SpYJpExh8oDwUQRFHHntindvjHxrlA3vnEVyvFJ3u9/MyorpuyISuMH3O9fpPEFzvbkZ+C/6mcbz2FnOogmpZQUZXV8McdcqbNVN5fOXX29ykI848fp6PhT8GI+2FA8t3lq6/klVApz+1NqJaUYSLnxp43VAin0GArLmHF+KBQlgy2AbPkodq7v9nnCYT3QUUxkXF0uDyCQgO7rpgim7bFHYuOpyFu69U5lnyA=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <ADE83ECAC2BC474EA837455494A5DDBE@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f3e918f6-e7b1-45d3-220d-08d6ff1cfc06
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Jul 2019 18:42:07.4459
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5855
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 10:25:17AM +0200, Christoph Hellwig wrote:
> And I've demonstrated that I can't send patch series..  While this
> has all the right patches, it also has the extra patches already
> in the hmm tree, and four extra patches I wanted to send once
> this series is merged.  I'll give up for now, please use the git
> url for anything serious, as it contains the right thing.

Okay, I sorted it all out and temporarily put it here:

https://github.com/jgunthorpe/linux/commits/hmm

Bit involved job:
- Took Ira's v4 patch into hmm.git and confirmed it matches what
  Andrew has in linux-next after all the fixups
- Checked your github v4 and the v3 that hit the mailing list were
  substantially similar (I never did get a clean v4) and largely
  went with the github version
- Based CH's v4 series on -rc7 and put back the removal hunk in swap.c
  so it compiles
- Merge'd CH's series to hmm.git and fixed all the conflicts with Ira
  and Ralph's patches (such that swap.c remains unchanged)
- Added Dan's ack's and tested-by's

I think this fairly closely follows what was posted to the mailing
list.

As it was more than a simple 'git am', I'll let it sit on github until
I hear OK's then I'll move it to kernel.org's hmm.git and it will hit
linux-next. 0-day should also run on this whole thing from my github.

What I know is outstanding:
 - The conflicting ARM patches, I understand Andrew will handle these
   post-linux-next
 - The conflict with AMD GPU in -next, I am waiting to hear from AMD

Otherwise I think we are done with hmm.git for this
cycle.

Unfortunately this is still not enough to progress rdma's ODP, so we
will need to do this again next cycle :( I'll be working on patches
once I get all the merge window prep I have to do done.

Regards,
Jason

