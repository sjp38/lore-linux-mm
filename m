Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08CD2C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 14:24:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 751D120827
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 14:24:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 751D120827
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E328E007D; Tue,  8 Jan 2019 09:24:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 265C48E0038; Tue,  8 Jan 2019 09:24:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12C3F8E007D; Tue,  8 Jan 2019 09:24:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2C3E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:24:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n50so3548172qtb.9
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:24:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=k6xseUPe9qQU2uZnQ0kVDvjECjk6XHnpI44Pp9bRI+M=;
        b=NF50v1yJkF87yPmJ+vjdsjh4yjZxC3bNAfxmpN3I8118TBFdhDCoIOl1iiCCJyMVbM
         XSm0xh763lEarURnN9QYDQQKlnercEajDLrFz+E1POrLVfc8DlR1SvhTFB6fuO5azbBA
         0G8QcrTu6q/PBpskZj83DE2OPJWejIGjBS9Apz9B7k7znrk99i+lVpoeSiDPKk1jDU9b
         futQAvtQcOziwcGF2syfGgLNyZscyyoLoRql6hWN5kbI+cW5tRcQ0S1dJhI6Pt1TjD+Y
         sXFqRBQ7XscgPOE4CXwzRr2F8aVF3kOqUdq6doAW/V6sdXiZYHCqbcXrxaNM9AjsQeBO
         neXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfVjtmbBzzfLL5DvFWQtWYYPffA4mRQ8WBWT9pmuLFQCrd6TXDX
	m9oVl6DM1tyXtzn4RBBXw+ofY04fZ3R4y6TjeMTXYVLal7/jncdY04Lz+aZOgPJX5KPJZE1bSbM
	aWfZ0UaFFYN3YOgc2204GfXhllbfyBZJW3geiS2nxJjP6zU6zh1PdnYWY09xYfSQxQA==
X-Received: by 2002:ac8:b0e:: with SMTP id e14mr1877341qti.336.1546957440557;
        Tue, 08 Jan 2019 06:24:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6C2WYMMOLjMOpEmh8tTumF1V0gta4Txh/E4k3Esb5SPUemHqhm8l+SpqT1FDpakVgw+UOq
X-Received: by 2002:ac8:b0e:: with SMTP id e14mr1877294qti.336.1546957439728;
        Tue, 08 Jan 2019 06:23:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546957439; cv=none;
        d=google.com; s=arc-20160816;
        b=0Mjr40+6iDnOUH+i73IaqVPjqwSqhrFdzR6D0Uz3UKqj1+jJ/1IgVjT+QjkUj6O3Ap
         F3obFNgZc3aTv9d2ITIpkIHq5tjtxAZGjib/JP5jKM8igTuijB39RPXtjIgCcct7VYlb
         JXelZVZuBpwWBdw8K3qaUzUOi+RnPUY7/5nD+3+QM0T1JmjZ4QUWcETTFZeMT2KogM3q
         z256kOcfUJcnAP36WReCyIXExXd5xyw1/1jnSym/PLTQMKtmEuheDlDfLO2snaXcVbrP
         hMVY/Dy0plCBTuFhzzvdufYMwqDWSXWqAujg5adZ3B2+6KhCqdFONUfHf3J6nUzMmT+i
         3L1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=k6xseUPe9qQU2uZnQ0kVDvjECjk6XHnpI44Pp9bRI+M=;
        b=dda6gY6NmKIpuFnnQTND6nY6v9R6cDxNrkO5gXHK3KKwVjCAgqLYXbpmPHCtt5zdHD
         89ZMts90RjYThFEQfc7NvgzCeeP5D4CULwmd1/ywWPhZlutEhr8xxhYbNPYonMZrRrgY
         Z6d24zjcm9acb8tT7N/lDuSCcxLcsdm9UxLtGrC8z7PUsDNNyafBwhhE0j8hZ6nnTtjN
         fKjQNiwbRReBFGgGfhqKB9+gT3sxecEUS1zCpjBQhNHaLg/D0v80zKesr/S3KsWn+HLl
         4AykBfYa8VYeoCDy8tCTAN3/WQqMF+CoR/2GBq7CrTVEfAXesc52ciNe/G5tYShNO/gq
         +JoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w128si2632882qkc.37.2019.01.08.06.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:23:59 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x08EJZ3W079645
	for <linux-mm@kvack.org>; Tue, 8 Jan 2019 09:23:59 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pvtkw2hd5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:23:58 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 8 Jan 2019 14:23:52 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 8 Jan 2019 14:23:46 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x08ENjnw56295606
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 8 Jan 2019 14:23:45 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3B191A4054;
	Tue,  8 Jan 2019 14:23:45 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4B5E5A405C;
	Tue,  8 Jan 2019 14:23:43 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.241])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  8 Jan 2019 14:23:43 +0000 (GMT)
