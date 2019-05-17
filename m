Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E331C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 15:18:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1074921734
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 15:18:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1074921734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 889F26B0003; Fri, 17 May 2019 11:18:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83B786B0008; Fri, 17 May 2019 11:18:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DB5F6B000A; Fri, 17 May 2019 11:18:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE956B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 11:18:01 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id s145so6550031ywg.17
        for <linux-mm@kvack.org>; Fri, 17 May 2019 08:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=c7v8o1ExcUq48/KuMmzfr/Zhg5wbwAXLkSvkumDp7V8=;
        b=P1MWytpvFsM15wAy5VHljzgDdAG90I9hZoL7WyxCgZnF1d/V2+U+3Wu+xeTEd/VhVR
         /QiJMJx8UeD2454yxVcwL9/4VO3eiJ/g/NfXASqc+Nf5uqgd353508Isj6PNi3SZHA9X
         I2Jv0y+tNmr+lCoDjk92hhKetJRKVixT/kUbnHR7vcVBolRjNmR14/J4KcyQi7eeN61B
         TeuzmXAuU2uRMz8RWyPOuxCxeb7Vf1PosrPn75jBcd+8Rc1aPWSrU6TiQJlNzK1PSFBj
         4pPRAxHQ8k7M3qBpUUxtUysWyaO1bK/ePFgLjj6+fVPVSFGlwlSO1A80rsiLjCVEpUEZ
         EQwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUH1B7i1HAaDKQPKShJJ2QSyahUke/MDOviwLXgSDZlYfPIGNS0
	CEtpls5kuwO9OUQSNHxceAcsmzLDcapOfzTBO2v9+H+2QRaU8fxUljnlMzW0J8Ndysm9YakppIe
	OpKjyRb9Gmxe8SbIbAuzcp1TCMQWYp9ywIf0ieegMUdcVqwSWPBq1GVF3k6okNuAz+A==
X-Received: by 2002:a25:9cc4:: with SMTP id z4mr26418789ybo.92.1558106280956;
        Fri, 17 May 2019 08:18:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypm+wqNLMEJ1RiiEqTWdpIRZKxDKQncMR2kbcKUbs8IKD3N/tk3eLlAjzoBpd14bP0CxRS
X-Received: by 2002:a25:9cc4:: with SMTP id z4mr26418709ybo.92.1558106279581;
        Fri, 17 May 2019 08:17:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558106279; cv=none;
        d=google.com; s=arc-20160816;
        b=bTy0rt7whj16aIprq8aky9P2WbS+xRHgFgxWb9VGp53eAEoshzd6BuEoa/MwiTgXZ1
         hogbU18Lqy9P4SscU+1/pFGqtMXQanqdcEP3zxJ7tsa5ypx8ZofpybjJTgd/9AE0xyoB
         LrLykD4vuyCQSItvAbCldpkMEY5Oq4orAelGWjWdnMPX9ezbI8bPgWyRs9q/SuDpM30h
         o+WDEw96bzerPRr0YMtDYdAu2Hn4WL4zJ7xkkFn13VGFT7U4S5mQ41KW/0O4GN9pOi0p
         e6mCWlQO08umcuUUyfCY5CvHfqtqh8Fa05k/pg4o2wNVxJ1rIZWb5n/jDnX+o5GpsvmN
         uJLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=c7v8o1ExcUq48/KuMmzfr/Zhg5wbwAXLkSvkumDp7V8=;
        b=T7tfCPbDRxJ2JLgpINRHw+EkGwccLKjUOImfASm3l6BJSraIpQYG2YED2VeL8rPgu0
         34TU5sT4fWzqHNIRLsSoiargpGp/Bn9Cy949VBdFAW2ysiN0FfttILw9RUjvkxqn36hw
         Q3ah4sSB0F6ctAtgkWhzhqDE6f1uQnQqwhJ21MScbjFgPZRj3xvS6qgsG5demJMAq36p
         DUbg1ydH6vYIqlkrwvvXLZsNdb8HadvZ3Qo0G9WXY9e8BnwMgEtjM2lGRMX7z3Xr9sGC
         5rfLjm5+5oguf/w3rCMgB6Xvtzntts5uOy0ceDfeUKIFW1RmBYPgp9lWu1nqLSMXZEE6
         y0sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f192si735376ybb.241.2019.05.17.08.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 08:17:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4HF8TcS118143
	for <linux-mm@kvack.org>; Fri, 17 May 2019 11:17:59 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2shw2e743e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 May 2019 11:17:58 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 17 May 2019 16:17:54 +0100
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 17 May 2019 16:17:51 +0100
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4HFHoPi18350418
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 May 2019 15:17:50 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 601856E04C;
	Fri, 17 May 2019 15:17:50 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 952746E050;
	Fri, 17 May 2019 15:17:48 +0000 (GMT)
