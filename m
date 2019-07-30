Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FFA2C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:15:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA877206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:15:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="r85R4yma"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA877206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0348E0005; Tue, 30 Jul 2019 09:15:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 650418E0001; Tue, 30 Jul 2019 09:15:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CA438E0005; Tue, 30 Jul 2019 09:15:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF9638E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:15:02 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so31858818wru.16
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:15:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=57mhJ9lMltaZjfOvKsO3150A4ENNC9zgifoRzzxIcoA=;
        b=EjOlfHVFzkuxpvzNmzXUyMhRtu4oFTQ1PZ4p8hhyI1QXmhBYMInfJQNeKtzwiKBSq8
         xcR1DbVa90qXNRzdEQ/3wX1rvUuBxSPhP3zJ9eCIQlrDcJco6lE2me9RyGeuHE6kHhlK
         cnN/saQrdnQXNJPxOHEOsOMfVS9HGwTWfnEnDw3rOcQJh9w8uItwr4eBLZI3LWfhkq2g
         51KpLD7yGcSBZNqJxrnwqhMRc2aYJh1KxMVj70OxzPkRzv0pn5gLpSmrilgXqjX8t17b
         5zUiROWNxX7nCJN3Ip3ZpE7ok4b9zxiTCucXEwBaCYTAlfbmK3xKa7fL3dcFj7HWpKWA
         u9Yw==
X-Gm-Message-State: APjAAAVZchnzAKSP4KoZ6oLFNpliGeckbjUA6Q/p2qwZNGCZlfO7LlZ2
	0Y+gJIr3fBSgZEFl2Q/qvn/QZOkAIIr81lLrgC6c5Gf+FDM8IjB2YB0oJ5/LeQAlqXQ803sA6+d
	Ca12XAhYwMzTt7/Q4vhIt8TBQArCaF1xL6xowrOglatwIqLCFjdYPg+tE5Fm27ewO0w==
X-Received: by 2002:a1c:ca06:: with SMTP id a6mr7870432wmg.48.1564492502495;
        Tue, 30 Jul 2019 06:15:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqLro0dap/x8aUW4mJgLmwUICJXHqX2AhUnKnALzv7GAMEMF+t0BXBaYKk3dgPW76WRz9A
X-Received: by 2002:a1c:ca06:: with SMTP id a6mr7870385wmg.48.1564492501766;
        Tue, 30 Jul 2019 06:15:01 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564492501; cv=pass;
        d=google.com; s=arc-20160816;
        b=ndZnvROr+c2gKQqETGILssSw2IrtjdPT/60QKiK7ieIk5m1RZyAOabtFrSzFhld8Ko
         b04osRnMBlSIK/JfQiOrZpfvTBNAnWNDAzFbQnbkwmVxvgMOWllseVWdJG1CvIi0mVo2
         nrliMc+Qx7FF8EWs8xR9F5QJaH5PFEED6caj+0HKqw2gKtkp1eL2wb2nHlAa3Eh9DoOs
         M97sOwYvdhGLFs5HkoEeLLk/MaZliEexqaDne1py7MpPdW5ph1t2yM59qupRuYP45B6S
         Mitsh35cMcZfgcih8l1DBXOk5Ol90NwTKOr17sFV3lys8eC7kJXqQ2svTB9wZ2JiApfV
         h1Cg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=57mhJ9lMltaZjfOvKsO3150A4ENNC9zgifoRzzxIcoA=;
        b=wjlKQfdKNDrmFEqvJBF1X9jDVcSM5slTCiDOLDIxqT2/azcYOKncC9e4bjDZpYrX15
         XCVsWWLjGtQ+f/SkWXWaw1bLYGjq5KJHgmNcm55vtenXFf7XIYnjTxuDasQMiaTuusTs
         iahQlvZdNsbdn3Wqw2LMS0BmaoVhn73jMLnezQbWiuZGNaEJ1Z+jAFvtuQMMR1Uhu2O7
         tpEwwlDAMgvVfCIw6tDM39FGXORdGs0Qb5smS058bdlTNgKmL1Alpj8S6yRR3YxVXHdE
         g4FJttbmYnukV5+ubgK7V1XCl8v5A5ujUT8mxzGm9+MwWun1bW5M7FOETuGI1LloWUHZ
         KWAA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=r85R4yma;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.82 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40082.outbound.protection.outlook.com. [40.107.4.82])
        by mx.google.com with ESMTPS id w16si59662845wrl.74.2019.07.30.06.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 06:15:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.82 as permitted sender) client-ip=40.107.4.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=r85R4yma;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.82 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=YeyHKzxapEPVsPmYMjmnzxv52O6MhXo2GMBEa8dRb+fRGhk2kRwQm8SrkjZDxyB1diwMJoDLUmgRUz9JQu5IxqMfS2I7tHyzbiDPDd556kN/mkx0gpZAWRZ0nJdvQhJoWEvdeLspd4uhxAjxwlhkP/XqW/IZ4nOaESLXxRKXNU0rWtZ4CZeqFNeoTMoJuNqYbX6u3a/ShzAvs+ldJT3T4+ID+Gj6A/B68O+vDLMFgqnZ+qec07ob8CS/p/238G9ZneXC4g6Te4Hn98KFm3FzevWvBWgqQe44sPMdc2Y65nbOnVd04pLnTBTJu/z6NFK1uWmMNKZtiZE6SJ98JME+Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=57mhJ9lMltaZjfOvKsO3150A4ENNC9zgifoRzzxIcoA=;
 b=JvmnHemilL+Oe7BEKHfkoUcxQyTk2V9ecEYkzC9xQs8D93FojseY9SnjLSi/S/6vbBnNO28GLlDlLm9tIxTLwslNkVCS1OaY4hy5HD5huy02FaEWR7ei730q3mQM6XFF0sH4+gVkA7WFxhjKUtxQ9vnVNFlnFUqk0k3xd+AGNjLX6GNR4PGqwvItpmR68VU+nTaXgQFAIgX9LYIM4kUsKMAvImraYPwyZaIIx/SmKWxW9kABYgwA3qOMOJjXhXK8vqVdVjTVB0rZyNhuts9ADIcT7yYbtJz1UkPhjPtRPot/cZXHaeGZourhulg9GrP7WyGzevIdqx+Lb1GPeN+iEg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=57mhJ9lMltaZjfOvKsO3150A4ENNC9zgifoRzzxIcoA=;
 b=r85R4ymaS8JN55FyHNv8uJSJgkrQ44ttgTpkVWvZgwWV4EszNSZOMcgJ54hyc6RDJTFTJJJEYA+Kmwnp5bJGksFqeHQtjD0Qzr/D5ZoBgX8NcykCHq0teC9wyIFAKOVu3arBC6XKVJYgv9LTBWegrPWROPvz7E7UZAptTETHZmQ=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4288.eurprd05.prod.outlook.com (52.133.12.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.12; Tue, 30 Jul 2019 13:14:59 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 13:14:58 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/13] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Thread-Topic: [PATCH 03/13] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Thread-Index: AQHVRpr4kL6aKlcudUqEUBBy4/lXjabjGXIAgAAJtACAAAExAA==
