Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32DA8C282CB
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 08:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D139220818
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 08:59:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D139220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C9FB8E00B1; Sat,  9 Feb 2019 03:59:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278E38E00AA; Sat,  9 Feb 2019 03:59:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 142978E00B1; Sat,  9 Feb 2019 03:59:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C48678E00AA
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 03:59:52 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b4so3793166plb.9
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 00:59:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=yO8myC2QFTTOZ+7iHdNkQ4xZnsZVMa90Y0Tgs8lXpqc=;
        b=nHeWv6fS/L6QY2T6QESbszfmKpKtcRsFGjuABvXslZx1QvfYnp+Q6Jb+Zro5K87poc
         UHv9tvHGPkyGuLD/OyJ6py9eSu6U3SdSbO5sY7QIpveP9Bx/HdGE+O9V9s6nlEakED+A
         0Pq/hWYrcccBrKa/HP1M0ihNtEooTAoCkGB9d7TXW13ikgUCe9Uj+Nbl/S9C9Q2xhpqY
         lSEDMaVXFuvAuGllTJcbi/G4IPuqrHcAzvEHE5WZvjZ1ju5z85j25L8LoPPN/5WNxfDF
         JcmhMQ1me/p7HC5k62NAu1oIyz5pGDuHKdYeDzWL/Z1p+DXN5zNUJSj8IwPN9EFGWIYW
         jSSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaNHHOCXgbPJxr6gWuYlQBzBao5mYgkObjgefCv3tUXl0/6MitC
	usNrqPqSDAl2OZ3scPjFF9qKozmpaMROy+S5G8P8NoqLAosZlToI2pPKUErGkHV4sb73mGqrgJG
	CkKOklqOPQXUQqmXBLsznESg1MwXgIy5f8T1Fc7Ad0VoOwebIXB2Xzj2guPw9CGQO+A==
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr27536096pla.138.1549702792275;
        Sat, 09 Feb 2019 00:59:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ52fH/ibjwgsFrA5fLAaUWEXdfS3Tqoy4YEjXLgt2VsxTsSA1+vugxs8VKr9s4+8vVOUiz
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr27536063pla.138.1549702791473;
        Sat, 09 Feb 2019 00:59:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549702791; cv=none;
        d=google.com; s=arc-20160816;
        b=xGq/1wgyBhTxUbrvzBr/KJNWpRjKxf6aOcUVfrNZ9GG/TvcwVdQDsM2RO5OJ1AMuHU
         j2c70Y924S0ar8QbvzoD8SyG5hBPzlt9Z6lNdkPbG3409ZVwtkF5Eejy0fg7PA0cXO1q
         uKyH1qfhBoLfJwD6D4NUEG7tr3ju8mjobxnMj81akMX/0YVXOPyiPdX8af/iFaHRgNzk
         +XcgWRJZJuONTK+w/D362eLbAqGjLG0qPkuLFJ4DN4DRRrlXtr0mTI8l3OvcHfSLvIKJ
         LQ79y/uHDlkbazDGZ/NxXGFk8w169lDJ5RqaI1xguDUPf5CTigo27Bq8icWWehfPUo8h
         OTOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=yO8myC2QFTTOZ+7iHdNkQ4xZnsZVMa90Y0Tgs8lXpqc=;
        b=l/4g1Hv5MGMmTanCGcyn5Tt9M2RLOJHGa7IEcSowdtJDqtegywgJwJ0WyWHE6nKduL
         dBJSw8+rJOf5O8StC7E8/KyTM0gm5AboUfcWK6k+6qiqp/zELiqzN8WIBi5ZuyOX0k3k
         rSUTICd3FVuFoNoJidFdB3VfdJ2NJ4bLHOmtQMHB9uTmwseVC6w9M4goX9+WA0R3so35
         A/x57sXxKAyyZCd+MOPUJjp6G74ieV1FON/nz+FTKSEB7S5vFz+ejdaHwzs5T13hNhfC
         IZRftWGmGAveJ58u5acpJZiZt1Suv6QDAHMrwPbgrAPMCzKQ3xNTZqDOK8hVsev+3j2e
         wuzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f23si5049924pfa.228.2019.02.09.00.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Feb 2019 00:59:51 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x198wJGL095729
	for <linux-mm@kvack.org>; Sat, 9 Feb 2019 03:59:50 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qht38bp8j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 09 Feb 2019 03:59:50 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sat, 9 Feb 2019 08:59:48 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 9 Feb 2019 08:59:44 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x198xi4T63242430
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 9 Feb 2019 08:59:44 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0344CA4062;
	Sat,  9 Feb 2019 08:59:44 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 672EAA405F;
	Sat,  9 Feb 2019 08:59:43 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.132])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sat,  9 Feb 2019 08:59:43 +0000 (GMT)
Date: Sat, 9 Feb 2019 10:59:41 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] memblock: update comments and kernel-doc
References: <1549626347-25461-1-git-send-email-rppt@linux.ibm.com>
 <20190208144047.66254b6d08edfea462e6466a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208144047.66254b6d08edfea462e6466a@linux-foundation.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020908-0008-0000-0000-000002BE604F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020908-0009-0000-0000-0000222A70B2
Message-Id: <20190209085941.GA13657@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-09_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=900 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902090067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 02:40:47PM -0800, Andrew Morton wrote:
> On Fri,  8 Feb 2019 13:45:47 +0200 Mike Rapoport <rppt@linux.ibm.com> wrote:
> 
> > * Remove comments mentioning bootmem
> > * Extend "DOC: memblock overview"
> > * Add kernel-doc comments for several more functions
> > 
> > ...
> >
> > @@ -1400,6 +1413,19 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
> >  	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE);
> >  }
> >  
> > +/**
> > + * memblock_phys_alloc_range - allocate a memory block from specified MUMA node
> > + * @size: size of memory block to be allocated in bytes
> > + * @align: alignment of the region and block's size
> > + * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
> > + *
> > + * Allocates memory block from the specified NUMA node. If the node
> > + * has no available memory, attempts to allocated from any node in the
> > + * system.
> > + *
> > + * Return: physical address of the allocated memory block on success,
> > + * %0 on failure.
> > + */
> >  phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
> >  {
> >  	return memblock_alloc_range_nid(size, align, 0,
> 
> copy-n-paste!

Oops, thanks for the fix!
 
> --- a/mm/memblock.c~memblock-update-comments-and-kernel-doc-fix
> +++ a/mm/memblock.c
> @@ -1414,7 +1414,7 @@ phys_addr_t __init memblock_phys_alloc_r
>  }
>  
>  /**
> - * memblock_phys_alloc_range - allocate a memory block from specified MUMA node
> + * memblock_phys_alloc_try_nid - allocate a memory block from specified MUMA node
>   * @size: size of memory block to be allocated in bytes
>   * @align: alignment of the region and block's size
>   * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
> 

-- 
Sincerely yours,
Mike.

