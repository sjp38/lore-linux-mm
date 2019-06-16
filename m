Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAB47C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 07:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 744AD2133D
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 07:49:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 744AD2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC2F88E0002; Sun, 16 Jun 2019 03:49:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D277F8E0001; Sun, 16 Jun 2019 03:49:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEC978E0002; Sun, 16 Jun 2019 03:49:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 934AC8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 03:49:48 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b75so8340454ywh.8
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 00:49:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version
         :content-transfer-encoding:message-id;
        bh=s8EIb+SBgo+u5tnpcL0LRXguJHl3+T8lXUG9FR3Aha4=;
        b=O/e7meElHOoPcRIE/XeW1tUAsdsdquOtVqLHYjfViGgjI8Hx46MW9w2LzErFQ3JyJ7
         zcar85Js5VtrjL2IxwaNO8yHBNvw3UT4KqBpdf1ygFN4MO7g/14Hx5bvphK0PPVtDeZs
         U8w+0UXjE0MeX9GZQrir1f6gM6JP8NbSWu6v1ozcucW+BA1b/Js9xMw5IDMJNeXX76aw
         6n9s5D12XLyAicxmqi9GiFIwIXuY0YzOF7ksbZnyM+SZFpjC8PVZqH9sKnopDa5CsawK
         9xF7e76WTwTwizavtp1HXIVvHuShJQuTrhYsxGg0jXN47up9zGKcmY+QWIY+i0wrO3mP
         xHOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW8Yw9V2UhZuq+3Me/JijOosVdGPECJ3QlTwWgF1OQxYrZDyyuG
	yt2FDRRHcZbMeadRwX1UToLez+/1xJ432h9D5YKAEkI+cieDZevJ11oeg9EqVzONFo/yktqEcOl
	yJKq/NZdFChQbE3sf1Fnr8d0oQbweiwvCDXJhuEYce1mRBmnuXsThVQ2fPendhTfXcQ==
X-Received: by 2002:a25:458:: with SMTP id 85mr51771991ybe.167.1560671388353;
        Sun, 16 Jun 2019 00:49:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxH6pt3FkPrAmrxXpj3y/TRz6T4gLPRXkpl5229eW12B52xpWVO2CunkyJIoulxAmG1+oV
X-Received: by 2002:a25:458:: with SMTP id 85mr51771981ybe.167.1560671387545;
        Sun, 16 Jun 2019 00:49:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560671387; cv=none;
        d=google.com; s=arc-20160816;
        b=ID2TS3lozOkgfhULb/+dVP8rQUZgXZfAMvHuosPU72GKG0/dWOlFniYUv2nRW0f0Vw
         JKO+0KuJ6DQYjUvIoca8T8XbZDRL8YcuS2VpP4UWPv6ik6nN+4rkJJ76xi/nbK50Ujrg
         QHipWNWmCUAKlLe0GlVDEXZRnXuLKpV8CdxoZy/uzSMLM0LLeu9AcRhoKZ4vquAsGast
         IeBxk+CpxlUu3wLlVBrlRtSu/RtVlEXA7VmjqykmH9CHLfNOqqcP9nuPrv7DvR/mQoy/
         LbZ0wAZsG0bb8FwhwYcCRYzPLvf/H+Kny4bx/FfeQ6IPRLPH5byORAGcfUC8USXbQRu/
         dWZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:references
         :in-reply-to:subject:cc:to:from;
        bh=s8EIb+SBgo+u5tnpcL0LRXguJHl3+T8lXUG9FR3Aha4=;
        b=YZOUgKRetKdFmeSFXZR1xpkE59XGPQ9fGYdpT4sc6CGykLr9A62qqiTIBgHAThY49s
         DAnXsH1vme9HweaGY4fQVRJYTHNj+cWrAISm3EU5Lw5NCjPf5Gk579u70bxwNNrfmwP6
         kjZDF5oCnyvUaY1aQ9zpRz5Y1RxPPoJaQoLRDtwWtzXpcjw+Jws3iavUN2ZrauuFTTNQ
         6C/xCwouvc6yFy4tCsrTT2rdt1aACvl1f57ky7+VYI2vyATCanrU7oFEcNyhgkFKk7wL
         YZmtJPqdMgll2kBUiJlZ9L6Ec1WEvbP9SC5D4ZY6WOD7cErMY9ruuMmgeedP+Qmhk4kC
         qWkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a130si2854083ybb.140.2019.06.16.00.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 00:49:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5G7l1Cw127851
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 03:49:47 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t5dwxdgrx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 03:49:46 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sun, 16 Jun 2019 08:49:45 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 16 Jun 2019 08:49:41 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5G7nerW29622376
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 16 Jun 2019 07:49:40 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8D64F4C04E;
	Sun, 16 Jun 2019 07:49:40 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6FD194C046;
	Sun, 16 Jun 2019 07:49:38 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.86.48])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun, 16 Jun 2019 07:49:38 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: mhocko@suse.com, Pavel Tatashin <pasha.tatashin@soleen.com>,
        linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org,
        =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
        osalvador@suse.de
Subject: Re: [PATCH v9 10/12] mm/devm_memremap_pages: Enable sub-section remap
In-Reply-To: <155977193326.2443951.14201009973429527491.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com> <155977193326.2443951.14201009973429527491.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Sun, 16 Jun 2019 13:19:36 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-TM-AS-GCONF: 00
x-cbid: 19061607-0020-0000-0000-0000034A7E9E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061607-0021-0000-0000-0000219DBFAE
Message-Id: <87zhmigeb3.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-16_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906160076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> Teach devm_memremap_pages() about the new sub-section capabilities of
> arch_{add,remove}_memory(). Effectively, just replace all usage of
> align_start, align_end, and align_size with res->start, res->end, and
> resource_size(res). The existing sanity check will still make sure that
> the two separate remap attempts do not collide within a sub-section (2MB
> on x86).
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  kernel/memremap.c |   61 +++++++++++++++++++++--------------------------=
------
>  1 file changed, 24 insertions(+), 37 deletions(-)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 57980ed4e571..a0e5f6b91b04 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -58,7 +58,7 @@ static unsigned long pfn_first(struct dev_pagemap *pgma=
p)
>  	struct vmem_altmap *altmap =3D &pgmap->altmap;
>  	unsigned long pfn;
>=20=20
> -	pfn =3D res->start >> PAGE_SHIFT;
> +	pfn =3D PHYS_PFN(res->start);
>  	if (pgmap->altmap_valid)
>  		pfn +=3D vmem_altmap_offset(altmap);
>  	return pfn;
> @@ -86,7 +86,6 @@ static void devm_memremap_pages_release(void *data)
>  	struct dev_pagemap *pgmap =3D data;
>  	struct device *dev =3D pgmap->dev;
>  	struct resource *res =3D &pgmap->res;
> -	resource_size_t align_start, align_size;
>  	unsigned long pfn;
>  	int nid;
>=20=20
> @@ -96,25 +95,21 @@ static void devm_memremap_pages_release(void *data)
>  	pgmap->cleanup(pgmap->ref);
>=20=20
>  	/* pages are dead and unused, undo the arch mapping */
> -	align_start =3D res->start & ~(PA_SECTION_SIZE - 1);
> -	align_size =3D ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
> -		- align_start;
> -
> -	nid =3D page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
> +	nid =3D page_to_nid(pfn_to_page(PHYS_PFN(res->start)));

Why do we not require to align things to subsection size now?=20

-aneesh

