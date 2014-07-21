Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id C322F6B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:46:17 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so7330100ieb.4
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:46:17 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id qt5si17809702igb.41.2014.07.21.15.46.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 15:46:17 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id h18so3365805igc.6
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:46:16 -0700 (PDT)
Date: Mon, 21 Jul 2014 15:46:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH=5D_mm=EF=BC=9Abugfix=2C_pfn=5Fvalid_sometimes_return_incorrect_when_memmap_parameter_specified?=
In-Reply-To: <615092B2FD0E7648B6E4B43E029BCFB852D66798@SZXEMA503-MBS.china.huawei.com>
Message-ID: <alpine.DEB.2.02.1407211544280.29389@chino.kir.corp.google.com>
References: <615092B2FD0E7648B6E4B43E029BCFB852D66798@SZXEMA503-MBS.china.huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wulizhen (Pss)" <pss.wulizhen@huawei.com>

On Mon, 21 Jul 2014, Huangpeng (Peter) wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 835aa3d..c54284b 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1199,7 +1199,7 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
>  #ifndef CONFIG_HAVE_ARCH_PFN_VALID
>  static inline int pfn_valid(unsigned long pfn)
>  {
> - if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> + if (pfn >= max_pfn || pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>   return 0;
>   return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>  }

Why should valid_section() return non-zero for sparsemem if it is above 
max_pfn?  (I think you're modifying the wrong function.)

Your patch is also whitespace damaged and cannot be applied, please see 
Documentation/SubmittingPatches which also references 
Documentation/email-clients.txt.

> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 04a9d94..7eb273e 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -31,7 +31,7 @@ EXPORT_SYMBOL(contig_page_data);
>  unsigned long max_low_pfn;
>  unsigned long min_low_pfn;
>  unsigned long max_pfn;
> -
> +EXPORT_SYMBOL(max_pfn);
>  static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
>   u64 goal, u64 limit)
>  {

This is an unrelated change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
