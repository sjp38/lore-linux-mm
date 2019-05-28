Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5223C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5913A20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Lsxy8R9/";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="KsyKcwMf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5913A20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC8036B026C; Tue, 28 May 2019 18:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D79796B0273; Tue, 28 May 2019 18:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3FFA6B0279; Tue, 28 May 2019 18:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id A35CF6B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:43:04 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id i195so2431395ite.1
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:43:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=qEefO5qlvpqj8Ir9UIvRGcC8kRNnq0kftq2KGhfMV7E=;
        b=BBMXdXO2joQWvZ3x52qXrl3nd73ivT+/Ev+haIXi8/4vxr1r06hcApNsw/32KYmQes
         Cnvtn5U0g8BpMV7FlTJpxB9w5QnCXKVoQVt40lHDd4YW2IH4L0JfLP0ePq4Zx0ROXAUW
         V2Zc/7fTBzhCoOuYx68lOs5kj6iNymAqE8P203RF3XJo0x3GXADB9CfHouWzMRN0PvzS
         kTyhKZgN8YzyUGDibB4vs6e3nzPZOMvGVJjO6YO8My5SuCxb5Xj9Nu6465og9NlUrEF/
         QzCHbhIDosf3NMTC6cqvrqSXMvulAos9CNmPzvsGELLohD4PGwlHBazhl3uuYonP2GQ6
         XNEg==
X-Gm-Message-State: APjAAAVf8/odffSfvX0ps4f1j9dnPh00GA95a03uTDvx/mjH00sBBorH
	Gez9apATT2+FFruPYcfk4l8RArmrjYWlksiaGf2LluzrYQbpLDu4xmpXHzPfSumwwl+opJINLUk
	drfDDkgbdnS4nwKk/LLepZWwkRKyTpZ0PVAZid39mtGZjNMosJ1XOKFlwKf9VN+rB8w==
X-Received: by 2002:a5e:8618:: with SMTP id z24mr17303501ioj.174.1559083384423;
        Tue, 28 May 2019 15:43:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxji5XdOGIXEtgfJNJFLlH58V0iD4Iepc8rRP2YO1TOfmUlhaxo86pn9cxGCDgxMw4/BkzN
