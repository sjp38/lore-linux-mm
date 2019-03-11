Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F205C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 22:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7DDF2087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 22:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ffOOxDpV";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="KN9pdTDm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7DDF2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 417088E0003; Mon, 11 Mar 2019 18:49:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C6DE8E0002; Mon, 11 Mar 2019 18:49:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28FC48E0003; Mon, 11 Mar 2019 18:49:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0202C8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:49:10 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id f67so912633ywa.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:49:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=adpu0xNcGZmaMckLjj+HHNg2kM0BLj0DmknGcAI7v2A=;
        b=s2x/jL6k5xdT/zKG4RSdHNVoEFV72iTQyY+KNXbiIFRWVMg6N+PzvLDjpslgQW8tWs
         i5ZULqSCN4V0sRPbZxpOZG+A1SPzHxSO6z9H1GenwAhC4IAd2yRFdIOlI3S5NdTY1XPp
         g8m3ArHuevNSpZMZUqxJ+fXMaAZY8/cC2Zh3xjPpGcCgCqSqofHpQSQpg6AdC3DJ7vUV
         rAnuhD+sCxoz1Vho4HUfdvuns5nG8VIJGIFQKyyeu8wi80HhZa/Ip7QtjfD+WwzY8jgJ
         zfcIUrIpc/YHwRcDgI0pB7IJmWfD9aGvLYN9DjEGoaP88guU9FDytXHkIeLPUfpGjAWP
         xPYg==
X-Gm-Message-State: APjAAAWjFzV+sCHOfZtxMbZXgtUj881iqM6wb/qBt4825eP7hY3JetC6
	oXO02ogwwDVcNgKhrELKev14zM4vpkHz57pWRljsiTh2YsUKbKj/Ln8Vcijlrt8Ht8Kx6k31+dr
	jfJnMILpmBOkB4f30GgHOioWN5ns+p8vwu7jHnUOm+bw0zp0T0iobZVgRuT4XclIgMA==
X-Received: by 2002:a81:a607:: with SMTP id d7mr27144981ywh.397.1552344549681;
        Mon, 11 Mar 2019 15:49:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0as48qEXGQ93xpPhBepmV3/5Q1jeRZfZ59xNRUgTqHmksbi2Mh8tLAUHs6UhxGMrx5U7k
