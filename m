Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 992CEC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 19:27:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 495832084B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 19:27:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="ZSwtME/S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 495832084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EEB26B0006; Wed, 19 Jun 2019 15:27:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 578198E0002; Wed, 19 Jun 2019 15:27:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F1C08E0001; Wed, 19 Jun 2019 15:27:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF4466B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:27:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so777097edp.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:27:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=FSRKc0hpLpMPKshog4wha+zcC6Sxgq2cZ5PlvZB0qoM=;
        b=ictiu0PgBa+4OsVlYHFVdp7TsF9XzadfrdhBlYDioG7sOGS78jFFCbogz7VT/gRI+f
         uFuBRKsioBmYPo4DWyUXRj67DSvACeZUAHYc1f2ifmZsJ8q2tGNOeXIWWd5BJxuAdzgM
         5CByCJ6vpASbsw1J3bqO7aWhepXW5NXIWLgHaV/UAyAOfvfpJ1WIjEzwm9nEeGVq3AKU
         U612wz7ilW/yi0U1W2zWiCSXKHNejyyfPL3khXwWPN/gSnG7EYklfis6Ui+8vnbd55/T
         ZOGpJV+ewufk/4S4hErwdpwNcG4+GG3JQzeTOgmIbFRMJp6FH01OYrhAK4Dg0TkejrCI
         fy1g==
X-Gm-Message-State: APjAAAXicdlUPEPQgZv8j5CIxXEhA9t/BM2ROrAJXsDuygofr6XHKv1Y
	H6a29wU7yUCQ8ybLTZ8l7qBH7fHEOX7ENAL9n6ykDEQHZX3rNgROhA2dzUeN0IjEHKDFQhVxVhN
	GYTT2sM2Yp+4iUV4ql7XfO8G2c/aTqc7YXAWZUyhOyDRPoRggZo38WMQziobYXLESwA==
X-Received: by 2002:a17:906:4e57:: with SMTP id g23mr35155893ejw.52.1560972448293;
        Wed, 19 Jun 2019 12:27:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpCYb+CmzkOx2h/f6YhZ/nVrUyncdAeKnSkKvaNjJveB7ZxWaAc11YHspEZ6GDf96U3Hz8
