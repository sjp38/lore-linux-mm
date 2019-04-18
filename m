Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08F62C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:05:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A49D3217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:05:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="O0/YsIB8";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VOx+HOyQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A49D3217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D1F26B000A; Thu, 18 Apr 2019 14:05:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4839F6B000C; Thu, 18 Apr 2019 14:05:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FD9B6B000D; Thu, 18 Apr 2019 14:05:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06CCA6B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:05:49 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id v4so1117171vka.10
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:05:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=rtCtANNIr/1Sg2LyrELfXsaYNGiy8l+IvutL0qSsLpo=;
        b=UHjbr0xHaNPzUphetRaott20d6mK7b4GZl6LEWJX9hxbeWUJApZrhlxsCp96XsdHrM
         y53VRKXT4M6vQyZaYxml/ThzuLLueN0Ul4CUabDgyDRrgP+3REcfGjEMQC7+S+HNcMZy
         Betb4I2XKQG+PoM47dJUZgU0cWKiHy3VgUvyh0K5VY6qRxDryv/s2sS2/+kS2Xz1Wyfe
         WyiG0fR3LNQAwLIGLxwJwkJk9AA1CGXJpz6GS9fiZ0F3MTsnKI5PLi6P/VQNc++qoka/
         ENkz5LvUnR7w+jB1CbxkMa+xESKb8Xkn/XykuzYpFOclC4y4vvRgNb7cgugayXFJ4iOG
         hDpg==
X-Gm-Message-State: APjAAAVRJtYUAD3efNGR6c2D28O+GiFzle2ZZQutwkFwYDwh3oi84qZV
	wbaTKq3fFyAuCyS8Z815lRBpRLVRZlk4PnbcV2Rpd/NDDtVrijKlQRblxiyFoamwYxL3hrpxOVT
	i/VVkXe1tJzdy0DDlO1Ld8NMkElfU8zLAH1PrLBPnen8R4fmF5PpaRbuoa/0aSxiEEw==
X-Received: by 2002:ab0:3419:: with SMTP id z25mr7364122uap.102.1555610748716;
        Thu, 18 Apr 2019 11:05:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrE4/1wawlpQfv7n10NV42dtUpBI5GpA9w0qocO9Nb1E7WlxlF4Vnd2OHoxMfyDkaUj7HO
