Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C35126B2A4C
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:25:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so2919620pgp.3
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:25:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13-v6si4211365plq.320.2018.08.23.06.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 06:25:28 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:25:26 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the
 boundary for pfn check
Message-ID: <20180823132526.GL29735@dhcp22.suse.cz>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-4-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823130732.9489-4-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu 23-08-18 21:07:32, Wei Yang wrote:
> And it is known, __highest_present_section_nr is a more strict boundary
> than NR_MEM_SECTIONS.
> 
> This patch uses a __highest_present_section_nr to check a valid pfn.

But why is this an improvement? Sure when you loop over all sections
than __highest_present_section_nr makes a lot of sense. But all the
updated function perform a trivial comparision.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  include/linux/mmzone.h | 4 ++--
>  mm/sparse.c            | 1 +
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 33086f86d1a7..5138efde11ae 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1237,7 +1237,7 @@ extern int __highest_present_section_nr;
>  #ifndef CONFIG_HAVE_ARCH_PFN_VALID
>  static inline int pfn_valid(unsigned long pfn)
>  {
> -	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> +	if (pfn_to_section_nr(pfn) > __highest_present_section_nr)
>  		return 0;
>  	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>  }
> @@ -1245,7 +1245,7 @@ static inline int pfn_valid(unsigned long pfn)
>  
>  static inline int pfn_present(unsigned long pfn)
>  {
> -	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> +	if (pfn_to_section_nr(pfn) > __highest_present_section_nr)
>  		return 0;
>  	return present_section(__nr_to_section(pfn_to_section_nr(pfn)));
>  }
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 90bab7f03757..a9c55c8da11f 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -174,6 +174,7 @@ void __meminit mminit_validate_memmodel_limits(unsigned long *start_pfn,
>   * those loops early.
>   */
>  int __highest_present_section_nr;
> +EXPORT_SYMBOL(__highest_present_section_nr);
>  static void section_mark_present(struct mem_section *ms)
>  {
>  	int section_nr = __section_nr(ms);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
