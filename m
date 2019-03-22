Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 783D7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:55:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CE29218D4
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:55:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="IwGMciNH";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="CrFCLmgz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CE29218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0E656B0005; Fri, 22 Mar 2019 17:55:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 997B66B0006; Fri, 22 Mar 2019 17:55:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C2D36B0007; Fri, 22 Mar 2019 17:55:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC826B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:55:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 75so3189903qki.13
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:55:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=w9RjF/mP+EaoGdtaz1B1//9NNkDo3Y0ftF/0V2S861w=;
        b=cmxb8C8pZZagVny3XkphEQAAPZRX/KUqbl6JmpjMfvAXr8EYptQZr1FtAWd2JlKDxI
         jHNa+HqRQjgldW3K3xR6WBOk1KWce44MrcALRM/iJZfwLrnjGWNdsFlTsb20ERgO+Z6H
         QkxT2yAS0LYuF2YbRFuF2fZdeDQyTRJ1yn8uKRtoGWodrLubWdEVGEPcimjyYwYQF6nC
         C5Ie5qMzlaVmZTnqmmYhsUFYBhS4gLaf5hVTeaqxIyIVOJJjB774AXBsJsjAYKBHqnqA
         KTYJZ3+BuCa6GhtsFj59s6u9qdKY3YenZmW6cnWOSfR9vY/qi8/eGFXSr1xBeNNM4FaH
         g3pA==
X-Gm-Message-State: APjAAAXkN1+1JSpsu79Hx3ztEhJgWww+bXYIXBTQruw79naun5Iz4lBK
	BcJSW96fpAFu0PStO0qnBQPbxLctNlEoyufKGD9wPN0/ywR4BykN5GrWHSxjbrIM1Kh9rRAWWCg
	1i6BZs6bCvtxM4xKpamTOdObrnpzRgvk/4MbvOQ0mw1G92QDu48S4j5zJAWuENVTXSg==
X-Received: by 2002:ac8:3390:: with SMTP id c16mr10274225qtb.172.1553291706974;
        Fri, 22 Mar 2019 14:55:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQ1lmRdk3COdIhbn1VGs4lnfLEcQERK08QglKJUZKjeK/AROC3ML8QUm2bUGxW70mnBksD
X-Received: by 2002:ac8:3390:: with SMTP id c16mr10274147qtb.172.1553291705303;
        Fri, 22 Mar 2019 14:55:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553291705; cv=none;
        d=google.com; s=arc-20160816;
        b=aGwzxkDdL4sq6rnRUKUn/8JCyWVzex/96s/FYneRoyuslk5O0/4goQBlhcH9SduGXX
         llwQMC2eqFcNqIFRxxe1GUfo0xKb3o168wdMOQUfHAKy4E3U0MF0w8rB8g2cv4v4egqK
         zDevADynhou/zGbYw4X0f+bpFGCjEC4eT4MqdyutI+m80PYiC6ojPa6RqEIHW7eVEsVE
         0gOUN3VQsp39iyuhtVQbCVxTu1JxDAP5bRbGofUcSZ6Ijv+toX2XuFvJYRJjwfaNzYkA
         Eq4TywWECI2XIecxYWGCwvXjSS0X1mYIpssPI8L+hXcxCwJH7HGspSEUC30rEAng7nUh
         keAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=w9RjF/mP+EaoGdtaz1B1//9NNkDo3Y0ftF/0V2S861w=;
        b=ELQ7R+IDXmetPC97oTLuH5c9PO0NKADgMviDcpempTdNmg+pmnwNdi2c1HJ8R1EbY/
         aMZFp2YQLH4Kh/l5AutNt3ztwqogfDTgrQdTqv3klRfni9dU7IX7yvW2eJ2J+QTYnFl3
         bD0c8aEZqIWRJjs2UHdavSNujTgbkkG3m2DF7QhDADfqWvgSRns/zsnItAD/XonHaIah
         HAqUtYuNnDB8kNNPQGUH93UyKwzWePby70FCDmgmgQLIKYyIhl59IE0taU9pqE6vtFKh
         oDBa1D1Pr+jJTLgmhvXMUzY3Kk9T93vGvN6vtj1PZX0ondXFTuzROibnUdfJ13vA5dAx
         bsxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IwGMciNH;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=CrFCLmgz;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f18si1375063qth.160.2019.03.22.14.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 14:55:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IwGMciNH;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=CrFCLmgz;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x2MLs81b004574;
	Fri, 22 Mar 2019 14:54:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=w9RjF/mP+EaoGdtaz1B1//9NNkDo3Y0ftF/0V2S861w=;
 b=IwGMciNHFR4ePgAeDBw2ur+grrhSpD8gF5pmcOLfrYuOD8qNwJJamU9fwMnsixAhOI0q
 Bnia7AGjwiWkJ4CleQS+GIW4NNeU04ZvGxPhudvZKpAuy0CX7iFAr7BrEaY/40gq1jlG
 r+yjVJqlLgT9x0CcLl1ZUbv+U9Xy/bX1UY0= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by m0089730.ppops.net with ESMTP id 2rd6kj8a99-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 22 Mar 2019 14:54:21 -0700
