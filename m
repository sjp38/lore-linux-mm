Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D90B8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 01:58:22 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so8908646edc.6
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 22:58:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cx1-v6si2713934ejb.63.2019.01.21.22.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 22:58:21 -0800 (PST)
Date: Tue, 22 Jan 2019 07:58:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/hotplug: invalid PFNs from pfn_to_online_page()
Message-ID: <20190122065818.GA4087@dhcp22.suse.cz>
References: <20190121212747.23029-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121212747.23029-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, catalin.marinas@arm.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 21-01-19 16:27:47, Qian Cai wrote:
[...]

Sorry to miss this before but you want to

> +#define pfn_to_online_page(pfn)					   \
> +({								   \
> +	struct page *___page = NULL;				   \
	unsigned long ___pfn = pfn;
> +	unsigned long ___nr = pfn_to_section_nr(pfn);		   \
			      pfn_to_section_nr(___pfn);
> +								   \
> +	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> +	    pfn_valid_within(pfn))				   \
	    pfn_valid_within(___pfn))
	
> +		___page = pfn_to_page(pfn);			   \
> +	___page;						   \
>  })

to prevent from issues when pfn expression has side effects.
-- 
Michal Hocko
SUSE Labs