X-Received: by 2002:a81:a607:: with SMTP id d7mr27144955ywh.397.1552344548817;
        Mon, 11 Mar 2019 15:49:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552344548; cv=none;
        d=google.com; s=arc-20160816;
        b=Xhm19ZrcOx1A64FAMQW5Lrw6bIdPwHctUlvTB+M3jGLjaVvyd+jwn71NPYf+O98SqG
         NSMbVd2yDrwVonFBZB2Vywu+gfV5Fic/bIaLdnC1AuIiTBKrpWDrtm9I8GgOZ4DDaRJ8
         2I1c+jxXXpbPMZJd771c2pMhFHaqRNxr7+v1JhkfrDY1fmJIBpZTE47lp6oDrR9qnYL2
         tFvyk4iAYnMGJ+tDEAWC7/8Az9lbXkr4mKhrFhcvfyDQY6G0s0lARu92BN0O3VttN/aR
         NGlW10ETvhnnf0aBKCTJM3PD2zum1dAVDMN/KtkE9aAxZdKXYc2dHFWFjK94uMHWN60Z
         jJEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=adpu0xNcGZmaMckLjj+HHNg2kM0BLj0DmknGcAI7v2A=;
        b=S+j9xW/wJYFwUF//+oBjhc9686AvYC6PTxRQeAJGe0UJoY6/nJJ1lsD68sMeGO/Tg9
         tJlgZqz4yKbXG4UuqtPVycNf5THUw4Bk4Hgu0EN2R/7tYibVk8JDbAZEPcc4jtGLKYhO
         E3YEXoTQ7amLex945UuQ/INu6SKYqflBJUBkKbgrj5pUxRy2hO5qxsOHbyF/YXgTPoiv
         GxBF7dx4cYSMoaTReIE4jtRjk4yAzmHUUExm1gS2DZPhNfVKz2I0Y/Bfl5b3Eaa5d/vB
         21TRSa+8TgM0e9xLQckQkMkvac7JPf7AZwp7WXklvGDz5X3lESkyWj0pFyJZQfRJvDve
         N+nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ffOOxDpV;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=KN9pdTDm;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f8si3738097ywf.331.2019.03.11.15.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 15:49:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ffOOxDpV;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=KN9pdTDm;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BMjpqm027674;
	Mon, 11 Mar 2019 15:48:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=adpu0xNcGZmaMckLjj+HHNg2kM0BLj0DmknGcAI7v2A=;
 b=ffOOxDpV0pfLOl+a4Jh9otNUzLTjuIurc6pB9GgRAEuu/mo2uhrdLJAvGUwA6DWGHjBP
 dDDQQjJAgOLa7fVfCdac02BbDnjq48tJVjOM68puw/54PgrzZk0eLzNKL97JCJ0IJrOM
 brK1WX7BzEFgYK71nuI44DfDabdpSeeoqT4= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r5xupgdax-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 11 Mar 2019 15:48:49 -0700
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 15:48:48 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 15:48:48 -0700
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 11 Mar 2019 15:48:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=adpu0xNcGZmaMckLjj+HHNg2kM0BLj0DmknGcAI7v2A=;
 b=KN9pdTDm+RzNvyejDYK0YYAcDc6MefD5c7q8ZMQvv7nDE1DB1Fu2tGkQDgLsp1+fDTGcUh5cxSR4kwzDj/bB+q3U2nPLN/UDTedyph3o+YAsvPCfV+NBaDtv7DM2lp6NQnOKet8QBGEvd2c+RZ8a45fP0KMGpTQA49mmhGVTfOU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2261.namprd15.prod.outlook.com (52.135.197.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.20; Mon, 11 Mar 2019 22:48:45 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Mon, 11 Mar 2019
 22:48:45 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <tobin@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Christopher Lameter
	<cl@linux.com>,
        Pekka Enberg <penberg@cs.helsinki.fi>,
        Matthew Wilcox
	<willy@infradead.org>, Tycho Andersen <tycho@tycho.ws>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
Thread-Topic: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
Thread-Index: AQHU1WWOlMss86oUX0OspYov/G2S1KYHDlsA
Date: Mon, 11 Mar 2019 22:48:45 +0000
Message-ID: <20190311224842.GC7915@tower.DHCP.thefacebook.com>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-5-tobin@kernel.org>
In-Reply-To: <20190308041426.16654-5-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR0201CA0025.namprd02.prod.outlook.com
 (2603:10b6:301:74::38) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:b487]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9019397a-d2b8-43ec-7365-08d6a673b7e2
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2261;
x-ms-traffictypediagnostic: BYAPR15MB2261:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2261;20:EodXjxmQ76caHpmdpHs5hXrsTd9HHCx57nJsgoix0ZXrnLNaezYiVLb8RVKLhiOlDRN5S2ryXtxHbPLeREuKWAZuB4zikluDB7XTTIvUNWv/uybQLYHZ2BN7DilNZVBsfcOXguAO4uHyRZ0aXXpwETTIbc+y5rj2dCkNsAzywZk=
x-microsoft-antispam-prvs: <BYAPR15MB2261F5ED4BA2DE6376620A76BE480@BYAPR15MB2261.namprd15.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(346002)(136003)(376002)(396003)(366004)(189003)(199004)(386003)(6506007)(76176011)(52116002)(106356001)(46003)(105586002)(8936002)(102836004)(486006)(476003)(11346002)(14454004)(229853002)(33656002)(256004)(14444005)(71200400001)(54906003)(446003)(71190400001)(86362001)(478600001)(68736007)(97736004)(316002)(81156014)(7736002)(53936002)(186003)(25786009)(9686003)(6512007)(2906002)(6116002)(8676002)(81166006)(1076003)(6486002)(6246003)(5660300002)(305945005)(99286004)(6436002)(6916009)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2261;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 5530l7Bgol9FEelWiMEfyJ+P+vEp1aj5ZerWpLiGEldwdtBxIOJrEhWQrplH1kvDdwyNjqN+c+wvMGZ2Nu4WGp7A2JL6GwbdAhe+bRRSeoA8xMV+SJaCoB57hiGDuBzT6vKQgwDXtJPF4p5ypMq66IH7U1P/im+fdwxZH931bKwD56F4vgNWlCejSYvu2wQjzZ6MZ3bGqYWSBUVz/eKNdh0IRqIeRHQLhSsY2spostb+D26cHkS2bJg7L9NzjCp491y+3WOUlHwrolgmMwxyCz5Pt4hCW+LJTUSGRCi1QAKQBV1OSKdCDWMACPwPQrL/xXwQZD1AQwjvl/uiAJDbEvfiVjR75FYzrdY2bK1pJ+hOi7yA803gRFVXSDzKaJfKJMI0rhoINmWn2W4PH3hU1AGs9IG3ljgfE7QvwVOzi40=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AABB0B331AE3EB46905B1D6C02F77584@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9019397a-d2b8-43ec-7365-08d6a673b7e2
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 22:48:45.8586
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2261
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-11_16:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:14:15PM +1100, Tobin C. Harding wrote:
> We have now in place a mechanism for adding callbacks to a cache in
> order to be able to implement object migration.
>=20
> Add a function __move() that implements SMO by moving all objects in a
> slab page using the isolate/migrate callback methods.
>=20
> Co-developed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  mm/slub.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 85 insertions(+)
>=20
> diff --git a/mm/slub.c b/mm/slub.c
> index 0133168d1089..6ce866b420f1 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4325,6 +4325,91 @@ int __kmem_cache_create(struct kmem_cache *s, slab=
_flags_t flags)
>  	return err;
>  }
> =20
> +/*
> + * Allocate a slab scratch space that is sufficient to keep pointers to
> + * individual objects for all objects in cache and also a bitmap for the
> + * objects (used to mark which objects are active).
> + */
> +static inline void *alloc_scratch(struct kmem_cache *s)
> +{
> +	unsigned int size =3D oo_objects(s->max);
> +
> +	return kmalloc(size * sizeof(void *) +
> +		       BITS_TO_LONGS(size) * sizeof(unsigned long),
> +		       GFP_KERNEL);

I wonder how big this allocation can be?
Given that the reason for migration is probably highly fragmented memory,
we probably don't want to have a high-order allocation here. So maybe
kvmalloc()?

> +}
> +
> +/*
> + * __move() - Move all objects in the given slab.
> + * @page: The slab we are working on.
> + * @scratch: Pointer to scratch space.
> + * @node: The target node to move objects to.
> + *
> + * If the target node is not the current node then the object is moved
> + * to the target node.  If the target node is the current node then this
> + * is an effective way of defragmentation since the current slab page
> + * with its object is exempt from allocation.
> + */
> +static void __move(struct page *page, void *scratch, int node)
> +{

__move() isn't a very explanatory name. kmem_cache_move() (as in Christophe=
r's
version) is much better, IMO. Or maybe move_slab_objects()?

