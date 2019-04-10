Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F38FBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 13:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3D3C2083E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 13:09:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3D3C2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371166B0295; Wed, 10 Apr 2019 09:09:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FA116B0296; Wed, 10 Apr 2019 09:09:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19BBE6B0297; Wed, 10 Apr 2019 09:09:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B58746B0295
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 09:09:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t14so1235743edw.15
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 06:09:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=INwUb4zuFpqoA9eyxvr1PUfOYyaWM6QPieYkQrBbqwM=;
        b=e457bYxiA4EBOlQHcUQbwYonDBjGdaMXnLwYVrDWHhmiSObiBt9umf4sx8jw3DMe3T
         ZBjC3lNH6ReIZ3HfcebsDfFfBUfu40K8gtYLa68MOeS0YcRA+bnHR7D3/HuMq8XfmpS9
         aMUT5xEMr0myxVLHMW5ntZwqdK07qsbwglyrLixRIHrHfNqyBxy8q0I/E+L0It2fB82d
         KXG/fOYjB2MsWtLYcUnM5ooqOSTgMMU9oE7da5AQb8n+wGEGrDiNnOYohtjJFT7oohtB
         HKobWjm6u4KRf0GW2X2TylD3GB2/p5TM83G+X3irCIW2KQvD3j9yFi5WHUmeFUQbWEzF
         ofHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUkx7+Pq1nrmf/xySQW8tKBzvE+9Hysq7zhbEKF6sjjw95+HuDz
	M0jBv+DhbJbgcAKCFgHftH6oVt88CDsedkgKdPZgzUiHSZwuWqvw7pWtUbTPy0iBHEmGX010BFX
	9DJ/H53XeNyuuUz5/mL218Y+FEVVA8ruqUSkPawHN+eU1COk/3dz5/M0+l6D/QH9hfw==
X-Received: by 2002:a17:906:5a94:: with SMTP id l20mr23413179ejq.131.1554901774167;
        Wed, 10 Apr 2019 06:09:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyH5RkMFa4fsHVgVLq9FQ5fzxBTciDbtSSyH28qdOmKL/QZhGtfeeYpR+TjrXX2Dh5iE4FJ
X-Received: by 2002:a17:906:5a94:: with SMTP id l20mr23413119ejq.131.1554901772976;
        Wed, 10 Apr 2019 06:09:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554901772; cv=none;
        d=google.com; s=arc-20160816;
        b=QuWCtVfAhhELR30fRxfrat2jSnpDbFB4XEnPDoHtZbd0kceYRp48SOf7fTyKquCocz
         JqztD7ffgtOefmtP4iIm+xo/E56ficQOZBeMCsOPLZ+8We2SmesiHOlSysCLa1NW78Qs
         tVRaLXXSR7fNfBzlGqZQc6N/aB14W9cHLiGzd5/CSGdwIJykYKHkdIUu6eVXIwNv390d
         2HcXwwYKdtTgjGIh+8cnj4S+iX84jQhNFJDIt9EJ+3QE6oeCFnhkvus4lmu4JHIdoxsF
         LuuFY4PxDGMOi7qeomnaTv/FmvZDlvdoyEf5Q8A4SGugbF5KDi/GzAG7D5/OJYFUNMrx
         MCUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=INwUb4zuFpqoA9eyxvr1PUfOYyaWM6QPieYkQrBbqwM=;
        b=tCnIwgk88QpFqNcsI1RnkTvzFyEDNJq6hzvxT4Tusrfe4YpWPnHnASttpUlYBmbYhz
         Dl3PKuxuA+bRkpwFn/95BGBKiLyM0kZE5dcXwo/opJk7YD20W6lDTd8TD4FAOkxY1mRU
         UnIT0Bh4Ks3LC0KTEYXnir4qI5HzvM5w6uV4LSN10l4JYleaHYbRF/RVHmTX+MuplcyG
         7FLpbES+pyrWGnmL1N9Lj74xAN7CJmyO6nu09nowv98/iPmVvNaQZBkOCT+DTHDTxmcQ
         5DhlGPSU1L+yv9p13ZuDup1wcCVPHpNKYeRPTMBeGJ9nHIBbu/I+OeuoxISXfM6KCFm4
         DCSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l4si4203582edw.78.2019.04.10.06.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 06:09:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3AD4Yvx069937
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 09:09:31 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rsg203kfm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 09:09:30 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 10 Apr 2019 14:09:28 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 10 Apr 2019 14:09:22 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3AD9LaD49938468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Apr 2019 13:09:21 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9D009A405B;
	Wed, 10 Apr 2019 13:09:21 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1F4C5A4064;
	Wed, 10 Apr 2019 13:09:20 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.205])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 10 Apr 2019 13:09:20 +0000 (GMT)
