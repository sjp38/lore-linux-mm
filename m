Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47919C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 17:17:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF3A82084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 17:17:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="rEObaRHC";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="JJ6czcJ5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF3A82084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690A46B0005; Wed, 15 May 2019 13:17:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 667AF6B0006; Wed, 15 May 2019 13:17:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 508456B0007; Wed, 15 May 2019 13:17:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C35F6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 13:17:58 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id 2so103507vsp.23
        for <linux-mm@kvack.org>; Wed, 15 May 2019 10:17:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=HE2MZiOXjgj8hgaGwMJPCyOpBUfLUlcBZGgaIA1NrUM=;
        b=oAy7eH5SU7DAJrSrXwVRZ2WB/H1U3tDVy8zBfkdK1eg8+g9lEltdFPaJoM3sKpkYGI
         EzsVJx9g1ghjxd7N5TCE2NT64jkVWhUr0+QlmgDjLYZsRjX4kk/x/0rCmpgr2BEKQOOw
         skWJ7WGvpsvvxzqN39yGTWVDaT7aQetgd9Bdi2/SaU/3kLrgldYdEZsmHIztQMDfep4C
         dAFtfpE4tUyAkwyYgYTsxujgYVwMW9+bqr6htgHG7M0xf41ZtVBgiCAl7unRoM9vNi4B
         3tUKsAbOofhuOm1TPbgGwuL3kdK35YTjdJ3mjxSU2GlMrUEh6TLl6Z3OlG7TK0LQd/pI
         W3fw==
X-Gm-Message-State: APjAAAVBLwoILusOxZRbOz58RaIhPaIPv7PiDfaqQJDOYkXmP9I0bzj7
	CuBjHsYFWSq169fJ+zmZFVmBvMrE3dmbaPzadQBFRZxZx9lWIPxKcQqDiHFAor4h6WESaleMVvq
	4elgTSZ2xawQ0C3n+4w/T4t7c9XGZ8SKLR+Fii3mIdVCNqhcr3sy4KUko71vcBsgnTw==
X-Received: by 2002:a67:fd93:: with SMTP id k19mr7153314vsq.45.1557940677759;
        Wed, 15 May 2019 10:17:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxB+EVx1hIH12cm+2nKLIzJTfYJZqyC1AY4HKa/bih77BVlrFxOmh5xtSWGESiKxB/v8Pel
