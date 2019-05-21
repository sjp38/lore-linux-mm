Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F873C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:26:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1202C21479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="cV0lLUlr";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ilzm6/in"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1202C21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2E186B0003; Mon, 20 May 2019 21:25:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDEF86B0005; Mon, 20 May 2019 21:25:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B800E6B0006; Mon, 20 May 2019 21:25:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93B7A6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:25:59 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id h186so16305090ywc.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:25:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=qQY7M2pX7FKl+KTn1kvOE0nFTcOn6+9hWnKGcflZUGc=;
        b=BqB0dSaKADhn6xtovFtZYpgzpoeZUbkzFx8hb1DZmo3Dkts/4CueSUlo1uYj/Dioi3
         yVGveC7vsZZ6QfNCwKq7mPQTijmyqORVA6+XbJDY+whpVi0Bs/3kpeZeQ6MT4h0XjaH4
         6/ZzpSzj+QZqzpzLi3J/hzuL8dytpgEfCgM91Q3jNJN/5BbxhBK7UL5z+WxpjxZzYF+L
         Kc2lEiGWv+TglIxi/q6ncfok/CwSGKSW9wpoVofKC4R2YoS6cHEGnUljif64ksXnGkm/
         5B6khH1E6GNANRrktnD98BvVg/OxrSJCcpUreSaKv4wE0pNAAP8+MIBuqOYAD7xmDdkW
         X6/g==
X-Gm-Message-State: APjAAAXcRsywqaS2DarSzlsiXJ9K33ryz3VrZ7ahv5wfBggchKT+TjI2
	xEiPiPIGaGDiPenKI3ZppSkQsgSBq3S7/GPDAV7pKXvMXoAPq6DnyYZVQ3H2SyIq/J8Lc6bt/Id
	Ef6Jb4W6pKwWwD3Snx+EdDsAFLPBqQSBzuldhMZH74HqoRuV99ph4B0Mn+XiGutauUA==
X-Received: by 2002:a0d:dfd7:: with SMTP id i206mr36758415ywe.256.1558401959248;
        Mon, 20 May 2019 18:25:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNI4akuahfhNHpB72ihVvbyaNorof2zME+6YoSvKpksayZJ91ZdZSHHwbPPKkNzlt5V6Vs
X-Received: by 2002:a0d:dfd7:: with SMTP id i206mr36758404ywe.256.1558401958593;
        Mon, 20 May 2019 18:25:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558401958; cv=none;
        d=google.com; s=arc-20160816;
        b=aXSS9mgbVjjTWc7F4Ilk6GnE+EsLETmeQyandco0lJorVEezJzcuY2AUJ3UCSJOO6U
         T8DwiWq/FF2NBl+WPaLKvcLMAKPP2k1ke2+H4djMdRGOenZPjSsOObQC7QJP7ZpZSd46
         0dFy+J0DsvDLfnkh+zWA/AKvAvLTbzj0sN73VDeZXxQzaFe2OTFvYrO0I3gIP6i+sb2B
         yD5yaanwsFlkRnC892yi5NznxEZbJ5njksJBcnkFwt8sz5e75EAJv4PFBd+YjON9ntev
         aWg4HuC+HMv1DtzOu65yEMg5q+o+ODg4B/iG2+vzOpUBOrqLbUMD07rcSMDv83PJG9Pl
         SEKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=qQY7M2pX7FKl+KTn1kvOE0nFTcOn6+9hWnKGcflZUGc=;
        b=WyCTU0TIU4FuXu7SG+TERsTodfInH0pUZlk7NLqa2hfmaPSBUZw3b7m8fIAnmuzeUk
         hm6rmpKOeuzlz2O/kL/8QOhNTXBgq3WkOL1NgJDdrATLNajrn37yzluztPOK1Y2r0b7w
         rtIN5yFFNwPgUyzLZpa/wQhn356ql4cJ6YeUIlW6xRWgBDHgkw42h5ubZFD3Vqr7/Pb2
         9rcvIty1wUvIBmI6rbvZQsQa02jyLlRfY6EHfgxCoyTP9+T8h/07dezPP4yU98g8rDM5
         aLl8WYTdgm/utjj30ogE33pxd43ayhdwt5+kNgiwdht20mWOYqDziuYxfz0TISCTOoSP
         x4kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=cV0lLUlr;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="ilzm6/in";
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q8si5514357ybq.309.2019.05.20.18.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:25:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=cV0lLUlr;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="ilzm6/in";
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4L1N7hx008944;
	Mon, 20 May 2019 18:25:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=qQY7M2pX7FKl+KTn1kvOE0nFTcOn6+9hWnKGcflZUGc=;
 b=cV0lLUlrchR0bRh2GkHvxebknzu+eYv3DZ/XbqI43AyTVwffMBqOIQsVQ/sOniJJOJer
 aP+qM6GJezdrbqcoRnUzYBBRmK+LDQzE0wWFgC9YYypnKlxBWt05XcYDWWCUVbC0wLV5
 ZZ875w3oWXIum8ZcALzVnIgbjEhlm+cYLo0= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2skusdtjmy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 20 May 2019 18:25:41 -0700
