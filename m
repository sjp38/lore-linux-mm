Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 756ECC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF9F2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:06:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VfHbP3eR";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="U9a69QI6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF9F2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEDE36B0003; Mon, 20 May 2019 22:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A78A16B0005; Mon, 20 May 2019 22:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F1176B0006; Mon, 20 May 2019 22:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 676FF6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:06:13 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l27so16341428ywa.22
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=JufoTuKodLOP6cNvtUurbE0MDMs17aY9sLS5YnGw8dw=;
        b=UhDztG+8ocTanixoq2YW+uH6Ipt4tmEMpsFZCk0w3OjSK8T49+gCfJnrTIvdAdFE5h
         md12RwPEN6Qmag4dNqlZEh+z8Ryk3WmZ4ccXrLe+93ep5/GbJWtzyIas95Je5I6as75h
         2JgswULL8fBXBVMrLnw0SiaCX4RXleq8a4aU0RLEbHW5cO1kSn2o2CwEBIujLgmQRKCu
         FZVP5MLfsum4ZJt6q2ODaQEtDs2g6swZHnqzeiKoQo6gV1dM7UWDKstOMV0Ugo2sl3ll
         bnjT6HPjjIUn//SP+KXucZ8vKGJ59OPqk8v3yTTUFRR2JkxWYHUEcW6uTmgF5Sab36NL
         1+rg==
X-Gm-Message-State: APjAAAWszkwen22RraJNxE3s3x4sKx000UYzjO3nbqnhE10he1WnNNz8
	Li20Lrms1miR4YKdz7QDyUEPIzfwRwZ7Kbhq017yctUECFAqX3bL3i/78PhXJfPmf+757ok0L7p
	ssUGiW6B2Dwh9QE3O6Nw+ZwTeQhozt7dSoybL8PNlk/9Xo4u1eYj9JnQny0bMLX/OFQ==
X-Received: by 2002:a0d:ef85:: with SMTP id y127mr35814039ywe.471.1558404373152;
        Mon, 20 May 2019 19:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8wqMs0cipCx2PNA/RDwuvLvI9ro8Ooq0Gs3eruhKklf5q+anAhq8d3Atj4IP1/jXZgFrN
