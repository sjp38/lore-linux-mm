Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 858C3C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:07:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A4AD206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:07:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nwnK/NDn";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="gjnH+S+3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A4AD206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7E2E6B0269; Wed,  3 Apr 2019 17:07:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2DBB6B026A; Wed,  3 Apr 2019 17:07:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D0736B026B; Wed,  3 Apr 2019 17:07:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC4B6B0269
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 17:07:46 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id g140so386353ywb.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 14:07:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=yQ9wAy6lusWBR2h3+aI0LmRCdQ/zEzYWXwhB51+EPV4=;
        b=Ho0UF5O0bS4yt83Kq+JMIEHO2tNBxyM5m1LwzpD6/ZH3n06dzxUSxiBeAz416p9i36
         yp9Rq0lOJaIvIyhVysbxysph6Ins4K59KjyfCvMTqatbyNvhyyzf4Plz43FQiO1xi4+8
         R1BBQHKgxuqsLp/gfVivqw6pBs7faDS/F2nFriBRvzdzLUDpSquF0jvMTCkwa00uQ2VE
         0R7XNeKYdpi5713aHmr9ZOqdwb2mhCkID+F2ag7rw0X6mYIreGwK7rNjNdKOSphuCAQR
         imYU17EOg0enlAcvDry+LY7cKgzTE+x9TS9kMsrrHqPIwte0Z0SfqFCYPFlYlYnYReO/
         s+4w==
X-Gm-Message-State: APjAAAXdOB0Gtv8nsLKSGhDXxpNmgt9mTUFRfqK3ObT/mEo6NiBV9jpO
	nu8LsCI9lKq7aZigyNfzIWHd9r0rylvcfX0KCV3WriM7nk7f/sbEqYYluwL/Ja3JnAVI/WdTVx9
	9+zkELytanTT8xcejqJ6Li6pZ6Ba0ljyIK05p0DmmuvlM2SnN8FOIS9EokdOJ3mBDqw==
X-Received: by 2002:a25:8106:: with SMTP id o6mr2116210ybk.53.1554325666027;
        Wed, 03 Apr 2019 14:07:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9Dh/bUhs1MpS5llCfKgAbnzXTe9guRqFvIzpxtA+dnKm3lxoRpy942lVyWcXOlTIV4yOH
