Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58A9BC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 085462166E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:49:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 085462166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DC9A6B0005; Fri, 17 May 2019 10:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78CF16B0006; Fri, 17 May 2019 10:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 654DC6B0007; Fri, 17 May 2019 10:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2938D6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:49:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l16so4654825pfb.23
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:49:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=AWHb1Vdqsfj8ky6Sp34Jz0v8fHhXWIitz2FRLSMMlbE=;
        b=OacL3YK6mCClg03rdYyM1Bmh08eYA+6Bj3QrbD/hmuM2/4tJkix7ASsEaVY6tpM/Yb
         1VK3qq/QKWY9Gyyo3+yYOqazSI3Sh6AtaqnMxjTU8KPrTTRkhIVmc5Q0aIAFBkizNUhS
         m5B2QwmSyAPIujnSPtlPzmULUx9T65KD7r2mI68opChY5vnwibambnmgRJyHs+P14Itg
         R98HXTN4b2UMBt/yS3FwJ9axFtvAl2AXVO14275y3G8vsbU5NO/73GjhX+nX/XtdIcTh
         N9qGTuoVc3MlcUgqBm3Oo1YlLEdTOT4oSz5V01b4VQ5EkmYN8/WxcZS3WCvR/tjA/k4D
         GW3A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of vaibhav@linux.vnet.ibm.com) smtp.mailfrom=vaibhav@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW5EsIRDnW78yiBlrQ4GsFEHms69umTI48cT+M09NI43+MTxtaH
	PSeFSj4ymPz6aSNPLU95VSORI9MWKmnzGMjMtd5TYw/PRNPh1uReUAEAytapph9QzEC6/iUa+tE
	8rfU+kFUqkVuwF0WIGkRzuw1+udkZdUKD2hiQl+38zMXWYGhjFDSGY+/8khr043Y=
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr35774239pld.332.1558104572688;
        Fri, 17 May 2019 07:49:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvgDPku3LJ15T1fO8GLFX5ODN6B/nWrQ2CZYEC9Mv+QNnr77cwVAs1mdkOVEXFxOkNb8NC
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr35774155pld.332.1558104571446;
        Fri, 17 May 2019 07:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558104571; cv=none;
        d=google.com; s=arc-20160816;
        b=kS1f+/PcRS9bd6FKcl4lqBurG72gUASkhmaCwoSwBqNQ2ZNGmfCwMszOW9Ohy1stXF
         iuCfq5RLOCiSu1LPtqOyAvCVFR/S0hIjnjdoTCrzIiHoHNc5y0/TcPuIIjZeXOwP6S8i
         HWDBEUhuiRTHQ+HZK5fpKi56OeUDY3Lu3T0UJCGSzeRfB751BSfBj5YQh+Ukyr82JfNO
         x0NU8Jdy8PmK7mIduuxePcKx5HvAOtx56kPtdIR3kGDbPVutOEcd5iui1m3LYQC+yacR
         viYI2CD0LB/dY9PDiRgH6vh2rw437hUJA5vNQQSvLUrboAKnI8zmQbvAOGNkNg06OEoP
         QGGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=AWHb1Vdqsfj8ky6Sp34Jz0v8fHhXWIitz2FRLSMMlbE=;
        b=LXQ+On079eDRboaVvBIjV8IHcN92orwL2Qa4PEpH8mpvIBqZIe0h6xF31ISfgFnCyl
         yOO7SZzIi4ts30jPmaT21fH07STOcwOQr4N706FxRfCRD+X35VUHYL1QQGCvmUJpt/Y1
         cJBhe2DSqAwnqzdGW7GnFmvvBZbarNF9A5YPko1ncY7peW2kuMl3IdAUXuTVyt36zypR
         4E4007V3MvElGrstpjO+I4Mkm4LOZa1UnyUlvFJP0QwqL1SqF/zRmhhe3MEHx1Sa4mx9
         /s/btthkCgNfisM73H4MzNGX+ZsjyG6WmtTbKt7tTxzWSfhotP56aRLFk36hiaY3EqJl
         mSPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of vaibhav@linux.vnet.ibm.com) smtp.mailfrom=vaibhav@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f14si3021542pgv.265.2019.05.17.07.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 07:49:31 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of vaibhav@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of vaibhav@linux.vnet.ibm.com) smtp.mailfrom=vaibhav@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4HEhMQX023539
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:49:30 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2shwt9v1vd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:49:30 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <vaibhav@linux.vnet.ibm.com>;
	Fri, 17 May 2019 15:49:28 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 17 May 2019 15:49:26 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4HEnPBm58654892
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 May 2019 14:49:26 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D1240A4055;
	Fri, 17 May 2019 14:49:25 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5FA92A404D;
	Fri, 17 May 2019 14:49:23 +0000 (GMT)
