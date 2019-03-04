Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 941E7C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 06:01:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 482422082F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 06:01:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 482422082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3E808E0003; Mon,  4 Mar 2019 01:01:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEDA28E0001; Mon,  4 Mar 2019 01:01:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB6688E0003; Mon,  4 Mar 2019 01:01:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD8C8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 01:01:39 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id e1so3641209iog.0
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 22:01:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=56BSj3Cr9Eyx+lYa1Luq4GESpDGirxiWxD6UhjgUHVk=;
        b=obB9vFxvaBiIiGjLUu8rWTkwKFp78OpPQaVTYSRY4eZvPjkxcIwq45iL9VxhFiykFJ
         cC3ydQXFIxGbXzaonp983TF7YTWbxTGijUCua/HSs6ljA3QdKbKyaG5c8MRqZsqCARCW
         6sDeq23Pau8kdRwUEFN15SjYr9COWeenLShgqNRg2fHKB9xUTd1JVb8FdYO1ba3j88W3
         tHdidPuLNWgmOnqlRggUwGiptZE0LET+jP07CjAyhBa7bH089Vy+W8cGBLQxTsDHHWuO
         3SGq5VgZXhOJ+itgkL0YV+ERJwJKatm75lmpQSZG7wtXR6ikHwGJWPKJiIn0DVi0fUWe
         blvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWQ8IV1dcohTcLzzzmt4TTdbTfO/vTjHvJSoC2btA7pjpgOatRW
	lbQRYBIaVnTFDeEs1HnsogFc6gKzF7BvUavCG5VStR+APDtCwAM106nBxowAOjUuCzbWz8KHpfr
	5d/k40I+kBAp3V//HdrAQFblDBNLSezMhpQJwgL1pT68p2HM/25TUNSJOiD5Jl8nOrw==
X-Received: by 2002:a5e:de05:: with SMTP id e5mr5421856iok.111.1551679299334;
        Sun, 03 Mar 2019 22:01:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqxdiJ4wMh2FR6q4bB2J0cGvK2Bo+KGTutHtn53NPCGc3OM6+kpNgR1IVJLh91qiFjY9dUwx
X-Received: by 2002:a5e:de05:: with SMTP id e5mr5421809iok.111.1551679298176;
        Sun, 03 Mar 2019 22:01:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551679298; cv=none;
        d=google.com; s=arc-20160816;
        b=qZnxL9Dgppb3EoNczGz0slkQ9mjgesbNYs9YjbGLaom+HA8QFdEjBr3de5kZA1ZTab
         Mb0sYJ/ptwk4byBQAIVF6eMmxvww0ZzH8VxKDZIOQPEUW4ITEG5np4N4s5m3JSjfM2uw
         U6pc8ZXeIg/GuJsVnpCG9fqR4WKlSPLALMrSyF0/pguykqpVErTGQ8d1Ks04MMU0T6e9
         lUxZpOWBrJfu2Yu4DLm/u4nR2QG52+REs+BGIznKYXRVe+bFzqMSUHz2CiOIF3H/vVRr
         SjkY1htu3i8Yk03we0i4Je2EIxjvUstblBHH4qSUdro6IeJQV4moUMZQIIaTXpOfnqKN
         MglA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=56BSj3Cr9Eyx+lYa1Luq4GESpDGirxiWxD6UhjgUHVk=;
        b=ZYa//ndy4IWHqFoENuyNrWtOVM/5g6q+QX5Kf4N6/OBG3NU4eOJk3iWbPfdxT/IkY7
         yWmSlSQKwaIscP/xaySjxuWUSYNrPe+xxOTkkg9vMlNdW8iwJmS+WqcvwQKbNk1seZjq
         aC4HpJJV8r6bMKcjYAbyqBE5RqWGru+OiseebcDd8GZQySdZs+sPsTffM3Dc/sgy9pcv
         me5iL8Hq/nwpHIH8Nyf0K9BW4xydvrikgRl7LYIbefpepfUWcT3FpZtxhXgNQfFM08IU
         5WMX7cORWu+YgSUJ4tBhRcdd0bPSrimdxkXSD4iBZXtuCqxv7Zx7jmiRXuPSOcxYTlV+
         xZaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id d17si2577206itd.130.2019.03.03.22.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 22:01:38 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x2461M5a024438
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 4 Mar 2019 15:01:22 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2461MuS007092;
	Mon, 4 Mar 2019 15:01:22 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x245tpSt008051;
	Mon, 4 Mar 2019 15:01:22 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.151] [10.38.151.151]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-2987327; Mon, 4 Mar 2019 15:00:25 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC23GP.gisp.nec.co.jp ([10.38.151.151]) with mapi id 14.03.0319.002; Mon, 4
 Mar 2019 15:00:23 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: David Rientjes <rientjes@google.com>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "hughd@google.com" <hughd@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "Andrea Arcangeli" <aarcange@redhat.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Thread-Topic: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Thread-Index: AQHUzKNmJ08QFadITkadXECqBzMSPaXvQTOAgADisACAABkvAIAAEDUAgAB2wwCAAEK9AIAA3REAgAiLHgA=
