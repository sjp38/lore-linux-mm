Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24D59C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:36:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC6902087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:36:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VldQpBRH";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="NnWXIl30"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC6902087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 295088E0003; Mon, 11 Mar 2019 19:36:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 245398E0002; Mon, 11 Mar 2019 19:36:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BEAF8E0003; Mon, 11 Mar 2019 19:36:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9B858E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:36:02 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w11so424227iom.20
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:36:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=2O7ABWPLQXM625HMSFShD+0Mrpv8Y7GSk57ItTesBAE=;
        b=mszrOw3qxx5auzBHA9oHmpV494GFkmjcLJjjPSr7QNkl+s9x3ikT7Fm+MfZlY/xjms
         AVijifjFEZx+7sMrByD/7UPEOnHZgnNHgg/nt6XtccQ4ia3Riptey8E0jPqrO9FfeoLf
         tFfPyytb8zVdgKWARgyRZ1FsoR9cw3xp3ZiaJCINTBaSphLolF09vcQmEqiI5u9FX7eC
         UJl+mEMQVElP9DtI9FZEud6ybDUY7CDRKtX2gs1dSkWnlp5mH85fb7+nGOZ+jkXH8q1I
         9U1fl5PVhDgr6M6yTim79C1JAr8eI3BywsFZX1QN6jas8hQr4WELd52hgdoSlCCGtOj8
         /meA==
X-Gm-Message-State: APjAAAWkL0kyOZh/76wzKp08gRHtX2W43+nhfKuQSPk/WVF7ocCldM/8
	xUgVYcCNGh20HykQxlCS7aAGYj6ceOlIjtdSK4EH1oGovjuBQZ7zX67OEuq781t1CB9iuP/P4Ak
	lpzsK27MAo6zwtej36mS19Askd8CxS8Lg10xonjJRJjfxYtL6fhTipyBAtJpK6u95Hw==
X-Received: by 2002:a02:c893:: with SMTP id m19mr4611512jao.28.1552347362631;
        Mon, 11 Mar 2019 16:36:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwokspCVN2zCZNDgvcGMWZjkc3WGDXoKnQTDFjBMQ7k9dGYMN/jekL85ycN3+MbImweI8Uh
X-Received: by 2002:a02:c893:: with SMTP id m19mr4611474jao.28.1552347361524;
        Mon, 11 Mar 2019 16:36:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552347361; cv=none;
        d=google.com; s=arc-20160816;
        b=H4TsajSPxW1bbHl/G6SFYVYwpdYDhVq6PA7oOuYbt3xe+aElbUJsXojXRpUBtV9v6K
         CGHkS/IcRAD/PyJ0RSrxHzVoDfD+2wMcLKgIawHgqMUMgVcngjbVS0gnGctpQY1oJytR
         9xjBCeAI+LMOZUDRaxOcqwuI6lmqWdx9CmvXICEGSzFvazX7MSTLyNufKMSajge8477e
         PPw5FTH/jdBJZB1Mj3+nHzEhiC6GfRzdL9uSEi7BdliRGF+GtVK+8yZFNOT7aDC7A3CJ
         VSNoTpssiWyUgx5SzH5oI8x729e7UrKmExJ5o+dZj12hYJEeLpvSu1Q39e+7pLwvMhrp
         hkQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=2O7ABWPLQXM625HMSFShD+0Mrpv8Y7GSk57ItTesBAE=;
        b=jorLDNI74FeKqWqBB/lzrOHKAXYMbKbFAMfl2vaQWfwbBSOAPGFaZk4QtZMynX6tnn
         PF+1jyH+CVtQNm8ILXN7wrB0HIR5Q3yhH5mNho1ztPtK7rAPY0ZVeCrcBO+Vq4XvNLtz
         vg90bOObU5PLss3trBM1qDASrAw6k2ZKHGhHA4nCNMBIvsgHU64If/K4DSeiC/4qfoHu
         0OCu+cJ32B44FiFFUfNwy0DRr8sg30RU7wjzTmis3jwixc4TKUjLX2ppjhz2fWmecQ+M
         qHtKfoeeI5Mhrig8p7jt00S4RsTomjOboDxhg+kxuRD0bdTLWIPFT5sjULCvcq3QHhiW
         W77w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VldQpBRH;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=NnWXIl30;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c17si3196302ioo.158.2019.03.11.16.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 16:36:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VldQpBRH;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=NnWXIl30;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BNZCvk031815;
	Mon, 11 Mar 2019 16:35:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=2O7ABWPLQXM625HMSFShD+0Mrpv8Y7GSk57ItTesBAE=;
 b=VldQpBRHu4qFZU7vybY9A0/4RqfU3zq++0uep49xQhUaZjVyFpPUjLn6swszI+/uUuBN
 wwAN91wrH01vou7sB3pxO3v4UZwDC947zwjKfuA8gGRJThPJkAZHzPvJIQ+8EpF6RXSq
 AeJndVLdQsyc8RI2MaXJ+XvnIg+8c+oVJmo= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r5xupggjr-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 11 Mar 2019 16:35:49 -0700
