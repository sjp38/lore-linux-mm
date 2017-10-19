Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD2106B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 10:22:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x82so8653191qkb.11
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 07:22:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r124si37000qkf.182.2017.10.19.07.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 07:22:44 -0700 (PDT)
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v9JEMhiv006280
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:22:43 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v9JEMgvc029996
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:22:42 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v9JEMgXR005041
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:22:42 GMT
Received: by mail-oi0-f41.google.com with SMTP id f66so15200574oib.2
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 07:22:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171018144019.c20bc90461c71fc80ac49ff4@linux-foundation.org>
References: <201710181834.h61cZcRt%fengguang.wu@intel.com> <20171018144019.c20bc90461c71fc80ac49ff4@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 19 Oct 2017 10:22:41 -0400
Message-ID: <CAOAebxsJVrDuMEqC+B4RNH5gFb6u7B70RwCceyuHwquRXiB4Zw@mail.gmail.com>
Subject: Re: [linux-next:master 6243/6567] WARNING: vmlinux.o(.text.unlikely+0x5fb7):
 Section mismatch in reference from the function __def_free() to the function .init.text:__free_pages_boot_core()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew,

Yes, we need __init for both: deferred_init_range() and __def_free().

Thank you,
Pavel

On Wed, Oct 18, 2017 at 5:40 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 18 Oct 2017 18:41:44 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
>> head:   a7dd40274d75326ca868479c62090b1198a357ad
>> commit: 430676b385fb341d5a33950bae284d0df2e70117 [6243/6567] mm: deferred_init_memmap improvements
>> config: x86_64-randconfig-it0-10181522 (attached as .config)
>> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
>> reproduce:
>>         git checkout 430676b385fb341d5a33950bae284d0df2e70117
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64
>>
>> All warnings (new ones prefixed by >>):
>>
>> >> WARNING: vmlinux.o(.text.unlikely+0x5fb7): Section mismatch in reference from the function __def_free() to the function .init.text:__free_pages_boot_core()
>>    The function __def_free() references
>>    the function __init __free_pages_boot_core().
>>    This is often because __def_free lacks a __init
>>    annotation or the annotation of __free_pages_boot_core is wrong.
>
> This?
>
> --- a/mm/page_alloc.c~mm-deferred_init_memmap-improvements-fix
> +++ a/mm/page_alloc.c
> @@ -1448,7 +1448,7 @@ static inline void __init pgdat_init_rep
>   * Helper for deferred_init_range, free the given range, reset the counters, and
>   * return number of pages freed.
>   */
> -static inline unsigned long __def_free(unsigned long *nr_free,
> +static unsigned long __init __def_free(unsigned long *nr_free,
>                                        unsigned long *free_base_pfn,
>                                        struct page **page)
>  {
> @@ -1462,8 +1462,8 @@ static inline unsigned long __def_free(u
>         return nr;
>  }
>
> -static unsigned long deferred_init_range(int nid, int zid, unsigned long pfn,
> -                                        unsigned long end_pfn)
> +static unsigned long __init deferred_init_range(int nid, int zid,
> +                               unsigned long pfn, unsigned long end_pfn)
>  {
>         struct mminit_pfnnid_cache nid_init_state = { };
>         unsigned long nr_pgmask = pageblock_nr_pages - 1;
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