X-Received: by 2002:a0d:ef85:: with SMTP id y127mr35814019ywe.471.1558404372528;
        Mon, 20 May 2019 19:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558404372; cv=none;
        d=google.com; s=arc-20160816;
        b=X9rA2lQXuWnOIYzub+kBYM0eSiSJf+6OGYemCUWR6eobFJNUASBejRI54WdKEv6hQ8
         4BVQM/+gdE5eD6a2cSIJL5yUM2hQnVIt4VzpyTSQG36MVIY0Nr+gmuKG3IQe6kJp34NY
         AdDk01i0JFteTl8yvfPPkDZhKn2pnp0Bxwh6yAOmMg4KemnnjkQjozwu657lg58nS3MF
         b3cxeeYqJCb6elFRZUaOU6UETS9EttYrk2VcBSCnA3xuMOHHCV3Jb5pHClcz8XSBmy4Z
         7CYZErBvx18rHUU1QBtYOtSTAZbOFNa9VqCFoGR4jCsPTX5IQmq+BNMrbjkQGSY38EGa
         Iqqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=JufoTuKodLOP6cNvtUurbE0MDMs17aY9sLS5YnGw8dw=;
        b=mOhVHiZBvk2WjcP902fMLBKedzJuNpLgt+ooYmBX+gXh40fr4uXtE6TTKr0QO/A7Tf
         LSi9B0GkEgqWLgZsWjjmnS1mgktlN9XJUQs+nnCQ1WnMxqjybo/h99wyrkjpzr7E7F4x
         Yrdb2iOb5Dv4+QodMB27FUGj72vHK5Z+500k/gtRM/SkmEWXmsfSL1SGdfF35czA+2nq
         uUrYizpk4ZNtX7HZvAxCY+3cgZWG43FD0t3DU9xONdqZHuGqzLoTwVWm9UEYqvs0CX+R
         iUyaXi+WukjU86Vnxw4GxBIhKb7PShrDp9Z5I1lNBq/B9dVthYbWv2c1BvPtNeW7Pugk
         jxDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VfHbP3eR;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=U9a69QI6;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q82si3226459ywg.321.2019.05.20.19.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 19:06:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VfHbP3eR;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=U9a69QI6;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4L1xEL9026293;
	Mon, 20 May 2019 19:05:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=JufoTuKodLOP6cNvtUurbE0MDMs17aY9sLS5YnGw8dw=;
 b=VfHbP3eRnvj1wXJhvJA/w33AM9Y3vvPzH3ypX6ym2zJimfj9AgHBeYQsI0PBhGrVoMkJ
 eJ/C8AJt0tcPRFLGK6jVXDNyxK5IvFK97upJgbm6WU+SVtp6tU9rtS/8e0Qq8SAI73RI
 ecy8gpbOOrBTb2tbm39urcqRQBj4h7h8nDk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sm0ahsndm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 20 May 2019 19:05:42 -0700
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 20 May 2019 19:05:41 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 20 May 2019 19:05:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JufoTuKodLOP6cNvtUurbE0MDMs17aY9sLS5YnGw8dw=;
 b=U9a69QI6d0UrpKYJED1rtLt/AIuBXwHvvdIY7oSWF04D9BZOybozSChPITtBulKEgJnU3s6UnJ2n5Ft/hp4qXaRfoETaJWcEgFlzVkSidSsEYHrjd2Sm5Uy7gN2bsZ2Rai7yOsnt8+ymIjRahgQGuadTCUthDv1St08b+fKKGfk=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3304.namprd15.prod.outlook.com (20.179.58.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.17; Tue, 21 May 2019 02:05:38 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.020; Tue, 21 May 2019
 02:05:38 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <me@tobin.cc>
CC: "Tobin C. Harding" <tobin@kernel.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>,
        "Alexander
 Viro" <viro@ftp.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        "Pekka
 Enberg" <penberg@cs.helsinki.fi>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Christopher Lameter <cl@linux.com>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Andreas Dilger <adilger@dilger.ca>, Waiman Long <longman@redhat.com>,
        Tycho Andersen <tycho@tycho.ws>, "Theodore
 Ts'o" <tytso@mit.edu>,
        Andi Kleen <ak@linux.intel.com>, David Chinner
	<david@fromorbit.com>,
        Nick Piggin <npiggin@gmail.com>, Rik van Riel
	<riel@redhat.com>,
        Hugh Dickins <hughd@google.com>, Jonathan Corbet
	<corbet@lwn.net>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v5 16/16] dcache: Add CONFIG_DCACHE_SMO
Thread-Topic: [RFC PATCH v5 16/16] dcache: Add CONFIG_DCACHE_SMO
Thread-Index: AQHVDs7p5YZCYW51S0W/c+2xf0nte6Z0TWwAgAB+vACAAAmSgA==
Date: Tue, 21 May 2019 02:05:38 +0000
Message-ID: <20190521020530.GA18287@tower.DHCP.thefacebook.com>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-17-tobin@kernel.org>
 <20190521005740.GA9552@tower.DHCP.thefacebook.com>
 <20190521013118.GB25898@eros.localdomain>