Received: from frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) by
 frc-hub01.TheFacebook.com (2620:10d:c021:18::171) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 16:35:32 -0700
Received: from frc-hub02.TheFacebook.com (2620:10d:c021:18::172) by
 frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 16:35:32 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.72) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 11 Mar 2019 16:35:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2O7ABWPLQXM625HMSFShD+0Mrpv8Y7GSk57ItTesBAE=;
 b=NnWXIl30lkUuxZtpX2jfRu4Y307seFrcQzqvwU4olB0uL+5OPU43OZync/kKkd1cyVr5Y7b+UvMNBpwkudLe0x3rY3CkehtYygTlhWj+SERS8yHBePOYlWpwTYLBnRjTHsze40Ir8nc/rd6B26OYBsC20YDsd32GrWHVl7nKdnU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3254.namprd15.prod.outlook.com (20.179.57.89) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.18; Mon, 11 Mar 2019 23:35:30 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Mon, 11 Mar 2019
 23:35:30 +0000
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
Subject: Re: [RFC 09/15] slub: Enable slab defragmentation using SMO
Thread-Topic: [RFC 09/15] slub: Enable slab defragmentation using SMO
Thread-Index: AQHU1WWfhBcxVXGpmEaLa5G6zVmHuqYHG2kA
Date: Mon, 11 Mar 2019 23:35:29 +0000
Message-ID: <20190311233523.GA20098@tower.DHCP.thefacebook.com>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-10-tobin@kernel.org>
In-Reply-To: <20190308041426.16654-10-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1601CA0009.namprd16.prod.outlook.com
 (2603:10b6:300:da::19) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:b487]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 531eaddf-bf91-41a6-54be-08d6a67a3f32
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3254;
x-ms-traffictypediagnostic: BYAPR15MB3254:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3254;20:aY8HdMnN3J5kY2YAfpeuI4kfaDxqQdmmdoXh1yuCFF0Y99zt0wGQCoF9bpZpol6IPTWAKd7pFjHzzajcKUdVnBvW5wOa6Dg+r3cQ96IZd5VlNZ1/recvhaBt4AwcJlK3HXy/aAZh6ZcJvALdplJLTI42Y1oRELVDQztj7k3eT0w=
x-microsoft-antispam-prvs: <BYAPR15MB3254798BC052C0C71A2A262FBE480@BYAPR15MB3254.namprd15.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(366004)(376002)(136003)(39860400002)(199004)(189003)(46003)(53936002)(9686003)(6512007)(99286004)(71200400001)(71190400001)(52116002)(256004)(6486002)(97736004)(76176011)(30864003)(1076003)(106356001)(2906002)(14444005)(6436002)(102836004)(105586002)(386003)(6506007)(486006)(446003)(11346002)(476003)(186003)(8676002)(4326008)(6246003)(229853002)(478600001)(81156014)(6116002)(33656002)(5660300002)(316002)(81166006)(305945005)(86362001)(7736002)(14454004)(68736007)(54906003)(8936002)(25786009)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3254;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: P1RAMhvAqEFixv5XfjV8fF7Ofjo3MERy458ivCz72zjsy1+9SKI/yv/6/VULvr993vReX25LvYQHU+jNGZ7Y3oG2C+9gwA5ymQ9DEfbhTNdP4jQC4ErDi1FBBtxYIqw5P8QnjrNxJGeYjshOG29i7Jyye3meP6C3TXiXZkEBdJp5aDevT8GJiFS2GuBk2EHmSClDItuA+sbwzPQGYsujD44q/MnXv0GluCAOyF+uN7re4YZuXlTc/z1EtyxV2lopjqba+LAt+njUGnfFBsEYw0j7YfxJ9A4ua8hOoM7mDKSCDFnlczFBDyj5u4+QWW1EKZh576HCqAIt2NBbG8trP0ikopycuPqsa0qv/8knvPZ2kj0gchtwjoTj8rnLDYyCkhzaCeSscYOKmNqm0utRkliMJt2ybvuHwhrG+s6b4Ls=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <71234231DCFE6B4693BBDB8ED250BB94@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 531eaddf-bf91-41a6-54be-08d6a67a3f32
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 23:35:29.9030
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3254
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-11_17:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:14:20PM +1100, Tobin C. Harding wrote:
> If many objects are allocated with the slab allocator and freed in an
> arbitrary order then the slab caches can become internally fragmented.
> Now that the slab allocator supports movable objects we can defragment
> any cache that has this feature enabled.
>=20
> Slab defragmentation may occur:
>=20
> 1. Unconditionally when __kmem_cache_shrink() is called on a slab cache
>    by the kernel calling kmem_cache_shrink().
>=20
> 2. Unconditionally through the use of the slabinfo command.
>=20
> 	slabinfo <cache> -s
>=20
> 3. Conditionally via the use of kmem_cache_defrag()
>=20
> Use SMO when shrinking cache.  Currently when the kernel calls
> kmem_cache_shrink() we curate the partial slabs list.  If object
> migration is not enabled for the cache we still do this, if however SMO
> is enabled, we attempt to move objects in partially full slabs in order
> to defragment the cache.  Shrink attempts to move all objects in order
> to reduce the cache to a single partial slab for each node.
>=20
> kmem_cache_defrag() differs from shrink in that it operates dependent on
> the defrag_used_ratio and only attempts to move objects if the number of
> partial slabs exceeds MAX_PARTIAL (for each node).
>=20
> Add function kmem_cache_defrag(int node).
>=20
>    kmem_cache_defrag() only performs defragmentation if the usage ratio
>    of the slab is lower than the configured percentage (sysfs file added
>    in previous patch).  Fragmentation ratios are measured by calculating
>    the percentage of objects in use compared to the total number of
>    objects that the slab page can accommodate.
>=20
>    The scanning of slab caches is optimized because the defragmentable
>    slabs come first on the list. Thus we can terminate scans on the
>    first slab encountered that does not support defragmentation.
>=20
>    kmem_cache_defrag() takes a node parameter. This can either be -1 if
>    defragmentation should be performed on all nodes, or a node number.
>=20
>    Defragmentation may be disabled by setting defrag ratio to 0
>=20
> 	echo 0 > /sys/kernel/slab/<cache>/defrag_used_ratio
>=20
> In order for a cache to be defragmentable the cache must support object
> migration (SMO).  Enabling SMO for a cache is done via a call to the
> recently added function:
>=20
> 	void kmem_cache_setup_mobility(struct kmem_cache *,
> 				       kmem_cache_isolate_func,
> 			               kmem_cache_migrate_func);
>=20
> Co-developed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  include/linux/slab.h |   1 +
>  mm/slub.c            | 266 +++++++++++++++++++++++++++++++------------
>  2 files changed, 194 insertions(+), 73 deletions(-)
>=20
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 22e87c41b8a4..b9b46bc9937e 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -147,6 +147,7 @@ struct kmem_cache *kmem_cache_create_usercopy(const c=
har *name,
>  			void (*ctor)(void *));
>  void kmem_cache_destroy(struct kmem_cache *);
>  int kmem_cache_shrink(struct kmem_cache *);
> +int kmem_cache_defrag(int node);
> =20
>  void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
>  void memcg_deactivate_kmem_caches(struct mem_cgroup *);
> diff --git a/mm/slub.c b/mm/slub.c
> index 515db0f36c55..53dd4cb5b5a4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -354,6 +354,12 @@ static __always_inline void slab_lock(struct page *p=
age)
>  	bit_spin_lock(PG_locked, &page->flags);
>  }
> =20
> +static __always_inline int slab_trylock(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(PageTail(page), page);
> +	return bit_spin_trylock(PG_locked, &page->flags);
> +}
> +
>  static __always_inline void slab_unlock(struct page *page)
>  {
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> @@ -3959,79 +3965,6 @@ void kfree(const void *x)
>  }
>  EXPORT_SYMBOL(kfree);
> =20
> -#define SHRINK_PROMOTE_MAX 32
> -
> -/*
> - * kmem_cache_shrink discards empty slabs and promotes the slabs filled
> - * up most to the head of the partial lists. New allocations will then
> - * fill those up and thus they can be removed from the partial lists.
> - *
> - * The slabs with the least items are placed last. This results in them
> - * being allocated from last increasing the chance that the last objects
> - * are freed in them.
> - */
> -int __kmem_cache_shrink(struct kmem_cache *s)
> -{
> -	int node;
> -	int i;
> -	struct kmem_cache_node *n;
> -	struct page *page;
> -	struct page *t;
> -	struct list_head discard;
> -	struct list_head promote[SHRINK_PROMOTE_MAX];
> -	unsigned long flags;
> -	int ret =3D 0;
> -
> -	flush_all(s);
> -	for_each_kmem_cache_node(s, node, n) {
> -		INIT_LIST_HEAD(&discard);
> -		for (i =3D 0; i < SHRINK_PROMOTE_MAX; i++)
> -			INIT_LIST_HEAD(promote + i);
> -
> -		spin_lock_irqsave(&n->list_lock, flags);
> -
> -		/*
> -		 * Build lists of slabs to discard or promote.
> -		 *
> -		 * Note that concurrent frees may occur while we hold the
> -		 * list_lock. page->inuse here is the upper limit.
> -		 */
> -		list_for_each_entry_safe(page, t, &n->partial, lru) {
> -			int free =3D page->objects - page->inuse;
> -
> -			/* Do not reread page->inuse */
> -			barrier();
> -
> -			/* We do not keep full slabs on the list */
> -			BUG_ON(free <=3D 0);
> -
> -			if (free =3D=3D page->objects) {
> -				list_move(&page->lru, &discard);
> -				n->nr_partial--;
> -			} else if (free <=3D SHRINK_PROMOTE_MAX)
> -				list_move(&page->lru, promote + free - 1);
> -		}
> -
> -		/*
> -		 * Promote the slabs filled up most to the head of the
> -		 * partial list.
> -		 */
> -		for (i =3D SHRINK_PROMOTE_MAX - 1; i >=3D 0; i--)
> -			list_splice(promote + i, &n->partial);
> -
> -		spin_unlock_irqrestore(&n->list_lock, flags);
> -
> -		/* Release empty slabs */
> -		list_for_each_entry_safe(page, t, &discard, lru)
> -			discard_slab(s, page);
> -
> -		if (slabs_node(s, node))
> -			ret =3D 1;
> -	}
> -
> -	return ret;
> -}
> -
>  #ifdef CONFIG_MEMCG
>  static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
>  {
> @@ -4411,6 +4344,193 @@ static void __move(struct page *page, void *scrat=
ch, int node)
>  	s->migrate(s, vector, count, node, private);
>  }
> =20
> +/*
> + * __defrag() - Defragment node.
> + * @s: cache we are working on.
> + * @node: The node to move objects from.
> + * @target_node: The node to move objects to.
> + * @ratio: The defrag ratio (percentage, between 0 and 100).
> + *
> + * Release slabs with zero objects and try to call the migration functio=
n
> + * for slabs with less than the 'ratio' percentage of objects allocated.
> + *
> + * Moved objects are allocated on @target_node.
> + *
> + * Return: The number of partial slabs left on the node after the operat=
ion.
> + */
> +static unsigned long __defrag(struct kmem_cache *s, int node, int target=
_node,
> +			      int ratio)