X-Received: by 2002:a25:8106:: with SMTP id o6mr2116071ybk.53.1554325664000;
        Wed, 03 Apr 2019 14:07:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554325663; cv=none;
        d=google.com; s=arc-20160816;
        b=WKj8qciJcC1T0SEoNdcYmtDOdT5n6LPw3l0T70gt8iXM2ynzAv2SC0QO/P2s6hsT24
         1K8fLGkxl7MWK7WtLAwFN43P9VqJmcjAHE7E9QxltzFAENl41G1doAxSZ0J3RnxTJgpp
         AL6S7ovEDbK1ytO6xfCXztTZI2Er7HQuSCNEsrLxyeM4bjwGbF3hmIHcdguaAnXGKit7
         tzKrTMg0dOK5tmjK1y14CEhfzv0+YGTOXYwev4yPvDiVepF3TRvux4olDIHejBTwbqRY
         PFa08ChsH0WxY3tso+Tmd9WsG0YwwnAd7ISi3Wrm6XSPx6kVarrp+D27Qiv4yl4ZgQRl
         sw/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=yQ9wAy6lusWBR2h3+aI0LmRCdQ/zEzYWXwhB51+EPV4=;
        b=qKzCHcWHPaQ8of1u2Hc3VwT+U5ntxwWSJxya6pdXXj5YxAiWCTJHu8wsiLsVhydmoO
         QeIXnZZmKON5mdimkHGI7dW19iO/JfuYx6inEbe8eD/tukKj3zF6bM9GwAY65Hg2pO++
         /9L3Zj8fdG8MybmD3I183fA4OEOJ/J07mwRPWQXUtFTfhHgENL92GZ4FTQD4i8TNX3p4
         BT2TfErmkvuc+3Saa3gCSCXRrsUyTMBY2XVKUmc2y/t5ZeNslYse0qZYnPkNpbKINVro
         tmYCNn0taFCU3AD+SR0vlT2xt+xj0vN+er9j71wxo+Mi8MZurRtcXf29Ugp6VDKgi6UI
         FCLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="nwnK/NDn";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=gjnH+S+3;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x65si11060855ywf.21.2019.04.03.14.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 14:07:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="nwnK/NDn";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=gjnH+S+3;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x33Kmjg8017367;
	Wed, 3 Apr 2019 14:06:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=yQ9wAy6lusWBR2h3+aI0LmRCdQ/zEzYWXwhB51+EPV4=;
 b=nwnK/NDnHIU4BVtc7a+63XGeuWG5WXeMSNpmhLXRM9sCA+thX1RMjOcCt5ftMO0ZYean
 32HmVdcQVZstP42nUBd8oxLPpLnSZB1ze09cHevURKJboQeWOnXtrM9g57ropHkvQZ+P
 0GscIRJhanRI3Ub2894ywUt9Sqr7gy6zLl8= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rn30traqg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 03 Apr 2019 14:06:54 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 14:06:52 -0700
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 3 Apr 2019 14:06:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yQ9wAy6lusWBR2h3+aI0LmRCdQ/zEzYWXwhB51+EPV4=;
 b=gjnH+S+33HPWFTdzrLggwI/HgL0zq6QXTCWjSmKkSbFQIvp86v/7m3JYbxr3jL8kI+BYdYALc3cQJxeSylEo418llKI4+dpA1r7WNfXbU7kN3v5WnNBQOXkqQm7WqCWshtUXpyy1rYxavqJ5itJ7lDdVqFN9DzyQoObvpz0Bc8E=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3094.namprd15.prod.outlook.com (20.178.239.76) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.17; Wed, 3 Apr 2019 21:06:49 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Wed, 3 Apr 2019
 21:06:49 +0000
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
Subject: Re: [RESEND PATCH 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Topic: [RESEND PATCH 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Index: AQHU6XC/t3CdtEyCo0+G5po95xTuJ6Yq72iA
Date: Wed, 3 Apr 2019 21:06:49 +0000
Message-ID: <20190403210644.GH6778@tower.DHCP.thefacebook.com>
References: <20190402162531.10888-1-urezki@gmail.com>
 <20190402162531.10888-2-urezki@gmail.com>
In-Reply-To: <20190402162531.10888-2-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR08CA0016.namprd08.prod.outlook.com
 (2603:10b6:301:5f::29) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:9220]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 537f8fd0-70e8-4f8e-b722-08d6b87849a7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3094;
x-ms-traffictypediagnostic: BYAPR15MB3094:
x-microsoft-antispam-prvs: <BYAPR15MB3094B1F4DF2B7E57454E86C5BE570@BYAPR15MB3094.namprd15.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39860400002)(366004)(376002)(346002)(396003)(189003)(199004)(54094003)(1076003)(478600001)(33656002)(11346002)(6246003)(486006)(71200400001)(5660300002)(2906002)(46003)(102836004)(4326008)(6436002)(6486002)(1411001)(76176011)(386003)(71190400001)(53946003)(305945005)(14454004)(229853002)(6916009)(7736002)(54906003)(81156014)(316002)(25786009)(52116002)(7416002)(476003)(53936002)(6506007)(9686003)(6512007)(446003)(86362001)(8676002)(8936002)(68736007)(186003)(256004)(81166006)(105586002)(97736004)(30864003)(14444005)(106356001)(6116002)(99286004)(559001)(569006);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3094;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: tGkZ/DgtiGcEK4FKKCh9Gp1YbeL2c8wurjWMRDXTeo2edkbPdWWt3TB2BPLdnGuv+1bFtxR5DCm1Da/D52hvGUPS31jwDotNDOC82rng/IQuslZmovB4E4IhOP1/dh6wgPjf55R+4Fnb93L9Ab4G5ZFJaTXiDhzAQCPlikwh3ZtCtqs4xLSrNwwaR0QNNRjz01eXAnqb50sG+WjAeju7byqDaZVqmN3YwVX4v6GVmmu7ajfF/A+b10zMbj9DCvweK4WZfxxWBEBvBuoki2fiDG8UqKZmYWY3o0Z2jCtwgkV0TF0Fi2gJQHoBgx0ICWlIhYVgdZkmkeljIdtyU2lE4pxR6pj+FKr1rwX+VX4cDIAB6mSpZJYOnqr5zuNKAXxvYkMmkYTkhglS3AlxgsnNf18Xd7wQiqlccvssBG8p3t4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2F546A2BE7FCFD4E972970468CCE87B9@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 537f8fd0-70e8-4f8e-b722-08d6b87849a7
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 21:06:49.4230
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3094
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-03_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Uladzislau!

