Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A004C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:17:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 332AE20673
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:17:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="nCu10o7P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 332AE20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B61756B000C; Fri,  7 Jun 2019 10:17:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEB3E6B000E; Fri,  7 Jun 2019 10:17:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98CB46B0266; Fri,  7 Jun 2019 10:17:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49E1F6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 10:17:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f15so3382439ede.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 07:17:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=498yq0m+SHUwWSq8e+SHH+wyGc7fgwEQ3BhNsZt4ya8=;
        b=IC64Pk5foZb/iuOArgEUrvhMpmd9O7PVDviwgpC4Mg4kP7MThEpdt76V8pfc4EeEls
         4AurIPOwHTyEVqCHugk39+88itoMgfNJlLfN7r820C6mdd0YpmR+Wsr+EWdXeQyOz72W
         M3jzy3sbGb9SpQaWF0DF/pcSqLjaR25+bCNU0lnndIe5Rt7Wuu4RhhOpQAf9SENQm2QR
         x6LAaANE1YeyOVZl/yDsiWMpo1WOJI+Pk7r1o0d8CZt1Fbt0mfTTOg8/QlNdcROWD80a
         j6VLrx52uxQ5Xh/6pKQIM4KxoCCadVNwmUdOs6MW+0hxM/wspZyEOhjgrduRRlQK7zzk
         kQGQ==
X-Gm-Message-State: APjAAAXzfJab5+c+TCeI4vqRW+rCHPxq9nUYG0irjr9BWU5Dfgr5BuK7
	hJ6R9h+O7Zh+uIsOIE9/A5XthkCc8+Fn0Qh3y71FvbOlPt8G0I5GF+mM5nhixCqbIqX01GkQZQj
	DNCUif8zFiR2ePOf4ygHR+psT90bWaBo3RY7ZTNI+VIDYCf4Jwq4VFmDIUXtH1qqWkA==
X-Received: by 2002:a17:906:9a9:: with SMTP id q9mr46565479eje.125.1559917041849;
        Fri, 07 Jun 2019 07:17:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXHIcw6exG8qLgPIzkjk7l6rDGA6CP2kQndO3kyPTA94t8nvxb9xdN5AwUTiSvqO3PK73a
X-Received: by 2002:a17:906:9a9:: with SMTP id q9mr46565333eje.125.1559917040149;
        Fri, 07 Jun 2019 07:17:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559917040; cv=none;
        d=google.com; s=arc-20160816;
        b=lVakbNsfZNZULjhB6CZXJktebLkV70i/OLpjJkvDcPVIl5mmS+JQ4Ul5cbU4YwO6ZO
         gR5tYnMHHom3g9+uuhJLPwFILP3u3DS5ujmNB/MtqzVmumZI2bQv74cqUTnc4ppUzhLc
         A8jISLTMKJTlbuLq+ihVEruj5I/02V//cg8dLG2A4nkCRo63UB/2EsDp3ndDQhGORuEA
         qPmIy20iOmV2q6M8/XDQy6KEhQQcqyub4JiPX77buiaIVlmbU/7frJo2mJYK3nBnQXxm
         uhED3pITWsUm1l1PRlM77wnRH5D1dzcHDQrGNaae+fKXL+MLYxpSn4gvI8vGvM3t1Jsm
         oi0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=498yq0m+SHUwWSq8e+SHH+wyGc7fgwEQ3BhNsZt4ya8=;
        b=mBY8ABG3amI9kuLB0f6Ks2XOXns49ODB9TdxLmWFxLyQouQiLBfDytneWcePGnY6tg
         ehufn+1nomKP1MMVeI4yz2sumw4A0c3zOJUhNHVxjVWWw5WNhB8oW68oFJMa49/KQ4I0
         uu64iw+q1ED2OOJaD7obpdaI6/kBzL77Co6rEWDMQ2vDfvmOS7KBNzM/owDaudO7GhJq
         yvkTEDsxdf5zu7hPdu5+mqOGSR8NF6lEMF1EJK86U7RSCFsrFUzjSODUBBNDx+VEiMng
         tRmGZvwfqLxES13e00kdLNVk6HVNT+1L0mRyWwLueCBQxrvR4B7im1HKlLNkSIuEcD/U
         z0KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=nCu10o7P;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.74 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30074.outbound.protection.outlook.com. [40.107.3.74])
        by mx.google.com with ESMTPS id m38si1566695edd.215.2019.06.07.07.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 07:17:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.74 as permitted sender) client-ip=40.107.3.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=nCu10o7P;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.74 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=498yq0m+SHUwWSq8e+SHH+wyGc7fgwEQ3BhNsZt4ya8=;
 b=nCu10o7PN1wZvzjF7TNJjd0UUDugqJ19ulToaLF8odHHGA9oHxig6WG2PdRmMHJXNWqcohu5Qv24qA2qborFMAxHjPHdRXpbiqaZnQfFImRf6njhisUxgwSer3X398ioLV/U43D1PFo1ADiFQOQqXkC411NLqCk2qP7W4JqPLPc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6141.eurprd05.prod.outlook.com (20.178.205.87) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.12; Fri, 7 Jun 2019 14:17:18 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1965.011; Fri, 7 Jun 2019
 14:17:18 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ira Weiny <ira.weiny@intel.com>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Jerome Glisse
	<jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard
	<jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 01/11] mm/hmm: Fix use after free with struct hmm in
 the mmu notifiers
