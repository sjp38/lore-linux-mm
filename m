Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABAFAC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4820F214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="It/Xa59x";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Elk+kPR+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4820F214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1D408E0003; Mon, 11 Mar 2019 17:51:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCE358E0002; Mon, 11 Mar 2019 17:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6D8C8E0003; Mon, 11 Mar 2019 17:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6D48E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:51:54 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id o73so440376itb.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 14:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=HE7+Bgg3bIZZ4pb7dvD9pFN8hu7z4uU/LN+CBLP6b2c=;
        b=Pp84TAvh1N3poPsoetLgvnGgms2vQc8488tGPxFQTWXEmXbfbKbHNENrc7TnipHd5x
         O/e3waWYyBcMhfavl+P4PFC0r3JKUWGkUBOZCjOndZvkUpgPtmwjwmyWBm0iHDWa3WDn
         5mwg3tSGEiJCvHh39voojJLy9jFl1AiqjUlZCXha9dE4cQVmfvkCM2PRDNujzOTc3doI
         nxLTt6VdTaiKEz0apK3XqFbl9Fu7ASaD8MntDkdZqgKMDgpCbTSuzFzqdE2nNaM5Zraj
         j1+kdTV41EFFiYtDJUiPjo7iM79F0vsUx4yKvxH+/ntbS6BjK+sAFltakY1dVnkJgkyA
         QJ6g==
X-Gm-Message-State: APjAAAV3TzzRmFZ33nLSkllNDeAsyxofbcraybJu5nqk3nw1AY4DJqmf
	47cZ5yEuB/xiZmQRyOZMOcTli279IS2RecRgm6/h43mdIlzwfw6rC9Ln12CLSI/4gC2X4pYUb5O
	RByXIZoxlSkhdIXLLN+QynU6gHZi/ZsHvfkUo0u+MwrRUvhgw2vZ8Wu1wwV7zwVUbKA==
X-Received: by 2002:a24:9982:: with SMTP id a124mr235500ite.79.1552341114249;
        Mon, 11 Mar 2019 14:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAKuVIXVYoNynOSfWlyP/aBWmP6NR9DcnO9zz5gALJ4ZOl9b+1VbDQx46dfn292KgQ/mVj