The patch looks really good to me! I've tried hard, but didn't find
any serious issues/bugs. Some small nits below.

Thank you for working on it!

BTW, when sending a new iteration, please use "[PATCH vX]" subject prefix,
e.g. [PATCH v3 1/3] mm/vmap: keep track of free blocks for vmap allocation"=
.
RESEND usually means that you're sending the same version, e.g. when
you need cc more people.


On Tue, Apr 02, 2019 at 06:25:29PM +0200, Uladzislau Rezki (Sony) wrote:
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

I'd add here that an augmented red-black tree is used, and nodes
are augmented with the size of the maximum available free block.

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
>=20
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  include/linux/vmalloc.h |    6 +-
>  mm/vmalloc.c            | 1004 +++++++++++++++++++++++++++++++++++------=
------
>  2 files changed, 762 insertions(+), 248 deletions(-)
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
> index 755b02983d8d..3adbad3fb6c1 100644
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
> @@ -320,9 +321,7 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr=
)
>  }
>  EXPORT_SYMBOL(vmalloc_to_pfn);
> =20
> -
>  /*** Global kva allocator ***/
> -

Do we need this change?

>  #define VM_LAZY_FREE	0x02
>  #define VM_VM_AREA	0x04
> =20
> @@ -331,14 +330,76 @@ static DEFINE_SPINLOCK(vmap_area_lock);
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
> =20
> -/* The vmap cache globals are protected by vmap_area_lock */
> -static struct rb_node *free_vmap_cache;
> -static unsigned long cached_hole_size;
> -static unsigned long cached_vstart;
> -static unsigned long cached_align;
> +static __always_inline unsigned long
> +__va_size(struct vmap_area *va)
> +{
> +	return (va->va_end - va->va_start);
> +}
> +
> +static __always_inline unsigned long
> +get_subtree_max_size(struct rb_node *node)
> +{
> +	struct vmap_area *va;
> =20
> -static unsigned long vmap_area_pcpu_hole;
> +	va =3D rb_entry_safe(node, struct vmap_area, rb_node);
> +	return va ? va->subtree_max_size : 0;
> +}
> +
> +/*
> + * Gets called when remove the node and rotate.
> + */
> +static __always_inline unsigned long
> +compute_subtree_max_size(struct vmap_area *va)
> +{
> +	unsigned long max_size =3D __va_size(va);
> +	unsigned long child_max_size;
> +
> +	child_max_size =3D get_subtree_max_size(va->rb_node.rb_right);
> +	if (child_max_size > max_size)
> +		max_size =3D child_max_size;
> +
> +	child_max_size =3D get_subtree_max_size(va->rb_node.rb_left);
> +	if (child_max_size > max_size)
> +		max_size =3D child_max_size;
> +
> +	return max_size;

Nit: you can use max3 instead, e.g. :

return max3(__va_size(va),
	    get_subtree_max_size(va->rb_node.rb_left),
	    get_subtree_max_size(va->rb_node.rb_right));

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
> @@ -359,41 +420,520 @@ static struct vmap_area *__find_vmap_area(unsigned=
 long addr)
>  	return NULL;
>  }
> =20
> -static void __insert_vmap_area(struct vmap_area *va)
> -{
> -	struct rb_node **p =3D &vmap_area_root.rb_node;
> -	struct rb_node *parent =3D NULL;
> -	struct rb_node *tmp;
> +/*
> + * This function returns back addresses of parent node
> + * and its left or right link for further processing.
> + */
> +static __always_inline struct rb_node **
> +__find_va_links(struct vmap_area *va,
> +	struct rb_root *root, struct rb_node *from,
> +	struct rb_node **parent)

The function looks much cleaner now, thank you!

But if I understand it correctly, it returns a node (via parent)
and a pointer to one of two links, so that the returned value
is always =3D=3D parent + some constant offset.
If so, I wonder if it's cleaner to return a parent node
(as rb_node*) and a bool value which will indicate if the left
or the right link should be used.

Not a strong opinion, just an idea.

> +{
> +	struct vmap_area *tmp_va;
> +	struct rb_node **link;
> +
> +	if (root) {
> +		link =3D &root->rb_node;
> +		if (unlikely(!*link)) {
> +			*parent =3D NULL;
> +			return link;
> +		}
> +	} else {
> +		link =3D &from;
> +	}
> =20
> -	while (*p) {
> -		struct vmap_area *tmp_va;
> +	/*
> +	 * Go to the bottom of the tree.
> +	 */
> +	do {
> +		tmp_va =3D rb_entry(*link, struct vmap_area, rb_node);
> =20
> -		parent =3D *p;
> -		tmp_va =3D rb_entry(parent, struct vmap_area, rb_node);
> -		if (va->va_start < tmp_va->va_end)
> -			p =3D &(*p)->rb_left;
> -		else if (va->va_end > tmp_va->va_start)
> -			p =3D &(*p)->rb_right;
> +		/*
> +		 * During the traversal we also do some sanity check.
> +		 * Trigger the BUG() if there are sides(left/right)
> +		 * or full overlaps.
> +		 */
> +		if (va->va_start < tmp_va->va_end &&
> +				va->va_end <=3D tmp_va->va_start)
> +			link =3D &(*link)->rb_left;
> +		else if (va->va_end > tmp_va->va_start &&
> +				va->va_start >=3D tmp_va->va_end)
> +			link =3D &(*link)->rb_right;
>  		else
>  			BUG();
> +	} while (*link);
> +
> +	*parent =3D &tmp_va->rb_node;
> +	return link;
> +}
> +
> +static __always_inline struct list_head *
> +__get_va_next_sibling(struct rb_node *parent, struct rb_node **link)
> +{
> +	struct list_head *list;
> +
> +	if (likely(parent)) {
> +		list =3D &rb_entry(parent, struct vmap_area, rb_node)->list;
> +		return (&parent->rb_right =3D=3D link ? list->next:list);
                                                             ^^^
A couple of missing spaces here.
Also, if !parent is almost unreachable, I'd invert the if condition, e.g.:
    if (unlikely(!parent)) {
	/* comment */
	return NULL;
    }

    /* normal case */
>  	}
> =20
> -	rb_link_node(&va->rb_node, parent, p);
> -	rb_insert_color(&va->rb_node, &vmap_area_root);
> +	/*
> +	 * The red-black tree where we try to find VA neighbors
> +	 * before merging or inserting is empty, i.e. it means
> +	 * there is no free vmap space. Normally it does not
> +	 * happen but we handle this case anyway.
> +	 */
> +	return NULL;
> +}
> +
> +static __always_inline void
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
> +static __always_inline void
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
> +		RB_CLEAR_NODE(&va->rb_node);
> +	}
> +}
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
> +static __always_inline void
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
> +}
> +
> +static void
> +__insert_vmap_area(struct vmap_area *va,
> +	struct rb_root *root, struct list_head *head)
> +{
> +	struct rb_node **link;
> +	struct rb_node *parent;
> +
> +	link =3D __find_va_links(va, root, NULL, &parent);
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
> +		link =3D __find_va_links(va, NULL, from, &parent);
> +	else
> +		link =3D __find_va_links(va, root, NULL, &parent);
> +
> +	__link_va(va, root, parent, link, head);
> +	__augment_tree_propagate_from(va);

Also, why almost all new functions have names starting with __?
Usually it means that there are non-__ versions of these functions,
which adding locking, or some additional checks, or are public.
As I can see, it's not true for some new functions.
So why not to spare some characters?

> +}
> +
> +/*
> + * Merge de-allocated chunk of VA memory with previous
> + * and next free blocks. If coalesce is not done a new
> + * free area is inserted. If VA has been merged, it is
> + * freed.
> + */
> +static __always_inline void
> +__merge_or_add_vmap_area(struct vmap_area *va,
> +	struct rb_root *root, struct list_head *head)
> +{
> +	struct vmap_area *sibling;
> +	struct list_head *next;
> +	struct rb_node **link;
> +	struct rb_node *parent;
> +	bool merged =3D false;
> +
> +	/*
> +	 * Find a place in the tree where VA potentially will be
> +	 * inserted, unless it is merged with its sibling/siblings.
> +	 */
> +	link =3D __find_va_links(va, root, NULL, &parent);
> +
> +	/*
> +	 * Get next node of VA to check if merging can be done.
> +	 */
> +	next =3D __get_va_next_sibling(parent, link);
> +	if (unlikely(next =3D=3D NULL))
> +		goto insert;
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
> +			__unlink_va(va, root);
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
> +	if (next->prev !=3D head) {
> +		sibling =3D list_entry(next->prev, struct vmap_area, list);
> +		if (sibling->va_end =3D=3D va->va_start) {
> +			sibling->va_end =3D va->va_end;
> +
> +			/* Check and update the tree if needed. */
> +			__augment_tree_propagate_from(sibling);
> +
> +			/* Remove this VA, it has been merged. */
> +			__unlink_va(va, root);
> +
> +			/* Free vmap_area object. */
> +			kmem_cache_free(vmap_area_cachep, va);
> +
> +			return;
> +		}
> +	}
> +
> +insert:
> +	if (!merged) {
> +		__link_va(va, root, parent, link, head);
> +		__augment_tree_propagate_from(va);
> +	}
> +}
> +
> +static __always_inline bool
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
> +static __always_inline struct vmap_area *
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
> +enum alloc_fit_type {
> +	NOTHING_FIT =3D 0,
> +	FL_FIT_TYPE =3D 1,	/* full fit */
> +	LE_FIT_TYPE =3D 2,	/* left edge fit */
> +	RE_FIT_TYPE =3D 3,	/* right edge fit */
> +	NE_FIT_TYPE =3D 4		/* no edge fit */
> +};
> +
> +static __always_inline u8
> +__classify_va_fit_type(struct vmap_area *va,
> +	unsigned long nva_start_addr, unsigned long size)
> +{
> +	u8 fit_type;

I believe enum alloc_fit_type is preferable over u8.

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
> +static __always_inline int
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
> +		__unlink_va(va, &free_vmap_area_root);
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
> +static __always_inline unsigned long
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
> +	if (WARN_ON_ONCE(fit_type =3D=3D NOTHING_FIT))
> +		return vend;
> +
> +	/* Update the free vmap_area. */
> +	ret =3D __adjust_va_to_fit_type(va, nva_start_addr, size, fit_type);
> +	if (ret)
> +		return vend;
> +
> +	return nva_start_addr;
> +}
> =20
>  /*
>   * Allocate a region of KVA of the specified size and alignment, within =
the
> @@ -405,18 +945,19 @@ static struct vmap_area *alloc_vmap_area(unsigned l=
ong size,
>  				int node, gfp_t gfp_mask)
>  {
>  	struct vmap_area *va;
> -	struct rb_node *n;
>  	unsigned long addr;
>  	int purged =3D 0;
> -	struct vmap_area *first;
> =20
>  	BUG_ON(!size);
>  	BUG_ON(offset_in_page(size));
>  	BUG_ON(!is_power_of_2(align));
> =20
> +	if (unlikely(!vmap_initialized))
> +		return ERR_PTR(-EBUSY);
> +
>  	might_sleep();
> =20
> -	va =3D kmalloc_node(sizeof(struct vmap_area),
> +	va =3D kmem_cache_alloc_node(vmap_area_cachep,
>  			gfp_mask & GFP_RECLAIM_MASK, node);
>  	if (unlikely(!va))
>  		return ERR_PTR(-ENOMEM);
> @@ -429,87 +970,20 @@ static struct vmap_area *alloc_vmap_area(unsigned l=
ong size,
> =20
>  retry:
>  	spin_lock(&vmap_area_lock);
> -	/*
> -	 * Invalidate cache if we have more permissive parameters.
> -	 * cached_hole_size notes the largest hole noticed _below_
> -	 * the vmap_area cached in free_vmap_cache: if size fits
> -	 * into that hole, we want to scan from vstart to reuse
> -	 * the hole instead of allocating above free_vmap_cache.
> -	 * Note that __free_vmap_area may update free_vmap_cache
> -	 * without updating cached_hole_size or cached_align.
> -	 */
> -	if (!free_vmap_cache ||
> -			size < cached_hole_size ||
> -			vstart < cached_vstart ||
> -			align < cached_align) {
> -nocache:
> -		cached_hole_size =3D 0;
> -		free_vmap_cache =3D NULL;
> -	}
> -	/* record if we encounter less permissive parameters */
> -	cached_vstart =3D vstart;
> -	cached_align =3D align;
> -
> -	/* find starting point for our search */
> -	if (free_vmap_cache) {
> -		first =3D rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> -		addr =3D ALIGN(first->va_end, align);
> -		if (addr < vstart)
> -			goto nocache;
> -		if (addr + size < addr)
> -			goto overflow;
> -
> -	} else {
> -		addr =3D ALIGN(vstart, align);
> -		if (addr + size < addr)
> -			goto overflow;
> =20
> -		n =3D vmap_area_root.rb_node;
> -		first =3D NULL;
> -
> -		while (n) {
> -			struct vmap_area *tmp;
> -			tmp =3D rb_entry(n, struct vmap_area, rb_node);
> -			if (tmp->va_end >=3D addr) {
> -				first =3D tmp;
> -				if (tmp->va_start <=3D addr)
> -					break;
> -				n =3D n->rb_left;
> -			} else
> -				n =3D n->rb_right;
> -		}
> -
> -		if (!first)
> -			goto found;
> -	}
> -
> -	/* from the starting point, walk areas until a suitable hole is found *=
/
> -	while (addr + size > first->va_start && addr + size <=3D vend) {
> -		if (addr + cached_hole_size < first->va_start)
> -			cached_hole_size =3D first->va_start - addr;
> -		addr =3D ALIGN(first->va_end, align);
> -		if (addr + size < addr)
> -			goto overflow;
> -
> -		if (list_is_last(&first->list, &vmap_area_list))
> -			goto found;
> -
> -		first =3D list_next_entry(first, list);
> -	}
> -
> -found:
>  	/*
> -	 * Check also calculated address against the vstart,
> -	 * because it can be 0 because of big align request.
> +	 * If an allocation fails, the "vend" address is
> +	 * returned. Therefore trigger the overflow path.
>  	 */
> -	if (addr + size > vend || addr < vstart)
> +	addr =3D __alloc_vmap_area(size, align, vstart, vend, node);
> +	if (unlikely(addr =3D=3D vend))
>  		goto overflow;
> =20
>  	va->va_start =3D addr;
>  	va->va_end =3D addr + size;
>  	va->flags =3D 0;
> -	__insert_vmap_area(va);
> -	free_vmap_cache =3D &va->rb_node;
> +	__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
> +
>  	spin_unlock(&vmap_area_lock);
> =20
>  	BUG_ON(!IS_ALIGNED(va->va_start, align));
> @@ -538,7 +1012,8 @@ static struct vmap_area *alloc_vmap_area(unsigned lo=
ng size,
>  	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
>  		pr_warn("vmap allocation for size %lu failed: use vmalloc=3D<size> to =
increase size\n",
>  			size);
> -	kfree(va);
> +
> +	kmem_cache_free(vmap_area_cachep, va);
>  	return ERR_PTR(-EBUSY);
>  }
> =20
> @@ -558,35 +1033,16 @@ static void __free_vmap_area(struct vmap_area *va)
>  {
>  	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> =20
> -	if (free_vmap_cache) {
> -		if (va->va_end < cached_vstart) {
> -			free_vmap_cache =3D NULL;
> -		} else {
> -			struct vmap_area *cache;
> -			cache =3D rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> -			if (va->va_start <=3D cache->va_start) {
> -				free_vmap_cache =3D rb_prev(&va->rb_node);
> -				/*
> -				 * We don't try to update cached_hole_size or
> -				 * cached_align, but it won't go very wrong.
> -				 */
> -			}
> -		}
> -	}
> -	rb_erase(&va->rb_node, &vmap_area_root);
> -	RB_CLEAR_NODE(&va->rb_node);
> -	list_del_rcu(&va->list);
> -
>  	/*
> -	 * Track the highest possible candidate for pcpu area
> -	 * allocation.  Areas outside of vmalloc area can be returned
> -	 * here too, consider only end addresses which fall inside
> -	 * vmalloc area proper.
> +	 * Remove from the busy tree/list.
>  	 */
> -	if (va->va_end > VMALLOC_START && va->va_end <=3D VMALLOC_END)
> -		vmap_area_pcpu_hole =3D max(vmap_area_pcpu_hole, va->va_end);
> +	__unlink_va(va, &vmap_area_root);
> =20
> -	kfree_rcu(va, rcu_head);
> +	/*
> +	 * Merge VA with its neighbors, otherwise just add it.
> +	 */
> +	__merge_or_add_vmap_area(va,
> +		&free_vmap_area_root, &free_vmap_area_list);
>  }
> =20
>  /*
> @@ -793,8 +1249,6 @@ static struct vmap_area *find_vmap_area(unsigned lon=
g addr)
> =20
>  #define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
> =20
> -static bool vmap_initialized __read_mostly =3D false;
> -
>  struct vmap_block_queue {
>  	spinlock_t lock;
>  	struct list_head free;
> @@ -1248,12 +1702,52 @@ void __init vm_area_register_early(struct vm_stru=
ct *vm, size_t align)
>  	vm_area_add_early(vm);
>  }
> =20
> +static void vmap_init_free_space(void)
> +{
> +	unsigned long vmap_start =3D 1;
> +	const unsigned long vmap_end =3D ULONG_MAX;
> +	struct vmap_area *busy, *free;
> +
> +	/*
> +	 *     B     F     B     B     B     F
> +	 * -|-----|.....|-----|-----|-----|.....|-
> +	 *  |           The KVA space           |
> +	 *  |<--------------------------------->|
> +	 */
> +	list_for_each_entry(busy, &vmap_area_list, list) {
> +		if (busy->va_start - vmap_start > 0) {
> +			free =3D kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);

Don't we need to check free for NULL pointer here?

> +			free->va_start =3D vmap_start;
> +			free->va_end =3D busy->va_start;
> +
> +			__insert_vmap_area_augment(free, NULL,
> +				&free_vmap_area_root, &free_vmap_area_list);
> +		}
> +
> +		vmap_start =3D busy->va_end;
> +	}
> +
> +	if (vmap_end - vmap_start > 0) {
> +		free =3D kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);