X-Received: by 2002:a67:fd93:: with SMTP id k19mr7153270vsq.45.1557940676879;
        Wed, 15 May 2019 10:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557940676; cv=none;
        d=google.com; s=arc-20160816;
        b=x6GECp8C/WtkHKahkHxvXikrvrFkfLoXN716rP9seOUg2Jxg9VvpQMSnA20lpm3RGc
         apuO31fKtFNX1Fb1/KJWVmwtUaUnGqIx7hB0FX4+y+OlAbI/sO2Qw8EyjFNrNhe0Z6jN
         w62rbKvajt1/pqMgebW3Po48tDzslmgL8V4I/FGRtC6Wz1QLdV92ewBrrrgxSKgrekgo
         XDP5hTY0okj821pc9dQfbQgEAzXqXkCd9QgF3SE4vxFEbq2hL50apzkMh8qHu84hrSmb
         whhk2d31svZyMOd2h2Y/ly4F0mSVBnIIzgtt8ivrAYuPqPcMUt/IQMKogPGlH61T4Miu
         FtpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=HE2MZiOXjgj8hgaGwMJPCyOpBUfLUlcBZGgaIA1NrUM=;
        b=pifXH8+yQNDQHOARmuglfPtV2UdnnSg0NObbr770GLwqTgRo1tZ5V80ece4OSJz8Ce
         etEZNmd0p2URgeq6ezyPNWjTXmgkq0nVMXzxanbF6DraCuu/hkW+FkEwHkMeUSoeItXq
         Ak/EEwIqCXBkniPICi+NMQSeFI8XMtOBTGtLKICDuo6T0yWY3RimPJ3FrcLjPNJ94phz
         Hq4PIZXdVAVpqgF3McTAM9jOYfQdLGGdr571rbifMUmG1cBlPkWhx8rluePRRW0BfcmE
         bd4qdMjcpX9oLR30Bu/DfhQimPPgREFoQNorH145q8RKAxtVZzxc8PsFjVvs0dYHJ8l7
         GTWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rEObaRHC;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=JJ6czcJ5;
       spf=pass (google.com: domain of prvs=0038d347e3=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0038d347e3=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n10si672841vsp.99.2019.05.15.10.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 10:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0038d347e3=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rEObaRHC;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=JJ6czcJ5;
       spf=pass (google.com: domain of prvs=0038d347e3=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0038d347e3=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4FHGMFS015521;
	Wed, 15 May 2019 10:17:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=HE2MZiOXjgj8hgaGwMJPCyOpBUfLUlcBZGgaIA1NrUM=;
 b=rEObaRHC50A8l562hy8A9bbD6Q2j+jE6K6UV2qmBl58a9fq4PouoThsPIjdVTzgksJB7
 hTPSSl7zluiVCYscvQSvSloDGa3xXL8Jxw76sc+yherRGIVlCL1mIJDPJjiAhXmweQ/B
 MkXjv7Fa74LjR3bgYmoTWhGzVp6a7fbY11k= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2sg4chkh6r-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 15 May 2019 10:17:38 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 15 May 2019 10:17:36 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 15 May 2019 10:17:35 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 15 May 2019 10:17:35 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HE2MZiOXjgj8hgaGwMJPCyOpBUfLUlcBZGgaIA1NrUM=;
 b=JJ6czcJ5UltQ8BqcTMO1sOEY2mr4zzKfn6CzQSEDbcJYV5IUqgMdXUzAvXdmF6gRmmOfAudK3Q6uA63PWh49fDvihKkxTUI2xBHEP2zD7e53EFIqAfOWlKRS92iKM/T+iluBiHp1EXunGKfQNZ17VfoY5GrF5dbWr1xYm+Nf7rk=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3272.namprd15.prod.outlook.com (20.179.57.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.16; Wed, 15 May 2019 17:17:34 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1878.024; Wed, 15 May 2019
 17:17:34 +0000
From: Roman Gushchin <guro@fb.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Matthew Wilcox <willy@infradead.org>,
        Vlastimil
 Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
Thread-Topic: [PATCH] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
Thread-Index: AQHVCq//khAEDBlALkSFD6zmmU+RfaZrzesAgACg2oA=
Date: Wed, 15 May 2019 17:17:33 +0000
Message-ID: <20190515171729.GC9307@castle>
References: <20190514235111.2817276-1-guro@fb.com>
 <7ad2b16d-c1a3-b826-df4d-6d9ed1d9fc9f@arm.com>
In-Reply-To: <7ad2b16d-c1a3-b826-df4d-6d9ed1d9fc9f@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO1PR15CA0048.namprd15.prod.outlook.com
 (2603:10b6:101:1f::16) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::779]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 78ee93fc-5ba2-465e-eecd-08d6d959380d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3272;
x-ms-traffictypediagnostic: BYAPR15MB3272:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <BYAPR15MB32721773590000F06149BE36BE090@BYAPR15MB3272.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0038DE95A2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(396003)(136003)(39860400002)(366004)(376002)(346002)(189003)(199004)(71190400001)(71200400001)(6116002)(86362001)(1076003)(2906002)(33716001)(256004)(14444005)(5660300002)(6916009)(53936002)(305945005)(7736002)(4326008)(25786009)(66476007)(64756008)(6306002)(52116002)(102836004)(386003)(6246003)(68736007)(316002)(8936002)(81156014)(81166006)(486006)(54906003)(46003)(11346002)(446003)(476003)(14454004)(478600001)(99286004)(966005)(186003)(6506007)(76176011)(53546011)(229853002)(6436002)(8676002)(6486002)(66556008)(73956011)(66446008)(66946007)(6512007)(9686003)(33656002)(37363001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3272;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: vg3BzHvxkPXFjgIqSEWTEWzw+8MlX5xUwCYvsuInvLQfXx+/XVVscPghTPTch3GHsda0ll4OToxi2aCY3JJVhc3JeqaBGfRctXbz21+K9sWPHh2GlXNiYDMlVJbuwMcSRtfhthOdx2waa8KnzMp9t6WLBrhgXEgETgRrRiPfvuVrLYZLGslGhY8XRGsAxn1jYGfFESRqm9iSU9uyHOQjeJ+KoCeqozrsIyl0r9TTzgZIh7HEH8+5b7SigLRNvPgwctR9STTOnWafT1sfXRFlJh7jrTWBoP8rmKrIUCiKzqqws5eTg54h2SI98zYAne1dZz+IUCU6ViBpzDczIrtjJEHV0ML7ycRHBpxH04y9TBZpPAxUNz3d6I1piNGvAD63CXQYT9tsSVpCv1KRMktImcqs0l0cx8pqb9D2p29EuHo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <315A17B3378CFB4999879700E65EF6B5@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 78ee93fc-5ba2-465e-eecd-08d6d959380d
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 May 2019 17:17:33.8955
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3272
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-15_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=495 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905150104
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 01:11:46PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 05/15/2019 05:21 AM, Roman Gushchin wrote:
> > __vunmap() calls find_vm_area() twice without an obvious reason:
> > first directly to get the area pointer, second indirectly by calling
> > vm_remove_mappings()->remove_vm_area(), which is again searching
> > for the area.
> >=20
> > To remove this redundancy, let's split remove_vm_area() into
> > __remove_vm_area(struct vmap_area *), which performs the actual area
> > removal, and remove_vm_area(const void *addr) wrapper, which can
> > be used everywhere, where it has been used before. Let's pass
> > a pointer to the vm_area instead of vm_struct to vm_remove_mappings(),
> > so it can pass it to __remove_vm_area() and avoid the redundant area
> > lookup.
> >=20
> > On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
> > of 4-pages vmalloc blocks.
> >=20
> > Perf report before:
> >   29.44%  cat      [kernel.kallsyms]  [k] free_unref_page
> >   11.88%  cat      [kernel.kallsyms]  [k] find_vmap_area
> >    9.28%  cat      [kernel.kallsyms]  [k] __free_pages
> >    7.44%  cat      [kernel.kallsyms]  [k] __slab_free
> >    7.28%  cat      [kernel.kallsyms]  [k] vunmap_page_range
> >    4.56%  cat      [kernel.kallsyms]  [k] __vunmap
> >    3.64%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
> >    3.04%  cat      [kernel.kallsyms]  [k] __free_vmap_area
> >=20
> > Perf report after:
> >   32.41%  cat      [kernel.kallsyms]  [k] free_unref_page
> >    7.79%  cat      [kernel.kallsyms]  [k] find_vmap_area
> >    7.40%  cat      [kernel.kallsyms]  [k] __slab_free
> >    7.31%  cat      [kernel.kallsyms]  [k] vunmap_page_range
> >    6.84%  cat      [kernel.kallsyms]  [k] __free_pages
> >    6.01%  cat      [kernel.kallsyms]  [k] __vunmap
> >    3.98%  cat      [kernel.kallsyms]  [k] smp_call_function_single
> >    3.81%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
> >    2.77%  cat      [kernel.kallsyms]  [k] __free_vmap_area
> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  mm/vmalloc.c | 52 +++++++++++++++++++++++++++++-----------------------
> >  1 file changed, 29 insertions(+), 23 deletions(-)
> >=20
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index c42872ed82ac..8d4907865614 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2075,6 +2075,22 @@ struct vm_struct *find_vm_area(const void *addr)
> >  	return NULL;
> >  }
> > =20
> > +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> > +{
> > +	struct vm_struct *vm =3D va->vm;
> > +
> > +	spin_lock(&vmap_area_lock);
> > +	va->vm =3D NULL;
> > +	va->flags &=3D ~VM_VM_AREA;
> > +	va->flags |=3D VM_LAZY_FREE;
> > +	spin_unlock(&vmap_area_lock);
> > +
> > +	kasan_free_shadow(vm);
> > +	free_unmap_vmap_area(va);
> > +
> > +	return vm;
> > +}
> > +
> >  /**
> >   * remove_vm_area - find and remove a continuous kernel virtual area
> >   * @addr:	    base address
> > @@ -2087,26 +2103,14 @@ struct vm_struct *find_vm_area(const void *addr=
)
> >   */
> >  struct vm_struct *remove_vm_area(const void *addr)
> >  {
> > +	struct vm_struct *vm =3D NULL;
> >  	struct vmap_area *va;
> > =20
> > -	might_sleep();
>=20
> Is not this necessary any more ?

We've discussed it here: https://lkml.org/lkml/2019/4/17/1098 .
Tl;dr it's not that useful.

>=20
> > -
> >  	va =3D find_vmap_area((unsigned long)addr);
> > -	if (va && va->flags & VM_VM_AREA) {
> > -		struct vm_struct *vm =3D va->vm;
> > -
> > -		spin_lock(&vmap_area_lock);
> > -		va->vm =3D NULL;
> > -		va->flags &=3D ~VM_VM_AREA;
> > -		va->flags |=3D VM_LAZY_FREE;
> > -		spin_unlock(&vmap_area_lock);
> > -
> > -		kasan_free_shadow(vm);
> > -		free_unmap_vmap_area(va);
> > +	if (va && va->flags & VM_VM_AREA)
> > +		vm =3D __remove_vm_area(va);
> > =20
> > -		return vm;
> > -	}
> > -	return NULL;
> > +	return vm;
> >  }
>=20
> Other callers of remove_vm_area() cannot use __remove_vm_area() directly =
as well
> to save a look up ?
>=20

I'll take a look. Good idea, thanks!

Roman