Maybe kmem_cache_defrag_node()?

> +{
> +	struct kmem_cache_node *n =3D get_node(s, node);
> +	struct page *page, *page2;
> +	LIST_HEAD(move_list);
> +	unsigned long flags;
> +
> +	if (node =3D=3D target_node && n->nr_partial <=3D 1) {
> +		/*
> +		 * Trying to reduce fragmentation on a node but there is
> +		 * only a single or no partial slab page. This is already
> +		 * the optimal object density that we can reach.
> +		 */
> +		return n->nr_partial;
> +	}
> +
> +	spin_lock_irqsave(&n->list_lock, flags);
> +	list_for_each_entry_safe(page, page2, &n->partial, lru) {
> +		if (!slab_trylock(page))
> +			/* Busy slab. Get out of the way */
> +			continue;
> +
> +		if (page->inuse) {
> +			if (page->inuse > ratio * page->objects / 100) {
> +				slab_unlock(page);
> +				/*
> +				 * Skip slab because the object density
> +				 * in the slab page is high enough.
> +				 */
> +				continue;
> +			}
> +
> +			list_move(&page->lru, &move_list);
> +			if (s->migrate) {
> +				/* Stop page being considered for allocations */
> +				n->nr_partial--;
> +				page->frozen =3D 1;
> +			}
> +			slab_unlock(page);
> +		} else {	/* Empty slab page */
> +			list_del(&page->lru);
> +			n->nr_partial--;
> +			slab_unlock(page);
> +			discard_slab(s, page);
> +		}
> +	}
> +
> +	if (!s->migrate) {
> +		/*
> +		 * No defrag method. By simply putting the zaplist at the
> +		 * end of the partial list we can let them simmer longer
> +		 * and thus increase the chance of all objects being
> +		 * reclaimed.
> +		 *
> +		 */
> +		list_splice(&move_list, n->partial.prev);
> +	}
> +
> +	spin_unlock_irqrestore(&n->list_lock, flags);
> +
> +	if (s->migrate && !list_empty(&move_list)) {
> +		void **scratch =3D alloc_scratch(s);
> +		struct page *page, *page2;
> +
> +		if (scratch) {
> +			/* Try to remove / move the objects left */
> +			list_for_each_entry(page, &move_list, lru) {
> +				if (page->inuse)
> +					__move(page, scratch, target_node);
> +			}
> +			kfree(scratch);
> +		}
> +
> +		/* Inspect results and dispose of pages */
> +		spin_lock_irqsave(&n->list_lock, flags);
> +		list_for_each_entry_safe(page, page2, &move_list, lru) {
> +			list_del(&page->lru);
> +			slab_lock(page);
> +			page->frozen =3D 0;
> +
> +			if (page->inuse) {
> +				/*
> +				 * Objects left in slab page, move it to the
> +				 * tail of the partial list to increase the
> +				 * chance that the freeing of the remaining
> +				 * objects will free the slab page.
> +				 */
> +				n->nr_partial++;
> +				list_add_tail(&page->lru, &n->partial);
> +				slab_unlock(page);
> +			} else {
> +				slab_unlock(page);
> +				discard_slab(s, page);
> +			}
> +		}
> +		spin_unlock_irqrestore(&n->list_lock, flags);
> +	}
> +
> +	return n->nr_partial;
> +}
> +
> +/**
> + * kmem_cache_defrag() - Defrag slab caches.
> + * @node: The node to defrag or -1 for all nodes.
> + *
> + * Defrag slabs conditional on the amount of fragmentation in a page.
> + */
> +int kmem_cache_defrag(int node)
> +{
> +	struct kmem_cache *s;
> +	unsigned long left =3D 0;
> +
> +	/*
> +	 * kmem_cache_defrag may be called from the reclaim path which may be
> +	 * called for any page allocator alloc. So there is the danger that we
> +	 * get called in a situation where slub already acquired the slub_lock
> +	 * for other purposes.
> +	 */
> +	if (!mutex_trylock(&slab_mutex))
> +		return 0;
> +
> +	list_for_each_entry(s, &slab_caches, list) {
> +		/*
> +		 * Defragmentable caches come first. If the slab cache is not
> +		 * defragmentable then we can stop traversing the list.
> +		 */
> +		if (!s->migrate)
> +			break;
> +
> +		if (node =3D=3D -1) {
> +			int nid;
> +
> +			for_each_node_state(nid, N_NORMAL_MEMORY)
> +				if (s->node[nid]->nr_partial > MAX_PARTIAL)
> +					left +=3D __defrag(s, nid, nid, s->defrag_used_ratio);
> +		} else {
> +			if (s->node[node]->nr_partial > MAX_PARTIAL)
> +				left +=3D __defrag(s, node, node, s->defrag_used_ratio);
> +		}
> +	}
> +	mutex_unlock(&slab_mutex);
> +	return left;
> +}
> +EXPORT_SYMBOL(kmem_cache_defrag);
> +
> +/**
> + * __kmem_cache_shrink() - Shrink a cache.
> + * @s: The cache to shrink.
> + *
> + * Reduces the memory footprint of a slab cache by as much as possible.
> + *
> + * This works by:
> + *  1. Removing empty slabs from the partial list.
> + *  2. Migrating slab objects to denser slab pages if the slab cache
> + *  supports migration.  If not, reorganizing the partial list so that
> + *  more densely allocated slab pages come first.
> + *
> + * Not called directly, called by kmem_cache_shrink().
> + */
> +int __kmem_cache_shrink(struct kmem_cache *s)
> +{
> +	int node;
> +	int left =3D 0;

s/int/unsigned long? Or s/unsigned long/int in __defrag()?

Thanks!

