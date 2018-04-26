Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08DA46B0009
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 15:11:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x205so7591592pgx.19
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 12:11:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1-v6si19257735pld.168.2018.04.26.12.11.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Apr 2018 12:11:15 -0700 (PDT)
Date: Thu, 26 Apr 2018 21:11:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: sections are not offlined during memory hotremove
Message-ID: <20180426191111.GV17484@dhcp22.suse.cz>
References: <20180426155834.16845-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180426155834.16845-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 26-04-18 11:58:34, Pavel Tatashin wrote:
> Memory hotplug, and hotremove operate with per-block granularity. If
> machine has large amount of memory (more than 64G), the size of memory
> block can span multiple sections. By mistake, during hotremove we set
> only the first section to offline state.
> 
> The bug was discovered because kernel selftest started to fail:
> https://lkml.kernel.org/r/20180423011247.GK5563@yexl-desktop
> 
> After commit, "mm/memory_hotplug: optimize probe routine". But, the bug is
> older than this commit. In this optimization we also added a check for
> sections to be in a proper state during hotplug operation.
> 
> Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to have holes")

Dohh. When I saw this I've had that feeling that I have fixed this
already and it must have get lost somewhere. But no, this was the same
bug in a different path b4ccec41af82 ("mm/sparse.c: fix typo in
online_mem_sections"). I wonder why I haven't noticed the same pattern
in the offline path.

Thanks for noticing and fixing this.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/sparse.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 62eef264a7bd..73dc2fcc0eab 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -629,7 +629,7 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  	unsigned long pfn;
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> -		unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
>  		struct mem_section *ms;
>  
>  		/*
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