Received: from vajain21.in.ibm.com (unknown [9.109.195.228])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with SMTP;
	Fri, 17 May 2019 14:49:23 +0000 (GMT)
Received: by vajain21.in.ibm.com (sSMTP sendmail emulation); Fri, 17 May 2019 20:19:22 +0530
From: Vaibhav Jain <vaibhav@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, dan.j.williams@intel.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        linux-nvdimm@lists.01.org
Subject: Re: [PATCH] mm/nvdimm: Pick the right alignment default when creating dax devices
In-Reply-To: <20190514025449.9416-1-aneesh.kumar@linux.ibm.com>
References: <20190514025449.9416-1-aneesh.kumar@linux.ibm.com>
Date: Fri, 17 May 2019 20:19:22 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19051714-0028-0000-0000-0000036EC8A4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051714-0029-0000-0000-0000242E6839
Message-Id: <875zq9m8zx.fsf@vajain21.in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-17_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905170091
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Aneesh,

Apart from a minor review comment for changes to nd_pfn_validate() the
patch looks good to me.

Also, I Tested this patch on a PPC64 qemu guest with virtual nvdimm and
verified that default alignment of newly created devdax namespace was
64KiB instead of 16MiB. Below are the test results:

* Without the patch creating a devdax namespace results in namespace
  with 16MiB default alignment. Using daxio to zero out the dax device
  results in a SIGBUS and a hashing failure.

  $ sudo ndctl create-namespace --mode=devdax  | grep align
    "align":16777216,
  "align":16777216

  $ sudo cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
  65536 16777216

  $ sudo daxio.static-debug  -z -o /dev/dax0.0
  Bus error (core dumped)

  $ dmesg | tail
  [  438.738958] lpar: Failed hash pte insert with error -4
  [  438.739412] hash-mmu: mm: Hashing failure ! EA=0x7fff17000000 access=0x8000000000000006 current=daxio
  [  438.739760] hash-mmu:     trap=0x300 vsid=0x22cb7a3 ssize=1 base psize=2 psize 10 pte=0xc000000501002b86
  [  438.740143] daxio[3860]: bus error (7) at 7fff17000000 nip 7fff973c007c lr 7fff973bff34 code 2 in libpmem.so.1.0.0[7fff973b0000+20000]
  [  438.740634] daxio[3860]: code: 792945e4 7d494b78 e95f0098 7d494b78 f93f00a0 4800012c e93f0088 f93f0120 
  [  438.741015] daxio[3860]: code: e93f00a0 f93f0128 e93f0120 e95f0128 <f9490000> e93f0088 39290008 f93f0110 

* With the patch creating a devdax namespace results in namespace
  with 64KiB default alignment. Using daxio to zero out the dax device
  succeeds:
  
  $ sudo ndctl create-namespace --mode=devdax  | grep align
    "align":65536,
  "align":65536

  $ sudo cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
  65536

  $ daxio -z -o /dev/dax0.0
  daxio: copied 2130706432 bytes to device "/dev/dax0.0"

Hence,