X-Received: by 2002:a24:9982:: with SMTP id a124mr235466ite.79.1552341113102;
        Mon, 11 Mar 2019 14:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552341113; cv=none;
        d=google.com; s=arc-20160816;
        b=B/chb6iFyOMfm6GnJotWacbEQroAxI1lJVttyfVCLHNihmeAdZv7fv8lw5m+V65Cqo
         zJnyFNMYeOHdpuqmrXiY4Tr7OnKCOaOvHuedXfuogiuctQZE9m13Vm7cqVA2DNQTlnBZ
         Wz9Vkuw7uBzJ8LFUhJJVTBsJGeKOG/PvJ8quMqMayPebYqOzcfTUlBrIek/ewSnBOmbr
         /WQ2Aesd3phlpQBfEl3+NVsOFk+6yql3RIuKac+cl8tDbFkcauL4XwdMIVALfEw3UQ3q
         eokl1zkm+1pXXL7viGcQETEnE3JJ1OokUfrGOVDYMUMoEuwvMSnv+5xieEwrQvZZPpw9
         zJ4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=HE7+Bgg3bIZZ4pb7dvD9pFN8hu7z4uU/LN+CBLP6b2c=;
        b=BqKNYpYPOBZ5xOjrR8b2x8QHC2N0fsAcHx7ywUuGFWaPQyCeRy/kg+J6D14pyqeayz
         KLsimqXMKh3Q9CNQD5vXT8E3HGJce5X3jgdKKNDYgNEk3QbUR705HGhfyV5qU+IVxx5P
         6knfXv4G4vv28YG1VRjIaS5HxlEe8718kiApf+Glod4zo3yE2I3U97xgW/YbhU0d7ZOO
         IVEnpRHoX83c/o3j062QHKFYfZvYrXgyw5O6a6o4nCtzQMijhLhQxI5qMDS4bqQ27Iw4
         765QZc1cBcVux0R+NCpds1iPVGit1fWC97TgCfClP9IzoADxRbecGPvblcIAXhcIjTIA
         aiwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="It/Xa59x";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Elk+kPR+;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 11si258616itx.64.2019.03.11.14.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 14:51:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="It/Xa59x";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Elk+kPR+;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BLjMji021683;
	Mon, 11 Mar 2019 14:51:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=HE7+Bgg3bIZZ4pb7dvD9pFN8hu7z4uU/LN+CBLP6b2c=;
 b=It/Xa59xXBjXoOhX4Cskit0px35ycmqC0MsPCroxl4l4b9ns5qeeHx3UtyN4ePZAFdkA
 v6qktrGppVwnu+cuaKoxvwOPZwsQfa2hTaot7caixtXqWUODXLCBG39K6IiYKjBbpZ4t
 Ozg86Eeo5ratxgveR3V5z6CgTYSH3JkyO8M= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r5wuw8fde-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 11 Mar 2019 14:51:42 -0700
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 14:51:12 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 14:51:12 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 11 Mar 2019 14:51:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HE7+Bgg3bIZZ4pb7dvD9pFN8hu7z4uU/LN+CBLP6b2c=;
 b=Elk+kPR+/lWGStMZd9oXt2hnzaSNGtjdmNMmijr/0GL9FtGh+uNxvIPK76tpG6ungXBqQ7ZpJIwj8nPMbRK+/rakmxlm4oulW/Sv5w4FAVuDl0ji0eKGsYnDP0WqQTx/pjqT5jbDgPFloacHqLk7OxGtw7txaudl3o99OGUQGyc=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2262.namprd15.prod.outlook.com (52.135.197.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.19; Mon, 11 Mar 2019 21:51:09 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Mon, 11 Mar 2019
 21:51:09 +0000
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
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Thread-Topic: [RFC 02/15] slub: Add isolate() and migrate() methods
Thread-Index: AQHU1WWOzoo+8Mo/g0+TXm2HFlFybKYG/kMA
Date: Mon, 11 Mar 2019 21:51:09 +0000
Message-ID: <20190311215106.GA7915@tower.DHCP.thefacebook.com>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
In-Reply-To: <20190308041426.16654-3-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR08CA0001.namprd08.prod.outlook.com
 (2603:10b6:a03:100::14) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:b487]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2e2de05f-6db7-4f1a-f655-08d6a66babeb
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2262;
x-ms-traffictypediagnostic: BYAPR15MB2262:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2262;20:wnEeT3LekANxezNI+AW2CCjJaLmhkbMgV18YtI3B3g/Zx9CMBMqhhw+bwJN+pOnBfwgmwTXT/0SWoVwD0M4V+VhQpLTkGsKZ1vve9gD+khoLWVgt/gbVBssE/iZ2v+l+paBCvvLCOu4sZrE3snR8lJqKOJb2v37nAGorJAEm8v0=
x-microsoft-antispam-prvs: <BYAPR15MB2262E707A7F8CA7739F49F19BE480@BYAPR15MB2262.namprd15.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(366004)(136003)(346002)(376002)(54094003)(199004)(189003)(5660300002)(6116002)(53936002)(316002)(6486002)(54906003)(81166006)(478600001)(68736007)(305945005)(386003)(6512007)(99286004)(81156014)(76176011)(1076003)(52116002)(6436002)(6506007)(8936002)(9686003)(7736002)(25786009)(105586002)(229853002)(6246003)(2906002)(8676002)(97736004)(186003)(4326008)(106356001)(6916009)(14454004)(71190400001)(446003)(71200400001)(11346002)(486006)(476003)(33656002)(46003)(14444005)(256004)(102836004)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2262;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 4dCundw96p/+F4EB4H9V1wlBa7XyIpoEtYMIzLLfyOpGW2mAS8FVkxgo2r2Pmv1YGIb7cq4hZ++H25ZcpiItBEh8KdT+67S/FMzQRhD79z6VONuzXlET2XFGdmAO0g4GvabgMnyJigP8jprnjvzZ+1v8OvD41ybCL3PNm9FCfqtAQCfG/o2BMRA/MaL7G6WRouOA3O7xoKK5KWU7KIzorU14m4KO7dUyToxjRHhBLycQEfBGABOmcN2DINvymD1exsD9VZWNx+FfgYz5WRbba6C6wAx8cokSjsIxwCTJ0Zb9D6PvjpXKJgovCyltmwMBMM75ibKZT5sj8Hdw3qN8PPN2vhtfZB2IX6J8xYDHoJV2HI9WjyQe8MiVrKk/W9oX9W14vDHlD7RyfOoETmAzu6cJjvgP8ba7r/8wfsUCUvk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C887680CD53FAB4D95B7FFA57CF5A72D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2e2de05f-6db7-4f1a-f655-08d6a66babeb
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 21:51:09.8285
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2262
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

