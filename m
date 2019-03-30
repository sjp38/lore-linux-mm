Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A81DC10F00
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 09:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA9C9218AC
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 09:50:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA9C9218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC916B000D; Sat, 30 Mar 2019 05:50:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435A26B000E; Sat, 30 Mar 2019 05:50:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D9AC6B0010; Sat, 30 Mar 2019 05:50:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC4C96B000D
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 05:50:57 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d33so3391124pla.19
        for <linux-mm@kvack.org>; Sat, 30 Mar 2019 02:50:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=uruyKcgs3/AmmfnUT0zmQ28BMUDb6SwCWvNgsHkvi3I=;
        b=jYAh0awrTVQzEfVP19TvT3LSfP/m7pWmoo2sHFnLSwEIHhsLQMsM41Sf3Bw2tuQZfx
         DEYtxRihjT67JGI/GrSUZPENuDones753NAHc1lKewgnifPGaTWlGk21CTyJkgaHkNv/
         crbqxwVzuauIyeY6i7f4b5jz6HdA/SKt4guRnPE+Hjg9mykWjUgSnYxlQz6GzQOIXW7W
         /8pOywMtvI6J89Pu5hEpkTkIGs3FD0IM5aE/dEJZPA/ocXvk3CpKRfb9sKmbdGwg3v4y
         t/u6YHKFb5ph1+bs93QAdKN0Y6X/VeqDCPwQ7OBtELTe9BwmsfdBDJpye2GttL+0PwyE
         UHxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVVmc2CuAC8LQ7lDZCppdQJ38ubwPQ1x+4zBcNUJSdAtQr64V0H
	FnKZDPC0bh0xndANW4hV+lwF49OFMon2tGHwkDgLMvTmd1d19B3xXifqNpGnfKPYq2N207dnXNT
	ZL/5/4Nehg2WoO8RmPVZrl/rsSZdSl84rL8CKuNLn8QkPc+yPbpC6KnZkkaClLYuyrQ==
X-Received: by 2002:a63:5a20:: with SMTP id o32mr48285385pgb.225.1553939457256;
        Sat, 30 Mar 2019 02:50:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1W0AVN6dWOep46VUdl0zH+P+jmiwOwjjnebwK4IJ1YDhEb9F4Va1zFTruy4EPT/O/FyVA
X-Received: by 2002:a63:5a20:: with SMTP id o32mr48285339pgb.225.1553939456468;
        Sat, 30 Mar 2019 02:50:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553939456; cv=none;
        d=google.com; s=arc-20160816;
        b=X8EVCZD/LqRKHHXddWN6TtLrHo0GR2GRg+VK6YJm0O39RWP0WSKoraGplzL02tTlRh
         mrsBLlVSkmtamPMM68j7XY6zvDWVESFtJjDiwtRqtdwDF/IUYt7IveaZ3d6Czb+LwTam
         2eMAOTmF632fuByGeTmXJ2UxurOcDBr2+gHLWm7f3/dr8T8/8w7HoMni4PxdM6l7QpxB
         5YnzyTMMoukep1ek8H+SepaEYmCD/8DLFiCN2W09o80Zwk1YI300SeFY7BY813t+2ZI3
         8zs49xMciJTsJFuQS0A+YHbU0oZJ3baRHyGZwzPwTmHzVbjUSalzUnozGfGv0Ro96bPg
         4uqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=uruyKcgs3/AmmfnUT0zmQ28BMUDb6SwCWvNgsHkvi3I=;
        b=I+hectD0fSRb3bT14umgd9ev2ywauTThykhMYorsqPkUKmNtcbmCCZQQyBvGogJ1VY
         bl9N2oODh+lA/pxedVl2DcjJruiovfQS3ruOWGmxh9GrRMfyr9bVHk9RP+cRQsfBi8RG
         zndyyaN5wRpgrP5ioaJcptVcly+q8FVyrtyTLygSpx05AP6f+NdlZ6vP38OB2kAk2KGA
         JudYmGnSctmvFQ+Q2cYm0X8Ir6ZabFiYkb1xlziRxF2LUk34FSsvIGMdZqzkAxvX67Tw
         KZ7Amu4BJWD2YuQ0ci5+D5H7NqAuo10lSxlGTscIpptWmQUNlCui13YXhIMYwYw89V3O
         mnsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a15si3884569pgw.110.2019.03.30.02.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Mar 2019 02:50:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2U9n6np101828
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 05:50:55 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rj50h1yqb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 05:50:55 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sat, 30 Mar 2019 09:50:53 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 30 Mar 2019 09:50:50 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2U9ooxs59113630
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 30 Mar 2019 09:50:50 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E43CDA4054;
	Sat, 30 Mar 2019 09:50:49 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 04694A405B;
	Sat, 30 Mar 2019 09:50:49 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.99])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sat, 30 Mar 2019 09:50:48 +0000 (GMT)
Date: Sat, 30 Mar 2019 12:50:47 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
        akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de,
        willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 1/2] mm/sparse: Clean up the obsolete code comment
References: <20190329082915.19763-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329082915.19763-1-bhe@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19033009-0008-0000-0000-000002D43C17
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19033009-0009-0000-0000-000022403DBC
Message-Id: <20190330095046.GA26141@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-30_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903300071
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 04:29:14PM +0800, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> v2->v3:
>   Normalize the code comment to use '/**' at 1st line of doc
>   above function.
> v1-v2:
>   Add comments to explain what the returned value means for
>   each error code.
>  mm/sparse.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..363f9d31b511 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -684,10 +684,19 @@ static void free_map_bootmem(struct page *memmap)
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
> -/*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> +/**
> + * sparse_add_one_section - add a memory section
> + * @nid: The node to add section on
> + * @start_pfn: start pfn of the memory range
> + * @altmap: device page map
> + *
> + * This is only intended for hotplug.
> + *
> + * Returns:
> + *   0 on success.
> + *   Other error code on failure:
> + *     - -EEXIST - section has been present.
> + *     - -ENOMEM - out of memory.
>   */
>  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  				     struct vmem_altmap *altmap)
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.

