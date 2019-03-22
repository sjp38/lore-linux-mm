Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85999C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:37:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4617821900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:37:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4617821900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8CFB6B0005; Fri, 22 Mar 2019 17:37:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3ACF6B0006; Fri, 22 Mar 2019 17:37:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29846B0007; Fri, 22 Mar 2019 17:37:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72DD26B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:37:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d128so3300083pgc.8
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:37:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Nt6OLgA21xckIOP7JrNY8nLH45Ad911pKdHaT6wP1rw=;
        b=kFsViSfbkUQMvf51KO5U8dv6iejkRvPEbjO99Qlc57OD419nb6QeyDErxWFuQ5CLPI
         uAtc4zzklW56QAopZqIBQBA+JCAr1AupBiBPjQ8uPuQ5u+/9FXC/O8hzik3JM4S1qy+9
         6JGDntZlor0IiPSQ0MaHmzHXf5KHrElL10boQo3YgTaDu9B12TNcgj3HKCnKD51qt1Hb
         aZeB6Av79812FWONZnZrBNkEUIFLZU8TmSlm7D7JWq/i/xFHCwYlM7ZU2/lV4tzr3d+g
         Whii8FRx9Y/0+4V6uticzM+CWTKIXVC+iJg9i8CLvhsKKQSRN23JIHrgad4EjbEbdH26
         mrWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUOM8s+QC+pOnX0p5PudYx9Sy+uyFe7v0OOwhEhM/SkAL4uvU0i
	giSqZgXytlkd/m8KUHAHRWH2iTkwSxPI69MHQykUrft2IAbEg1cESLbqtHvq+7gdFyPzG0d2kTI
	6NXZERF1yTufHsPyiVQCKI3PiHkLQplLuvfwdnMGejdkd+G5tJofeaWBbx3un7b2vfw==
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr11886607plp.165.1553290654122;
        Fri, 22 Mar 2019 14:37:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweHOd3PEJnwMGH360/hAvAZoZLt9SLcwE9A++rdado2JtgufN7IrZgy4W38JFYWCCQISMZ
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr11886574plp.165.1553290653475;
        Fri, 22 Mar 2019 14:37:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553290653; cv=none;
        d=google.com; s=arc-20160816;
        b=Fri1MRPcZdCXHwKaAPfDSS09Oj3PGhJ7Pej5PXot4a3V3fNDgCRXXMmO5yAKBPQZBP
         uWzPGmfqxVRw7VN4H9OxixtDqNq7M+rM2JSmosjPzBnDJStgVl1SvsvfkqhDehGOtKXX
         jBYFM+pC/7BgqA4F4PnHjVusq6fbQOLn+pBhgB5VrdOQaRKvbIoWVYWa3xxOawYIq0o9
         PQKwBiyKCkgX2LKKPmzDoQzRkGEqL6WzFXueH1/kOgKeJfeY8ni7ai+StsfUSUfC22Wd
         mA+2t5AQF2QqHHvtBpmC5QADtfBRw0wyM57vniNxwbsKOjXfBRjFVXiENsZbqmbpnP9V
         9J/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Nt6OLgA21xckIOP7JrNY8nLH45Ad911pKdHaT6wP1rw=;
        b=PJ1xXXCs2PNe4YVJzD2Czq8DtHm/7V8Vhe0YknG3SLU+VtG1bk4RdJCRAvM6i2ViP1
         HjL0tUAKAHESvYCSbJfvzO2ASo3nzSs/SBSJesQiGQ4HprGTSR8iyoj2otiJpG5NnFSJ
         muFeDg/s3pRdbIFM1965mWKQiQtRndTPFAnZgAKhkzXZZzq34HHH+3CYUDRIeSzZX9jW
         17BIE/o3mU/nfev2ZwDnFh2L9LPLpapOYoBOv2cPefdlhdQfvgFbXXUXuMslg+xhzBy6
         cAqDaNfr3IJjeHYFlDW7g4NMklnceF5SuyansaVrYBX0qAM05WjBCS+bk9QnVmrYe2nl
         4Wiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o18si7550285pgh.403.2019.03.22.14.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 14:37:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MLUvaj024303
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:37:33 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rd7dsgmwm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:37:32 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 22 Mar 2019 21:37:21 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 22 Mar 2019 21:37:15 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2MLbNnN33554594
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Mar 2019 21:37:23 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 44001A4051;
	Fri, 22 Mar 2019 21:37:23 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5FFE7A4040;
	Fri, 22 Mar 2019 21:37:21 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.23])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri, 22 Mar 2019 21:37:21 +0000 (GMT)
Date: Fri, 22 Mar 2019 23:37:19 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v3 22/28] userfaultfd: wp: enabled write protection in
 userfaultfd API
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-23-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320020642.4000-23-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032221-4275-0000-0000-0000031E35EE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032221-4276-0000-0000-0000382CC33B
Message-Id: <20190322213719.GB9303@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=966 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903220152
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:36AM +0800, Peter Xu wrote:
> From: Shaohua Li <shli@fb.com>
> 
> Now it's safe to enable write protection in userfaultfd API
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/uapi/linux/userfaultfd.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 95c4a160e5f8..e7e98bde221f 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -19,7 +19,8 @@
>   * means the userland is reading).
>   */
>  #define UFFD_API ((__u64)0xAA)
> -#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
> +#define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP |	\
> +			   UFFD_FEATURE_EVENT_FORK |		\
>  			   UFFD_FEATURE_EVENT_REMAP |		\
>  			   UFFD_FEATURE_EVENT_REMOVE |	\
>  			   UFFD_FEATURE_EVENT_UNMAP |		\
> @@ -34,7 +35,8 @@
>  #define UFFD_API_RANGE_IOCTLS			\
>  	((__u64)1 << _UFFDIO_WAKE |		\
>  	 (__u64)1 << _UFFDIO_COPY |		\
> -	 (__u64)1 << _UFFDIO_ZEROPAGE)
> +	 (__u64)1 << _UFFDIO_ZEROPAGE |		\
> +	 (__u64)1 << _UFFDIO_WRITEPROTECT)
>  #define UFFD_API_RANGE_IOCTLS_BASIC		\
>  	((__u64)1 << _UFFDIO_WAKE |		\
>  	 (__u64)1 << _UFFDIO_COPY)
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