Tested-by: Vaibhav Jain <vaibhav@linux.ibm.com>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> Allow arch to provide the supported alignments and use hugepage alignment only
> if we support hugepage. Right now we depend on compile time configs whereas this
> patch switch this to runtime discovery.
>
> Architectures like ppc64 can have THP enabled in code, but then can have
> hugepage size disabled by the hypervisor. This allows us to create dax devices
> with PAGE_SIZE alignment in this case.
>
> Existing dax namespace with alignment larger than PAGE_SIZE will fail to
> initialize in this specific case. We still allow fsdax namespace initialization.
>
> With respect to identifying whether to enable hugepage fault for a dax device,
> if THP is enabled during compile, we default to taking hugepage fault and in dax
> fault handler if we find the fault size > alignment we retry with PAGE_SIZE
> fault size.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/libnvdimm.h |  9 ++++++++
>  arch/powerpc/mm/Makefile             |  1 +
>  arch/powerpc/mm/nvdimm.c             | 34 ++++++++++++++++++++++++++++
>  arch/x86/include/asm/libnvdimm.h     | 19 ++++++++++++++++
>  drivers/nvdimm/nd.h                  |  6 -----
>  drivers/nvdimm/pfn_devs.c            | 32 +++++++++++++++++++++++++-
>  include/linux/huge_mm.h              |  7 +++++-
>  7 files changed, 100 insertions(+), 8 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/libnvdimm.h
>  create mode 100644 arch/powerpc/mm/nvdimm.c
>  create mode 100644 arch/x86/include/asm/libnvdimm.h
>
> diff --git a/arch/powerpc/include/asm/libnvdimm.h b/arch/powerpc/include/asm/libnvdimm.h
> new file mode 100644
> index 000000000000..d35fd7f48603
> --- /dev/null
> +++ b/arch/powerpc/include/asm/libnvdimm.h
> @@ -0,0 +1,9 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _ASM_POWERPC_LIBNVDIMM_H
> +#define _ASM_POWERPC_LIBNVDIMM_H
> +
> +#define nd_pfn_supported_alignments nd_pfn_supported_alignments
> +extern unsigned long *nd_pfn_supported_alignments(void);
> +extern unsigned long nd_pfn_default_alignment(void);
> +
> +#endif
> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
> index 0f499db315d6..42e4a399ba5d 100644
> --- a/arch/powerpc/mm/Makefile
> +++ b/arch/powerpc/mm/Makefile
> @@ -20,3 +20,4 @@ obj-$(CONFIG_HIGHMEM)		+= highmem.o
>  obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
>  obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
>  obj-$(CONFIG_KASAN)		+= kasan/
> +obj-$(CONFIG_NVDIMM_PFN)		+= nvdimm.o
> diff --git a/arch/powerpc/mm/nvdimm.c b/arch/powerpc/mm/nvdimm.c
> new file mode 100644
> index 000000000000..a29a4510715e
> --- /dev/null
> +++ b/arch/powerpc/mm/nvdimm.c
> @@ -0,0 +1,34 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#include <asm/pgtable.h>
> +#include <asm/page.h>
> +
> +#include <linux/mm.h>
> +/*
> + * We support only pte and pmd mappings for now.
> + */
> +const unsigned long *nd_pfn_supported_alignments(void)
> +{
> +	static unsigned long supported_alignments[3];
> +
> +	supported_alignments[0] = PAGE_SIZE;
> +
> +	if (has_transparent_hugepage())
> +		supported_alignments[1] = HPAGE_PMD_SIZE;
> +	else
> +		supported_alignments[1] = 0;
> +
> +	supported_alignments[2] = 0;
> +	return supported_alignments;
> +}
> +
> +/*
> + * Use pmd mapping if supported as default alignment
> + */
> +unsigned long nd_pfn_default_alignment(void)
> +{
> +
> +	if (has_transparent_hugepage())
> +		return HPAGE_PMD_SIZE;
> +	return PAGE_SIZE;
> +}
> diff --git a/arch/x86/include/asm/libnvdimm.h b/arch/x86/include/asm/libnvdimm.h
> new file mode 100644
> index 000000000000..3d5361db9164
> --- /dev/null
> +++ b/arch/x86/include/asm/libnvdimm.h
> @@ -0,0 +1,19 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _ASM_X86_LIBNVDIMM_H
> +#define _ASM_X86_LIBNVDIMM_H
> +
> +static inline unsigned long nd_pfn_default_alignment(void)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	return HPAGE_PMD_SIZE;
> +#else
> +	return PAGE_SIZE;
> +#endif
> +}
> +
> +static inline unsigned long nd_altmap_align_size(unsigned long nd_align)
> +{
> +	return PMD_SIZE;
> +}
> +
> +#endif
> diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
> index a5ac3b240293..44fe923b2ee3 100644
> --- a/drivers/nvdimm/nd.h
> +++ b/drivers/nvdimm/nd.h
> @@ -292,12 +292,6 @@ static inline struct device *nd_btt_create(struct nd_region *nd_region)
>  struct nd_pfn *to_nd_pfn(struct device *dev);
>  #if IS_ENABLED(CONFIG_NVDIMM_PFN)
>
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define PFN_DEFAULT_ALIGNMENT HPAGE_PMD_SIZE
> -#else
> -#define PFN_DEFAULT_ALIGNMENT PAGE_SIZE
> -#endif
> -
>  int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns);
>  bool is_nd_pfn(struct device *dev);
>  struct device *nd_pfn_create(struct nd_region *nd_region);
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 01f40672507f..347cab166376 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -18,6 +18,7 @@
>  #include <linux/slab.h>
>  #include <linux/fs.h>
>  #include <linux/mm.h>
> +#include <asm/libnvdimm.h>
>  #include "nd-core.h"
>  #include "pfn.h"
>  #include "nd.h"
> @@ -111,6 +112,8 @@ static ssize_t align_show(struct device *dev,
>  	return sprintf(buf, "%ld\n", nd_pfn->align);
>  }
>
> +#ifndef nd_pfn_supported_alignments
> +#define nd_pfn_supported_alignments nd_pfn_supported_alignments
>  static const unsigned long *nd_pfn_supported_alignments(void)
>  {
>  	/*
> @@ -133,6 +136,7 @@ static const unsigned long *nd_pfn_supported_alignments(void)
>
>  	return data;
>  }
> +#endif
>
>  static ssize_t align_store(struct device *dev,
>  		struct device_attribute *attr, const char *buf, size_t len)
> @@ -310,7 +314,7 @@ struct device *nd_pfn_devinit(struct nd_pfn *nd_pfn,
>  		return NULL;
>
>  	nd_pfn->mode = PFN_MODE_NONE;
> -	nd_pfn->align = PFN_DEFAULT_ALIGNMENT;
> +	nd_pfn->align = nd_pfn_default_alignment();
>  	dev = &nd_pfn->dev;
>  	device_initialize(&nd_pfn->dev);
>  	if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
> @@ -420,6 +424,20 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
>  	return 0;
>  }
>
> +static bool nd_supported_alignment(unsigned long align)
> +{
> +	int i;
> +	const unsigned long *supported = nd_pfn_supported_alignments();
> +
> +	if (align == 0)
> +		return false;
> +
> +	for (i = 0; supported[i]; i++)
> +		if (align == supported[i])
> +			return true;
> +	return false;
> +}
> +
>  int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>  {
>  	u64 checksum, offset;
> @@ -474,6 +492,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>  		align = 1UL << ilog2(offset);
>  	mode = le32_to_cpu(pfn_sb->mode);
>
> +	/*
> +	 * Check whether the we support the alignment. For Dax if the
> +	 * superblock alignment is not matching, we won't initialize
> +	 * the device.
> +	 */
> +	if (!nd_supported_alignment(align) &&
> +	    memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
Suggestion to change this check to:

if (memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN) &&
   !nd_supported_alignment(align))

It would look  a bit more natural i.e. "If the device has dax signature and alignment is
not supported". 


> +		dev_err(&nd_pfn->dev, "init failed, settings mismatch\n");
> +		dev_dbg(&nd_pfn->dev, "align: %lx:%lx\n", nd_pfn->align, align);
> +		return -EINVAL;
> +	}
> +
>  	if (!nd_pfn->uuid) {
>  		/*
>  		 * When probing a namepace via nd_pfn_probe() the uuid
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 381e872bfde0..d5cfea3d8b86 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -110,7 +110,12 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>
>  	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>  		return true;
> -
> +	/*
> +	 * For dax let's try to do hugepage fault always. If we don't support
> +	 * hugepages we will not have enabled namespaces with hugepage alignment.
> +	 * This also means we try to handle hugepage fault on device with
> +	 * smaller alignment. But for then we will return with VM_FAULT_FALLBACK
> +	 */
>  	if (vma_is_dax(vma))
>  		return true;
>
> -- 
> 2.21.0
>

-- 
Vaibhav Jain <vaibhav@linux.ibm.com>
Linux Technology Center, IBM India Pvt. Ltd.

