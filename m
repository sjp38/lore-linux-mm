Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 865BEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 15:36:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CF1B20684
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 15:36:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CF1B20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A24A8E0003; Wed, 27 Feb 2019 10:36:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 702C58E0001; Wed, 27 Feb 2019 10:36:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CCBC8E0003; Wed, 27 Feb 2019 10:36:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 298F68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:36:38 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id r136so5514775ith.3
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 07:36:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=88nfiZKobsur8ygEUIU224PuSndfMr8Knt6sH/Heosc=;
        b=UQ04srZwGJO4ZTQBhN/P8df1lpt7WwDjEuhavhbr2mj+2MmY0SMAu5fLGC2QfHIccB
         cfSbQ9CckWqeEaqwgjMS+kV8QzAzbBroQ2K8qLM02JrhgQikw9hqKyziRvnMG2xwt1lE
         r9gVMgnWEWTh8crUg2KxcjyFYABSB1U8Ol9GjRX7IA3QITnnGK6z1nOb3UqDwKpYUa92
         iEsRWG2JgXJjGosEBxy+a4FAJQ/IhANDyqgKCkJ+Y7Ta/muIO0GFtmVKgySnklaq4mI3
         70ONmzWXVS3fZ2RtMkfXEJMqGzn/Y5+CiK1SOScsalsbjYHQAXlQNmI3wVLPA6WrHtXb
         iVrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX0r1+eulq6eX7EWV4s0Kl+TkyNu0gpHO9XXjJVI40NIG0sQ1GS
	7d0qcCx32ESTkgLQlQG1BVOMDJPAN+JYAlFsRdJ+9yKSL6vTETmdtaX1Jaxn2hZUw9LBB6mSGbA
	m3exeB6OVEcccVmats2kMPZNNUfVKE9t1g6HpXtF/iaqgHembocKtKoTWKV0hroSSqQ==
X-Received: by 2002:a6b:dd1a:: with SMTP id f26mr2285942ioc.10.1551281797895;
        Wed, 27 Feb 2019 07:36:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqydWzfPtGI4E5tEuBSz0Nhj7wCYXigbsedFhRt268KVlee1Le5FwWpfYQ/J9DKozj+pabhI
X-Received: by 2002:a6b:dd1a:: with SMTP id f26mr2285879ioc.10.1551281796740;
        Wed, 27 Feb 2019 07:36:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551281796; cv=none;
        d=google.com; s=arc-20160816;
        b=tzwKFs2vl7RGkNE8oGJY+fBwkWp2SYvB3j6isXUUZiE0OpgeSo46ZSJgX0O5ekSXbZ
         ySMZEYDbn5306sL/VytXhqLoaP/UpZO+wPV4e33HI0Bq2CLqRl5oZFGuJP/yjl4vRTHn
         X20rK48mHgj+DHnMYl54HYwOf79bikYZDtHmttDiCIAdW/NZF6Qsr0l73IfJcLdqDhpz
         BRxhLsDMomNLvlduNbyQ0JwDkm944bo0pak8hd/Rlp+umrfXcewUpl3W1xjqd68vUfnX
         fz9HYWGeN+TFHTNYQ01zw2AyCBgWIVF4pos78G0qK5IvqDVtCibaPVwF/nA1o1nm1ZQw
         e45g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=88nfiZKobsur8ygEUIU224PuSndfMr8Knt6sH/Heosc=;
        b=IYbf3Yet3H6Ezo8GQbnUEUjDi9my9yuZrlAmhVH0sfAYahznQE1z7sUS0/VeU54qXb
         ozvNFt+PWF08Mvk+c9qkc7tu6oHeUFnZ7Hc2K/sL74HIQN9Idcj3matYBFx14UoL6W8q
         OZAKiM7emnV8S0ZqBRICJoAnYVUlgcemI3N+C/aIAcheW56UeuX0VB3nHnEkuAREv7SZ
         AVJFZenr60RE5ZR16Ub+P0h0Ezryq3KD+MoOAf1OIzlEa4+kzLYEt3BOsW7ahVspqlWv
         0kDlUr3/GZhlT5FFg6IqyTMcJXm3SJMdR/43qIhWoLm/y3LfsC4VOVR9dQMSaKln4MRX
         W/eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k19si1389700itk.8.2019.02.27.07.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 07:36:36 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1RFXb1A092718
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:36:36 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qwvp1jeqk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:36:35 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 27 Feb 2019 15:36:33 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 15:36:30 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1RFaTAw11731014
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 15:36:29 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2CEA34C046;
	Wed, 27 Feb 2019 15:36:29 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 321B94C058;
	Wed, 27 Feb 2019 15:36:28 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 27 Feb 2019 15:36:28 +0000 (GMT)
Date: Wed, 27 Feb 2019 17:36:26 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peng Fan <peng.fan@nxp.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "labbott@redhat.com" <labbott@redhat.com>,
        "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
        "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>,
        "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
        "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
        "andreyknvl@google.com" <andreyknvl@google.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH V2] mm/cma: cma_declare_contiguous: correct err handling
References: <20190227144631.16708-1-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227144631.16708-1-peng.fan@nxp.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022715-0020-0000-0000-0000031BF6C8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022715-0021-0000-0000-0000216D63E8
Message-Id: <20190227153626.GF16901@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 02:34:55PM +0000, Peng Fan wrote:
> In case cma_init_reserved_mem failed, need to free the memblock allocated
> by memblock_reserve or memblock_alloc_range.
> 
> Quote Catalin's comments:
> https://lkml.org/lkml/2019/2/26/482
> Kmemleak is supposed to work with the memblock_{alloc,free} pair and it
> ignores the memblock_reserve() as a memblock_alloc() implementation
> detail. It is, however, tolerant to memblock_free() being called on
> a sub-range or just a different range from a previous memblock_alloc().
> So the original patch looks fine to me. FWIW:
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> 
> V2:
>  Per Mike's comments, add more information in commit log
>  Add R-B
> 
>  mm/cma.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index c7b39dd3b4f6..f4f3a8a57d86 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  
>  	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
>  	if (ret)
> -		goto err;
> +		goto free_mem;
>  
>  	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
>  		&base);
>  	return 0;
>  
> +free_mem:
> +	memblock_free(base, size);
>  err:
>  	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
>  	return ret;
> -- 
> 2.16.4
> 

-- 
Sincerely yours,
Mike.