On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> Add the two methods needed for moving objects and enable the display of
> the callbacks via the /sys/kernel/slab interface.
>=20
> Add documentation explaining the use of these methods and the prototypes
> for slab.h. Add functions to setup the callbacks method for a slab
> cache.
>=20
> Add empty functions for SLAB/SLOB. The API is generic so it could be
> theoretically implemented for these allocators as well.
>=20
> Co-developed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  include/linux/slab.h     | 69 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/slub_def.h |  3 ++
>  mm/slab_common.c         |  4 +++
>  mm/slub.c                | 42 ++++++++++++++++++++++++
>  4 files changed, 118 insertions(+)
>=20
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 11b45f7ae405..22e87c41b8a4 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -152,6 +152,75 @@ void memcg_create_kmem_cache(struct mem_cgroup *, st=
ruct kmem_cache *);
>  void memcg_deactivate_kmem_caches(struct mem_cgroup *);
>  void memcg_destroy_kmem_caches(struct mem_cgroup *);
> =20
> +/*
> + * Function prototypes passed to kmem_cache_setup_mobility() to enable
> + * mobile objects and targeted reclaim in slab caches.
> + */
> +
> +/**
> + * typedef kmem_cache_isolate_func - Object migration callback function.
> + * @s: The cache we are working on.
> + * @ptr: Pointer to an array of pointers to the objects to migrate.
> + * @nr: Number of objects in array.
> + *
> + * The purpose of kmem_cache_isolate_func() is to pin each object so tha=
t
> + * they cannot be freed until kmem_cache_migrate_func() has processed
> + * them. This may be accomplished by increasing the refcount or setting
> + * a flag.
> + *
> + * The object pointer array passed is also passed to
> + * kmem_cache_migrate_func().  The function may remove objects from the
> + * array by setting pointers to NULL. This is useful if we can determine
> + * that an object is being freed because kmem_cache_isolate_func() was
> + * called when the subsystem was calling kmem_cache_free().  In that
> + * case it is not necessary to increase the refcount or specially mark
> + * the object because the release of the slab lock will lead to the
> + * immediate freeing of the object.
> + *
> + * Context: Called with locks held so that the slab objects cannot be
> + *          freed.  We are in an atomic context and no slab operations
> + *          may be performed.
> + * Return: A pointer that is passed to the migrate function. If any
> + *         objects cannot be touched at this point then the pointer may
> + *         indicate a failure and then the migration function can simply
> + *         remove the references that were already obtained. The private
> + *         data could be used to track the objects that were already pin=
ned.
> + */
> +typedef void *kmem_cache_isolate_func(struct kmem_cache *s, void **ptr, =
int nr);
> +
> +/**
> + * typedef kmem_cache_migrate_func - Object migration callback function.
> + * @s: The cache we are working on.
> + * @ptr: Pointer to an array of pointers to the objects to migrate.
> + * @nr: Number of objects in array.
> + * @node: The NUMA node where the object should be allocated.
> + * @private: The pointer returned by kmem_cache_isolate_func().
> + *
> + * This function is responsible for migrating objects.  Typically, for
> + * each object in the input array you will want to allocate an new
> + * object, copy the original object, update any pointers, and free the
> + * old object.
> + *
> + * After this function returns all pointers to the old object should now
> + * point to the new object.
> + *
> + * Context: Called with no locks held and interrupts enabled.  Sleeping
> + *          is possible.  Any operation may be performed.
> + */
> +typedef void kmem_cache_migrate_func(struct kmem_cache *s, void **ptr,
> +				     int nr, int node, void *private);
> +
> +/*
> + * kmem_cache_setup_mobility() is used to setup callbacks for a slab cac=
he.
> + */
> +#ifdef CONFIG_SLUB
> +void kmem_cache_setup_mobility(struct kmem_cache *, kmem_cache_isolate_f=
unc,
> +			       kmem_cache_migrate_func);
> +#else
> +static inline void kmem_cache_setup_mobility(struct kmem_cache *s,
> +	kmem_cache_isolate_func isolate, kmem_cache_migrate_func migrate) {}
> +#endif
> +
>  /*
>   * Please use this macro to create slab caches. Simply specify the
>   * name of the structure and maybe some flags that are listed above.
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 3a1a1dbc6f49..a7340a1ed5dc 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -99,6 +99,9 @@ struct kmem_cache {
>  	gfp_t allocflags;	/* gfp flags to use on each alloc */
>  	int refcount;		/* Refcount for slab cache destroy */
>  	void (*ctor)(void *);
> +	kmem_cache_isolate_func *isolate;
> +	kmem_cache_migrate_func *migrate;
> +
>  	unsigned int inuse;		/* Offset to metadata */
>  	unsigned int align;		/* Alignment */
>  	unsigned int red_left_pad;	/* Left redzone padding size */
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index f9d89c1b5977..754acdb292e4 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
>  	if (!is_root_cache(s))
>  		return 1;
> =20
> +	/*
> +	 * s->isolate and s->migrate imply s->ctor so no need to
> +	 * check them explicitly.
> +	 */
>  	if (s->ctor)
>  		return 1;
> =20
> diff --git a/mm/slub.c b/mm/slub.c
> index 69164aa7cbbf..0133168d1089 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4325,6 +4325,34 @@ int __kmem_cache_create(struct kmem_cache *s, slab=
_flags_t flags)
>  	return err;
>  }
> =20
> +void kmem_cache_setup_mobility(struct kmem_cache *s,
> +			       kmem_cache_isolate_func isolate,
> +			       kmem_cache_migrate_func migrate)
> +{

I wonder if it's better to adapt kmem_cache_create() to take two additional
argument? I suspect mobility is not a dynamic option, so it can be
set on kmem_cache creation.

> +	/*
> +	 * Mobile objects must have a ctor otherwise the object may be
> +	 * in an undefined state on allocation.  Since the object may
> +	 * need to be inspected by the migration function at any time
> +	 * after allocation we must ensure that the object always has a
> +	 * defined state.
> +	 */
> +	if (!s->ctor) {
> +		pr_err("%s: cannot setup mobility without a constructor\n",
> +		       s->name);
> +		return;
> +	}
> +
> +	s->isolate =3D isolate;
> +	s->migrate =3D migrate;
> +
> +	/*
> +	 * Sadly serialization requirements currently mean that we have
> +	 * to disable fast cmpxchg based processing.
> +	 */

Can you, please, elaborate a bit more here?

> +	s->flags &=3D ~__CMPXCHG_DOUBLE;
> +}
> +EXPORT_SYMBOL(kmem_cache_setup_mobility);
> +
>  void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long =
caller)
>  {
>  	struct kmem_cache *s;
> @@ -5018,6 +5046,20 @@ static ssize_t ops_show(struct kmem_cache *s, char=
 *buf)
> =20
>  	if (s->ctor)
>  		x +=3D sprintf(buf + x, "ctor : %pS\n", s->ctor);
> +
> +	if (s->isolate) {
> +		x +=3D sprintf(buf + x, "isolate : ");
> +		x +=3D sprint_symbol(buf + x,
> +				(unsigned long)s->isolate);
> +		x +=3D sprintf(buf + x, "\n");
> +	}

Is there a reason why s->ctor and s->isolate/migrate are printed
using different methods?

> +
> +	if (s->migrate) {
> +		x +=3D sprintf(buf + x, "migrate : ");
> +		x +=3D sprint_symbol(buf + x,
> +				(unsigned long)s->migrate);
> +		x +=3D sprintf(buf + x, "\n");
> +	}
>  	return x;
>  }
>  SLAB_ATTR_RO(ops);
> --=20
> 2.21.0
>=20

Thanks!

