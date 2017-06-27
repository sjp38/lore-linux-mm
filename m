Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A27EF83296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:24:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z81so31361406wrc.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:24:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v3si14913695wrv.127.2017.06.27.08.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 08:24:29 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5RFNZdn030456
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:24:28 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bbfskvcyq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:24:27 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 27 Jun 2017 11:24:27 -0400
Subject: Re: [RFC v4 09/17] powerpc: call the hash functions with the correct
 pkey value
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
 <1498558319-32466-10-git-send-email-linuxram@us.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 27 Jun 2017 20:54:07 +0530
MIME-Version: 1.0
In-Reply-To: <1498558319-32466-10-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <5e4fa932-4313-5376-2147-a6431bbec16b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com



On Tuesday 27 June 2017 03:41 PM, Ram Pai wrote:
> Pass the correct protection key value to the hash functions on
> page fault.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>   arch/powerpc/include/asm/pkeys.h | 11 +++++++++++
>   arch/powerpc/mm/hash_utils_64.c  |  4 ++++
>   arch/powerpc/mm/mem.c            |  6 ++++++
>   3 files changed, 21 insertions(+)
> 
> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index ef1c601..1370b3f 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -74,6 +74,17 @@ static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
>   }
> 
>   /*
> + * return the protection key of the vma corresponding to the
> + * given effective address @ea.
> + */
> +static inline int mm_pkey(struct mm_struct *mm, unsigned long ea)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, ea);
> +	int pkey = vma ? vma_pkey(vma) : 0;
> +	return pkey;
> +}
> +
> +/*
>

That is not going to work in hash fault path right ? We can't do a 
find_vma there without holding the mmap_sem

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
