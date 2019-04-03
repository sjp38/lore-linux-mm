Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52CD3C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:00:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E437E2133D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:00:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="FK513RHT";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="LA0XP2cm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E437E2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B74A6B000C; Wed,  3 Apr 2019 14:00:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 575C46B000D; Wed,  3 Apr 2019 14:00:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F4BB6B000E; Wed,  3 Apr 2019 14:00:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D09AA6B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 14:00:44 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so15364837qkg.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 11:00:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=o+c+bA8MO26B8kHENhutu/5MRQhebutrzZgxv/ZEKVk=;
        b=NSIHmRWTJEwoHYg0wsijlbA2llPaUXjgNUdWxLa9sUc7i9FbAthZrds5ohNV8WCHn7
         /xzotFrgs18Je+OM5esFYpRlFQ1UoyMCLgPuBIRrrKb2IumpeQzEoD6nWn7zmfp8CMhT
         bpjVO5xrE8fdKi2BlES3vfTd+Wqhyh7mw60RrXZWA5f2GVjIKjF8AVgjGJXlU3PcSDrK
         d19KwRf0F1uh8PQ5WzrztPhEVMXF+6pw3mocUzyKtXThKWwNA8+OrlKAvELrdzwSEWQb
         qjg7rGMjRI5FsDpM5yDJIpLVm+yiaSZRb3jhiPXN//f5MFmfHQHLY8fcDq/sDXcL2cMr
         pgjg==
X-Gm-Message-State: APjAAAWOlUcdikG/tU4f0UOBp4zeKD2PPy4DFD96XHqHdmnzOeG2cmjh
	8AUo6bwMN+CRBazFo8yCYq4akSk0E7VmQklPbpTthlQqo/1M1WDMyuo7uHsvJ1LTe1i+YA/kYOd
	GgNJgW4TyPSOc6ZvMRDrPSbTs3ZhlL3TJ5QYQGRECKjQQa9EJqz2wQK6V6L74z9arEg==
X-Received: by 2002:a37:9b87:: with SMTP id d129mr1230391qke.263.1554314444551;
        Wed, 03 Apr 2019 11:00:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMhyv8flihTulX203PkUzzhfoNSXAebAcS0OniBevgFTJ6rYu7aOuSmtm3XFHgWDV4n3yg
X-Received: by 2002:a37:9b87:: with SMTP id d129mr1230310qke.263.1554314443660;
        Wed, 03 Apr 2019 11:00:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554314443; cv=none;
        d=google.com; s=arc-20160816;
        b=IrvoHYQonSLbUuKB4qBaWDRRlrLqplYx3CRdAYaQZzy/51joTDbse+VoFlHcRyJK44
         WAz8Ry540NB74txi8W8Qi+QTe2PRFhnkvpykHa9+HoVDD4iQdQp1Rdsspt+oQK1iWuxt
         zb2NgGklluF1I0KukQXxoNWMcP4H4ULNMEWtaX0L28KcQur0YHMzaK8+Y+Q8PUS8Kepz
         ETKy7eZsF0Jks5N6qn2ak+asIbVAeBebDJHOj+fLJObW5nQC0iAFa1KFncPDDYs6M4ZW
         fuzWkETG2kqBUj0lD7VzonquDTx3muL02rOsk+qWh9l4qhtrzB11U+RxvTM796evRiEF
         qiUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=o+c+bA8MO26B8kHENhutu/5MRQhebutrzZgxv/ZEKVk=;
        b=S1ukr9zchOlwOp7p3tBp1nWxhYRiRfnhy2q60lkNCwQSGAfCZ/TF8Q7iXD5IvEPwPi
         aVN4JrMDgQIP/UuF3DZzxI3R/bfbv07V9cGW1XSqkqhi6T/QBdNl4UDRl+iZP58KdKRI
         rH5uiBlNJFcZYnyqECe5QXMYiP7mHYi1hb6rD4pDQ2G+IC2zXwH8T9BJknG3xeUkoOTK
         Yp9K9vjlQl/pVAn6KUkAHkWpiQdZkyq+kNDHJCz/A32ljpBJfk9FMCJf3j3go/qIPZ/E
         iHymZN0MdxjLfBIiGggwIEIFpkboF3CHpTRWfqYv7eo2FWELbTCN7LFz/gm96RIAPpUu
         g1SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=FK513RHT;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=LA0XP2cm;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 34si3688037qve.70.2019.04.03.11.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 11:00:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=FK513RHT;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=LA0XP2cm;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x33Hxl0b012148;
	Wed, 3 Apr 2019 11:00:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=o+c+bA8MO26B8kHENhutu/5MRQhebutrzZgxv/ZEKVk=;
 b=FK513RHTEuWDb5BZKa/nzYUAWPlijjXzW5H2o0OjnVYotvcCyqQ05Y2On1FpX4F981/i
 8mzHRHu/iNtgrV3NZpdl/mIYkccBWr0ZeKeK90p6zOZGV5irnDk5pzfTT3Jnp32d0tL5
 nm+404Vgf5et+97kG5RKB3ZUQiDAy7L8oLM= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rmx9t8y8e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 03 Apr 2019 11:00:33 -0700