Received: from [9.199.59.156] (unknown [9.199.59.156])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri, 17 May 2019 15:17:48 +0000 (GMT)
Subject: Re: [PATCH] mm/nvdimm: Pick the right alignment default when creating
 dax devices
To: Vaibhav Jain <vaibhav@linux.vnet.ibm.com>, dan.j.williams@intel.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
        linux-nvdimm@lists.01.org
References: <20190514025449.9416-1-aneesh.kumar@linux.ibm.com>
 <875zq9m8zx.fsf@vajain21.in.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 17 May 2019 20:47:47 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <875zq9m8zx.fsf@vajain21.in.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19051715-0012-0000-0000-000017382F49
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011112; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01204664; UDB=6.00632425; IPR=6.00985599;
 MB=3.00026933; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-17 15:17:52
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051715-0013-0000-0000-0000574DF97B
Message-Id: <de5cbe7d-bd47-6793-1f1a-2274c5c59eb5@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-17_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905170093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/17/19 8:19 PM, Vaibhav Jain wrote:
> Hi Aneesh,
> 
> Apart from a minor review comment for changes to nd_pfn_validate() the
> patch looks good to me.
> 
> Also, I Tested this patch on a PPC64 qemu guest with virtual nvdimm and
> verified that default alignment of newly created devdax namespace was
> 64KiB instead of 16MiB. Below are the test results:
> 
> * Without the patch creating a devdax namespace results in namespace
>    with 16MiB default alignment. Using daxio to zero out the dax device
>    results in a SIGBUS and a hashing failure.
> 
>    $ sudo ndctl create-namespace --mode=devdax  | grep align
>      "align":16777216,
>    "align":16777216
> 
>    $ sudo cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
>    65536 16777216
> 
>    $ sudo daxio.static-debug  -z -o /dev/dax0.0
>    Bus error (core dumped)
> 
>    $ dmesg | tail
>    [  438.738958] lpar: Failed hash pte insert with error -4
>    [  438.739412] hash-mmu: mm: Hashing failure ! EA=0x7fff17000000 access=0x8000000000000006 current=daxio
>    [  438.739760] hash-mmu:     trap=0x300 vsid=0x22cb7a3 ssize=1 base psize=2 psize 10 pte=0xc000000501002b86
>    [  438.740143] daxio[3860]: bus error (7) at 7fff17000000 nip 7fff973c007c lr 7fff973bff34 code 2 in libpmem.so.1.0.0[7fff973b0000+20000]
>    [  438.740634] daxio[3860]: code: 792945e4 7d494b78 e95f0098 7d494b78 f93f00a0 4800012c e93f0088 f93f0120
>    [  438.741015] daxio[3860]: code: e93f00a0 f93f0128 e93f0120 e95f0128 <f9490000> e93f0088 39290008 f93f0110
> 
> * With the patch creating a devdax namespace results in namespace
>    with 64KiB default alignment. Using daxio to zero out the dax device
>    succeeds:
>    
>    $ sudo ndctl create-namespace --mode=devdax  | grep align
>      "align":65536,
>    "align":65536
> 
>    $ sudo cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
>    65536
> 
>    $ daxio -z -o /dev/dax0.0
>    daxio: copied 2130706432 bytes to device "/dev/dax0.0"
> 
> Hence,
> 
> Tested-by: Vaibhav Jain <vaibhav@linux.ibm.com>
> 
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> 
>> Allow arch to provide the supported alignments and use hugepage alignment only
>> if we support hugepage. Right now we depend on compile time configs whereas this
>> patch switch this to runtime discovery.
>>
>> Architectures like ppc64 can have THP enabled in code, but then can have
>> hugepage size disabled by the hypervisor. This allows us to create dax devices
>> with PAGE_SIZE alignment in this case.
>>
>> Existing dax namespace with alignment larger than PAGE_SIZE will fail to
>> initialize in this specific case. We still allow fsdax namespace initialization.
>>
>> With respect to identifying whether to enable hugepage fault for a dax device,
>> if THP is enabled during compile, we default to taking hugepage fault and in dax
>> fault handler if we find the fault size > alignment we retry with PAGE_SIZE
>> fault size.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>   arch/powerpc/include/asm/libnvdimm.h |  9 ++++++++
>>   arch/powerpc/mm/Makefile             |  1 +
>>   arch/powerpc/mm/nvdimm.c             | 34 ++++++++++++++++++++++++++++
>>   arch/x86/include/asm/libnvdimm.h     | 19 ++++++++++++++++
>>   drivers/nvdimm/nd.h                  |  6 -----
>>   drivers/nvdimm/pfn_devs.c            | 32 +++++++++++++++++++++++++-
>>   include/linux/huge_mm.h              |  7 +++++-
>>   7 files changed, 100 insertions(+), 8 deletions(-)
>>   create mode 100644 arch/powerpc/include/asm/libnvdimm.h
>>   create mode 100644 arch/powerpc/mm/nvdimm.c
>>   create mode 100644 arch/x86/include/asm/libnvdimm.h
>>
>> diff --git a/arch/powerpc/include/asm/libnvdimm.h b/arch/powerpc/include/asm/libnvdimm.h
>> new file mode 100644
>> index 000000000000..d35fd7f48603
>> --- /dev/null
>> +++ b/arch/powerpc/include/asm/libnvdimm.h
>> @@ -0,0 +1,9 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +#ifndef _ASM_POWERPC_LIBNVDIMM_H
>> +#define _ASM_POWERPC_LIBNVDIMM_H
>> +
>> +#define nd_pfn_supported_alignments nd_pfn_supported_alignments
>> +extern unsigned long *nd_pfn_supported_alignments(void);
>> +extern unsigned long nd_pfn_default_alignment(void);
>> +
>> +#endif
>> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
>> index 0f499db315d6..42e4a399ba5d 100644
>> --- a/arch/powerpc/mm/Makefile
>> +++ b/arch/powerpc/mm/Makefile
>> @@ -20,3 +20,4 @@ obj-$(CONFIG_HIGHMEM)		+= highmem.o
>>   obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
>>   obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
>>   obj-$(CONFIG_KASAN)		+= kasan/
>> +obj-$(CONFIG_NVDIMM_PFN)		+= nvdimm.o
>> diff --git a/arch/powerpc/mm/nvdimm.c b/arch/powerpc/mm/nvdimm.c
>> new file mode 100644
>> index 000000000000..a29a4510715e
>> --- /dev/null
>> +++ b/arch/powerpc/mm/nvdimm.c
>> @@ -0,0 +1,34 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +
>> +#include <asm/pgtable.h>
>> +#include <asm/page.h>
>> +
>> +#include <linux/mm.h>
>> +/*
>> + * We support only pte and pmd mappings for now.
>> + */
>> +const unsigned long *nd_pfn_supported_alignments(void)
>> +{
>> +	static unsigned long supported_alignments[3];
>> +
>> +	supported_alignments[0] = PAGE_SIZE;
>> +
>> +	if (has_transparent_hugepage())
>> +		supported_alignments[1] = HPAGE_PMD_SIZE;
>> +	else
>> +		supported_alignments[1] = 0;
>> +
>> +	supported_alignments[2] = 0;
>> +	return supported_alignments;
>> +}
>> +
>> +/*
>> + * Use pmd mapping if supported as default alignment
>> + */
>> +unsigned long nd_pfn_default_alignment(void)
>> +{
>> +
>> +	if (has_transparent_hugepage())
>> +		return HPAGE_PMD_SIZE;
>> +	return PAGE_SIZE;
>> +}
>> diff --git a/arch/x86/include/asm/libnvdimm.h b/arch/x86/include/asm/libnvdimm.h
>> new file mode 100644
>> index 000000000000..3d5361db9164
>> --- /dev/null
>> +++ b/arch/x86/include/asm/libnvdimm.h
>> @@ -0,0 +1,19 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +#ifndef _ASM_X86_LIBNVDIMM_H
>> +#define _ASM_X86_LIBNVDIMM_H
>> +
>> +static inline unsigned long nd_pfn_default_alignment(void)
>> +{
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	return HPAGE_PMD_SIZE;
>> +#else
>> +	return PAGE_SIZE;
>> +#endif
>> +}
>> +
>> +static inline unsigned long nd_altmap_align_size(unsigned long nd_align)
>> +{
>> +	return PMD_SIZE;
>> +}
>> +
>> +#endif
>> diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
>> index a5ac3b240293..44fe923b2ee3 100644
>> --- a/drivers/nvdimm/nd.h
>> +++ b/drivers/nvdimm/nd.h
>> @@ -292,12 +292,6 @@ static inline struct device *nd_btt_create(struct nd_region *nd_region)
>>   struct nd_pfn *to_nd_pfn(struct device *dev);
>>   #if IS_ENABLED(CONFIG_NVDIMM_PFN)
>>
>> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> -#define PFN_DEFAULT_ALIGNMENT HPAGE_PMD_SIZE
>> -#else
>> -#define PFN_DEFAULT_ALIGNMENT PAGE_SIZE
>> -#endif
>> -
>>   int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns);
>>   bool is_nd_pfn(struct device *dev);
>>   struct device *nd_pfn_create(struct nd_region *nd_region);
>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
>> index 01f40672507f..347cab166376 100644
>> --- a/drivers/nvdimm/pfn_devs.c
>> +++ b/drivers/nvdimm/pfn_devs.c
>> @@ -18,6 +18,7 @@
>>   #include <linux/slab.h>
>>   #include <linux/fs.h>
>>   #include <linux/mm.h>
>> +#include <asm/libnvdimm.h>
>>   #include "nd-core.h"
>>   #include "pfn.h"
>>   #include "nd.h"
>> @@ -111,6 +112,8 @@ static ssize_t align_show(struct device *dev,
>>   	return sprintf(buf, "%ld\n", nd_pfn->align);
>>   }
>>
>> +#ifndef nd_pfn_supported_alignments
>> +#define nd_pfn_supported_alignments nd_pfn_supported_alignments
>>   static const unsigned long *nd_pfn_supported_alignments(void)
>>   {
>>   	/*
>> @@ -133,6 +136,7 @@ static const unsigned long *nd_pfn_supported_alignments(void)
>>
>>   	return data;
>>   }
>> +#endif
>>
>>   static ssize_t align_store(struct device *dev,
>>   		struct device_attribute *attr, const char *buf, size_t len)
>> @@ -310,7 +314,7 @@ struct device *nd_pfn_devinit(struct nd_pfn *nd_pfn,
>>   		return NULL;
>>
>>   	nd_pfn->mode = PFN_MODE_NONE;
>> -	nd_pfn->align = PFN_DEFAULT_ALIGNMENT;
>> +	nd_pfn->align = nd_pfn_default_alignment();
>>   	dev = &nd_pfn->dev;
>>   	device_initialize(&nd_pfn->dev);
>>   	if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
>> @@ -420,6 +424,20 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
>>   	return 0;
>>   }
>>
>> +static bool nd_supported_alignment(unsigned long align)
>> +{
>> +	int i;
>> +	const unsigned long *supported = nd_pfn_supported_alignments();
>> +
>> +	if (align == 0)
>> +		return false;
>> +
>> +	for (i = 0; supported[i]; i++)
>> +		if (align == supported[i])
>> +			return true;
>> +	return false;
>> +}
>> +
>>   int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>>   {
>>   	u64 checksum, offset;
>> @@ -474,6 +492,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>>   		align = 1UL << ilog2(offset);
>>   	mode = le32_to_cpu(pfn_sb->mode);
>>
>> +	/*
>> +	 * Check whether the we support the alignment. For Dax if the
>> +	 * superblock alignment is not matching, we won't initialize
>> +	 * the device.
>> +	 */
>> +	if (!nd_supported_alignment(align) &&
>> +	    memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
> Suggestion to change this check to:
> 
> if (memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN) &&
>     !nd_supported_alignment(align))
> 
> It would look  a bit more natural i.e. "If the device has dax signature and alignment is
> not supported".
> 

I guess that should be !memcmp()? . I will send an updated patch with 
the hash failure details in the commit message.

-aneesh