Thread-Topic: [RFC PATCH 01/11] mm/hmm: Fix use after free with struct hmm in
 the mmu notifiers
Thread-Index: AQHVEX0K7JKRenZ5i0yE9OOqwFE+2qaPY2+AgADxAIA=
Date: Fri, 7 Jun 2019 14:17:18 +0000
Message-ID: <20190607141715.GC14771@mellanox.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-2-jgg@ziepe.ca>
 <20190606235440.GA13674@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190606235440.GA13674@iweiny-DESK2.sc.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR1501CA0012.namprd15.prod.outlook.com
 (2603:10b6:207:17::25) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 26aff798-13f4-4096-10c3-08d6eb52d91c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6141;
x-ms-traffictypediagnostic: VI1PR05MB6141:
x-microsoft-antispam-prvs:
 <VI1PR05MB61416E67D450A9870407A720CF100@VI1PR05MB6141.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2201;
x-forefront-prvs: 0061C35778
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(366004)(39850400004)(346002)(136003)(376002)(199004)(189003)(256004)(6506007)(102836004)(71200400001)(71190400001)(6246003)(76176011)(53936002)(52116002)(386003)(14444005)(14454004)(229853002)(486006)(6916009)(25786009)(4326008)(36756003)(3846002)(2906002)(478600001)(54906003)(68736007)(6116002)(99286004)(6436002)(66946007)(66476007)(66556008)(64756008)(66446008)(476003)(6486002)(5660300002)(66066001)(86362001)(73956011)(6512007)(1076003)(8936002)(26005)(316002)(446003)(11346002)(2616005)(33656002)(81166006)(81156014)(305945005)(186003)(7736002)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6141;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 S9PkCY1ICVuPK3MQ2qDYV4gAFsv+fn80mXAjICfCHo2KGasdWny+Vn09vRRJtHO2rGbYW+fan7RvqUwlcnx3ZJTkCWb3apHioR8fTrPHUmxtyolq/dHDheIlVBPzJHTF4/qLNS1M94NzSpph+mtXp3uZftDYCDKBVDDopMBiCp9NE/TiTYglPRzFTldzSKY81PRejIVZSkY4EMB1nTcaMmU4u6s5mStcDXQpNELVqEZo1S30McBwWRN6k6x7x05qrqyFhLjxFSc2prs+Y82vSAnBB0289Hsf7L4qEibNFYNGK53wLzpIm1jI2M9MRABuZCJgNM9lyz970ZRrFmHoFJ+pG93hnlcqrcUOSIR7r0TmawxWy+H8G56jwyWvOqfwT4lLFGoPYEB9tEAASxBDpCgnW0EPbY5l6SYXcrzxuUQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1E7B450F71F8AF44AD1259D6AFA5DCC3@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 26aff798-13f4-4096-10c3-08d6eb52d91c
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Jun 2019 14:17:18.7971
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 04:54:41PM -0700, Ira Weiny wrote:
> On Thu, May 23, 2019 at 12:34:26PM -0300, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> >=20
> > mmu_notifier_unregister_no_release() is not a fence and the mmu_notifie=
r
> > system will continue to reference hmm->mn until the srcu grace period
> > expires.
> >=20
> > Resulting in use after free races like this:
> >=20
> >          CPU0                                     CPU1
> >                                                __mmu_notifier_invalidat=
e_range_start()
> >                                                  srcu_read_lock
> >                                                  hlist_for_each ()
> >                                                    // mn =3D=3D hmm->mn
> > hmm_mirror_unregister()
> >   hmm_put()
> >     hmm_free()
> >       mmu_notifier_unregister_no_release()
> >          hlist_del_init_rcu(hmm-mn->list)
> > 			                           mn->ops->invalidate_range_start(mn, range=
);
> > 					             mm_get_hmm()
> >       mm->hmm =3D NULL;
> >       kfree(hmm)
> >                                                      mutex_lock(&hmm->l=
ock);
> >=20
> > Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
> > existing. Get the now-safe hmm struct through container_of and directly
> > check kref_get_unless_zero to lock it against free.
> >=20
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> >  include/linux/hmm.h |  1 +
> >  mm/hmm.c            | 25 +++++++++++++++++++------
> >  2 files changed, 20 insertions(+), 6 deletions(-)
> >=20
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 51ec27a8466816..8b91c90d3b88cb 100644
> > +++ b/include/linux/hmm.h
> > @@ -102,6 +102,7 @@ struct hmm {
> >  	struct mmu_notifier	mmu_notifier;
> >  	struct rw_semaphore	mirrors_sem;
> >  	wait_queue_head_t	wq;
> > +	struct rcu_head		rcu;
> >  	long			notifiers;
> >  	bool			dead;
> >  };
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 816c2356f2449f..824e7e160d8167 100644
> > +++ b/mm/hmm.c
> > @@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_str=
uct *mm)
> >  	return NULL;
> >  }
> > =20
> > +static void hmm_fee_rcu(struct rcu_head *rcu)
>=20
> NIT: "free"
>=20
> Other than that looks good.
>=20
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>

Fixed in v2, thanks

Jason

