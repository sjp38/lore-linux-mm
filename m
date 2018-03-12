Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 479F46B0005
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 13:11:24 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id i9so9793515oth.3
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 10:11:24 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t16si2047009oih.278.2018.03.12.10.11.23
        for <linux-mm@kvack.org>;
        Mon, 12 Mar 2018 10:11:23 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] mm/page_alloc: fix memmap_init_zone pageblock
 alignment
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <cover.1520011944.git.neelx@redhat.com>
 <0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com>
 <20180302164052.5eea1b896e3a7125d1e1f23a@linux-foundation.org>
 <CACjP9X_tpVVDPUvyc-B2QU=2J5MXbuFsDcG90d7L0KuwEEuR-g@mail.gmail.com>
 <CAPKp9ubzXBMeV6Oi=KW1HaPOrv_P78HOXcdQeZ5e1=bqY97tkA@mail.gmail.com>
 <CA+G9fYvWm5NYX64POULrdGB1c3Ar3WfZAsBTEKw4+NYQ_mmddA@mail.gmail.com>
 <CACjP9X96_Wtj3WOXgkjfijN-ZXB9pS=K547-JerRq4QKkrYkfQ@mail.gmail.com>
From: Sudeep Holla <sudeep.holla@arm.com>
Message-ID: <461ae12b-bdff-0987-3b4e-0d7dbc09b2eb@arm.com>
Date: Mon, 12 Mar 2018 17:11:16 +0000
MIME-Version: 1.0
In-Reply-To: <CACjP9X96_Wtj3WOXgkjfijN-ZXB9pS=K547-JerRq4QKkrYkfQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>, Naresh Kamboju <naresh.kamboju@linaro.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, linux- stable <stable@vger.kernel.org>



On 12/03/18 16:51, Daniel Vacek wrote:
[...]

> 
> Hmm, does it step back perhaps?
> 
> Can you check if below cures the boot hang?
> 

Yes it does fix the boot hang.

> --nX
> 
> ~~~~
> neelx@metal:~/nX/src/linux$ git diff
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3d974cb2a1a1..415571120bbd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5365,8 +5365,10 @@ void __meminit memmap_init_zone(unsigned long
> size, int nid, unsigned long zone,
>                          * the valid region but still depends on correct page
>                          * metadata.
>                          */
> -                       pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
> +                       unsigned long next_pfn;
> +                       next_pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>                                         ~(pageblock_nr_pages-1)) - 1;
> +                       pfn = max(next_pfn, pfn);
>  #endif
>                         continue;
>                 }
> ~~~~
> 

-- 
Regards,
Sudeep