Date: Mon, 4 Mar 2019 06:00:23 +0000
Message-ID: <20190304060024.GA26610@hori.linux.bs1.fc.nec.co.jp>
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
 <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
 <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
In-Reply-To: <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DF7354B168D1794AA4B3582797AC467F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 11:32:24AM -0800, Mike Kravetz wrote:
> On 2/25/19 10:21 PM, David Rientjes wrote:
> > On Tue, 26 Feb 2019, Jing Xiangfeng wrote:
> >> On 2019/2/26 3:17, David Rientjes wrote:
> >>> On Mon, 25 Feb 2019, Mike Kravetz wrote:
> >>>
> >>>> Ok, what about just moving the calculation/check inside the lock as =
in the
> >>>> untested patch below?
> >>>>
> >>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>=20
> <snip>
>=20
> >>>
> >>> Looks good; Jing, could you test that this fixes your case?
> >>
> >> Yes, I have tested this patch, it can also fix my case.
> >=20
> > Great!
> >=20
> > Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> > Tested-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> > Acked-by: David Rientjes <rientjes@google.com>
>=20
> Thanks Jing and David!
>=20
> Here is the patch with an updated commit message and above tags:
>=20
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Tue, 26 Feb 2019 10:43:24 -0800
> Subject: [PATCH] hugetlbfs: fix potential over/underflow setting node spe=
cific
> nr_hugepages
>=20
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
> in underflow.  To fix, the calculation is moved to within the routine
> set_max_huge_pages() where the lock is held.
>=20
> Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Tested-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> Acked-by: David Rientjes <rientjes@google.com>

Looks good to me with improved comments.
Thanks everyone.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hugetlb.c | 34 ++++++++++++++++++++++++++--------
>  1 file changed, 26 insertions(+), 8 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index b37e3100b7cc..a7e4223d2df5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
> nodemask_t *nodes_allowed,
>  }
>=20
>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pag=
es)
> -static int set_max_huge_pages(struct hstate *h, unsigned long count,
> +static int set_max_huge_pages(struct hstate *h, unsigned long count, int=
 nid,
>  						nodemask_t *nodes_allowed)
>  {
>  	unsigned long min_count, ret;
> @@ -2289,6 +2289,23 @@ static int set_max_huge_pages(struct hstate *h, un=
signed
> long count,
>  		goto decrease_pool;
>  	}
>=20
> +	spin_lock(&hugetlb_lock);
> +
> +	/*
> +	 * Check for a node specific request.  Adjust global count, but
> +	 * restrict alloc/free to the specified node.
> +	 */
> +	if (nid !=3D NUMA_NO_NODE) {
> +		unsigned long old_count =3D count;
> +		count +=3D h->nr_huge_pages - h->nr_huge_pages_node[nid];
> +		/*
> +		 * If user specified count causes overflow, set to
> +		 * largest possible value.
> +		 */
> +		if (count < old_count)
> +			count =3D ULONG_MAX;
> +	}
> +
>  	/*
>  	 * Increase the pool size
>  	 * First take pages out of surplus state.  Then make up the
> @@ -2300,7 +2317,6 @@ static int set_max_huge_pages(struct hstate *h, uns=
igned
> long count,
>  	 * pool might be one hugepage larger than it needs to be, but
>  	 * within all the constraints specified by the sysctls.
>  	 */
> -	spin_lock(&hugetlb_lock);
>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
>  		if (!adjust_pool_surplus(h, nodes_allowed, -1))
>  			break;
> @@ -2421,16 +2437,18 @@ static ssize_t __nr_hugepages_store_common(bool
> obey_mempolicy,
>  			nodes_allowed =3D &node_states[N_MEMORY];
>  		}
>  	} else if (nodes_allowed) {
> +		/* Node specific request */
> +		init_nodemask_of_node(nodes_allowed, nid);
> +	} else {
>  		/*
> -		 * per node hstate attribute: adjust count to global,
> -		 * but restrict alloc/free to the specified node.
> +		 * Node specific request, but we could not allocate
> +		 * node mask.  Pass in ALL nodes, and clear nid.
>  		 */
> -		count +=3D h->nr_huge_pages - h->nr_huge_pages_node[nid];
> -		init_nodemask_of_node(nodes_allowed, nid);
> -	} else
> +		nid =3D NUMA_NO_NODE;
>  		nodes_allowed =3D &node_states[N_MEMORY];
> +	}
>=20
> -	err =3D set_max_huge_pages(h, count, nodes_allowed);
> +	err =3D set_max_huge_pages(h, count, nid, nodes_allowed);
>  	if (err)
>  		goto out;
>=20
> --=20
> 2.17.2
>=20
> =

