Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3110EC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E85172087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:05:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E85172087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E31E8E0002; Thu, 31 Jan 2019 06:05:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7903D8E0001; Thu, 31 Jan 2019 06:05:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680C28E0002; Thu, 31 Jan 2019 06:05:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27B208E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:05:05 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r16so1900733pgr.15
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:05:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=qqWmO8AI4KSGMfJaug0P2hvjji8QZYITlZwKDfpNZUs=;
        b=ejwUVD2uOfmmgDU24zpt3Ap7wXc8n0+ngaug5/BEeWhAS1eNYf1BZNePeX3IxiytXN
         c7udZDJ6CkhyEsNOUgIHLo9I+jpEsLIVLOr7APBcpQU4xQk2tNXUtDAt4HT8VAN7EBsO
         BBj/UroKvga3vb8TXfRbUVlzBKoGfFDK++7G4+zlPqzRgehc0afrIMaQhn5uqWWaFhhg
         +TGwKrClvxRPxt/n25qg8eNPAAn89s2uZ9AwYmO90BvyG8PJuz0A+1WxIIwei4S/274p
         74BoJQLkns5h94nyN4YhqfqpYyyDp6H2lfSiUY8gLhL4FQoTH+Oc31516P1DoXsagSLd
         skZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfHHugiHsxMDqVB630DyO8InQUl/riXrjC2fnBFcc5X8vPVH+TP
	fj+O85lq0nuzQlE7M5cUxm2auZtiYfZb8fmuBMGo+RrHAw75W0h3XDUU1Xp/XkLS8FQRIP0Ght+
	cl9nSwRCXYCVtR9BQTllmpd+fn/FJ53235+KnvziN8bCZgHiSzPe7GSEhm6A++S0DXA==
X-Received: by 2002:a17:902:bd4a:: with SMTP id b10mr34523922plx.232.1548932704801;
        Thu, 31 Jan 2019 03:05:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7mDEvBaSdwtKDO7anM3sXCMXfQiEGxzkTWryH2f4ip00RJZv5Iopwee/Hlt6l4lMFnkj7m
X-Received: by 2002:a17:902:bd4a:: with SMTP id b10mr34523867plx.232.1548932704035;
        Thu, 31 Jan 2019 03:05:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548932704; cv=none;
        d=google.com; s=arc-20160816;
        b=IurTFCvt5RfqfTegL0pVOU1OOEQC7qKYsdb4TT/HMJEzN8Ph1HRiVC3PIzJhVQp066
         sgCBfOF6gYYjWO/ktEDOwy1T34fiavaFHbx8RigIlV7EPdAkh+m9qWMzM9ovAbj7VRVp
         CdFHw5MVUwoGqTmXO7UFKp2RmUYLe0kL5XXFmo3QSxX23Ol0zf9XYzFCtlC0ZwoVeWZN
         kH6QvCg7n/FOHNugOyEkuZ+glyzVM5DmAYIxpe0tpGojxlDnKSutQjMcpuAy5muy95IJ
         DlZ26jgHOHvnL7ErQ4SsgsCfpCaLI+XCsr9AUZzRI3jgk4U6xlRciT2ZqTrThgBtQimp
         pjiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=qqWmO8AI4KSGMfJaug0P2hvjji8QZYITlZwKDfpNZUs=;
        b=uecbU14FpQqOlqIec9CGBZ32WM02rzeSBIWjcL7dlA2iwM8uyBCsKg0PgXliXTJ2Mg
         lJkxj2KInb3QHd36U54qLpzvMTSlFZ/Ap5oDNSJ47PPy9EtpfLJJtgu1jTSsIXlhBBSn
         rzfmsxR6u7OJqsPfMLlxtbGeiy3+kyzWUZGiaS6bRIgRIFav1TYcISKNRYeJQ/g2UbyW
         U/6vdkyJJskFu1KthzXF15jk3IXjZZv8JuDdeRb4NyV8nVrUXEAzd66OgithNQjARECJ
         ekzp6YRvHVrDNRD4jsH8/HVwDhC5pjSuRLfNp1gPomFcmtdo2rrNJdEYFyfXfIcL/Cjh
         egkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c4si4088041pfi.110.2019.01.31.03.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 03:05:04 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0VB0UZn125882
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:05:03 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qbwr5693n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:04:59 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 11:04:35 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 11:04:32 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0VB4VUE7537112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 11:04:31 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3EC2F11C05B;
	Thu, 31 Jan 2019 11:04:31 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BD04111C054;
	Thu, 31 Jan 2019 11:04:30 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 31 Jan 2019 11:04:30 +0000 (GMT)
Date: Thu, 31 Jan 2019 13:04:29 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] docs/core-api/mm: fix return value descriptions
References: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013111-0008-0000-0000-000002B94618
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013111-0009-0000-0000-000022254859
Message-Id: <20190131110428.GJ28876@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Any comments on these?

On Sun, Jan 20, 2019 at 02:01:34PM +0200, Mike Rapoport wrote:
> Many kernel-doc comments referenced by Documentation/core-api/mm-api.rst
> have the return value descriptions misformatted or lack it completely. This
> makes kernel-doc script unhappy and produces more than 100 warnings when
> running 
> 
> 	make htmldocs V=1
> 
> These patches fix the formatting of present return value descriptions and
> add some new ones.
> 
> Side note:
> ----------
> I've noticed that kernel-doc produces
> 
> 	warning: contents before sections
> 
> when it is parsing description of a function that has no parameters, but
> does have a return value, i.e.
> 
> 	unsigned long nr_free_buffer_pages(void)
> 
> As far as I can tell, the generated html is ok no matter if the detailed
> description present before 'the sections', so probably this warning is not
> really needed?
> 
> Mike Rapoport (3):
>   docs/mm: vmalloc: re-indent kernel-doc comemnts
>   docs/core-api/mm: fix user memory accessors formatting
>   docs/core-api/mm: fix return value descriptions in mm/
> 
>  arch/x86/include/asm/uaccess.h |  24 +--
>  arch/x86/lib/usercopy_32.c     |   8 +-
>  mm/dmapool.c                   |  13 +-
>  mm/filemap.c                   |  73 ++++++--
>  mm/memory.c                    |  26 ++-
>  mm/mempool.c                   |   8 +
>  mm/page-writeback.c            |  24 ++-
>  mm/page_alloc.c                |  24 ++-
>  mm/readahead.c                 |   2 +
>  mm/slab.c                      |  14 ++
>  mm/slab_common.c               |   6 +
>  mm/truncate.c                  |   6 +-
>  mm/util.c                      |  37 ++--
>  mm/vmalloc.c                   | 394 ++++++++++++++++++++++-------------------
>  14 files changed, 409 insertions(+), 250 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

