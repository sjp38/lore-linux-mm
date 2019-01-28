Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A9F8C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE28A20855
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:45:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="BudM2rNa";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="R0jQaX2D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE28A20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 570F68E0002; Mon, 28 Jan 2019 14:45:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D4048E0001; Mon, 28 Jan 2019 14:45:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3746E8E0002; Mon, 28 Jan 2019 14:45:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 049078E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:45:40 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b16so21539510qtc.22
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:45:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=9Xg2z06d0grI0x7GZspjaJOOGhjNdQFd/xwge1KNbxc=;
        b=Zq8YlEqn6vcoJMXB9aqms2U+0VJYcuEn/8o+wQuSkPV31UozFMcK9YBWe3HigEsZ1h
         74IdFfeMbWbjZ+n4xxBoXGYl+LNP7qoXoZeYna0/SofdV0bstGma5N75/klYD33pF6Is
         pDrsDx7DymT4GhjSN0gbMymc7ivNn4Z2dF6KyB47C179jjyGa+EiVu+5XZsBkY7oP4Ao
         b3Ub+Xkp6TPzdbgCmL/qbLW8+Jt6bXC2emDDopbpAvKavQ6LH4h97OVda/eCr8Y7Xzw6
         ORXYZbhlHGQ903JJgHpZEcsJmesLB0+9hTJaJZoX5MHzGK4W148hlOKi1hKNfabPcKkj
         HLPQ==
X-Gm-Message-State: AJcUukcQXIpD3zfzaMTuKj6dxJ6kiwAO1UADOaVAKwmBbamc2TpVw9wy
	0vz3ELJzmuNpYgwUVVuK4u1mmWvVQIso2TlB8rn/3Rd4QuIhCAe8UhaUc6gT9tz53mJXuY1Yjf3
	D6uJPw1K/1AMgnjALGpYdJMrcSjmufelUV1abgIs7pr9PfbV4vgWd3ZGP60VZ1adf4A==
X-Received: by 2002:a37:99c5:: with SMTP id b188mr21423154qke.100.1548704739742;
        Mon, 28 Jan 2019 11:45:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4yrGWGv2+A2mq5FCVgfWQE6x3ouabkmKFKi35ff6aLuzsDvfKExixb8SseJ5cvTcKuzR/f
X-Received: by 2002:a37:99c5:: with SMTP id b188mr21423115qke.100.1548704739002;
        Mon, 28 Jan 2019 11:45:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548704738; cv=none;
        d=google.com; s=arc-20160816;
        b=iN5TAPPDUwbJ9Bqu98v/qHo7n6PV5E44/vWT3PkpadzTnHy93o9xfF9m2ocCN/L5TY
         0seZ2B22FLL4o/8/TaB7+ysTk8gC11fCPyMi5Uc/Op7O5lGywyrgPUtgdbk1h0M+7nw6
         fGaIBBRS/+d4AzIFSpgVjUmWYpm2U2fPq+eQ+IysZ2dQF9qGiMyQOnr1go7lXzIh5/Os
         zNUEy4Lnk7bvoqXvXj24M0aV0VPLWmY4cs+51FzTchUlifTQ7ljEAtNVRxCGCn6Vk8Li
         qKk6dmoIUsDlRXPiMZwmXgGxzlQrmF6ROPcXoS0GPqgFxv9E2Zf1McfvheuUcKgBlz6o
         FoEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=9Xg2z06d0grI0x7GZspjaJOOGhjNdQFd/xwge1KNbxc=;
        b=x4fNiCQ5zdCEoOjlqyCv4sde3hmq2K54Tw+N0MRADVku3cgnBEc44UDHB1ShHpf5c0
         GJPS59xC+p0yO3Rw/047i0rbBr8Q2RXPSapY4vFbcpI6g2djcWIxbmc0bZ8sko+ghrjX
         2z2L08BjEbS3rP++rr50PE+xNbpXm0GDY8KxB3YPuFD58zv9wFl8HS/mSMy5YP6OCP5c
         E/qIqNWQjx5C6FwwjOIBJyotJ08Qjt9uxLbSvGYiEXsIyqMhoEolci0Fwh7IUFvpKCtY
         5/thAwnjzYTcLTrtKOHyfp9YH7i4O3NA+pzUnmnNHoUcxOpTIx8VBeC8qa5brwN3jOED
         kMgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=BudM2rNa;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=R0jQaX2D;
       spf=pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79316e96ce=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i56si6834482qti.84.2019.01.28.11.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 11:45:38 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=BudM2rNa;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=R0jQaX2D;
       spf=pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79316e96ce=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0SJhlJY020721;
	Mon, 28 Jan 2019 11:45:35 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=9Xg2z06d0grI0x7GZspjaJOOGhjNdQFd/xwge1KNbxc=;
 b=BudM2rNa7Hv2lwQieQgR1eGZGWbbECNaCoa5pcHpFj95/V/jGAU0Ys2xkCfggJrNPXQ8
 UdssBgCvARSGAYrzlHeezsIuWNQUvT9fdyfRSJpjCuiQ9eMDByqQCrhmD/13hIAo5c8M
 DhareAaEUjaEvLHrU4FWeMpTBkJnwmMCr58= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qa81j0166-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 28 Jan 2019 11:45:35 -0800
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 28 Jan 2019 11:45:11 -0800
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 28 Jan 2019 11:45:11 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9Xg2z06d0grI0x7GZspjaJOOGhjNdQFd/xwge1KNbxc=;
 b=R0jQaX2D4xwK7MBrv4rCCWENWgwulSsG6odz+FC1woqzLt1sr5xaTMYoaV8gzG3C7v1q/m9hmCl0tIn8SbPX0Q9OLXHwaNUAMB4uQEUQj/t3VUnYp/1zOIMkN6KVk259SEjLTlsHX5Wlehpp41kIuGnL86nKksVovC2L69KP9Bw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2536.namprd15.prod.outlook.com (20.179.154.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.17; Mon, 28 Jan 2019 19:45:10 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::7459:36fe:91f2:8b8a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::7459:36fe:91f2:8b8a%6]) with mapi id 15.20.1558.023; Mon, 28 Jan 2019
 19:45:10 +0000
