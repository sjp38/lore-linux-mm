Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E294BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 05:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BBD720700
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 05:22:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BBD720700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA42C6B0007; Fri, 29 Mar 2019 01:22:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B533E6B0008; Fri, 29 Mar 2019 01:22:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1B2D6B000C; Fri, 29 Mar 2019 01:22:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 812556B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:22:52 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id l140so1097282ita.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:22:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ygad+lK5vhzFqJkkHfbcTrJHteBumBoI/HXbq+cMlw8=;
        b=YmwChDWL5fFAxOmjU61e6szEiH6sClN7WA5243/fG3mHX6mTQ9aZHsLzlnMzOUWtgt
         oBQ9ZRI4hcJFPQ3iI7Sx6tjnSqrb1UjoHu4ajMv4wOg3BC6DpPr+IkAY71R1Fy2a80QI
         RNERLTFNFjyjEpGkCUNyRECGEM38Q/RQ6fw9AjCVeGUdAnl6vVfFHzIlwo0hEewjASuB
         jlJUezrBHwocE0RtF0ba8d0QTd74HuQc7NrSazujNXX3QX/Rvgiv1pyhPFC9eGdffrk0
         9DYBO48J8KeyehRlF7gZSyjno2UvZFlEGfJ2lPS8SfQPlR+W/Nr9UU4GU5I1in9r1m84
         Eh4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAVyim/in99feZDlmaDPvY88zTjhAUo+c9KNumueYLEVhuU08/uz
	zveU5m3uYJtEu1h5IaIw7Ur2c7koYhD5hCbrPASxv9LbhoCLC7EbGDtWCHSRx0Iu4pJ4924NWOf
	1T51OP1EaFR7wu+yCgpwp2wxiHuP5NZX8vzgVkebG7vxVuU0XaG6bGUhBT4j8hUss4Q==
X-Received: by 2002:a24:ba15:: with SMTP id p21mr3333578itf.66.1553836972177;
        Thu, 28 Mar 2019 22:22:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5+iumHTzA9H3ZC9qkD0jsEM4hl5qKjruZrb8iw/cccQ8PAnuDtrSh0LoMcXL/sYvAMlpI
X-Received: by 2002:a24:ba15:: with SMTP id p21mr3333550itf.66.1553836971256;
        Thu, 28 Mar 2019 22:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553836971; cv=none;
        d=google.com; s=arc-20160816;
        b=Z9nOAoRQguGhh6I4kHNkyL0nwIcenDfM2k42P3n9roTVDjZt4QIrakCJEWUolRTsgO
         XmmfwAuKblYVKMBxoVGKEFX+u4/4oXc1mCvSGkGoitPTD0XPNeaqGKUYuRQfBRfd1LN3
         LzFsJX0vV4TtAYN453Ph+SsnwG+9PM78Tx3RwfMCd/z+Am2Pvl9WFEXi/1wFP9SqgLZj
         k3QtaIHeQlwRXri63BNFSbDkYzU1oXhs/FSD7BGVQ0spu6KkX76P7gS6mwpjzUJTiw2t
         WtkdO0ctCTTKjbeOLVRAkZyXAzYgosuroHVTjaWoBxgQLwl15pfDWUqu3gp0tkTEUgJw
         jiKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=ygad+lK5vhzFqJkkHfbcTrJHteBumBoI/HXbq+cMlw8=;
        b=Q93pzuJaKdL4cjskpqx/LE33Cwj0SXa6fPQIxGEQbfryAbgZocyxjiEYoBj1cZ8v0W
         abysvg16eVzjB7ClrgJz0ogatS84N0ZyeMFFDVvQBt608xozQZ/fn/nsLstBKsahqRSg
         uat0s03kAQFOtRNpsLDzgQB2tjthX0kFyxK+2J9z0QTE8LEcdYXKv7cdABvb9cYzcb5k
         H+bQ7ukubHDr+w5TEqk8mSWDwr6d4UpFMoN2tm1VPypzfb90xzVM8yvqKumtF87Wra1N
         YFhMj3hvtJCUJ53RUJmeBDflKinBQOD2XcafiB0qf7LWysPm6PlvX5CbmMymSl7AyMvT
         qPQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 3si509837jaz.29.2019.03.28.22.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 22:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x2T5MY9A021796
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 29 Mar 2019 14:22:34 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2T5MYk2002617;
	Fri, 29 Mar 2019 14:22:34 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2T5MYgr026380;
	Fri, 29 Mar 2019 14:22:34 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-3804741; Fri, 29 Mar 2019 14:20:57 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Fri,
 29 Mar 2019 14:20:56 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.de>,
        "David Rientjes" <rientjes@google.com>, Alex Ghiti <alex@ghiti.fr>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>
Subject: Re: [PATCH REBASED] hugetlbfs: fix potential over/underflow setting
 node specific nr_hugepages