Also, it's usually better to avoid adding new functions without calling the=
m.
Maybe it's possible to merge this patch with (9)?

Thanks!


> +	unsigned long objects;
> +	struct kmem_cache *s;
> +	unsigned long flags;
> +	unsigned long *map;
> +	void *private;
> +	int count;
> +	void *p;
> +	void **vector =3D scratch;
> +	void *addr =3D page_address(page);
> +
> +	local_irq_save(flags);
> +	slab_lock(page);
> +
> +	BUG_ON(!PageSlab(page)); /* Must be s slab page */
> +	BUG_ON(!page->frozen);	 /* Slab must have been frozen earlier */
> +
> +	s =3D page->slab_cache;
> +	objects =3D page->objects;
> +	map =3D scratch + objects * sizeof(void **);
> +
> +	/* Determine used objects */
> +	bitmap_fill(map, objects);
> +	for (p =3D page->freelist; p; p =3D get_freepointer(s, p))
> +		__clear_bit(slab_index(p, s, addr), map);
> +
> +	/* Build vector of pointers to objects */
> +	count =3D 0;
> +	memset(vector, 0, objects * sizeof(void **));
> +	for_each_object(p, s, addr, objects)
> +		if (test_bit(slab_index(p, s, addr), map))
> +			vector[count++] =3D p;
> +
> +	if (s->isolate)
> +		private =3D s->isolate(s, vector, count);
> +	else
> +		/* Objects do not need to be isolated */
> +		private =3D NULL;
> +
> +	/*
> +	 * Pinned the objects. Now we can drop the slab lock. The slab
> +	 * is frozen so it cannot vanish from under us nor will
> +	 * allocations be performed on the slab. However, unlocking the
> +	 * slab will allow concurrent slab_frees to proceed. So the
> +	 * subsystem must have a way to tell from the content of the
> +	 * object that it was freed.
> +	 *
> +	 * If neither RCU nor ctor is being used then the object may be
> +	 * modified by the allocator after being freed which may disrupt
> +	 * the ability of the migrate function to tell if the object is
> +	 * free or not.
> +	 */
> +	slab_unlock(page);
> +	local_irq_restore(flags);
> +
> +	/* Perform callback to move the objects */
> +	s->migrate(s, vector, count, node, private);
> +}
> +
>  void kmem_cache_setup_mobility(struct kmem_cache *s,
>  			       kmem_cache_isolate_func isolate,
>  			       kmem_cache_migrate_func migrate)
> --=20
> 2.21.0
>=20