X-Received: by 2002:ab0:3419:: with SMTP id z25mr7364041uap.102.1555610748088;
        Thu, 18 Apr 2019 11:05:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555610748; cv=none;
        d=google.com; s=arc-20160816;
        b=v73C+l/aXC/ILiwrGNycRSqY6fhqnAg8eZ2uEiAFb3P5MdWJvMTZnkn0huRlMOYlMh
         oU+Do14QxA1IC18Hl1DAOGc7PnlVAySu+L6fyaeneC8up5QFBjB/4hzbzxQ1TmKrN0LQ
         K/v3LGt1JJrULxJ6s3s3n4amXkyRLz9GFsFInpm9cHvfjZmqiASYd5DFNYN1HDjT0wdC
         JChItOAmIbh90UdjdnaB3Cs6hfFPUPdz7JmzDatGbr+0v1JUOavJzJwKS9NcjhDTGCCa
         HCFqynJwJoL2CZr8JdCIVbAiSZEDhJ/fkoeVKh0r+wUJ8SuM4WB1SqmMxtpJh+FK0P+U
         WquQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=rtCtANNIr/1Sg2LyrELfXsaYNGiy8l+IvutL0qSsLpo=;
        b=uooJHjq5bNFx7rJGwhksfrb4FMYkxUA/WCPR7ybjw9XX1kZBi+pbHiD/SllEqRr1kq
         I4VtXCZgHKYypNV0Tbtvio7iz+tP62aX7xrxPufmIu1unhlTo53UKOxWcr+zWiUvN6sP
         CPF9M3SM4Wsae0xLccOS6JueYna3yq2udn9PZtpkazdypgETiY9TTIQe5Z1w13zaTrfG
         4Anb4SabcWR0eKqp2lA2lpBtMs7LSIfzDabUgKv1yojllkyiBbK7lrwUk/qNxOBNVLsR
         daohVk2I9wUadiYb2yGmMDi/1sEp/kBGv9jZkX/LeUcXM6tJqx6XWna7zRfPqZK28A5x
         eUqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="O0/YsIB8";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=VOx+HOyQ;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s70si48631vka.83.2019.04.18.11.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 11:05:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="O0/YsIB8";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=VOx+HOyQ;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3II2k0x023828;
	Thu, 18 Apr 2019 11:05:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=rtCtANNIr/1Sg2LyrELfXsaYNGiy8l+IvutL0qSsLpo=;
 b=O0/YsIB8j91b1QurTeZgnLlicpJGnVJXlvJugK/y8TXFPMUjohT1kDv0NGBAgn/hoSvc
 XICPATH/F7VuzdxZqrkPtiOqVF6cbKE3zvhoW5BXodgEX9O3534MiXaNOW8yX5gR5JqW
 AsLG3bGpNXMYDpfGYTJIYZxVUdrlxRG5pMk= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rxw16g9wt-15
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 18 Apr 2019 11:05:38 -0700
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 18 Apr 2019 11:05:17 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 18 Apr 2019 11:05:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rtCtANNIr/1Sg2LyrELfXsaYNGiy8l+IvutL0qSsLpo=;
 b=VOx+HOyQmIGnolCFHmc3EzyBHJJzE8LJrkbHw4yginIAfGOFYeyL7L8WrSsnTQD/4LvHWpsYkvjFWRkFRgw3qg0vcuItYN126ylK2QUMm2hM89DwEQFQg6wzfLuKw0aeSrp/IQ6jO9BDPtmv+gKvubSRedRTf8ulqWC4lH4NYqw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2598.namprd15.prod.outlook.com (20.179.155.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.12; Thu, 18 Apr 2019 18:05:15 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.021; Thu, 18 Apr 2019
 18:05:15 +0000
From: Roman Gushchin <guro@fb.com>
To: Christopher Lameter <cl@linux.com>
CC: Roman Gushchin <guroan@gmail.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        "david@fromorbit.com"
	<david@fromorbit.com>,
        Pekka Enberg <penberg@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>
Subject: Re: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Thread-Topic: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Thread-Index: AQHU9WhFLwAo90XwHUSqs2s91sh5hqZB7UQAgABKcoA=
Date: Thu, 18 Apr 2019 18:05:15 +0000
Message-ID: <20190418180510.GB11008@tower.DHCP.thefacebook.com>
References: <20190417215434.25897-1-guro@fb.com>
 <20190417215434.25897-5-guro@fb.com>
 <0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@email.amazonses.com>
In-Reply-To: <0100016a30abc330-011d895a-b4af-40a9-8937-990297ed4ffd-000000@email.amazonses.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR04CA0175.namprd04.prod.outlook.com
 (2603:10b6:104:4::29) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:497d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 777f9bff-4800-41cc-5f1d-08d6c4286875
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2598;
x-ms-traffictypediagnostic: BYAPR15MB2598:
x-microsoft-antispam-prvs: <BYAPR15MB259809DD1EA4E08AFBB83759BE260@BYAPR15MB2598.namprd15.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(346002)(396003)(376002)(39860400002)(189003)(199004)(81156014)(7416002)(14454004)(316002)(54906003)(46003)(86362001)(186003)(11346002)(476003)(52116002)(446003)(99286004)(76176011)(6506007)(386003)(486006)(6512007)(9686003)(97736004)(53936002)(6246003)(5660300002)(102836004)(25786009)(1076003)(305945005)(6436002)(7736002)(4326008)(68736007)(256004)(6916009)(229853002)(6486002)(14444005)(478600001)(6116002)(81166006)(2906002)(33656002)(8936002)(71190400001)(8676002)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2598;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JsG2fqPU9+8weaogw384QR1J7UewN1JOffdKIjR6XGZAqchFobnxSfFdKtcRHrhUzZgxBnaI10KNlrJ2o5NFRfoZwkwVie6Yn0JYmpEtywcaYLwgxur2XsuJShYziZDh7ZPhZ+jvbsJjKerx12o/8m2cOCcYXTygXdzPaU/dr2QjE+Bw7p5SyPgMNfOcQBArcs/pyshbOMFPa+XD3hjBxyDjiexcvtv98vhEq5N7TM094h+IfQyU4z3mA8tA8SoKjMQ11ZPRug4SrejQBTMRKnOH0Gn8kpnzlHafUhrD1qXgWRi90e6eJ4cdyYF129pcJ5fnu23heQ24KyplVLmQB2ixj6Lc7GW6UgQHT9WHvZr5aQw2uAoRuPqfHq2f/QCYvB1N7+UpmwTSuphtUjVq3CNErkPqrT0ndxv2Q3tbAdE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B63A3F64D484F84F9EBD4788F5ACDCFA@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 777f9bff-4800-41cc-5f1d-08d6c4286875
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 18:05:15.2184
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2598
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_08:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 01:38:44PM +0000, Christopher Lameter wrote:
> On Wed, 17 Apr 2019, Roman Gushchin wrote:
>=20
> >  static __always_inline int memcg_charge_slab(struct page *page,
> >  					     gfp_t gfp, int order,
> >  					     struct kmem_cache *s)
> >  {
> > -	if (is_root_cache(s))
> > +	int idx =3D (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> > +		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> > +	struct mem_cgroup *memcg;
> > +	struct lruvec *lruvec;
> > +	int ret;
> > +
> > +	if (is_root_cache(s)) {
> > +		mod_node_page_state(page_pgdat(page), idx, 1 << order);
>=20
> Hmmm... This is functionality that is not memcg specific being moved into
> a memcg function??? Maybe rename the function to indicate that it is not
> memcg specific and add the proper #ifdefs?
>=20
> >  static __always_inline void memcg_uncharge_slab(struct page *page, int=
 order,
> >  						struct kmem_cache *s)
> >  {
> > -	memcg_kmem_uncharge(page, order);
> > +	int idx =3D (s->flags & SLAB_RECLAIM_ACCOUNT) ?
> > +		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
> > +	struct mem_cgroup *memcg;
> > +	struct lruvec *lruvec;
> > +
> > +	if (is_root_cache(s)) {
> > +		mod_node_page_state(page_pgdat(page), idx, -(1 << order));
> > +		return;
> > +	}
>=20
> And again.
>=20

Good point! Will do in v2.

Thanks!