X-Received: by 2002:a17:906:4e57:: with SMTP id g23mr35155836ejw.52.1560972447422;
        Wed, 19 Jun 2019 12:27:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560972447; cv=none;
        d=google.com; s=arc-20160816;
        b=QPLhL/br9jImKLQB42EQLZI09a3+lk4mBwVK6lmYXI2QcXVrgjgXCiNWyqbd0sTi9w
         YwfLgng2+s/SIDnug3jlyQ6F+Xqs0LtPO9tlWzMo8z9Xml6iYpGYBONicDqgIx5ctOG8
         XTLFSeHFGJdLpmzy4sfduzUKBziel3rFMxIyP+PWp06vhfqT806mN7RaVY3y4zUKRaFh
         OoEzf07EGAB4Ac0/5TG74M3MzbIwPaVi8jGK13vGWlyuktafcIHravlC6Fv0cQgoF1LO
         1qKQFrVKBrdL1qhuMPkowfrshQt1Bouv12wkdVLjxzyb8VbeIEC2wmUWoFRaRmFBygZz
         Xvtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=FSRKc0hpLpMPKshog4wha+zcC6Sxgq2cZ5PlvZB0qoM=;
        b=Rks2juanM5hFnLCDZx78mgn0bEMBfOE+jA1/n0RRO9rOc2aJOdkei9oiEItKjbtDhO
         S2dC2TWSlKXu88qF+WbIQbOQeE4n8AVNZUzrjeb8H/o/fMNwqHouMmkuUD9zpJJhWEVK
         GLj3sFP6qKs5a8CkRnQErltb3X5rd/zjk4AYuRXLevvN3EETmPrrSaIYfOV/lCC8m2gV
         Ctwj2xBY1+dSsKnJUxuslNItjd8AmSFCfsZc6vIP4lPDo5pFXyzKxh6whqdGzsIP1yWs
         m/x3NQynlbxqTQbg39HPULNGIxRKBruzh5mhuxofpYYIduHLLpG6RHarqYxk1fNVi+Bi
         ltuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="ZSwtME/S";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.53 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70053.outbound.protection.outlook.com. [40.107.7.53])
        by mx.google.com with ESMTPS id m11si11338272eje.369.2019.06.19.12.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 12:27:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.53 as permitted sender) client-ip=40.107.7.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="ZSwtME/S";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.53 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FSRKc0hpLpMPKshog4wha+zcC6Sxgq2cZ5PlvZB0qoM=;
 b=ZSwtME/SMf2qmA+BpeVW3mHny8REA3FCMUxCHE8lRkkEMxElMjsQ1DX2cnJvGZGVJ8BbeL4b1n4axUNDLngO9Tr18RWshV7wZkZtMhndAHkT43IXAIrC7stLRS10BWy22PBb5aNUpDNdt5zSYXs70bV1ne5Av63H5Wf4DYzew6c=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5072.eurprd05.prod.outlook.com (20.177.52.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.15; Wed, 19 Jun 2019 19:27:25 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.014; Wed, 19 Jun 2019
 19:27:25 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: John Hubbard <jhubbard@nvidia.com>
CC: Ira Weiny <ira.weiny@intel.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Christoph Hellwig
	<hch@lst.de>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Topic: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Index:
 AQHVIcyVeqgMzBs0VkumwilsEzSkhqaZ/TwAgAACYgCAAAF6gIAAT5yAgAALIACACQqXgA==
Date: Wed, 19 Jun 2019 19:27:25 +0000
Message-ID: <20190619192719.GO9374@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com>
 <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
 <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com>
In-Reply-To: <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0017.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::30) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 900ad4f4-9a37-403d-9297-08d6f4ec28b2
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB5072;
x-ms-traffictypediagnostic: VI1PR05MB5072:
x-microsoft-antispam-prvs:
 <VI1PR05MB5072502328C7585990C51C52CFE50@VI1PR05MB5072.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(396003)(346002)(39860400002)(136003)(366004)(189003)(199004)(5660300002)(86362001)(6246003)(7736002)(73956011)(316002)(66476007)(71190400001)(7416002)(54906003)(486006)(1076003)(71200400001)(256004)(66556008)(2906002)(99286004)(26005)(11346002)(446003)(76176011)(476003)(52116002)(186003)(53546011)(6506007)(386003)(2616005)(36756003)(102836004)(25786009)(3846002)(8936002)(229853002)(6436002)(66946007)(6916009)(6486002)(68736007)(81166006)(53936002)(6116002)(66066001)(64756008)(81156014)(33656002)(66446008)(8676002)(4326008)(6512007)(478600001)(14454004)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5072;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 s0JMiyaM6v59K9Eqvq++39Arx4aDM+CpGKjs2X6UorK6bcpv6l9Q4i9tauNvj0vSZSD3N4mIT8Hy0RczR7OULw46AWpykaDPGF1OEg+O77QdgkpDWOpv6EWjxe0pahP7ur+CMqTY53LiG+BxjnFFCp8JQJtmb5bwiHUJegB+WQ8YHQ6cIuwuXKtyqf0J+vptYI6jTembRhhk2NbSxqeJ3aICqHn6qKizFRKk258+72b4as+ZsMq8T+L+kqMZ2lscGlebcSehAcXWxlWBgFCEtm5ZQ88/WBly85cxXZAolyF8V22GdtISRlQRpn9VBCgqKpJ2hvdBxWvhVfx0QzufxBaFBAPjRVRMNsw/QVIsTpXD2aPXpIJzN7yy81iT9PhiwC6koEHGMSJpMlOvS+4N3ZFn54BqDa6OSepntXF0w00=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <081C2DB7B7A13A4A93487CC051D6E961@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 900ad4f4-9a37-403d-9297-08d6f4ec28b2
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 19:27:25.5442
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5072
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:23:04PM -0700, John Hubbard wrote:
> On 6/13/19 5:43 PM, Ira Weiny wrote:
> > On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
> >> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
> >>>
> ...
> >> Hum, so the only thing this config does is short circuit here:
> >>
> >> static inline bool is_device_public_page(const struct page *page)
> >> {
> >>         return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
> >>                 IS_ENABLED(CONFIG_DEVICE_PUBLIC) &&
> >>                 is_zone_device_page(page) &&
> >>                 page->pgmap->type =3D=3D MEMORY_DEVICE_PUBLIC;
> >> }
> >>
> >> Which is called all over the place..=20
> >=20
> > <sigh>  yes but the earlier patch:
> >=20
> > [PATCH 03/22] mm: remove hmm_devmem_add_resource
> >=20
> > Removes the only place type is set to MEMORY_DEVICE_PUBLIC.
> >=20
> > So I think it is ok.  Frankly I was wondering if we should remove the p=
ublic
> > type altogether but conceptually it seems ok.  But I don't see any user=
s of it
> > so...  should we get rid of it in the code rather than turning the conf=
ig off?
> >=20
> > Ira
>=20
> That seems reasonable. I recall that the hope was for those IBM Power 9
> systems to use _PUBLIC, as they have hardware-based coherent device (GPU)
> memory, and so the memory really is visible to the CPU. And the IBM team
> was thinking of taking advantage of it. But I haven't seen anything on
> that front for a while.

Does anyone know who those people are and can we encourage them to
send some patches? :)

Jason