In-Reply-To: <20190521013118.GB25898@eros.localdomain>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR04CA0051.namprd04.prod.outlook.com
 (2603:10b6:300:6c::13) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:8d5a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0730f6cc-3600-4ad1-e2a2-08d6dd90d155
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3304;
x-ms-traffictypediagnostic: BYAPR15MB3304:
x-microsoft-antispam-prvs: <BYAPR15MB3304176D412FC8039AD398A0BE070@BYAPR15MB3304.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0044C17179
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(39860400002)(366004)(136003)(199004)(189003)(446003)(33656002)(86362001)(4326008)(6246003)(8936002)(54906003)(5660300002)(8676002)(53936002)(6916009)(476003)(11346002)(81166006)(81156014)(14454004)(186003)(2906002)(46003)(25786009)(316002)(486006)(6116002)(9686003)(6512007)(6436002)(99286004)(73956011)(1076003)(102836004)(66946007)(71200400001)(71190400001)(52116002)(76176011)(386003)(6506007)(66476007)(64756008)(66446008)(7736002)(229853002)(68736007)(6486002)(7416002)(256004)(66556008)(305945005)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3304;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: czXufusqJ0EjO7U4QtmV/sg52PG37cUGE105N3ZrhVVZkBMoLRh6oYzJit8/rae0Q1m3f1nx+mYjIZVUPzGfxcat6j4pbhR9fLgeegBXKfcGxK4hwopsvrlwSDmVcOtdrrN7PTL1Lf02jemZ2YpRsJq+Suiz8idsSaRDFz1fogUG14nQTAqrovLQbnKF5C+Qn5pBEdCPAW3usX5aSHvobkHfnibDDYgkk0EL0nWPW8IHJbG43NFrhWsqgGOi0DZa85gpf+nqRqdMO+ZD2PnOr9jeveEUdRpjxwVo/7aqDmXmzPGyFSgBiRNrFFOlHWvSh8lvcrvXhv8OPrUlcdB5FB3zOusp9rElXOkEGs2Ks7LVITP8SBhB7KLirX32wd0sWmZBDxRO/xcpe2iu/vSevyo3lNE08tHqjphbzvxEXhs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3186B1609B811D4389B9037DA091B469@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0730f6cc-3600-4ad1-e2a2-08d6dd90d155
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 May 2019 02:05:38.0377
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3304
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-20_09:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 11:31:18AM +1000, Tobin C. Harding wrote:
> On Tue, May 21, 2019 at 12:57:47AM +0000, Roman Gushchin wrote:
> > On Mon, May 20, 2019 at 03:40:17PM +1000, Tobin C. Harding wrote:
> > > In an attempt to make the SMO patchset as non-invasive as possible ad=
d a
> > > config option CONFIG_DCACHE_SMO (under "Memory Management options") f=
or
> > > enabling SMO for the DCACHE.  Whithout this option dcache constructor=
 is
> > > used but no other code is built in, with this option enabled slab
> > > mobility is enabled and the isolate/migrate functions are built in.
> > >=20
> > > Add CONFIG_DCACHE_SMO to guard the partial shrinking of the dcache vi=
a
> > > Slab Movable Objects infrastructure.
> >=20
> > Hm, isn't it better to make it a static branch? Or basically anything
> > that allows switching on the fly?
>=20
> If that is wanted, turning SMO on and off per cache, we can probably do
> this in the SMO code in SLUB.

Not necessarily per cache, but without recompiling the kernel.
>=20
> > It seems that the cost of just building it in shouldn't be that high.
> > And the question if the defragmentation worth the trouble is so much
> > easier to answer if it's possible to turn it on and off without rebooti=
ng.
>=20
> If the question is 'is defragmentation worth the trouble for the
> dcache', I'm not sure having SMO turned off helps answer that question.
> If one doesn't shrink the dentry cache there should be very little
> overhead in having SMO enabled.  So if one wants to explore this
> question then they can turn on the config option.  Please correct me if
> I'm wrong.

The problem with a config option is that it's hard to switch over.

So just to test your changes in production a new kernel should be built,
tested and rolled out to a representative set of machines (which can be
measured in thousands of machines). Then if results are questionable,
it should be rolled back.

What you're actually guarding is the kmem_cache_setup_mobility() call,
which can be perfectly avoided using a boot option, for example. Turning
it on and off completely dynamic isn't that hard too.

Of course, it's up to you, it's just probably easier to find new users
of a new feature, when it's easy to test it.

Thanks!

