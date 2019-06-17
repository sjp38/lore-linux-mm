Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74C73C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:52:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DB9720657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:52:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DB9720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C74E48E0003; Mon, 17 Jun 2019 02:52:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4B9B8E0001; Mon, 17 Jun 2019 02:52:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13BA8E0003; Mon, 17 Jun 2019 02:52:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 774838E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:52:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so6499620pfj.4
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:52:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=t+oEk6kgcIIjVu49KhrQu7ca9DlCqLRLN03XXZ7Dy1I=;
        b=MfQIhBp0yblQHnhr7jOmEkFV4mzhLSLAAJbCvF9GH7tkxR4nON6gE7TYf/CVCoKG1d
         pvIvSV0gL4wt7J5ewj5yaPnH52qeSUafWJw7fmVxK8mqpjgzUjfZ6ytBBGmxXkTfpzgP
         OLXWPp1+P1snoX3S1iYrRHK3fnEtXh3DjG1xyA1qlp7l7ixMf1Q87XyIH26kHV/jCYuL
         Dq449pufSuT0QdgN2aamoqQl+Zibfs4HHmMXtZaJ7/ta139x34AsuvVBnZk8VPiWg4L9
         pNHUxVkdp0yY4oM5qlbsuabUf5ELFOul7YFIyTE0YcOILjKvhcdVU9vMQf7hkK9czdBY
         woTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWmCOKs3SpSC+WUIjMWywUb7TAz4i4fKRmeyQIwX23zqcMTqinI
	U/ozBxW/r5jaQR/4za4evlcAdVi4wkq9Z4WKS4LAWQe/NA8md1mVyBMMxaME8fo+MLSx309aFiQ
	t0r7uXIQvNR7Seo5Ut6I1SxqK8JRXgfOmiBvVIKJjPjFlR3ESJXwBuKIdP4g/MUdUBg==
X-Received: by 2002:a17:90a:ae02:: with SMTP id t2mr24901549pjq.41.1560754367187;
        Sun, 16 Jun 2019 23:52:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/3Jsme04kte0SeIcVBSwa7Nnlh86tYH9YVtgrNoP6IjbMy4bXFqCl2taDfL3XxK5jl+ox
X-Received: by 2002:a17:90a:ae02:: with SMTP id t2mr24901501pjq.41.1560754366614;
        Sun, 16 Jun 2019 23:52:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754366; cv=none;
        d=google.com; s=arc-20160816;
        b=u9V8eV9k9iqM1DlWNqfJb5TMHxK0X6OZRb23BAnw4QsEkCx6bEEQ20If1O+WOLtPiZ
         8GSTHJPA0Tc/iynpQVKaaok0EXy1oIPqTShVE6aaWhjgCmE0OPt6t3uPOh8uAHjjvvoA
         410N7u/efba5kh50lhubUrI+pG0e53fq38ejgVKBcAfRxtTH6TyDBpzKkl9An1DKg72c
         gsSD4b6tFaCmT6OfhdBLUqoiioXmkNm1kpuZBLEV1CdpvKydGGm6sN2E/V5BuJuNTiLz
         MpRhMuWQMvaad4lPg+IjNBe6wfx/APJ01WW2MXLwY4txaKOFPVKx8npnz/sNwv+PQlWn
         IQKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=t+oEk6kgcIIjVu49KhrQu7ca9DlCqLRLN03XXZ7Dy1I=;
        b=DidzJszVFCu6g+GVVqzddCpuTuobXYPZHaovx0TAcgHkjnNrmgdABdR5TYftl6Wvgs
         UyxCegeNEvTVr0Y2zWQcFpPWxywN7o1eDr+EvM7I1YiV4Ck5KiAAo5Mx7H0tBFlFv6M1
         E4KcZqgTLrqNzOfiETNLJVDt6BBCcFi+0GdXE+fzUk2THQgv1dUkN0cxX756b4B/1VsN
         axfYJnR6dWDYNT06DCmjfXeWTcruHc4xpNXrXs9wh9TxgPj4Gtd825SVwF2Ov+K3TFjg
         f2OEFGbNJZG++pzF9Knijf1YgTCIeF9UqfeGUhXqgDzXosk4GXIOW4t+lMkdVHDHsIx8
         OW8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 18si8388647pgw.101.2019.06.16.23.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 23:52:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H6qYTr004755
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:52:46 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t64b33nrr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:52:45 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 17 Jun 2019 07:52:43 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 07:52:36 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H6qZ7b49610972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 06:52:35 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 40BD8A4065;
	Mon, 17 Jun 2019 06:52:35 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 91E37A4064;
	Mon, 17 Jun 2019 06:52:33 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 17 Jun 2019 06:52:33 +0000 (GMT)
Date: Mon, 17 Jun 2019 09:52:31 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Alastair D'Silva" <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>,
        Mukesh Ojha <mojha@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] mm: Don't manually decrement num_poisoned_pages
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-4-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617043635.13201-4-alastair@au1.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061706-0028-0000-0000-0000037AE672
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061706-0029-0000-0000-0000243AE904
Message-Id: <20190617065231.GC16810@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170064
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:36:29PM +1000, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> Use the function written to do it instead.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/sparse.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 66a99da9b11b..e2402937efe4 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -11,6 +11,8 @@
>  #include <linux/export.h>
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> 
>  #include "internal.h"
>  #include <asm/dma.h>
> @@ -771,7 +773,7 @@ static void clear_hwpoisoned_pages(struct page *memmap,
> 
>  	for (i = map_offset; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
> -			atomic_long_sub(1, &num_poisoned_pages);
> +			num_poisoned_pages_dec();
>  			ClearPageHWPoison(&memmap[i]);
>  		}
>  	}
> -- 
> 2.21.0
> 

-- 
Sincerely yours,
Mike.