X-Received: by 2002:a5e:8618:: with SMTP id z24mr17303461ioj.174.1559083383621;
        Tue, 28 May 2019 15:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559083383; cv=none;
        d=google.com; s=arc-20160816;
        b=R4xSF2r+OSuEwJ9LuH5Iv7hHu+y1Nhf8hrH2/Mffu5742mljEjKy24Rnohl6ca0+Sy
         zgkxANjY/OKHzoIzs0hP7UQOFDxeaFsEFL1w4K6EYEuhB4cMdan+t9El+M2FbULyZX7a
         JVfx7UZiMlhIfAMFNMEKCgAR0GkdufkwI5YCO59N9MJjPom/Nz33LgnbIkmmkwd3rgpU
         3hCX8ErrYSiFYJPgaDJrlpIr0Q25P1txXGNfYvDDUzrtBTl5+c3pw5qK9tdJsvEtcSNc
         XG0Y7642Uw3c+chXiSSOeo6irbFu8IrQt+cP4RCqf9jLeb373ITEbso7lMokuxFboJh/
         BX5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=qEefO5qlvpqj8Ir9UIvRGcC8kRNnq0kftq2KGhfMV7E=;
        b=Ybh2469piypADchnMyEWAPKU20dSy6H1A8VpecsvPz+0zyoiuhwzo+mlwAri8jUlRt
         LtwQk5EieZZfZDN0bTmptGVTcffvQCs6vovwQHlZJlFP6NBaE55NtSfv0scNxnQEt9x3
         r17KJ77+nfg+dfVBbJufkBjy70rC2pERjI2r+B3mG9mhnkyOW1nF17KJA8uWYLr3qzAm
         KgSlpKaMpV40cmPv/ojSTADQrQaax24hZNifAz5UgRw7bxUhIsLeDRTGqc6COAPyXeZq
         QWkTkCp3lfaI5ucPPcCnfRod8VEasZ8S7Bklyt5WnEgSMptlIm0mbo8cB4aTL6+ML27w
         BZYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Lsxy8R9/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=KsyKcwMf;
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d24si8915652ion.146.2019.05.28.15.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 15:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Lsxy8R9/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=KsyKcwMf;
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4SMfxcP016462;
	Tue, 28 May 2019 15:42:25 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=qEefO5qlvpqj8Ir9UIvRGcC8kRNnq0kftq2KGhfMV7E=;
 b=Lsxy8R9/FtOwqri8685JipZb293qgm9fH+eadvOQaIOC8rpRVuJ8kJ0LeorQwGs/Pxci
 yOR5+XWJcMbO9PQ2EfMq/WhIkEXp0vVqC4F+NGZ1BZPV/FVaremvV+fScCPvMScI+1Wi
 JpY3C/oIlueMHU+eLYFT4NF6Q1k9dkPbDp4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2ss7tv1f76-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 28 May 2019 15:42:25 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 28 May 2019 15:42:24 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 28 May 2019 15:42:24 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qEefO5qlvpqj8Ir9UIvRGcC8kRNnq0kftq2KGhfMV7E=;
 b=KsyKcwMfvudP6YtqKlkS9+pZG9zw4L5Bu+1YCa0LT1nWkl7OZ0I+IgHDdr8yyX/5IaMuMmBVYtqL1S5kT9Qpou8AKnHlqH05A71ZMYzk6IurzKWbuvvFUYCImRQRdo6eogDYMTR8zvofEt8IQQZpj8fypyXIxO6qFQKPE4zbAXM=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2216.namprd15.prod.outlook.com (52.135.196.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.22; Tue, 28 May 2019 22:42:21 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.021; Tue, 28 May 2019
 22:42:21 +0000
From: Roman Gushchin <guro@fb.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Hillf Danton <hdanton@sina.com>, Michal Hocko
	<mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        LKML
	<linux-kernel@vger.kernel.org>,
        Thomas Garnier <thgarnie@google.com>,
        "Oleksiy Avramchenko" <oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt
	<rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner
	<tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Thread-Topic: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Thread-Index: AQHVFHAH7qEvKKmW0EiXhNmDjWGv56aBJFUA
Date: Tue, 28 May 2019 22:42:21 +0000
Message-ID: <20190528224217.GG27847@tower.DHCP.thefacebook.com>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-3-urezki@gmail.com>
In-Reply-To: <20190527093842.10701-3-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BY5PR04CA0007.namprd04.prod.outlook.com
 (2603:10b6:a03:1d0::17) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:3dca]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 00281a02-882b-480f-9bcb-08d6e3bdbf01
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2216;
x-ms-traffictypediagnostic: BYAPR15MB2216:
x-microsoft-antispam-prvs: <BYAPR15MB221645465D12DBCA47DCF666BE1E0@BYAPR15MB2216.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 00514A2FE6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(376002)(366004)(39860400002)(136003)(199004)(189003)(305945005)(6916009)(86362001)(81166006)(7736002)(6116002)(81156014)(7416002)(6506007)(386003)(33656002)(25786009)(71190400001)(102836004)(476003)(14444005)(52116002)(5660300002)(4326008)(256004)(6246003)(486006)(446003)(11346002)(46003)(76176011)(71200400001)(66476007)(64756008)(1411001)(66946007)(6512007)(66446008)(68736007)(6436002)(73956011)(229853002)(66556008)(478600001)(1076003)(8676002)(2906002)(8936002)(54906003)(186003)(316002)(99286004)(6486002)(14454004)(53936002)(9686003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2216;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: hZkdIfn9cDHh8aSZes+7neE04Yq24cUvcfBCv+QqSyjUDcR2xuxo5rLrM6S9aVRC6sc03k6L9MMl/BMv843gvJtaq5Pl0+RPsf6wjbTQ1ZzPwyKntn5fPx5zybMtt8dkZAGwR8LJ88xTRkdTDmEJE0JfFCt7Ay4Yaz8V2Sc33Y3KtXtFSwzKEtB8/jSB4nLd1XYv0sx40KvyfNRvxLGTOqohhe8N86S1S20gmBPX5ns497jYuSRZxqUh+z2iVEae5yRJ6SFT2Raa1LL+r+r8RTkRtu7eTvJOz0Oig4UZBwBv2qm6calSc2MRdlRVly4U/XeGG01gJT725E2tf6sQyCZ9iV8h+hkrdYKU+xFcn/WwVlrZGlcqNaQd94FvyGgqtQTOmMUR6mbyi74WASEI3XU87ldSNf8fmi/bpm28xAg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AF112619B147974FA7A08017E68A4AED@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 00281a02-882b-480f-9bcb-08d6e3bdbf01
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 May 2019 22:42:21.5140
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2216
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280142
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 11:38:40AM +0200, Uladzislau Rezki (Sony) wrote:
> Refactor the NE_FIT_TYPE split case when it comes to an
> allocation of one extra object. We need it in order to
> build a remaining space.
>=20
> Introduce ne_fit_preload()/ne_fit_preload_end() functions
> for preloading one extra vmap_area object to ensure that
> we have it available when fit type is NE_FIT_TYPE.
>=20
> The preload is done per CPU in non-atomic context thus with
> GFP_KERNEL allocation masks. More permissive parameters can
> be beneficial for systems which are suffer from high memory
> pressure or low memory condition.
>=20
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  mm/vmalloc.c | 79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++---
>  1 file changed, 76 insertions(+), 3 deletions(-)

Hi Uladzislau!

This patch generally looks good to me (see some nits below),
but it would be really great to add some motivation, e.g. numbers.

Thanks!

>=20
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ea1b65fac599..b553047aa05b 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -364,6 +364,13 @@ static LIST_HEAD(free_vmap_area_list);
>   */
>  static struct rb_root free_vmap_area_root =3D RB_ROOT;
> =20
> +/*
> + * Preload a CPU with one object for "no edge" split case. The
> + * aim is to get rid of allocations from the atomic context, thus
> + * to use more permissive allocation masks.
> + */
> +static DEFINE_PER_CPU(struct vmap_area *, ne_fit_preload_node);
> +
>  static __always_inline unsigned long
>  va_size(struct vmap_area *va)
>  {
> @@ -950,9 +957,24 @@ adjust_va_to_fit_type(struct vmap_area *va,
>  		 *   L V  NVA  V R
>  		 * |---|-------|---|
>  		 */
> -		lva =3D kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> -		if (unlikely(!lva))
> -			return -1;
> +		lva =3D __this_cpu_xchg(ne_fit_preload_node, NULL);
> +		if (unlikely(!lva)) {
> +			/*
> +			 * For percpu allocator we do not do any pre-allocation
> +			 * and leave it as it is. The reason is it most likely
> +			 * never ends up with NE_FIT_TYPE splitting. In case of
> +			 * percpu allocations offsets and sizes are aligned to
> +			 * fixed align request, i.e. RE_FIT_TYPE and FL_FIT_TYPE
> +			 * are its main fitting cases.
> +			 *
> +			 * There are a few exceptions though, as an example it is
> +			 * a first allocation (early boot up) when we have "one"
> +			 * big free space that has to be split.
> +			 */
> +			lva =3D kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> +			if (!lva)
> +				return -1;
> +		}
> =20
>  		/*
>  		 * Build the remainder.
> @@ -1023,6 +1045,48 @@ __alloc_vmap_area(unsigned long size, unsigned lon=
g align,
>  }
> =20
>  /*
> + * Preload this CPU with one extra vmap_area object to ensure
> + * that we have it available when fit type of free area is
> + * NE_FIT_TYPE.
> + *
> + * The preload is done in non-atomic context, thus it allows us
> + * to use more permissive allocation masks to be more stable under
> + * low memory condition and high memory pressure.
> + *
> + * If success it returns 1 with preemption disabled. In case
> + * of error 0 is returned with preemption not disabled. Note it
> + * has to be paired with ne_fit_preload_end().
> + */
> +static int

Cosmetic nit: you don't need a new line here.

> +ne_fit_preload(int nid)

> +{
> +	preempt_disable();
> +
> +	if (!__this_cpu_read(ne_fit_preload_node)) {
> +		struct vmap_area *node;
> +
> +		preempt_enable();
> +		node =3D kmem_cache_alloc_node(vmap_area_cachep, GFP_KERNEL, nid);
> +		if (node =3D=3D NULL)
> +			return 0;
> +
> +		preempt_disable();
> +
> +		if (__this_cpu_cmpxchg(ne_fit_preload_node, NULL, node))
> +			kmem_cache_free(vmap_area_cachep, node);
> +	}
> +
> +	return 1;
> +}
> +
> +static void

Here too.

> +ne_fit_preload_end(int preloaded)
> +{
> +	if (preloaded)
> +		preempt_enable();
> +}

I'd open code it. It's used only once, but hiding preempt_disable()
behind a helper makes it harder to understand and easier to mess.

Then ne_fit_preload() might require disabled preemption (which it can
temporarily re-enable), so that preempt_enable()/disable() logic
will be in one place.

> +
> +/*
>   * Allocate a region of KVA of the specified size and alignment, within =
the
>   * vstart and vend.
>   */
> @@ -1034,6 +1098,7 @@ static struct vmap_area *alloc_vmap_area(unsigned l=
ong size,
>  	struct vmap_area *va;
>  	unsigned long addr;
>  	int purged =3D 0;
> +	int preloaded;
> =20
>  	BUG_ON(!size);
>  	BUG_ON(offset_in_page(size));
> @@ -1056,6 +1121,12 @@ static struct vmap_area *alloc_vmap_area(unsigned =
long size,
>  	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK)=
;
> =20
>  retry:
> +	/*
> +	 * Even if it fails we do not really care about that.
> +	 * Just proceed as it is. "overflow" path will refill
> +	 * the cache we allocate from.
> +	 */
> +	preloaded =3D ne_fit_preload(node);
>  	spin_lock(&vmap_area_lock);
> =20
>  	/*
> @@ -1063,6 +1134,8 @@ static struct vmap_area *alloc_vmap_area(unsigned l=
ong size,
>  	 * returned. Therefore trigger the overflow path.
>  	 */
>  	addr =3D __alloc_vmap_area(size, align, vstart, vend);
> +	ne_fit_preload_end(preloaded);
> +
>  	if (unlikely(addr =3D=3D vend))
>  		goto overflow;
> =20
> --=20
> 2.11.0
>=20

