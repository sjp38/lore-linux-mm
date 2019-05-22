Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AD2BC18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 09:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CE5820856
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 09:17:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CE5820856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85A1D6B0003; Wed, 22 May 2019 05:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E3546B0006; Wed, 22 May 2019 05:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 683656B0007; Wed, 22 May 2019 05:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 429D56B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 05:17:06 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id n76so1501591ybf.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 02:17:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=0jKpll0qhEVYUzda9RRCVCxIAJ/4J5kSnqZtsX5xeos=;
        b=KfUfEnILyoBnftCBOQJYSlkdXl7aZZbEkhCDXQmeaxnXOQDlzV90q3aoRShlvLDenk
         sR5azApAT8mNVkqoZjNVZszM69MiXh6Cp689tUUExbt53+9dm59DVh+RMXyUnlCoiZjW
         2njU0lKCUZkl1EaawQE172zcc5LXLe4ZomMcRQgKVW8vkpfOCGbJ3Ly67RSdMpLNyHhH
         qE96yCRkSZfSiWLLkx00W26+T38J5lBa9myg8JXQEiEafL1vhxpb3e0G4PDxaFNaNOTp
         M7crBl6J8H74dnlfaSsZxeR0YKO8iXpRsieyobmPMtsenWxoPJwhMz9iwcKyakKQhgpv
         2RQQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) smtp.mailfrom=sathnaga@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWHfbgmAptgWt3btUEgIKDCNlzMrY/PdLJKEGF9tou180QyIIi/
	JCXePuCb3E8TgcokqE5y4csV1j/Ryhe70ZCqQsfPzr20t1JUdnOMiftOOBi1znyJfKfbBRAywYP
	t19Js2LjSzCDwXq7UCrRkaENeuYzrkILf4In56HdQBgJs87OoC7qP7OfOL04Wb+A=
X-Received: by 2002:a25:b7ce:: with SMTP id u14mr42434698ybj.404.1558516625972;
        Wed, 22 May 2019 02:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAQ+lgDR4XVEu4pmj1GUxC1GOVN4lHlR/+t4EN5ggx266K3PBvMAnLgHVFbE2DNuQaHMqf
X-Received: by 2002:a25:b7ce:: with SMTP id u14mr42434655ybj.404.1558516624574;
        Wed, 22 May 2019 02:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558516624; cv=none;
        d=google.com; s=arc-20160816;
        b=FnLFhM/sUgnPHhFhgYUfv307lDETpviizHAse+3D4Klpf+smB4frd5neXN3360gpUz
         3GRvauAaWnFsm0C+gGXno1cxiHYaw3Kzlnlhd71lMAye621J3DUoyNJ4gzlPmwBdWWc2
         EkLL/j3Y7LQ8KulxM/Sj5zBR1RAtISAWa0y/uGfQwAzEMszT47MK+kifuqhGs2lObLaS
         QKaOaJThIJ/7PJj0luOgrZGOmqNUiQBdUtUpmf42sz4E2FKIm2TftvYq33Wr6KJVvldu
         w5MaG96mqUT531yUhE7fdX1ARO0kPuKdVsDmtlhI2G9InbXLKSI+Qyf5C89bsY3akkIJ
         /SbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=0jKpll0qhEVYUzda9RRCVCxIAJ/4J5kSnqZtsX5xeos=;
        b=0OcfRA78MDE9uPU1ZZlibZ6wQWYic6TyI2JOhdS8ulOKlgK7UpKttRLZK+B1w78Xyn
         J9ZsiMthb6/Y8HTheBcr06hcYrZk35mAPMkyBxp572oj99X7F6p1B4aXfBzshQOnY+Ot
         OgCNzQmq5h5gERcIiuKOhRL/X9gKruI8pXQ/thEVRe2WsfMsrq/AXWwGyXox+SuyFBks
         FKqVSVJdh4YsJAKA2Ybud+iRPWDtlIUIu/mn4SH2lOKwVbg0518OQg84XDoMqMNx9Zzd
         yLbYPxCNP2HS+RD+EwJ+WORBggduACChKGqHn2zDNbFseR7LAsUsHk+m+26uhdYSer0S
         xuhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) smtp.mailfrom=sathnaga@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n66si6770544yba.19.2019.05.22.02.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 02:17:04 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) smtp.mailfrom=sathnaga@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M92L5t108151
	for <linux-mm@kvack.org>; Wed, 22 May 2019 05:17:04 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sn3ctgqrv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 05:17:03 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sathnaga@linux.vnet.ibm.com>;
	Wed, 22 May 2019 10:17:02 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 10:17:01 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M9H0WN59375656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 09:17:00 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 25DFCA4060;
	Wed, 22 May 2019 09:17:00 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 024B1A405B;
	Wed, 22 May 2019 09:16:59 +0000 (GMT)