Received: from prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 11:00:32 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 11:00:32 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 3 Apr 2019 11:00:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=o+c+bA8MO26B8kHENhutu/5MRQhebutrzZgxv/ZEKVk=;
 b=LA0XP2cmh0RrbUphdabVb3tecIorin9IjLWCHCuJF9lSZ8dcOI33bh7MxHyBncAPsWAMYvu7SSootMqsg6WAXYnl/cwPH9RMjmxZwHIneym/hXIUSyncgVFa3rHaL1Fo9gSFcyp2jiJaKRF3AZstDtdnF0v9K9OJsjMrb66ipnw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2231.namprd15.prod.outlook.com (52.135.196.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.20; Wed, 3 Apr 2019 18:00:30 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Wed, 3 Apr 2019
 18:00:30 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <tobin@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter
	<cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        David Rientjes
	<rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Matthew Wilcox
	<willy@infradead.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 2/7] slob: Respect list_head abstraction layer
Thread-Topic: [PATCH v5 2/7] slob: Respect list_head abstraction layer
Thread-Index: AQHU6ajAyy6khhqQC0Sp/NoP4ahiCKYquukA
Date: Wed, 3 Apr 2019 18:00:30 +0000
Message-ID: <20190403180026.GC6778@tower.DHCP.thefacebook.com>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-3-tobin@kernel.org>
In-Reply-To: <20190402230545.2929-3-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR10CA0006.namprd10.prod.outlook.com (2603:10b6:301::16)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:9220]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d235e346-69f5-41f7-3089-08d6b85e427a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2231;
x-ms-traffictypediagnostic: BYAPR15MB2231:
x-microsoft-antispam-prvs: <BYAPR15MB223120194BF5A32BC0248DDEBE570@BYAPR15MB2231.namprd15.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39860400002)(346002)(136003)(376002)(199004)(189003)(6246003)(86362001)(25786009)(46003)(486006)(81166006)(186003)(81156014)(2906002)(305945005)(6512007)(7736002)(6436002)(1076003)(102836004)(6506007)(76176011)(9686003)(105586002)(6116002)(386003)(6916009)(8936002)(106356001)(14444005)(8676002)(4326008)(53936002)(99286004)(6486002)(14454004)(478600001)(52116002)(5660300002)(71190400001)(71200400001)(256004)(33656002)(68736007)(446003)(476003)(229853002)(11346002)(316002)(97736004)(54906003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2231;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8Ptqtd1re9v8y96NFBVGf432dZJ7x+1P8ju1RmqOWZ9RQ+ODP4qfCOHZGADPD/nHSFiddMEm3BjKk0qCxAEB7noF7DkHWKpijG9QX7v2bE7zHtIKngJDeoVSSxigv7Gupu/mpZ/y0KyYhiE43g5Wufm6+rxFhkYfNuoYtcajEpFyGjYIxwou3lHfegJLYkNLGAQrZgBDsJ4nbenmITBFjmNGd3hPNmRPsCilNydNX6Cxd+6S25H7U4TqRtxRa4RiIvK3OFe8ArGF8btztX0DIZ8yyfDQT9AxYLC48mGJanwY+N9JsqdR1ts6jSNeof8YkK75fWSOHAkmLFXPOF+A9ssUWas3Sr5jg5pZCIWAGsG3IyJb+Hz6uSzfJdW5tmDvnb1YuRjIvOPvXonkXBJxNgfojcQvlcDL3/XQx0oHxSU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2236E267A6A29A4AB52D175EC07527B4@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d235e346-69f5-41f7-3089-08d6b85e427a
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 18:00:30.4586
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2231
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-03_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:05:40AM +1100, Tobin C. Harding wrote:
> Currently we reach inside the list_head.  This is a violation of the
> layer of abstraction provided by the list_head.  It makes the code
> fragile.  More importantly it makes the code wicked hard to understand.
>=20
> The code reaches into the list_head structure to counteract the fact
> that the list _may_ have been changed during slob_page_alloc().  Instead
> of this we can add a return parameter to slob_page_alloc() to signal
> that the list was modified (list_del() called with page->lru to remove
> page from the freelist).
>=20
> This code is concerned with an optimisation that counters the tendency
> for first fit allocation algorithm to fragment memory into many small
> chunks at the front of the memory pool.  Since the page is only removed
> from the list when an allocation uses _all_ the remaining memory in the
> page then in this special case fragmentation does not occur and we
> therefore do not need the optimisation.
>=20
> Add a return parameter to slob_page_alloc() to signal that the
> allocation used up the whole page and that the page was removed from the
> free list.  After calling slob_page_alloc() check the return value just
> added and only attempt optimisation if the page is still on the list.
>=20
> Use list_head API instead of reaching into the list_head structure to
> check if sp is at the front of the list.
>=20
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  mm/slob.c | 51 +++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 37 insertions(+), 14 deletions(-)
>=20
> diff --git a/mm/slob.c b/mm/slob.c
> index 307c2c9feb44..07356e9feaaa 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -213,13 +213,26 @@ static void slob_free_pages(void *b, int order)
>  }
> =20
>  /*
> - * Allocate a slob block within a given slob_page sp.
> + * slob_page_alloc() - Allocate a slob block within a given slob_page sp=
.
> + * @sp: Page to look in.
> + * @size: Size of the allocation.
> + * @align: Allocation alignment.
> + * @page_removed_from_list: Return parameter.
> + *
> + * Tries to find a chunk of memory at least @size bytes big within @page=
.
> + *
> + * Return: Pointer to memory if allocated, %NULL otherwise.  If the
> + *         allocation fills up @page then the page is removed from the
> + *         freelist, in this case @page_removed_from_list will be set to
> + *         true (set to false otherwise).
>   */
> -static void *slob_page_alloc(struct page *sp, size_t size, int align)
> +static void *slob_page_alloc(struct page *sp, size_t size, int align,
> +			     bool *page_removed_from_list)