Received: from prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 20 May 2019 18:25:40 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 20 May 2019 18:25:39 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 20 May 2019 18:25:39 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qQY7M2pX7FKl+KTn1kvOE0nFTcOn6+9hWnKGcflZUGc=;
 b=ilzm6/inm9Y37LcSGvdcUd5NmQV5M9J4tITUmYEsGnFmT+j/Y0xaxlFzzVZzVHC/lRuyzy3UUHLpmIi3aMJKHaj0bM9gz77kEC298F7eDoK9sNTBVynl0SgDqzz9DT+OWSGgOr7crmw3XNN/NxYia9hg/lAnMADVHkrlrMrEA1g=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2197.namprd15.prod.outlook.com (52.135.196.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.18; Tue, 21 May 2019 01:25:35 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.020; Tue, 21 May 2019
 01:25:35 +0000
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
Subject: Re: [RFC PATCH v5 04/16] slub: Slab defrag core
Thread-Topic: [RFC PATCH v5 04/16] slub: Slab defrag core
Thread-Index: AQHVDs69QJvEmg+Y3UK7wQ/kts2ho6Z0S8sAgAB77YCAAALPAA==
Date: Tue, 21 May 2019 01:25:34 +0000
Message-ID: <20190521012525.GA15348@tower.DHCP.thefacebook.com>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-5-tobin@kernel.org>
 <20190521005152.GC21811@tower.DHCP.thefacebook.com>
 <20190521011525.GA25898@eros.localdomain>
In-Reply-To: <20190521011525.GA25898@eros.localdomain>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR15CA0030.namprd15.prod.outlook.com
 (2603:10b6:300:ad::16) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:8d5a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 14c67e2a-7744-41f5-760f-08d6dd8b38db
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2197;
x-ms-traffictypediagnostic: BYAPR15MB2197:
x-microsoft-antispam-prvs: <BYAPR15MB2197FE24F58D81F4BA87117EBE070@BYAPR15MB2197.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0044C17179
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(396003)(346002)(136003)(39860400002)(51914003)(189003)(199004)(186003)(81166006)(8676002)(8936002)(71200400001)(6246003)(9686003)(6512007)(71190400001)(4326008)(25786009)(33656002)(486006)(476003)(46003)(446003)(11346002)(81156014)(68736007)(316002)(256004)(6116002)(53936002)(14444005)(305945005)(7416002)(7736002)(14454004)(478600001)(6436002)(229853002)(6486002)(6916009)(1076003)(99286004)(86362001)(66476007)(66556008)(64756008)(66446008)(66946007)(102836004)(2906002)(73956011)(386003)(6506007)(5660300002)(54906003)(52116002)(76176011);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2197;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: m/w6VCHc8N1Ii0WYWFm+RWBOQTFYmzXNHG0b4esQJooXmiY42dG6MzG/Ad1JQ90gZFkIoTHVaDrv+w1zwWYFCtHLV02I+yOyBdg0rOO9lKVjNDaXXxC49JvvBrSIpgwV2jyHS4aj5eNQPGwk6mH99ByITNVx8p3DKmnRQiAwt0L+1D0bZ7MbXx2rLkjqj9oGbq4U2pa3oIQsA6WJnuWVG10BSkDcjx4B1SEjryS4L6D6/SGjX9mLUNHCiwKpY7gjbooqtuKCYROM60AkeKhXuvFwXeZkGqADAnbFKyjcXKwD6UCDjaqxTODuXK0Afy884difxN6JaqM6BgdIb8MrsCQ9p0gKET9NEzN6redKxziVdUvMWUwUKKes5apm//1fLUJwwiwan2jrI9VTltZtDIRoXxRPRkvtlvwL5Bn+h6c=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CEB87061787EEA4E84FBF6A45F2D93B9@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 14c67e2a-7744-41f5-760f-08d6dd8b38db
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 May 2019 01:25:34.7820
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2197
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

On Tue, May 21, 2019 at 11:15:25AM +1000, Tobin C. Harding wrote:
> On Tue, May 21, 2019 at 12:51:57AM +0000, Roman Gushchin wrote:
> > On Mon, May 20, 2019 at 03:40:05PM +1000, Tobin C. Harding wrote:
> > > Internal fragmentation can occur within pages used by the slub
> > > allocator.  Under some workloads large numbers of pages can be used b=
y
> > > partial slab pages.  This under-utilisation is bad simply because it
> > > wastes memory but also because if the system is under memory pressure
> > > higher order allocations may become difficult to satisfy.  If we can
> > > defrag slab caches we can alleviate these problems.
> > >=20
> > > Implement Slab Movable Objects in order to defragment slab caches.
> > >=20
> > > Slab defragmentation may occur:
> > >=20
> > > 1. Unconditionally when __kmem_cache_shrink() is called on a slab cac=
he
> > >    by the kernel calling kmem_cache_shrink().
> > >=20
> > > 2. Unconditionally through the use of the slabinfo command.
> > >=20
> > > 	slabinfo <cache> -s
> > >=20
> > > 3. Conditionally via the use of kmem_cache_defrag()
> > >=20
> > > - Use Slab Movable Objects when shrinking cache.
> > >=20
> > > Currently when the kernel calls kmem_cache_shrink() we curate the
> > > partial slabs list.  If object migration is not enabled for the cache=
 we
> > > still do this, if however, SMO is enabled we attempt to move objects =
in
> > > partially full slabs in order to defragment the cache.  Shrink attemp=
ts
> > > to move all objects in order to reduce the cache to a single partial
> > > slab for each node.
> > >=20
> > > - Add conditional per node defrag via new function:
> > >=20
> > > 	kmem_defrag_slabs(int node).
> > >=20
> > > kmem_defrag_slabs() attempts to defragment all slab caches for
> > > node. Defragmentation is done conditionally dependent on MAX_PARTIAL
> > > _and_ defrag_used_ratio.
> > >=20
> > >    Caches are only considered for defragmentation if the number of
> > >    partial slabs exceeds MAX_PARTIAL (per node).
> > >=20
> > >    Also, defragmentation only occurs if the usage ratio of the slab i=
s
> > >    lower than the configured percentage (sysfs field added in this
> > >    patch).  Fragmentation ratios are measured by calculating the
> > >    percentage of objects in use compared to the total number of objec=
ts
> > >    that the slab page can accommodate.
> > >=20
> > >    The scanning of slab caches is optimized because the defragmentabl=
e
> > >    slabs come first on the list. Thus we can terminate scans on the
> > >    first slab encountered that does not support defragmentation.
> > >=20
> > >    kmem_defrag_slabs() takes a node parameter. This can either be -1 =
if
> > >    defragmentation should be performed on all nodes, or a node number=
.
> > >=20
> > >    Defragmentation may be disabled by setting defrag ratio to 0
> > >=20
> > > 	echo 0 > /sys/kernel/slab/<cache>/defrag_used_ratio
> > >=20
> > > - Add a defrag ratio sysfs field and set it to 30% by default. A limi=
t
> > > of 30% specifies that more than 3 out of 10 available slots for objec=
ts
> > > need to be in use otherwise slab defragmentation will be attempted on
> > > the remaining objects.
> > >=20
> > > In order for a cache to be defragmentable the cache must support obje=
ct
> > > migration (SMO).  Enabling SMO for a cache is done via a call to the
> > > recently added function:
> > >=20
> > > 	void kmem_cache_setup_mobility(struct kmem_cache *,
> > > 				       kmem_cache_isolate_func,
> > > 			               kmem_cache_migrate_func);
> > >=20
> > > Co-developed-by: Christoph Lameter <cl@linux.com>
> > > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > > ---
> > >  Documentation/ABI/testing/sysfs-kernel-slab |  14 +
> > >  include/linux/slab.h                        |   1 +
> > >  include/linux/slub_def.h                    |   7 +
> > >  mm/slub.c                                   | 385 ++++++++++++++++--=
--
> > >  4 files changed, 334 insertions(+), 73 deletions(-)
> >=20
> > Hi Tobin!
> >=20
> > Overall looks very good to me! I'll take another look when you'll post
> > a non-RFC version, but so far I can't find any issues.
>=20
> Thanks for the reviews.
>=20
> > A generic question: as I understand, you do support only root kmemcache=
s now.
> > Is kmemcg support in plans?
>=20
> I know very little about cgroups, I have no plans for this work.
> However, I'm not the architect behind this - Christoph is guiding the
> direction on this one.  Perhaps he will comment.
>=20
> > Without it the patchset isn't as attractive to anyone using cgroups,
> > as it could be. Also, I hope it can solve (or mitigate) the memcg-speci=
fic
> > problem of scattering vfs cache workingset over multiple generations of=
 the
> > same cgroup (their kmem_caches).
>=20
> I'm keen to work on anything that makes this more useful so I'll do some
> research.  Thanks for the idea.

You're welcome! I'm happy to help or even to do it by myself, once
your patches will be merged.

Thanks!