Date: Tue, 30 Jul 2019 13:14:58 +0000
Message-ID: <20190730131454.GG24038@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-4-hch@lst.de> <20190730123554.GD24038@mellanox.com>
 <20190730131038.GB4566@lst.de>
In-Reply-To: <20190730131038.GB4566@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0007.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:15::20) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 567c83d6-26ec-4ba9-1306-08d714efec1a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4288;
x-ms-traffictypediagnostic: VI1PR05MB4288:
x-microsoft-antispam-prvs:
 <VI1PR05MB4288B858C7DEF569EBA2921FCFDC0@VI1PR05MB4288.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(396003)(376002)(346002)(39860400002)(199004)(189003)(54534003)(86362001)(33656002)(68736007)(25786009)(7736002)(305945005)(14444005)(2906002)(6916009)(229853002)(256004)(446003)(478600001)(6486002)(6436002)(1076003)(71190400001)(71200400001)(7416002)(66066001)(36756003)(11346002)(8676002)(4326008)(4744005)(81166006)(81156014)(486006)(476003)(186003)(53936002)(316002)(8936002)(386003)(6506007)(76176011)(26005)(14454004)(102836004)(99286004)(6512007)(54906003)(52116002)(2616005)(6116002)(66476007)(66556008)(66446008)(64756008)(5660300002)(3846002)(66946007)(6246003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4288;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 mG8LV/6niYle0ZfCKqOsSXVNrQ8TsIEpZPZqLtc80iGAge6QFyZsPbO30d+w3zdHDTEbD3U6wHgrvsPxKUMejwgk+w1i9GxHsu1wuIVJa0S5iRpKEjH90e5zi+s/3+gRx5AHYU+OeLLboPMXlrPOYCThmhXaZdDTxKJYeN1e02y099G/gaySkSr+sG88WiJQari78KQ/O1YAdV6b0mFHtNbEyv9g1PzFaEne7NAS/Tn0ypDFQQtG3k+P09mmNpwFr4Y1HXZAJm5fC7pJCML7w+0xdH1tjfhXcUNJIReXF7/mSduVlhTx5f4b4eUMed/wNqK33lbMvZ6Cpuu+wq5ZKRwAbWKtdisCmbKE4lDTZBGlqIt+GeEG5xbxh2gO/ASl9WiZt4YsXdBGriWoxOEUVDFJrWRKV2AxKVnJIw2ma0U=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9EFBC7D2033F0A4F9278F6401B93A640@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 567c83d6-26ec-4ba9-1306-08d714efec1a
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 13:14:58.8754
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4288
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 03:10:38PM +0200, Christoph Hellwig wrote:
> On Tue, Jul 30, 2019 at 12:35:59PM +0000, Jason Gunthorpe wrote:
> > On Tue, Jul 30, 2019 at 08:51:53AM +0300, Christoph Hellwig wrote:
> > > This avoid having to abuse the vma field in struct hmm_range to unloc=
k
> > > the mmap_sem.
> >=20
> > I think the change inside hmm_range_fault got lost on rebase, it is
> > now using:
> >=20
> >                 up_read(&range->hmm->mm->mmap_sem);
> >=20
> > But, yes, lets change it to use svmm->mm and try to keep struct hmm
> > opaque to drivers
>=20
> It got lost somewhat intentionally as I didn't want the churn, but I
> forgot to update the changelog.  But if you are fine with changing it
> over I can bring it back.

I have a patch deleting hmm->mm, so using svmm seems cleaner churn
here, we could defer and I can fold this into that patch?

Jason