Hi Tobin!

Isn't it better to make slob_page_alloc() return a bool value?
Then it's easier to ignore the returned value, no need to introduce "_unuse=
d".

Thanks!

>  {
>  	slob_t *prev, *cur, *aligned =3D NULL;
>  	int delta =3D 0, units =3D SLOB_UNITS(size);
> =20
> +	*page_removed_from_list =3D false;
>  	for (prev =3D NULL, cur =3D sp->freelist; ; prev =3D cur, cur =3D slob_=
next(cur)) {
>  		slobidx_t avail =3D slob_units(cur);
> =20
> @@ -254,8 +267,10 @@ static void *slob_page_alloc(struct page *sp, size_t=
 size, int align)
>  			}
> =20
>  			sp->units -=3D units;
> -			if (!sp->units)
> +			if (!sp->units) {
>  				clear_slob_page_free(sp);
> +				*page_removed_from_list =3D true;
> +			}
>  			return cur;
>  		}
>  		if (slob_last(cur))
> @@ -269,10 +284,10 @@ static void *slob_page_alloc(struct page *sp, size_=
t size, int align)
>  static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
>  {
>  	struct page *sp;
> -	struct list_head *prev;
>  	struct list_head *slob_list;
>  	slob_t *b =3D NULL;
>  	unsigned long flags;
> +	bool _unused;
> =20
>  	if (size < SLOB_BREAK1)
>  		slob_list =3D &free_slob_small;
> @@ -284,6 +299,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int a=
lign, int node)
>  	spin_lock_irqsave(&slob_lock, flags);
>  	/* Iterate through each partially free page, try to find room */
>  	list_for_each_entry(sp, slob_list, lru) {
> +		bool page_removed_from_list =3D false;
>  #ifdef CONFIG_NUMA
>  		/*
>  		 * If there's a node specification, search for a partial
> @@ -296,18 +312,25 @@ static void *slob_alloc(size_t size, gfp_t gfp, int=
 align, int node)
>  		if (sp->units < SLOB_UNITS(size))
>  			continue;
> =20
> -		/* Attempt to alloc */
> -		prev =3D sp->lru.prev;
> -		b =3D slob_page_alloc(sp, size, align);
> +		b =3D slob_page_alloc(sp, size, align, &page_removed_from_list);
>  		if (!b)
>  			continue;
> =20
> -		/* Improve fragment distribution and reduce our average
> -		 * search time by starting our next search here. (see
> -		 * Knuth vol 1, sec 2.5, pg 449) */
> -		if (prev !=3D slob_list->prev &&
> -				slob_list->next !=3D prev->next)
> -			list_move_tail(slob_list, prev->next);
> +		/*
> +		 * If slob_page_alloc() removed sp from the list then we
> +		 * cannot call list functions on sp.  If so allocation
> +		 * did not fragment the page anyway so optimisation is
> +		 * unnecessary.
> +		 */
> +		if (!page_removed_from_list) {
> +			/*
> +			 * Improve fragment distribution and reduce our average
> +			 * search time by starting our next search here. (see
> +			 * Knuth vol 1, sec 2.5, pg 449)
> +			 */
> +			if (!list_is_first(&sp->lru, slob_list))
> +				list_rotate_to_front(&sp->lru, slob_list);
> +		}
>  		break;
>  	}
>  	spin_unlock_irqrestore(&slob_lock, flags);
> @@ -326,7 +349,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int a=
lign, int node)
>  		INIT_LIST_HEAD(&sp->lru);
>  		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
>  		set_slob_page_free(sp, slob_list);
> -		b =3D slob_page_alloc(sp, size, align);
> +		b =3D slob_page_alloc(sp, size, align, &_unused);
>  		BUG_ON(!b);
>  		spin_unlock_irqrestore(&slob_lock, flags);
>  	}
> --=20
> 2.21.0
>=20

