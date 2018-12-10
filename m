Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBBC68E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 13:19:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so5740317edi.0
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:19:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e21si2731995edc.134.2018.12.10.10.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 10:19:29 -0800 (PST)
Date: Mon, 10 Dec 2018 19:19:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the
 full memory section
Message-ID: <20181210162410.GT1286@dhcp22.suse.cz>
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
 <20181210130712.30148-2-zaslonko@linux.ibm.com>
 <20181210132451.GO1286@dhcp22.suse.cz>
 <bcf681ea-7944-0a16-fbd4-c79ab176e638@linux.bm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bcf681ea-7944-0a16-fbd4-c79ab176e638@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zaslonko Mikhail <zaslonko@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Mon 10-12-18 16:45:37, Zaslonko Mikhail wrote:
> Hello,
> 
> On 10.12.2018 14:24, Michal Hocko wrote:
[...]
> > Why do we need to restrict this to the highest zone? In other words, why
> > cannot we do what I was suggesting earlier [1]. What does prevent other
> > zones to have an incomplete section boundary?
> 
> Well, as you were also suggesting earlier: 'If we do not have a zone which
> spans the rest of the section'. I'm not sure how else we should verify that.

I am not sure I follow here. Why cannot we simply drop end_pfn check and
keep the rest?

> Moreover, I was able to recreate the problem only with the highest zone
> (memory end is not on the section boundary).

What exactly prevents exactmap memmap to generate these unfinished zones?

> > [1] http://lkml.kernel.org/r/20181105183533.GQ4361@dhcp22.suse.cz
> > 
> >> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> >> Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> >> Cc: <stable@vger.kernel.org>
> >> ---
> >>  mm/page_alloc.c | 15 +++++++++++++++
> >>  1 file changed, 15 insertions(+)
> >>
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index 2ec9cc407216..41ef5508e5f1 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -5542,6 +5542,21 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> >>  			cond_resched();
> >>  		}
> >>  	}
> >> +#ifdef CONFIG_SPARSEMEM
> >> +	/*
> >> +	 * If there is no zone spanning the rest of the section
> >> +	 * then we should at least initialize those pages. Otherwise we
> >> +	 * could blow up on a poisoned page in some paths which depend
> >> +	 * on full sections being initialized (e.g. memory hotplug).
> >> +	 */
> >> +	if (end_pfn == max_pfn) {
> >> +		while (end_pfn % PAGES_PER_SECTION) {
> >> +			__init_single_page(pfn_to_page(end_pfn), end_pfn, zone,
> >> +					   nid);
> >> +			end_pfn++;
> >> +		}
> >> +	}
> >> +#endif
> >>  }
> >>  
> >>  #ifdef CONFIG_ZONE_DEVICE
> >> -- 
> >> 2.16.4
> > 
> 
> Thanks,
> Mikhail Zaslonko

-- 
Michal Hocko
SUSE Labs
