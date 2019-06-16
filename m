Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F302AC31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 06:07:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1F792133D
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 06:07:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1F792133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 497236B0007; Sun, 16 Jun 2019 02:07:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4214B6B0008; Sun, 16 Jun 2019 02:07:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C1EE8E0001; Sun, 16 Jun 2019 02:07:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E89366B0007
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 02:07:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x3so5197248pgp.8
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 23:07:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=dGjhz4aQzyD59eRLNizOYahJSu+PAkI6ueO7uaOQLME=;
        b=npwrQKx7VyitbdGEWkGiryFHf7WHwAXKHdDy4EI8mCEGAKIvsWE7uMcgWBx1950zNt
         I14RztnNNhZo7ByNNa6ZHqSnr4x9TceiVF/xjGA8MOPbCjZOfUFgc2ZUThx56Xmb9WLl
         ue64DcY8P3L/iK4Rf3aW632sPzM+nZxB//krdXHXru0FS8f+jm2KhDVyxDPfUhnADK4j
         il0dJLXxo6d+mToKGG1WEJ7j2ZOstxDF6xxYpjKWB4CyIrFmJgbq3aT2tEP7yLXAYiJv
         +y8whs+62dTtTaEmQ/76daEF4zS3vjOECH2Y+iW7IOfvSfaJ/X2u5KlUNs5x1DtOKBWt
         M6JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXE4d4v703heZ5dodJHc59fGltyWi0XnH+BvFEJW1mWxGpPGpvi
	C/tnTBQfk8Cs/z7gYng6aenvWEYSzenrvqxIpnFUOVNsBdKMotDISOvyseBeser9so+23AJaDiz
	YHx+P0pSFmSmSRIaruJt0mLBoAuGorexNdP3Isfx33ZgYB6y9Z5tncnyyQJDRi3paJQ==
X-Received: by 2002:a17:90a:af8b:: with SMTP id w11mr19675434pjq.135.1560665232627;
        Sat, 15 Jun 2019 23:07:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxT5qA6INXS0XrZ72J3rEXxtwjPaBU6fZ+uMt3XXLycEV9GvownggnHxoFpBYGEXDIIkl5u
X-Received: by 2002:a17:90a:af8b:: with SMTP id w11mr19675394pjq.135.1560665231823;
        Sat, 15 Jun 2019 23:07:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560665231; cv=none;
        d=google.com; s=arc-20160816;
        b=btqj3blLXsXzgFYQeQhvgdmqce66dX2H7iKWE52loTbvV06MjI21wl21UxATwQXB4n
         jtZb2HvRbO0MY0NdvuR9drbGZB7j4HPaLtenbzHpytyY4SE7DEWgTeMkrleLGKe/DbSY
         vbPaJl0gcVagsw5lEvBjMlrLtZ8lceuGc+dnzw+mGBBcoAgOV1oXyNC/nVbejbtF88ag
         sAEHeyci67IpcTmZwuHBf3oCvnEDqiNwmIhaTBMu7XbLeTRp7Qpni7SJIPUSLydybwus
         kMgBt3kOnxXlZFV70v2qKA1V2yVur/3chjFHL1/EkcQsruw9Yvw19Ue3e+AFieMs2gDv
         YM2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=dGjhz4aQzyD59eRLNizOYahJSu+PAkI6ueO7uaOQLME=;
        b=FP7XviXJEvK1xhoHzQKYyi8ky6NV+uCSZDGa0dOyxphxOd0iI4LUc6iEyEb/vgOQnp
         yvBLFePjNYaN596C/wod3tfk7f7mhnsfplOJiT7t8CvlZorutLgp0YTucAAwBLhHSkAz
         Oa2fkPAok7QWDAajYVB9d2L9d/h33V0x0McUwrklLzRycPs004iw9euaAvuIbZYKZ2FO
         uQEae6sc6Rd4JRWuyjF/qua6yZPMw9XtuH00moJEra5jQ1Q/Y3d67fln6FvcA6BXptEf
         QBJxI1CY2S+vACbR0bHlMtYt2DPl93NyfTrBQHGoLisWrwpHmUMSJR5HBKMOTaLvUWlK
         hoUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w11si6518547pjq.17.2019.06.15.23.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 23:07:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5G679O0127136
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 02:07:11 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t5e6wjvue-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 02:07:10 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sun, 16 Jun 2019 07:06:56 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 16 Jun 2019 07:06:53 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5G66qk146596116
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 16 Jun 2019 06:06:52 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6DDACAE04D;
	Sun, 16 Jun 2019 06:06:52 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 12D30AE045;
	Sun, 16 Jun 2019 06:06:50 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.86.48])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun, 16 Jun 2019 06:06:49 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>,
        Oscar Salvador <osalvador@suse.de>,
        Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
        linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
        osalvador@suse.de, mhocko@suse.com
Subject: Re: [PATCH v9 04/12] mm/sparsemem: Convert kmalloc_section_memmap() to populate_section_memmap()
In-Reply-To: <155977189139.2443951.460884430946346998.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com> <155977189139.2443951.460884430946346998.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Sun, 16 Jun 2019 11:36:47 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061606-0008-0000-0000-000002F42096
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061606-0009-0000-0000-000022612EA1
Message-Id: <8736kahxmw.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-16_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906160060
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> Allow sub-section sized ranges to be added to the memmap.
> populate_section_memmap() takes an explict pfn range rather than
> assuming a full section, and those parameters are plumbed all the way
> through to vmmemap_populate(). There should be no sub-section usage in
> current deployments. New warnings are added to clarify which memmap
> allocation paths are sub-section capable.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/mm/init_64.c |    4 ++-
>  include/linux/mm.h    |    4 ++-
>  mm/sparse-vmemmap.c   |   21 +++++++++++------
>  mm/sparse.c           |   61 +++++++++++++++++++++++++++++++------------------
>  4 files changed, 57 insertions(+), 33 deletions(-)
>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 8335ac6e1112..688fb0687e55 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1520,7 +1520,9 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>  {
>  	int err;
>  
> -	if (boot_cpu_has(X86_FEATURE_PSE))
> +	if (end - start < PAGES_PER_SECTION * sizeof(struct page))
> +		err = vmemmap_populate_basepages(start, end, node);
> +	else if (boot_cpu_has(X86_FEATURE_PSE))
>  		err = vmemmap_populate_hugepages(start, end, node, altmap);
>  	else if (altmap) {
>  		pr_err_once("%s: no cpu support for altmap allocations\n",

Can we move this to another patch? I am wondering what the x86 behaviour
here is? If the range is less that PAGES_PER_SECTION we don't allow to
use pmem as the map device? We sliently use memory range?

-aneesh

