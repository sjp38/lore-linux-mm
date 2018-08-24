Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 005A86B2CC6
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 20:09:15 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o16-v6so4147804pgv.21
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:09:14 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n7-v6si5249214plk.254.2018.08.23.17.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 17:09:13 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm/sparse: expand the CONFIG_SPARSEMEM_EXTREME range
 in __nr_to_section()
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-3-richard.weiyang@gmail.com>
 <20180823132112.GK29735@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ebdfe4aa-225c-8239-9f8d-065de8a5ddfc@intel.com>
Date: Thu, 23 Aug 2018 17:09:12 -0700
MIME-Version: 1.0
In-Reply-To: <20180823132112.GK29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On 08/23/2018 06:21 AM, Michal Hocko wrote:
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1155,9 +1155,9 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
>  #ifdef CONFIG_SPARSEMEM_EXTREME
>  	if (!mem_section)
>  		return NULL;
> -#endif
>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>  		return NULL;
> +#endif
>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
>  }

This patch has no practical effect and only adds unnecessary churn.

#ifdef CONFIG_SPARSEMEM_EXTREME
...
#else
struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
#endif

The compiler knows that NR_SECTION_ROOTS==1 and that
!mem_section[SECTION_NR_TO_ROOT(nr) is always false.  It doesn't need
our help.

My goal with the sparsemem code, and code in general is t avoid #ifdefs
whenever possible and limit their scope to the smallest possible area
whenever possible.