And here too.

> +		free->va_start =3D vmap_start;
> +		free->va_end =3D vmap_end;
> +
> +		__insert_vmap_area_augment(free, NULL,
> +			&free_vmap_area_root, &free_vmap_area_list);
> +	}
> +}
> +
>  void __init vmalloc_init(void)
>  {
>  	struct vmap_area *va;
>  	struct vm_struct *tmp;
>  	int i;
> =20
> +	/*
> +	 * Create the cache for vmap_area objects.
> +	 */
> +	vmap_area_cachep =3D KMEM_CACHE(vmap_area, SLAB_PANIC);
> +
>  	for_each_possible_cpu(i) {
>  		struct vmap_block_queue *vbq;
>  		struct vfree_deferred *p;
> @@ -1268,16 +1762,18 @@ void __init vmalloc_init(void)
> =20
>  	/* Import existing vmlist entries. */
>  	for (tmp =3D vmlist; tmp; tmp =3D tmp->next) {
> -		va =3D kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> +		va =3D kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
>  		va->flags =3D VM_VM_AREA;
>  		va->va_start =3D (unsigned long)tmp->addr;
>  		va->va_end =3D va->va_start + tmp->size;
>  		va->vm =3D tmp;
> -		__insert_vmap_area(va);
> +		__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
>  	}
> =20
> -	vmap_area_pcpu_hole =3D VMALLOC_END;
> -
> +	/*
> +	 * Now we can initialize a free vmap space.
> +	 */
> +	vmap_init_free_space();
>  	vmap_initialized =3D true;
>  }
> =20
> @@ -2385,81 +2881,66 @@ static struct vmap_area *node_to_va(struct rb_nod=
e *n)
>  }
> =20
>  /**
> - * pvm_find_next_prev - find the next and prev vmap_area surrounding @en=
d
> - * @end: target address
> - * @pnext: out arg for the next vmap_area
> - * @pprev: out arg for the previous vmap_area
> + * pvm_find_va_enclose_addr - find the vmap_area @addr belongs to
> + * @addr: target address
>   *
> - * Returns: %true if either or both of next and prev are found,
> - *	    %false if no vmap_area exists
> - *
> - * Find vmap_areas end addresses of which enclose @end.  ie. if not
> - * NULL, *pnext->va_end > @end and *pprev->va_end <=3D @end.
> + * Returns: vmap_area if it is found. If there is no such area
> + *   the first highest(reverse order) vmap_area is returned
> + *   i.e. va->va_start < addr && va->va_end < addr or NULL
> + *   if there are no any areas before @addr.
>   */
> -static bool pvm_find_next_prev(unsigned long end,
> -			       struct vmap_area **pnext,
> -			       struct vmap_area **pprev)
> +static struct vmap_area *
> +pvm_find_va_enclose_addr(unsigned long addr)
>  {
> -	struct rb_node *n =3D vmap_area_root.rb_node;
> -	struct vmap_area *va =3D NULL;
> +	struct vmap_area *va, *tmp;
> +	struct rb_node *n;
> +
> +	n =3D free_vmap_area_root.rb_node;
> +	va =3D NULL;
> =20
>  	while (n) {
> -		va =3D rb_entry(n, struct vmap_area, rb_node);
> -		if (end < va->va_end)
> -			n =3D n->rb_left;
> -		else if (end > va->va_end)
> +		tmp =3D rb_entry(n, struct vmap_area, rb_node);
> +		if (tmp->va_start <=3D addr) {
> +			va =3D tmp;
> +			if (tmp->va_end >=3D addr)
> +				break;
> +
>  			n =3D n->rb_right;
> -		else
> -			break;
> +		} else {
> +			n =3D n->rb_left;
> +		}
>  	}
> =20
> -	if (!va)
> -		return false;
> -
> -	if (va->va_end > end) {
> -		*pnext =3D va;
> -		*pprev =3D node_to_va(rb_prev(&(*pnext)->rb_node));
> -	} else {
> -		*pprev =3D va;
> -		*pnext =3D node_to_va(rb_next(&(*pprev)->rb_node));
> -	}
> -	return true;
> +	return va;
>  }
> =20
>  /**
> - * pvm_determine_end - find the highest aligned address between two vmap=
_areas
> - * @pnext: in/out arg for the next vmap_area
> - * @pprev: in/out arg for the previous vmap_area
> - * @align: alignment
> - *
> - * Returns: determined end address
> + * pvm_determine_end_from_reverse - find the highest aligned address
> + * of free block below VMALLOC_END
> + * @va:
> + *   in - the VA we start the search(reverse order);
> + *   out - the VA with the highest aligned end address.
>   *
> - * Find the highest aligned address between *@pnext and *@pprev below
> - * VMALLOC_END.  *@pnext and *@pprev are adjusted so that the aligned
> - * down address is between the end addresses of the two vmap_areas.
> - *
> - * Please note that the address returned by this function may fall
> - * inside *@pnext vmap_area.  The caller is responsible for checking
> - * that.
> + * Returns: determined end address within vmap_area
>   */
> -static unsigned long pvm_determine_end(struct vmap_area **pnext,
> -				       struct vmap_area **pprev,
> -				       unsigned long align)
> +static unsigned long
> +pvm_determine_end_from_reverse(struct vmap_area **va, unsigned long alig=
n)
>  {
> -	const unsigned long vmalloc_end =3D VMALLOC_END & ~(align - 1);
> +	unsigned long vmalloc_end =3D VMALLOC_END & ~(align - 1);
>  	unsigned long addr;
> =20
> -	if (*pnext)
> -		addr =3D min((*pnext)->va_start & ~(align - 1), vmalloc_end);
> -	else
> -		addr =3D vmalloc_end;
> +	if (unlikely(!(*va)))
> +		goto leave;
> =20
> -	while (*pprev && (*pprev)->va_end > addr) {
> -		*pnext =3D *pprev;
> -		*pprev =3D node_to_va(rb_prev(&(*pnext)->rb_node));
> +	list_for_each_entry_from_reverse((*va),
> +			&free_vmap_area_list, list) {
> +		addr =3D min((*va)->va_end & ~(align - 1), vmalloc_end);
> +		if ((*va)->va_start < addr)
> +			return addr;
>  	}
> =20
> -	return addr;
> +leave:
> +	return 0;

If the function has more than one return point, why do bother with the leav=
e
label?