Date: Wed, 10 Apr 2019 16:09:18 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        akpm@linux-foundation.org, ard.biesheuvel@linaro.org,
        horms@verge.net.au, takahiro.akashi@linaro.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kexec@lists.infradead.org, linux-mm@kvack.org,
        wangkefeng.wang@huawei.com
Subject: Re: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel
 regions
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-4-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409102819.121335-4-chenzhou10@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041013-0016-0000-0000-0000026D54ED
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041013-0017-0000-0000-000032C9845D
Message-Id: <20190410130917.GC17196@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-10_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904100093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 09, 2019 at 06:28:18PM +0800, Chen Zhou wrote:
> After commit (arm64: kdump: support reserving crashkernel above 4G),
> there may be two crash kernel regions, one is below 4G, the other is
> above 4G.
> 
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
> 
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>  arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
>  include/linux/memblock.h |  6 +++++
>  mm/memblock.c            |  7 ++---
>  3 files changed, 66 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 3bebddf..0f18665 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  
>  #ifdef CONFIG_KEXEC_CORE
>  
> +/* at most two crash kernel regions, low_region and high_region */
> +#define CRASH_MAX_USABLE_RANGES	2
> +#define LOW_REGION_IDX			0
> +#define HIGH_REGION_IDX			1
> +
>  /*
>   * reserve_crashkernel() - reserves memory for crash kernel
>   *
> @@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>  		const char *uname, int depth, void *data)
>  {
>  	struct memblock_region *usablemem = data;
> -	const __be32 *reg;
> -	int len;
> +	const __be32 *reg, *endp;
> +	int len, nr = 0;
>  
>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>  		return 0;
> @@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>  		return 1;
>  
> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +	endp = reg + (len / sizeof(__be32));
> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +
> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
> +			break;
> +	}
>  
>  	return 1;
>  }
>  
>  static void __init fdt_enforce_memory_region(void)
>  {
> -	struct memblock_region reg = {
> -		.size = 0,
> -	};
> +	int i, cnt = 0;
> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];

I only now noticed that fdt_enforce_memory_region() uses memblock_region to
pass the ranges around. If we'd switch to memblock_type instead, the
implementation of memblock_cap_memory_ranges() would be really
straightforward. Can you check if the below patch works for you? 

From e476d584098e31273af573e1a78e308880c5cf28 Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 10 Apr 2019 16:02:32 +0300
Subject: [PATCH] memblock: extend memblock_cap_memory_range to multiple ranges

The memblock_cap_memory_range() removes all the memory except the range
passed to it. Extend this function to recieve memblock_type with the
regions that should be kept. This allows switching to simple iteration over
memblock arrays with 'for_each_mem_range' to remove the unneeded memory.

Enable use of this function in arm64 for reservation of multile regions for
the crash kernel.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
 include/linux/memblock.h |  2 +-
 mm/memblock.c            | 45 ++++++++++++++++++++++-----------------------
 3 files changed, 47 insertions(+), 34 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 6bc1350..30a496f 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -64,6 +64,10 @@ EXPORT_SYMBOL(memstart_addr);
 phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
+
+/* at most two crash kernel regions, low_region and high_region */
+#define CRASH_MAX_USABLE_RANGES	2
+
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
  *