Date: Tue, 8 Jan 2019 16:23:41 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
        linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-mm@kvack.org, Rich Felker <dalias@libc.org>,
        Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
        Vincent Chen <deanbo422@gmail.com>, Jonas Bonn <jonas@southpole.se>,
        linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Russell King <linux@armlinux.org.uk>, Mark Salter <msalter@redhat.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>,
        openrisc@lists.librecores.org, Greentime Hu <green.hu@gmail.com>,
        Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>,
        linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>,
        linux-kernel@vger.kernel.org,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH v4 1/6] powerpc: prefer memblock APIs returning virtual
 address
References: <1546248566-14910-1-git-send-email-rppt@linux.ibm.com>
 <1546248566-14910-2-git-send-email-rppt@linux.ibm.com>
 <282fd5d1-24b5-81ac-b7ff-7329fe3c0fe1@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <282fd5d1-24b5-81ac-b7ff-7329fe3c0fe1@c-s.fr>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19010814-0012-0000-0000-000002E3F66B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19010814-0013-0000-0000-0000211B03C6
Message-Id: <20190108142341.GA14063@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-08_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901080118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108142341.coF4xBMGMHFDpDoZA1kzOTukrZBNnyDGEZ2NZdDcKm4@z>

Hi,

On Tue, Jan 08, 2019 at 11:02:24AM +0100, Christophe Leroy wrote:
> 
> Le 31/12/2018 à 10:29, Mike Rapoport a écrit :
> >There are a several places that allocate memory using memblock APIs that
> >return a physical address, convert the returned address to the virtual
> >address and frequently also memset(0) the allocated range.
> >
> >Update these places to use memblock allocators already returning a virtual
> >address. Use memblock functions that clear the allocated memory instead of
> >calling memset(0) where appropriate.
> >
> >The calls to memblock_alloc_base() that were not followed by memset(0) are
> >replaced with memblock_alloc_try_nid_raw(). Since the latter does not
> >panic() when the allocation fails, the appropriate panic() calls are added
> >to the call sites.
> >
> >Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> >---
> >  arch/powerpc/kernel/paca.c             | 16 ++++++----------
> >  arch/powerpc/kernel/setup_64.c         | 24 ++++++++++--------------
> >  arch/powerpc/mm/hash_utils_64.c        |  6 +++---
> >  arch/powerpc/mm/pgtable-book3e.c       |  8 ++------
> >  arch/powerpc/mm/pgtable-book3s64.c     |  5 +----
> >  arch/powerpc/mm/pgtable-radix.c        | 25 +++++++------------------
> >  arch/powerpc/platforms/pasemi/iommu.c  |  5 +++--
> >  arch/powerpc/platforms/pseries/setup.c | 18 ++++++++++++++----
> >  arch/powerpc/sysdev/dart_iommu.c       |  7 +++++--
> >  9 files changed, 51 insertions(+), 63 deletions(-)
> >
> >diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
> >index 913bfca..276d36d4 100644
> >--- a/arch/powerpc/kernel/paca.c
> >+++ b/arch/powerpc/kernel/paca.c
> >@@ -27,7 +27,7 @@
> >  static void *__init alloc_paca_data(unsigned long size, unsigned long align,
> >  				unsigned long limit, int cpu)
> >  {
> >-	unsigned long pa;
> >+	void *ptr;
> >  	int nid;
> >  	/*
> >@@ -42,17 +42,15 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
> >  		nid = early_cpu_to_node(cpu);
> >  	}
> >-	pa = memblock_alloc_base_nid(size, align, limit, nid, MEMBLOCK_NONE);
> >-	if (!pa) {
> >-		pa = memblock_alloc_base(size, align, limit);
> >-		if (!pa)
> >-			panic("cannot allocate paca data");
> >-	}
> >+	ptr = memblock_alloc_try_nid(size, align, MEMBLOCK_LOW_LIMIT,
> >+				     limit, nid);
> >+	if (!ptr)
> >+		panic("cannot allocate paca data");
> 
> AFAIKS, memblock_alloc_try_nid() panics if memblock_alloc_internal() returns
> NULL, so the above panic is useless, isn't it ?
 
My plan is to make all memblock_alloc() APIs to return NULL rather then
panic and then get rid of _nopanic variants. It's currently WIP and
hopefully I'll have the patches ready next week.

> >  	if (cpu == boot_cpuid)
> >  		memblock_set_bottom_up(false);
> >-	return __va(pa);
> >+	return ptr;
> >  }
> >  #ifdef CONFIG_PPC_PSERIES
> >@@ -118,7 +116,6 @@ static struct slb_shadow * __init new_slb_shadow(int cpu, unsigned long limit)
> >  	}
> >  	s = alloc_paca_data(sizeof(*s), L1_CACHE_BYTES, limit, cpu);
> >-	memset(s, 0, sizeof(*s));
> >  	s->persistent = cpu_to_be32(SLB_NUM_BOLTED);
> >  	s->buffer_length = cpu_to_be32(sizeof(*s));
> >@@ -222,7 +219,6 @@ void __init allocate_paca(int cpu)
> >  	paca = alloc_paca_data(sizeof(struct paca_struct), L1_CACHE_BYTES,
> >  				limit, cpu);
> >  	paca_ptrs[cpu] = paca;
> >-	memset(paca, 0, sizeof(struct paca_struct));
> >  	initialise_paca(paca, cpu);
> >  #ifdef CONFIG_PPC_PSERIES
> >diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> >index 236c115..3dcd779 100644
> >--- a/arch/powerpc/kernel/setup_64.c
> >+++ b/arch/powerpc/kernel/setup_64.c
> >@@ -634,19 +634,17 @@ __init u64 ppc64_bolted_size(void)
> >  static void *__init alloc_stack(unsigned long limit, int cpu)
> >  {
> >-	unsigned long pa;
> >+	void *ptr;
> >  	BUILD_BUG_ON(STACK_INT_FRAME_SIZE % 16);
> >-	pa = memblock_alloc_base_nid(THREAD_SIZE, THREAD_SIZE, limit,
> >-					early_cpu_to_node(cpu), MEMBLOCK_NONE);
> >-	if (!pa) {
> >-		pa = memblock_alloc_base(THREAD_SIZE, THREAD_SIZE, limit);
> >-		if (!pa)
> >-			panic("cannot allocate stacks");
> >-	}
> >+	ptr = memblock_alloc_try_nid(THREAD_SIZE, THREAD_SIZE,
> >+				     MEMBLOCK_LOW_LIMIT, limit,
> >+				     early_cpu_to_node(cpu));
> >+	if (!ptr)
> >+		panic("cannot allocate stacks");
> 
> Same ?
> 
> Christophe
> 
> >-	return __va(pa);
> >+	return ptr;
> >  }
> >  void __init irqstack_early_init(void)
> >@@ -739,20 +737,17 @@ void __init emergency_stack_init(void)
> >  		struct thread_info *ti;
> >  		ti = alloc_stack(limit, i);
> >-		memset(ti, 0, THREAD_SIZE);
> >  		emerg_stack_init_thread_info(ti, i);
> >  		paca_ptrs[i]->emergency_sp = (void *)ti + THREAD_SIZE;
> >  #ifdef CONFIG_PPC_BOOK3S_64
> >  		/* emergency stack for NMI exception handling. */
> >  		ti = alloc_stack(limit, i);
> >-		memset(ti, 0, THREAD_SIZE);
> >  		emerg_stack_init_thread_info(ti, i);
> >  		paca_ptrs[i]->nmi_emergency_sp = (void *)ti + THREAD_SIZE;
> >  		/* emergency stack for machine check exception handling. */
> >  		ti = alloc_stack(limit, i);
> >-		memset(ti, 0, THREAD_SIZE);
> >  		emerg_stack_init_thread_info(ti, i);
> >  		paca_ptrs[i]->mc_emergency_sp = (void *)ti + THREAD_SIZE;
> >  #endif
> >@@ -933,8 +928,9 @@ static void __ref init_fallback_flush(void)
> >  	 * hardware prefetch runoff. We don't have a recipe for load patterns to
> >  	 * reliably avoid the prefetcher.
> >  	 */
> >-	l1d_flush_fallback_area = __va(memblock_alloc_base(l1d_size * 2, l1d_size, limit));
> >-	memset(l1d_flush_fallback_area, 0, l1d_size * 2);
> >+	l1d_flush_fallback_area = memblock_alloc_try_nid(l1d_size * 2,
> >+						l1d_size, MEMBLOCK_LOW_LIMIT,
> >+						limit, NUMA_NO_NODE);
> >  	for_each_possible_cpu(cpu) {
> >  		struct paca_struct *paca = paca_ptrs[cpu];
> >diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
> >index 0cc7fbc..bc6be44 100644
> >--- a/arch/powerpc/mm/hash_utils_64.c
> >+++ b/arch/powerpc/mm/hash_utils_64.c
> >@@ -908,9 +908,9 @@ static void __init htab_initialize(void)
> >  #ifdef CONFIG_DEBUG_PAGEALLOC
> >  	if (debug_pagealloc_enabled()) {
> >  		linear_map_hash_count = memblock_end_of_DRAM() >> PAGE_SHIFT;
> >-		linear_map_hash_slots = __va(memblock_alloc_base(
> >-				linear_map_hash_count, 1, ppc64_rma_size));
> >-		memset(linear_map_hash_slots, 0, linear_map_hash_count);
> >+		linear_map_hash_slots = memblock_alloc_try_nid(
> >+				linear_map_hash_count, 1, MEMBLOCK_LOW_LIMIT,
> >+				ppc64_rma_size,	NUMA_NO_NODE);
> >  	}
> >  #endif /* CONFIG_DEBUG_PAGEALLOC */
> >diff --git a/arch/powerpc/mm/pgtable-book3e.c b/arch/powerpc/mm/pgtable-book3e.c
> >index e0ccf36..53cbc7d 100644
> >--- a/arch/powerpc/mm/pgtable-book3e.c
> >+++ b/arch/powerpc/mm/pgtable-book3e.c
> >@@ -57,12 +57,8 @@ void vmemmap_remove_mapping(unsigned long start,
> >  static __ref void *early_alloc_pgtable(unsigned long size)
> >  {
> >-	void *pt;
> >-
> >-	pt = __va(memblock_alloc_base(size, size, __pa(MAX_DMA_ADDRESS)));
> >-	memset(pt, 0, size);
> >-
> >-	return pt;
> >+	return memblock_alloc_try_nid(size, size, MEMBLOCK_LOW_LIMIT,
> >+				      __pa(MAX_DMA_ADDRESS), NUMA_NO_NODE);
> >  }
> >  /*
> >diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
> >index f3c31f5..55876b7 100644
> >--- a/arch/powerpc/mm/pgtable-book3s64.c
> >+++ b/arch/powerpc/mm/pgtable-book3s64.c
> >@@ -195,11 +195,8 @@ void __init mmu_partition_table_init(void)
> >  	unsigned long ptcr;
> >  	BUILD_BUG_ON_MSG((PATB_SIZE_SHIFT > 36), "Partition table size too large.");
> >-	partition_tb = __va(memblock_alloc_base(patb_size, patb_size,
> >-						MEMBLOCK_ALLOC_ANYWHERE));
> >-
> >  	/* Initialize the Partition Table with no entries */
> >-	memset((void *)partition_tb, 0, patb_size);
> >+	partition_tb = memblock_alloc(patb_size, patb_size);
> >  	/*
> >  	 * update partition table control register,
> >diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
> >index 9311560..29bcea5 100644
> >--- a/arch/powerpc/mm/pgtable-radix.c
> >+++ b/arch/powerpc/mm/pgtable-radix.c
> >@@ -51,26 +51,15 @@ static int native_register_process_table(unsigned long base, unsigned long pg_sz
> >  static __ref void *early_alloc_pgtable(unsigned long size, int nid,
> >  			unsigned long region_start, unsigned long region_end)
> >  {
> >-	unsigned long pa = 0;
> >-	void *pt;
> >+	phys_addr_t min_addr = MEMBLOCK_LOW_LIMIT;
> >+	phys_addr_t max_addr = MEMBLOCK_ALLOC_ANYWHERE;
> >-	if (region_start || region_end) /* has region hint */
> >-		pa = memblock_alloc_range(size, size, region_start, region_end,
> >-						MEMBLOCK_NONE);
> >-	else if (nid != -1) /* has node hint */
> >-		pa = memblock_alloc_base_nid(size, size,
> >-						MEMBLOCK_ALLOC_ANYWHERE,
> >-						nid, MEMBLOCK_NONE);
> >+	if (region_start)
> >+		min_addr = region_start;
> >+	if (region_end)
> >+		max_addr = region_end;
> >-	if (!pa)
> >-		pa = memblock_alloc_base(size, size, MEMBLOCK_ALLOC_ANYWHERE);
> >-
> >-	BUG_ON(!pa);
> >-
> >-	pt = __va(pa);
> >-	memset(pt, 0, size);
> >-
> >-	return pt;
> >+	return memblock_alloc_try_nid(size, size, min_addr, max_addr, nid);
> >  }
> >  static int early_map_kernel_page(unsigned long ea, unsigned long pa,
> >diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
> >index f297152..f62930f 100644
> >--- a/arch/powerpc/platforms/pasemi/iommu.c
> >+++ b/arch/powerpc/platforms/pasemi/iommu.c
> >@@ -208,7 +208,9 @@ static int __init iob_init(struct device_node *dn)
> >  	pr_debug(" -> %s\n", __func__);
> >  	/* For 2G space, 8x64 pages (2^21 bytes) is max total l2 size */
> >-	iob_l2_base = (u32 *)__va(memblock_alloc_base(1UL<<21, 1UL<<21, 0x80000000));
> >+	iob_l2_base = memblock_alloc_try_nid_raw(1UL << 21, 1UL << 21,
> >+					MEMBLOCK_LOW_LIMIT, 0x80000000,
> >+					NUMA_NO_NODE);
> >  	pr_info("IOBMAP L2 allocated at: %p\n", iob_l2_base);
> >@@ -269,4 +271,3 @@ void __init iommu_init_early_pasemi(void)
> >  	pasemi_pci_controller_ops.dma_bus_setup = pci_dma_bus_setup_pasemi;
> >  	set_pci_dma_ops(&dma_iommu_ops);
> >  }
> >-
> >diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platforms/pseries/setup.c
> >index 41f62ca2..e4f0dfd 100644
> >--- a/arch/powerpc/platforms/pseries/setup.c
> >+++ b/arch/powerpc/platforms/pseries/setup.c
> >@@ -130,8 +130,13 @@ static void __init fwnmi_init(void)
> >  	 * It will be used in real mode mce handler, hence it needs to be
> >  	 * below RMA.
> >  	 */
> >-	mce_data_buf = __va(memblock_alloc_base(RTAS_ERROR_LOG_MAX * nr_cpus,
> >-					RTAS_ERROR_LOG_MAX, ppc64_rma_size));
> >+	mce_data_buf = memblock_alloc_try_nid_raw(RTAS_ERROR_LOG_MAX * nr_cpus,
> >+					RTAS_ERROR_LOG_MAX, MEMBLOCK_LOW_LIMIT,
> >+					ppc64_rma_size, NUMA_NO_NODE);
> >+	if (!mce_data_buf)
> >+		panic("Failed to allocate %d bytes below %pa for MCE buffer\n",
> >+		      RTAS_ERROR_LOG_MAX * nr_cpus, &ppc64_rma_size);
> >+
> >  	for_each_possible_cpu(i) {
> >  		paca_ptrs[i]->mce_data_buf = mce_data_buf +
> >  						(RTAS_ERROR_LOG_MAX * i);
> >@@ -140,8 +145,13 @@ static void __init fwnmi_init(void)
> >  #ifdef CONFIG_PPC_BOOK3S_64
> >  	/* Allocate per cpu slb area to save old slb contents during MCE */
> >  	size = sizeof(struct slb_entry) * mmu_slb_size * nr_cpus;
> >-	slb_ptr = __va(memblock_alloc_base(size, sizeof(struct slb_entry),
> >-					   ppc64_rma_size));
> >+	slb_ptr = memblock_alloc_try_nid_raw(size, sizeof(struct slb_entry),
> >+					MEMBLOCK_LOW_LIMIT, ppc64_rma_size,
> >+					NUMA_NO_NODE);
> >+	if (!slb_ptr)
> >+		panic("Failed to allocate %zu bytes below %pa for slb area\n",
> >+		      size, &ppc64_rma_size);
> >+
> >  	for_each_possible_cpu(i)
> >  		paca_ptrs[i]->mce_faulty_slbs = slb_ptr + (mmu_slb_size * i);
> >  #endif
> >diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
> >index a5b40d1..25bc25f 100644
> >--- a/arch/powerpc/sysdev/dart_iommu.c
> >+++ b/arch/powerpc/sysdev/dart_iommu.c
> >@@ -251,8 +251,11 @@ static void allocate_dart(void)
> >  	 * 16MB (1 << 24) alignment. We allocate a full 16Mb chuck since we
> >  	 * will blow up an entire large page anyway in the kernel mapping.
> >  	 */
> >-	dart_tablebase = __va(memblock_alloc_base(1UL<<24,
> >-						  1UL<<24, 0x80000000L));
> >+	dart_tablebase = memblock_alloc_try_nid_raw(SZ_16M, SZ_16M,
> >+					MEMBLOCK_LOW_LIMIT, SZ_2G,
> >+					NUMA_NO_NODE);
> >+	if (!dart_tablebase)
> >+		panic("Failed to allocate 16MB below 2GB for DART table\n");
> >  	/* There is no point scanning the DART space for leaks*/
> >  	kmemleak_no_scan((void *)dart_tablebase);
> >
> 

-- 
Sincerely yours,
Mike.