Received: from frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 14:54:21 -0700
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 14:54:20 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 22 Mar 2019 14:54:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=w9RjF/mP+EaoGdtaz1B1//9NNkDo3Y0ftF/0V2S861w=;
 b=CrFCLmgz+/mbXEIa98cn0nVM5W5vFWUrICO49mtocpWKwAj3RmSh7Axid52KVpKXsSEEUy8fxfieSyPH3/yE1+z4z6Ym4o9M3M2DHJT4AxPUYEUtkWP9F4XjFleQmPfhBlpa5iUx8kcjJJuvU9BcM+AWsPlGuO1da7G6LMxQ6e4=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2312.namprd15.prod.outlook.com (52.135.197.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Fri, 22 Mar 2019 21:54:18 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1709.017; Fri, 22 Mar 2019
 21:54:17 +0000
From: Roman Gushchin <guro@fb.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Thomas Garnier
	<thgarnie@google.com>,
        Oleksiy Avramchenko
	<oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Topic: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Index: AQHU4BjXJdywTTE8CEqJ5FdlsRP4taYYM2GA
Date: Fri, 22 Mar 2019 21:54:17 +0000
Message-ID: <20190322215413.GA15943@tower.DHCP.thefacebook.com>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321190327.11813-2-urezki@gmail.com>
In-Reply-To: <20190321190327.11813-2-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR2101CA0018.namprd21.prod.outlook.com
 (2603:10b6:302:1::31) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:d234]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a4788265-0456-4b22-a02f-08d6af10ee7b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2312;