@@ -280,9 +284,9 @@ early_param("mem", early_mem);
 static int __init early_init_dt_scan_usablemem(unsigned long node,
 		const char *uname, int depth, void *data)
 {
-	struct memblock_region *usablemem = data;
-	const __be32 *reg;
-	int len;
+	struct memblock_type *usablemem = data;
+	const __be32 *reg, *endp;
+	int len, nr = 0;
 
 	if (depth != 1 || strcmp(uname, "chosen") != 0)
 		return 0;
@@ -291,22 +295,32 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
 		return 1;
 
-	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+	endp = reg + (len / sizeof(__be32));
+	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+		unsigned long base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+		unsigned long size = dt_mem_next_cell(dt_root_size_cells, &reg);
 
+		if (memblock_add_range(usablemem, base, size, NUMA_NO_NODE,
+				       MEMBLOCK_NONE))
+			return 0;
+		if (++nr >= CRASH_MAX_USABLE_RANGES)
+			break;
+	}
 	return 1;
 }
 
 static void __init fdt_enforce_memory_region(void)
 {
-	struct memblock_region reg = {
-		.size = 0,
+	struct memblock_region usable_regions[CRASH_MAX_USABLE_RANGES];
+	struct memblock_type usablemem = {
+		.max = CRASH_MAX_USABLE_RANGES,
+		.regions = usable_regions,
 	};
 
-	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
+	of_scan_flat_dt(early_init_dt_scan_usablemem, &usablemem);
 
-	if (reg.size)
-		memblock_cap_memory_range(reg.base, reg.size);
+	if (usablemem.cnt)
+		memblock_cap_memory_ranges(&usablemem);
 }
 
 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 294d5d8..a803ae9 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -404,7 +404,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
-void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
+void memblock_cap_memory_ranges(struct memblock_type *regions_to_keep);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
 bool memblock_is_map_memory(phys_addr_t addr);
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf..83d84d4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1605,36 +1605,34 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 			      PHYS_ADDR_MAX);
 }
 
-void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
+void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
 {
-	int start_rgn, end_rgn;
-	int i, ret;
-
-	if (!size)
-		return;
-
-	ret = memblock_isolate_range(&memblock.memory, base, size,
-						&start_rgn, &end_rgn);
-	if (ret)
-		return;
-
-	/* remove all the MAP regions */
-	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
+	phys_addr_t start, end;
+	u64 i;
 
-	for (i = start_rgn - 1; i >= 0; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
+	/* truncate memory while skipping NOMAP regions */
+	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
+			   MEMBLOCK_NONE, &start, &end, NULL)
+		memblock_remove(start, end);
 
 	/* truncate the reserved regions */
-	memblock_remove_range(&memblock.reserved, 0, base);
-	memblock_remove_range(&memblock.reserved,
-			base + size, PHYS_ADDR_MAX);
+	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
+			   MEMBLOCK_NONE, &start, &end, NULL)
+		memblock_remove_range(&memblock.reserved, start, end);
 }
 
 void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 {
+	struct memblock_region rgn = {
+		.base = 0,
+	};
+
+	struct memblock_type region_to_keep = {
+		.cnt = 1,
+		.max = 1,
+		.regions = &rgn,
+	};
+
 	phys_addr_t max_addr;
 
 	if (!limit)
@@ -1646,7 +1644,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 	if (max_addr == PHYS_ADDR_MAX)
 		return;
 
-	memblock_cap_memory_range(0, max_addr);
+	region_to_keep.regions[0].size = max_addr;
+	memblock_cap_memory_ranges(&region_to_keep);
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
-- 
2.7.4



-- 
Sincerely yours,
Mike.

