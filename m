Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6136B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 03:08:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so880261pff.23
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 00:08:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q4-v6si695036pgr.515.2018.04.27.00.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 00:08:37 -0700 (PDT)
Date: Fri, 27 Apr 2018 09:08:28 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: sections are not offlined during memory hotremove
Message-ID: <20180427070828.GC4931@kroah.com>
References: <20180426203002.3151-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180426203002.3151-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, mhocko@suse.com, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Apr 26, 2018 at 04:30:02PM -0400, Pavel Tatashin wrote:
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
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
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
> 2.17.0

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>