x-ms-traffictypediagnostic: BYAPR15MB2312:
x-microsoft-antispam-prvs: <BYAPR15MB2312A722F0EA0E040B4C24D7BE430@BYAPR15MB2312.namprd15.prod.outlook.com>
x-forefront-prvs: 09840A4839
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(39860400002)(346002)(366004)(376002)(189003)(199004)(9686003)(229853002)(4326008)(14454004)(11346002)(6246003)(6486002)(446003)(6436002)(1076003)(76176011)(6512007)(53946003)(6116002)(305945005)(52116002)(46003)(25786009)(71190400001)(7736002)(71200400001)(106356001)(102836004)(105586002)(33656002)(8676002)(81166006)(81156014)(1411001)(476003)(53936002)(6506007)(386003)(97736004)(86362001)(2906002)(7416002)(486006)(478600001)(5660300002)(99286004)(14444005)(6916009)(54906003)(8936002)(256004)(30864003)(68736007)(186003)(316002)(579004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2312;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: vB9QZTyPL1M9MbP2V0N6KMLeGAgElOEOkxxY5416LtWclDdJrrX6Dl78L4+EKWVTkbdV49WR32zOkRyTw9jKS5XPjvSntvTqvJ18qQyv9wjV2iB91/70fOYwZtbtcYGjXsP/U0/5M2DGleX+1wjimhJMwaFWZWsGWNOTk4MxoLr6U1vbd3TcCwn1NeSQQW2cUM6Ia68sAjP2COxZYpTznjHiBvaFyOmEpHs0V3K/AgzMdBKgvL/ZlFrNJNlYShVoErIla0Iio1cANi0qFlf7pW81+NEolM/sw1rW0/JI7THAWl62c1AuHdShCdektZMf7HEE+3DFJiOrDXX7NnkfGi02P/4Cv24GlwV7ZzLQS07owRhxRxMW9yjSXkurgtqsrZAgFl9vuuoQs53k5wtPnEx+IcJ5viQX79mjglWMxhE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B5C2ACEE93BCAD49A22741D43CDB744F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a4788265-0456-4b22-a02f-08d6af10ee7b
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Mar 2019 21:54:17.8333
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2312
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 08:03:27PM +0100, Uladzislau Rezki (Sony) wrote:
> Currently an allocation of the new vmap area is done over busy
> list iteration(complexity O(n)) until a suitable hole is found
> between two busy areas. Therefore each new allocation causes
> the list being grown. Due to over fragmented list and different
> permissive parameters an allocation can take a long time. For
> example on embedded devices it is milliseconds.
>=20
> This patch organizes the KVA memory layout into free areas of the
> 1-ULONG_MAX range. It uses an augment red-black tree that keeps
> blocks sorted by their offsets in pair with linked list keeping
> the free space in order of increasing addresses.
>=20
> Each vmap_area object contains the "subtree_max_size" that reflects
> a maximum available free block in its left or right sub-tree. Thus,
> that allows to take a decision and traversal toward the block that
> will fit and will have the lowest start address, i.e. sequential
> allocation.
>=20
> Allocation: to allocate a new block a search is done over the
> tree until a suitable lowest(left most) block is large enough
> to encompass: the requested size, alignment and vstart point.
> If the block is bigger than requested size - it is split.
>=20
> De-allocation: when a busy vmap area is freed it can either be
> merged or inserted to the tree. Red-black tree allows efficiently
> find a spot whereas a linked list provides a constant-time access
> to previous and next blocks to check if merging can be done. In case
> of merging of de-allocated memory chunk a large coalesced area is
> created.
>=20
> Complexity: ~O(log(N))

Hi, Uladzislau!

Definitely a clever idea and very promising numbers!

The overall approach makes total sense to me.

I tried to go through the code, but it was a bit challenging.
I wonder, if you can split it into smaller parts to simplify the review?

Idk how easy is to split the core (maybe the area merging code can be
separated?), but at least the optionally compiled debug code can
be moved into separate patches.

Some small nits/questions below.

>=20
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  include/linux/vmalloc.h |    6 +-
>  mm/vmalloc.c            | 1109 ++++++++++++++++++++++++++++++++++++-----=
------
>  2 files changed, 871 insertions(+), 244 deletions(-)
>=20
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 398e9c95cd61..ad483378fdd1 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -45,12 +45,16 @@ struct vm_struct {
>  struct vmap_area {
>  	unsigned long va_start;
>  	unsigned long va_end;
> +
> +	/*
> +	 * Largest available free size in subtree.
> +	 */
> +	unsigned long subtree_max_size;
>  	unsigned long flags;
>  	struct rb_node rb_node;         /* address sorted rbtree */
>  	struct list_head list;          /* address sorted list */
>  	struct llist_node purge_list;    /* "lazy purge" list */
>  	struct vm_struct *vm;
> -	struct rcu_head rcu_head;
>  };
> =20
>  /*
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 755b02983d8d..29e9786299cf 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -31,6 +31,7 @@
>  #include <linux/compiler.h>
>  #include <linux/llist.h>
>  #include <linux/bitops.h>
> +#include <linux/rbtree_augmented.h>
> =20
>  #include <linux/uaccess.h>
>  #include <asm/tlbflush.h>
> @@ -320,8 +321,9 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr=
)
>  }
>  EXPORT_SYMBOL(vmalloc_to_pfn);
> =20
> -
>  /*** Global kva allocator ***/
> +#define DEBUG_AUGMENT_PROPAGATE_CHECK 0
> +#define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
> =20
>  #define VM_LAZY_FREE	0x02
>  #define VM_VM_AREA	0x04
> @@ -331,14 +333,76 @@ static DEFINE_SPINLOCK(vmap_area_lock);
>  LIST_HEAD(vmap_area_list);
>  static LLIST_HEAD(vmap_purge_list);
>  static struct rb_root vmap_area_root =3D RB_ROOT;
> +static bool vmap_initialized __read_mostly;
> +
> +/*
> + * This kmem_cache is used for vmap_area objects. Instead of
> + * allocating from slab we reuse an object from this cache to
> + * make things faster. Especially in "no edge" splitting of
> + * free block.
> + */
> +static struct kmem_cache *vmap_area_cachep;
> +
> +/*
> + * This linked list is used in pair with free_vmap_area_root.
> + * It gives O(1) access to prev/next to perform fast coalescing.
> + */
> +static LIST_HEAD(free_vmap_area_list);
> +
> +/*
> + * This augment red-black tree represents the free vmap space.
> + * All vmap_area objects in this tree are sorted by va->va_start
> + * address. It is used for allocation and merging when a vmap
> + * object is released.
> + *
> + * Each vmap_area node contains a maximum available free block
> + * of its sub-tree, right or left. Therefore it is possible to
> + * find a lowest match of free area.
> + */
> +static struct rb_root free_vmap_area_root =3D RB_ROOT;
> +
> +static inline unsigned long
> +__va_size(struct vmap_area *va)
> +{
> +	return (va->va_end - va->va_start);
> +}
> +
> +static unsigned long
> +get_subtree_max_size(struct rb_node *node)
> +{
> +	struct vmap_area *va;
> +
> +	va =3D rb_entry_safe(node, struct vmap_area, rb_node);
> +	return va ? va->subtree_max_size : 0;
> +}
> +
> +/*
> + * Gets called when remove the node and rotate.
> + */
> +static unsigned long
> +compute_subtree_max_size(struct vmap_area *va)
> +{
> +	unsigned long max_size =3D __va_size(va);
> +	unsigned long child_max_size;
> +
> +	child_max_size =3D get_subtree_max_size(va->rb_node.rb_right);
> +	if (child_max_size > max_size)
> +		max_size =3D child_max_size;
> =20
> -/* The vmap cache globals are protected by vmap_area_lock */
> -static struct rb_node *free_vmap_cache;
> -static unsigned long cached_hole_size;
> -static unsigned long cached_vstart;
> -static unsigned long cached_align;
> +	child_max_size =3D get_subtree_max_size(va->rb_node.rb_left);
> +	if (child_max_size > max_size)
> +		max_size =3D child_max_size;
> =20
> -static unsigned long vmap_area_pcpu_hole;
> +	return max_size;
> +}
> +
> +RB_DECLARE_CALLBACKS(static, free_vmap_area_rb_augment_cb,
> +	struct vmap_area, rb_node, unsigned long, subtree_max_size,
> +	compute_subtree_max_size)
> +
> +static void purge_vmap_area_lazy(void);
> +static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> +static unsigned long lazy_max_pages(void);
> =20
>  static struct vmap_area *__find_vmap_area(unsigned long addr)
>  {
> @@ -359,41 +423,623 @@ static struct vmap_area *__find_vmap_area(unsigned=
 long addr)
>  	return NULL;
>  }
> =20
> -static void __insert_vmap_area(struct vmap_area *va)
> +/*
> + * This function returns back addresses of parent node
> + * and its left or right link for further processing.
> + */
> +static inline void
> +__find_va_links(struct vmap_area *va,
> +	struct rb_root *root, struct rb_node *from,
> +	struct rb_node **parent, struct rb_node ***link)

This function returns a pointer to parent, and it doesn't use
the initial value of (*parent). Can't it just return it?
I mean something like:

static struct rb_node *__find_va_links(struct vmap_area *va,
	struct rb_root *root, struct rb_node *from,
	struct rb_node ***link) { ... }

It would simplify things a bit.

Also this triple pointer looks scary.
If it returns a parent and one of two children, can't it return
a desired child instead? Or it can be NULL with a non-NULL parent?

>  {
> -	struct rb_node **p =3D &vmap_area_root.rb_node;
> -	struct rb_node *parent =3D NULL;
> -	struct rb_node *tmp;
> +	struct vmap_area *tmp_va;
> =20
> -	while (*p) {
> -		struct vmap_area *tmp_va;
> +	if (root) {
> +		*link =3D &root->rb_node;
> +		if (unlikely(!**link)) {
> +			*parent =3D NULL;
> +			return;
> +		}
> +	} else {
> +		*link =3D &from;
> +	}
> =20
> -		parent =3D *p;
> -		tmp_va =3D rb_entry(parent, struct vmap_area, rb_node);
> -		if (va->va_start < tmp_va->va_end)
> -			p =3D &(*p)->rb_left;
> -		else if (va->va_end > tmp_va->va_start)
> -			p =3D &(*p)->rb_right;
> +	/*
> +	 * Go to the bottom of the tree.
> +	 */
> +	do {
> +		tmp_va =3D rb_entry(**link, struct vmap_area, rb_node);
> +
> +		/*
> +		 * During the traversal we also do some sanity check.
> +		 * Trigger the BUG() if there are sides(left/right)
> +		 * or full overlaps.
> +		 */
> +		if (va->va_start < tmp_va->va_end &&
> +				va->va_end <=3D tmp_va->va_start)
> +			*link =3D &(**link)->rb_left;
> +		else if (va->va_end > tmp_va->va_start &&
> +				va->va_start >=3D tmp_va->va_end)
> +			*link =3D &(**link)->rb_right;
>  		else
>  			BUG();
> +	} while (**link);
> +
> +	*parent =3D &tmp_va->rb_node;
> +}
> +
> +static inline void
> +__find_va_free_siblings(struct rb_node *parent, struct rb_node **link,
> +	struct list_head **prev, struct list_head **next)
> +{
> +	struct list_head *list;
> +
> +	if (likely(parent)) {
> +		list =3D &rb_entry(parent, struct vmap_area, rb_node)->list;
> +		if (&parent->rb_right =3D=3D link) {
> +			*next =3D list->next;
> +			*prev =3D list;
> +		} else {
> +			*prev =3D list->prev;
> +			*next =3D list

So, does it mean that this function always returns two following elements?
Can't it return a single element using the return statement instead?
The second one can be calculated as ->next?

> +		}
> +	} else {
> +		/*
> +		 * The red-black tree where we try to find VA neighbors
> +		 * before merging or inserting is empty, i.e. it means
> +		 * there is no free vmap space. Normally it does not
> +		 * happen but we handle this case anyway.
> +		 */
> +		*prev =3D *next =3D &free_vmap_area_list;

And for example, return NULL in this case.

>  	}
> +}
> =20
> -	rb_link_node(&va->rb_node, parent, p);
> -	rb_insert_color(&va->rb_node, &vmap_area_root);
> +static inline void
> +__link_va(struct vmap_area *va, struct rb_root *root,
> +	struct rb_node *parent, struct rb_node **link, struct list_head *head)
> +{
> +	/*
> +	 * VA is still not in the list, but we can
> +	 * identify its future previous list_head node.
> +	 */
> +	if (likely(parent)) {
> +		head =3D &rb_entry(parent, struct vmap_area, rb_node)->list;
> +		if (&parent->rb_right !=3D link)
> +			head =3D head->prev;
> +	}
> =20
> -	/* address-sort this list */
> -	tmp =3D rb_prev(&va->rb_node);
> -	if (tmp) {
> -		struct vmap_area *prev;
> -		prev =3D rb_entry(tmp, struct vmap_area, rb_node);
> -		list_add_rcu(&va->list, &prev->list);
> -	} else
> -		list_add_rcu(&va->list, &vmap_area_list);
> +	/* Insert to the rb-tree */
> +	rb_link_node(&va->rb_node, parent, link);
> +	if (root =3D=3D &free_vmap_area_root) {
> +		/*
> +		 * Some explanation here. Just perform simple insertion
> +		 * to the tree. We do not set va->subtree_max_size to
> +		 * its current size before calling rb_insert_augmented().
> +		 * It is because of we populate the tree from the bottom
> +		 * to parent levels when the node _is_ in the tree.
> +		 *
> +		 * Therefore we set subtree_max_size to zero after insertion,
> +		 * to let __augment_tree_propagate_from() puts everything to
> +		 * the correct order later on.
> +		 */
> +		rb_insert_augmented(&va->rb_node,
> +			root, &free_vmap_area_rb_augment_cb);
> +		va->subtree_max_size =3D 0;
> +	} else {
> +		rb_insert_color(&va->rb_node, root);
> +	}
> +
> +	/* Address-sort this list */
> +	list_add(&va->list, head);
>  }
> =20
> -static void purge_vmap_area_lazy(void);
> +static inline void
> +__unlink_va(struct vmap_area *va, struct rb_root *root)
> +{
> +	/*
> +	 * During merging a VA node can be empty, therefore
> +	 * not linked with the tree nor list. Just check it.
> +	 */
> +	if (!RB_EMPTY_NODE(&va->rb_node)) {
> +		if (root =3D=3D &free_vmap_area_root)
> +			rb_erase_augmented(&va->rb_node,
> +				root, &free_vmap_area_rb_augment_cb);
> +		else
> +			rb_erase(&va->rb_node, root);
> =20
> -static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> +		list_del(&va->list);
> +	}
> +}
> +
> +#if DEBUG_AUGMENT_PROPAGATE_CHECK
> +static void
> +augment_tree_propagate_do_check(struct rb_node *n)
> +{
> +	struct vmap_area *va;
> +	struct rb_node *node;
> +	unsigned long size;
> +	bool found =3D false;
> +
> +	if (n =3D=3D NULL)
> +		return;
> +
> +	va =3D rb_entry(n, struct vmap_area, rb_node);
> +	size =3D va->subtree_max_size;
> +	node =3D n;
> +
> +	while (node) {
> +		va =3D rb_entry(node, struct vmap_area, rb_node);
> +
> +		if (get_subtree_max_size(node->rb_left) =3D=3D size) {
> +			node =3D node->rb_left;
> +		} else {
> +			if (__va_size(va) =3D=3D size) {
> +				found =3D true;
> +				break;
> +			}
> +
> +			node =3D node->rb_right;
> +		}
> +	}
> +
> +	if (!found) {
> +		va =3D rb_entry(n, struct vmap_area, rb_node);
> +		pr_emerg("tree is corrupted: %lu, %lu\n",
> +			__va_size(va), va->subtree_max_size);
> +	}
> +
> +	augment_tree_propagate_do_check(n->rb_left);
> +	augment_tree_propagate_do_check(n->rb_right);
> +}
> +
> +static void augment_tree_propagate_from_check(void)
> +{
> +	augment_tree_propagate_do_check(free_vmap_area_root.rb_node);
> +}
> +#endif
> +
> +/*
> + * This function populates subtree_max_size from bottom to upper
> + * levels starting from VA point. The propagation must be done
> + * when VA size is modified by changing its va_start/va_end. Or
> + * in case of newly inserting of VA to the tree.
> + *
> + * It means that __augment_tree_propagate_from() must be called:
> + * - After VA has been inserted to the tree(free path);
> + * - After VA has been shrunk(allocation path);
> + * - After VA has been increased(merging path).
> + *
> + * Please note that, it does not mean that upper parent nodes
> + * and their subtree_max_size are recalculated all the time up
> + * to the root node.
> + *
> + *       4--8
> + *        /\
> + *       /  \
> + *      /    \
> + *    2--2  8--8
> + *
> + * For example if we modify the node 4, shrinking it to 2, then
> + * no any modification is required. If we shrink the node 2 to 1
> + * its subtree_max_size is updated only, and set to 1. If we shrink
> + * the node 8 to 6, then its subtree_max_size is set to 6 and parent
> + * node becomes 4--6.
> + */
> +static inline void
> +__augment_tree_propagate_from(struct vmap_area *va)
> +{
> +	struct rb_node *node =3D &va->rb_node;
> +	unsigned long new_va_sub_max_size;
> +
> +	while (node) {
> +		va =3D rb_entry(node, struct vmap_area, rb_node);
> +		new_va_sub_max_size =3D compute_subtree_max_size(va);
> +
> +		/*
> +		 * If the newly calculated maximum available size of the
> +		 * subtree is equal to the current one, then it means that
> +		 * the tree is propagated correctly. So we have to stop at
> +		 * this point to save cycles.
> +		 */
> +		if (va->subtree_max_size =3D=3D new_va_sub_max_size)
> +			break;
> +
> +		va->subtree_max_size =3D new_va_sub_max_size;
> +		node =3D rb_parent(&va->rb_node);
> +	}
> +
> +#if DEBUG_AUGMENT_PROPAGATE_CHECK
> +	augment_tree_propagate_from_check();
> +#endif
> +}
> +
> +static void
> +__insert_vmap_area(struct vmap_area *va,
> +	struct rb_root *root, struct list_head *head)
> +{
> +	struct rb_node **link;
> +	struct rb_node *parent;
> +
> +	__find_va_links(va, root, NULL, &parent, &link);
> +	__link_va(va, root, parent, link, head);
> +}
> +
> +static void
> +__insert_vmap_area_augment(struct vmap_area *va,
> +	struct rb_node *from, struct rb_root *root,
> +	struct list_head *head)
> +{
> +	struct rb_node **link;
> +	struct rb_node *parent;
> +
> +	if (from)
> +		__find_va_links(va, NULL, from, &parent, &link);
> +	else
> +		__find_va_links(va, root, NULL, &parent, &link);
> +
> +	__link_va(va, root, parent, link, head);
> +	__augment_tree_propagate_from(va);
> +}
> +
> +static inline void
> +__remove_vmap_area_common(struct vmap_area *va,
> +	struct rb_root *root)
> +{
> +	__unlink_va(va, root);
> +}
> +
> +/*
> + * Merge de-allocated chunk of VA memory with previous
> + * and next free blocks. If coalesce is not done a new
> + * free area is inserted. If VA has been merged, it is
> + * freed.
> + */
> +static inline void
> +__merge_or_add_vmap_area(struct vmap_area *va,
> +	struct rb_root *root, struct list_head *head)
> +{
> +	struct vmap_area *sibling;
> +	struct list_head *next, *prev;
> +	struct rb_node **link;
> +	struct rb_node *parent;
> +	bool merged =3D false;
> +
> +	/*
> +	 * Find a place in the tree where VA potentially will be
> +	 * inserted, unless it is merged with its sibling/siblings.
> +	 */
> +	__find_va_links(va, root, NULL, &parent, &link);
> +
> +	/*
> +	 * Get next/prev nodes of VA to check if merging can be done.
> +	 */
> +	__find_va_free_siblings(parent, link, &prev, &next);
> +
> +	/*
> +	 * start            end
> +	 * |                |
> +	 * |<------VA------>|<-----Next----->|
> +	 *                  |                |
> +	 *                  start            end
> +	 */
> +	if (next !=3D head) {
> +		sibling =3D list_entry(next, struct vmap_area, list);
> +		if (sibling->va_start =3D=3D va->va_end) {
> +			sibling->va_start =3D va->va_start;
> +
> +			/* Check and update the tree if needed. */
> +			__augment_tree_propagate_from(sibling);
> +
> +			/* Remove this VA, it has been merged. */
> +			__remove_vmap_area_common(va, root);
> +
> +			/* Free vmap_area object. */
> +			kmem_cache_free(vmap_area_cachep, va);
> +
> +			/* Point to the new merged area. */
> +			va =3D sibling;
> +			merged =3D true;
> +		}
> +	}
> +
> +	/*
> +	 * start            end
> +	 * |                |
> +	 * |<-----Prev----->|<------VA------>|
> +	 *                  |                |
> +	 *                  start            end
> +	 */
> +	if (prev !=3D head) {
> +		sibling =3D list_entry(prev, struct vmap_area, list);
> +		if (sibling->va_end =3D=3D va->va_start) {
> +			sibling->va_end =3D va->va_end;
> +
> +			/* Check and update the tree if needed. */
> +			__augment_tree_propagate_from(sibling);
> +
> +			/* Remove this VA, it has been merged. */
> +			__remove_vmap_area_common(va, root);
> +
> +			/* Free vmap_area object. */
> +			kmem_cache_free(vmap_area_cachep, va);
> +
> +			return;
> +		}
> +	}
> +
> +	if (!merged) {
> +		__link_va(va, root, parent, link, head);
> +		__augment_tree_propagate_from(va);
> +	}
> +}
> +
> +static inline bool
> +is_within_this_va(struct vmap_area *va, unsigned long size,
> +	unsigned long align, unsigned long vstart)
> +{
> +	unsigned long nva_start_addr;
> +
> +	if (va->va_start > vstart)
> +		nva_start_addr =3D ALIGN(va->va_start, align);
> +	else
> +		nva_start_addr =3D ALIGN(vstart, align);
> +
> +	/* Can be overflowed due to big size or alignment. */
> +	if (nva_start_addr + size < nva_start_addr ||
> +			nva_start_addr < vstart)
> +		return false;
> +
> +	return (nva_start_addr + size <=3D va->va_end);
> +}
> +
> +/*
> + * Find the first free block(lowest start address) in the tree,
> + * that will accomplish the request corresponding to passing
> + * parameters.
> + */
> +static inline struct vmap_area *
> +__find_vmap_lowest_match(unsigned long size,
> +	unsigned long align, unsigned long vstart)
> +{
> +	struct vmap_area *va;
> +	struct rb_node *node;
> +	unsigned long length;
> +
> +	/* Start from the root. */
> +	node =3D free_vmap_area_root.rb_node;
> +
> +	/* Adjust the search size for alignment overhead. */
> +	length =3D size + align - 1;
> +
> +	while (node) {
> +		va =3D rb_entry(node, struct vmap_area, rb_node);
> +
> +		if (get_subtree_max_size(node->rb_left) >=3D length &&
> +				vstart < va->va_start) {
> +			node =3D node->rb_left;
> +		} else {
> +			if (is_within_this_va(va, size, align, vstart))
> +				return va;
> +
> +			/*
> +			 * Does not make sense to go deeper towards the right
> +			 * sub-tree if it does not have a free block that is
> +			 * equal or bigger to the requested search length.
> +			 */
> +			if (get_subtree_max_size(node->rb_right) >=3D length) {
> +				node =3D node->rb_right;
> +				continue;
> +			}
> +
> +			/*
> +			 * OK. We roll back and find the fist right sub-tree,
> +			 * that will satisfy the search criteria. It can happen
> +			 * only once due to "vstart" restriction.
> +			 */
> +			while ((node =3D rb_parent(node))) {
> +				va =3D rb_entry(node, struct vmap_area, rb_node);
> +				if (is_within_this_va(va, size, align, vstart))
> +					return va;
> +
> +				if (get_subtree_max_size(node->rb_right) >=3D length &&
> +						vstart <=3D va->va_start) {
> +					node =3D node->rb_right;
> +					break;
> +				}
> +			}
> +		}
> +	}
> +
> +	return NULL;
> +}
> +
> +#if DEBUG_AUGMENT_LOWEST_MATCH_CHECK
> +#include <linux/random.h>
> +
> +static struct vmap_area *
> +__find_vmap_lowest_linear_match(unsigned long size,
> +	unsigned long align, unsigned long vstart)
> +{
> +	struct vmap_area *va;
> +
> +	list_for_each_entry(va, &free_vmap_area_list, list) {
> +		if (!is_within_this_va(va, size, align, vstart))
> +			continue;
> +
> +		return va;
> +	}
> +
> +	return NULL;
> +}
> +
> +static void
> +__find_vmap_lowest_match_check(unsigned long size)
> +{
> +	struct vmap_area *va_1, *va_2;
> +	unsigned long vstart;
> +	unsigned int rnd;
> +
> +	get_random_bytes(&rnd, sizeof(rnd));
> +	vstart =3D VMALLOC_START + rnd;
> +
> +	va_1 =3D __find_vmap_lowest_match(size, 1, vstart);
> +	va_2 =3D __find_vmap_lowest_linear_match(size, 1, vstart);
> +
> +	if (va_1 !=3D va_2)
> +		pr_emerg("not lowest: t: 0x%p, l: 0x%p, v: 0x%lx\n",
> +			va_1, va_2, vstart);
> +}
> +#endif
> +
> +enum alloc_fit_type {
> +	NOTHING_FIT =3D 0,
> +	FL_FIT_TYPE =3D 1,	/* full fit */
> +	LE_FIT_TYPE =3D 2,	/* left edge fit */
> +	RE_FIT_TYPE =3D 3,	/* right edge fit */
> +	NE_FIT_TYPE =3D 4		/* no edge fit */
> +};
> +
> +static inline u8
> +__classify_va_fit_type(struct vmap_area *va,
> +	unsigned long nva_start_addr, unsigned long size)
> +{
> +	u8 fit_type;
> +
> +	/* Check if it is within VA. */
> +	if (nva_start_addr < va->va_start ||
> +			nva_start_addr + size > va->va_end)
> +		return NOTHING_FIT;
> +
> +	/* Now classify. */
> +	if (va->va_start =3D=3D nva_start_addr) {
> +		if (va->va_end =3D=3D nva_start_addr + size)
> +			fit_type =3D FL_FIT_TYPE;
> +		else
> +			fit_type =3D LE_FIT_TYPE;
> +	} else if (va->va_end =3D=3D nva_start_addr + size) {
> +		fit_type =3D RE_FIT_TYPE;
> +	} else {
> +		fit_type =3D NE_FIT_TYPE;
> +	}
> +
> +	return fit_type;
> +}
> +
> +static inline int
> +__adjust_va_to_fit_type(struct vmap_area *va,
> +	unsigned long nva_start_addr, unsigned long size, u8 fit_type)
> +{
> +	struct vmap_area *lva;
> +
> +	if (fit_type =3D=3D FL_FIT_TYPE) {
> +		/*
> +		 * No need to split VA, it fully fits.
> +		 *
> +		 * |               |
> +		 * V      NVA      V
> +		 * |---------------|
> +		 */
> +		__remove_vmap_area_common(va, &free_vmap_area_root);
> +		kmem_cache_free(vmap_area_cachep, va);
> +	} else if (fit_type =3D=3D LE_FIT_TYPE) {
> +		/*
> +		 * Split left edge of fit VA.
> +		 *
> +		 * |       |
> +		 * V  NVA  V   R
> +		 * |-------|-------|
> +		 */
> +		va->va_start +=3D size;
> +	} else if (fit_type =3D=3D RE_FIT_TYPE) {
> +		/*
> +		 * Split right edge of fit VA.
> +		 *
> +		 *         |       |
> +		 *     L   V  NVA  V
> +		 * |-------|-------|
> +		 */
> +		va->va_end =3D nva_start_addr;
> +	} else if (fit_type =3D=3D NE_FIT_TYPE) {
> +		/*
> +		 * Split no edge of fit VA.
> +		 *
> +		 *     |       |
> +		 *   L V  NVA  V R
> +		 * |---|-------|---|
> +		 */
> +		lva =3D kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
> +		if (unlikely(!lva))
> +			return -1;
> +
> +		/*
> +		 * Build the remainder.
> +		 */
> +		lva->va_start =3D va->va_start;
> +		lva->va_end =3D nva_start_addr;
> +
> +		/*
> +		 * Shrink this VA to remaining size.
> +		 */
> +		va->va_start =3D nva_start_addr + size;
> +	} else {
> +		return -1;
> +	}
> +
> +	if (fit_type !=3D FL_FIT_TYPE) {
> +		__augment_tree_propagate_from(va);
> +
> +		if (fit_type =3D=3D NE_FIT_TYPE)
> +			__insert_vmap_area_augment(lva, &va->rb_node,
> +				&free_vmap_area_root, &free_vmap_area_list);
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * Returns a start address of the newly allocated area, if success.
> + * Otherwise a vend is returned that indicates failure.
> + */
> +static inline unsigned long
> +__alloc_vmap_area(unsigned long size, unsigned long align,
> +	unsigned long vstart, unsigned long vend, int node)
> +{
> +	unsigned long nva_start_addr;
> +	struct vmap_area *va;
> +	u8 fit_type;
> +	int ret;
> +
> +	va =3D __find_vmap_lowest_match(size, align, vstart);
> +	if (unlikely(!va))
> +		return vend;
> +
> +	if (va->va_start > vstart)
> +		nva_start_addr =3D ALIGN(va->va_start, align);
> +	else
> +		nva_start_addr =3D ALIGN(vstart, align);
> +
> +	/* Check the "vend" restriction. */
> +	if (nva_start_addr + size > vend)
> +		return vend;
> +
> +	/* Classify what we have found. */
> +	fit_type =3D __classify_va_fit_type(va, nva_start_addr, size);
> +	if (unlikely(fit_type =3D=3D NOTHING_FIT)) {
> +		WARN_ON_ONCE(true);

Nit: WARN_ON_ONCE() has unlikely() built-in and returns the value,
so it can be something like:

  if (WARN_ON_ONCE(fit_type =3D=3D NOTHING_FIT))
  	return vend;

The same comment applies for a couple of other place, where is a check
for NOTHING_FIT.


I do not see any issues so far, just some places in the code are a bit
hard to follow. I'll try to spend more time on the patch in the next
couple of weeks.

Thank you!

Roman