Received: from sathnaga86.d4t-in.ibmmobiledemo.com (unknown [9.122.211.101])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 22 May 2019 09:16:58 +0000 (GMT)
Date: Wed, 22 May 2019 14:46:56 +0530
From: Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: dan.j.williams@intel.com, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org, linux-nvdimm@lists.01.org
Subject: Re: [RFC PATCH V2 3/3] mm/nvdimm: Use correct #defines instead of
 opencoding
Reply-To: Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>
References: <20190522082701.6817-1-aneesh.kumar@linux.ibm.com>
 <20190522082701.6817-3-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522082701.6817-3-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-TM-AS-GCONF: 00
x-cbid: 19052209-0008-0000-0000-000002E93770
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052209-0009-0000-0000-00002255F114
Message-Id: <20190522091656.GA19800@sathnaga86.d4t-in.ibmmobiledemo.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 01:57:01PM +0530, Aneesh Kumar K.V wrote:
> The nfpn related change is needed to fix the kernel message
> 
> "number of pfns truncated from 2617344 to 163584"
> 
> The change makes sure the nfpns stored in the superblock is right value.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/label.c       | 2 +-
>  drivers/nvdimm/pfn_devs.c    | 6 +++---
>  drivers/nvdimm/region_devs.c | 8 ++++----
>  3 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
> index f3d753d3169c..bc6de8fb0153 100644
> --- a/drivers/nvdimm/label.c
> +++ b/drivers/nvdimm/label.c
> @@ -361,7 +361,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
> 
>  	/* check that DPA allocations are page aligned */
>  	if ((__le64_to_cpu(nd_label->dpa)
> -				| __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
> +				| __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)
>  		return false;
> 
>  	/* check checksum */
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 39fa8cf8ef58..9fc2e514e28a 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -769,8 +769,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>  		 * when populating the vmemmap. This *should* be equal to
>  		 * PMD_SIZE for most architectures.
>  		 */
> -		offset = ALIGN(start + reserve + 64 * npfns,
> -				max(nd_pfn->align, PMD_SIZE)) - start;
> +		offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
> +			       max(nd_pfn->align, PMD_SIZE)) - start;
>  	} else if (nd_pfn->mode == PFN_MODE_RAM)
>  		offset = ALIGN(start + reserve, nd_pfn->align) - start;
>  	else
> @@ -782,7 +782,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>  		return -ENXIO;
>  	}
> 
> -	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
> +	npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
>  	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
>  	pfn_sb->dataoff = cpu_to_le64(offset);
>  	pfn_sb->npfns = cpu_to_le64(npfns);
> diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
> index b4ef7d9ff22e..2d8facea5a03 100644
> --- a/drivers/nvdimm/region_devs.c
> +++ b/drivers/nvdimm/region_devs.c
> @@ -994,10 +994,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
>  		struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
>  		struct nvdimm *nvdimm = mapping->nvdimm;
> 
> -		if ((mapping->start | mapping->size) % SZ_4K) {
> -			dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
> -					caller, dev_name(&nvdimm->dev), i);
> -
> +		if ((mapping->start | mapping->size) % PAGE_SIZE) {
> +			dev_err(&nvdimm_bus->dev,
> +				"%s: %s mapping%d is not 4K aligned\n",

s/not 4K aligned/not PAGE_SIZE aligned ?

hope the error msg need to be changed as well..

Regards,
-Satheesh.
> +				caller, dev_name(&nvdimm->dev), i);
>  			return NULL;
>  		}
> 
> -- 
> 2.21.0
> 