Thread-Topic: [PATCH REBASED] hugetlbfs: fix potential over/underflow
 setting node specific nr_hugepages
Thread-Index: AQHU5bJpwT7PIMyllUOstwX/Np6niKYhfBmA
Date: Fri, 29 Mar 2019 05:20:56 +0000
Message-ID: <20190329052055.GA32733@hori.linux.bs1.fc.nec.co.jp>
References: <20190328220533.19884-1-mike.kravetz@oracle.com>
In-Reply-To: <20190328220533.19884-1-mike.kravetz@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.148]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <100B784E0786CF49863E2D1C40235DF7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 03:05:33PM -0700, Mike Kravetz wrote:
> The number of node specific huge pages can be set via a file such as:
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
> When a node specific value is specified, the global number of huge
> pages must also be adjusted.  This adjustment is calculated as the
> specified node specific value + (global value - current node value).
> If the node specific value provided by the user is large enough, this
> calculation could overflow an unsigned long leading to a smaller
> than expected number of huge pages.
>=20
> To fix, check the calculation for overflow.  If overflow is detected,
> use ULONG_MAX as the requested value.  This is inline with the user
> request to allocate as many huge pages as possible.
>=20
> It was also noticed that the above calculation was done outside the
> hugetlb_lock.  Therefore, the values could be inconsistent and result
> in underflow.  To fix, the calculation is moved within the routine
> set_max_huge_pages() where the lock is held.
>=20
> In addition, the code in __nr_hugepages_store_common() which tries to
> handle the case of not being able to allocate a node mask would likely
> result in incorrect behavior.  Luckily, it is very unlikely we will
> ever take this path.  If we do, simply return ENOMEM.
>=20
> Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> This was sent upstream during 5.1 merge window, but dropped as it was
> based on an earlier version of Alex Ghiti's patch which was dropped.
> Now rebased on top of Alex Ghiti's "[PATCH v8 0/4] Fix free/allocation
> of runtime gigantic pages" series which was just added to mmotm.
>=20
>  mm/hugetlb.c | 41 ++++++++++++++++++++++++++++++++++-------
>  1 file changed, 34 insertions(+), 7 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index f3e84c1bef11..f79ae4e42159 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2287,13 +2287,33 @@ static int adjust_pool_surplus(struct hstate *h, =
nodemask_t *nodes_allowed,
>  }
> =20
>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pag=
es)
> -static int set_max_huge_pages(struct hstate *h, unsigned long count,
> +static int set_max_huge_pages(struct hstate *h, unsigned long count, int=
 nid,
>  			      nodemask_t *nodes_allowed)
>  {
>  	unsigned long min_count, ret;
> =20
>  	spin_lock(&hugetlb_lock);
> =20
> +	/*
> +	 * Check for a node specific request.
> +	 * Changing node specific huge page count may require a corresponding
> +	 * change to the global count.  In any case, the passed node mask
> +	 * (nodes_allowed) will restrict alloc/free to the specified node.
> +	 */
> +	if (nid !=3D NUMA_NO_NODE) {
> +		unsigned long old_count =3D count;
> +
> +		count +=3D h->nr_huge_pages - h->nr_huge_pages_node[nid];
> +		/*
> +		 * User may have specified a large count value which caused the
> +		 * above calculation to overflow.  In this case, they wanted
> +		 * to allocate as many huge pages as possible.  Set count to
> +		 * largest possible value to align with their intention.
> +		 */
> +		if (count < old_count)
> +			count =3D ULONG_MAX;
> +	}
> +
>  	/*
>  	 * Gigantic pages runtime allocation depend on the capability for large
>  	 * page range allocation.
> @@ -2445,15 +2465,22 @@ static ssize_t __nr_hugepages_store_common(bool o=
bey_mempolicy,
>  		}
>  	} else if (nodes_allowed) {
>  		/*
> -		 * per node hstate attribute: adjust count to global,
> -		 * but restrict alloc/free to the specified node.
> +		 * Node specific request.  count adjustment happens in
> +		 * set_max_huge_pages() after acquiring hugetlb_lock.
>  		 */
> -		count +=3D h->nr_huge_pages - h->nr_huge_pages_node[nid];
>  		init_nodemask_of_node(nodes_allowed, nid);
> -	} else
> -		nodes_allowed =3D &node_states[N_MEMORY];
> +	} else {
> +		/*
> +		 * Node specific request, but we could not allocate the few
> +		 * words required for a node mask.  We are unlikely to hit
> +		 * this condition.  Since we can not pass down the appropriate
> +		 * node mask, just return ENOMEM.
> +		 */
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> =20
> -	err =3D set_max_huge_pages(h, count, nodes_allowed);
> +	err =3D set_max_huge_pages(h, count, nid, nodes_allowed);
> =20
>  out:
>  	if (nodes_allowed !=3D &node_states[N_MEMORY])
> --=20
> 2.20.1
>=20
> =