From: Roman Gushchin <guro@fb.com>
To: Rik van Riel <riel@surriel.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
        Chris Mason <clm@fb.com>, Andrew Morton
	<akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>,
        "hange-folder>?"
	<toggle-mailboxes@castle.dhcp.thefacebook.com>
Subject: Re: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
Thread-Topic: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
Thread-Index: AQHUt0DNW/N3hHmpU0+8/TF4YJ27XaXFFWyA
Date: Mon, 28 Jan 2019 19:45:09 +0000
Message-ID: <20190128194502.GA30061@castle.DHCP.thefacebook.com>
References: <20190128143535.7767c397@imladris.surriel.com>
In-Reply-To: <20190128143535.7767c397@imladris.surriel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1401CA0010.namprd14.prod.outlook.com
 (2603:10b6:301:4b::20) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:b22f]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2536;20:iBlr0/ip04jZsBqu1kZesOvkbYzfkihbuHywrAyaOPIl1xNGpPr3njQa2W1EJ5Ptmr3juhsJK2Era7OdEEDD4s5+clVuNnQYgqPqWLifAJhrDZiaE4NQJ1lobyr3aNMuzBlT0M7uMTehuBEdhd0B0aiexK3gvT1L1iFFZ4jxdjc=
x-ms-office365-filtering-correlation-id: 53b5d469-98d8-49c0-e4f3-08d685591c70
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2536;
x-ms-traffictypediagnostic: BYAPR15MB2536:
x-microsoft-antispam-prvs: <BYAPR15MB2536D4A764A076F0217CD1A3BE960@BYAPR15MB2536.namprd15.prod.outlook.com>
x-forefront-prvs: 0931CB1479
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(39860400002)(136003)(376002)(396003)(189003)(199004)(76176011)(52116002)(97736004)(81156014)(446003)(25786009)(46003)(8676002)(53936002)(81166006)(476003)(7736002)(305945005)(54906003)(6916009)(6246003)(4326008)(33896004)(2906002)(86362001)(11346002)(316002)(99286004)(256004)(186003)(486006)(8936002)(68736007)(105586002)(71200400001)(106356001)(14454004)(33656002)(1076003)(229853002)(386003)(9686003)(6512007)(71190400001)(6486002)(6436002)(478600001)(6506007)(102836004)(6116002)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2536;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: jw0lE7XldqByeR1JkYot52Iu4wRPJ3J5Ia3XGfa5JSJb6Dc2kAUenDNnYcQ8o6sBaPiHCpXnlNcTroIqkOeiIljsDKYoc6GUEWoU0UO+COpK87V0BQwUwUHAfm5ZTNZJyosapuExSkRD6LpADwYMhPH2peMwMMkJEWVGPyh+981RwD/Toz64qKgd5Woh30f71K+hSW2lifewdKjLxaRE22N2WPQ+JPJAPiwQEtk7FuNEytrm2ZWen8bSPuTWDxGL7xsfmCMcEq3+LWkBK2eACUtdhJJSIK2HhFgpcGrL9AjsxvIuFi6vTQjmjC3GSW72SAEj7z7KuPMwNl5RZf0ORV5wNTHEoWb3A8rHvrZgi+wyS/vXIyXB8/txJzZ4yhKpxbDFrLYB2tfigkShnoJII4NxfUhcB3vXwEE9JhPfBIg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <76A242FEEB281C4FB87A8E48DEF7F215@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 53b5d469-98d8-49c0-e4f3-08d685591c70
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jan 2019 19:45:08.7122
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2536
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-28_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 02:35:35PM -0500, Rik van Riel wrote:
> There are a few issues with the way the number of slab objects to
> scan is calculated in do_shrink_slab.  First, for zero-seek slabs,
> we could leave the last object around forever. That could result
> in pinning a dying cgroup into memory, instead of reclaiming it.
> The fix for that is trivial.
>=20
> Secondly, small slabs receive much more pressure, relative to their
> size, than larger slabs, due to "rounding up" the minimum number of
> scanned objects to batch_size.
>=20
> We can keep the pressure on all slabs equal relative to their size
> by accumulating the scan pressure on small slabs over time, resulting
> in sometimes scanning an object, instead of always scanning several.
>=20
> This results in lower system CPU use, and a lower major fault rate,
> as actively used entries from smaller caches get reclaimed less
> aggressively, and need to be reloaded/recreated less often.
>=20
> Fixes: 4b85afbdacd2 ("mm: zero-seek shrinkers")
> Fixes: 172b06c32b94 ("mm: slowly shrink slabs with a relatively small num=
ber of objects")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Chris Mason <clm@fb.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: kernel-team@fb.com
> Tested-by: Chris Mason <clm@fb.com>

Hi, Rik!

There is a couple of formatting issues (see below), but other than that
the patch looks very good to me. Thanks!

Acked-by: Roman Gushchin <guro@fb.com>

> ---
>  include/linux/shrinker.h |  1 +
>  mm/vmscan.c              | 16 +++++++++++++---
>  2 files changed, 14 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 9443cafd1969..7a9a1a0f935c 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -65,6 +65,7 @@ struct shrinker {
> =20
>  	long batch;	/* reclaim batch size, 0 =3D default */
>  	int seeks;	/* seeks to recreate an obj */
> +	int small_scan;	/* accumulate pressure on slabs with few objects */
>  	unsigned flags;
> =20
>  	/* These are for internal use */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a714c4f800e9..0e375bd7a8b6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -488,18 +488,28 @@ static unsigned long do_shrink_slab(struct shrink_c=
ontrol *shrinkctl,
>  		 * them aggressively under memory pressure to keep
>  		 * them from causing refetches in the IO caches.
>  		 */
> -		delta =3D freeable / 2;
> +		delta =3D (freeable + 1)/ 2;
                                      ^
                                      A space is missing here.
>  	}
> =20
>  	/*
>  	 * Make sure we apply some minimal pressure on default priority
> -	 * even on small cgroups. Stale objects are not only consuming memory
> +	 * even on small cgroups, by accumulating pressure across multiple
> +	 * slab shrinker runs. Stale objects are not only consuming memory
>  	 * by themselves, but can also hold a reference to a dying cgroup,
>  	 * preventing it from being reclaimed. A dying cgroup with all
>  	 * corresponding structures like per-cpu stats and kmem caches
>  	 * can be really big, so it may lead to a significant waste of memory.
>  	 */
> -	delta =3D max_t(unsigned long long, delta, min(freeable, batch_size));
> +	if (!delta) {
> +		shrinker->small_scan +=3D freeable;
> +
> +		delta =3D shrinker->small_scan >> priority;
> +		shrinker->small_scan -=3D delta << priority;
> +
> +		delta *=3D 4;
> +		do_div(delta, shrinker->seeks);
> +

This empty line can be removed, I believe.

> +	}
> =20
>  	total_scan +=3D delta;
>  	if (total_scan < 0) {
>=20

