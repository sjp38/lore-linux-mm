Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C710C6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:08:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e10so3297753pff.3
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:08:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x20sor1279033pfj.151.2018.03.15.07.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 07:08:25 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
References: <20180313224240.25295-1-neelx@redhat.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <049a38e2-c446-85f4-656c-91d4e5bb1c0d@gmail.com>
Date: Thu, 15 Mar 2018 22:08:12 +0800
MIME-Version: 1.0
In-Reply-To: <20180313224240.25295-1-neelx@redhat.com>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Sudeep Holla <sudeep.holla@arm.com>, Naresh Kamboju <naresh.kamboju@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, ard.biesheuvel@linaro.org

Hi Daniel


On 3/14/2018 6:42 AM, Daniel Vacek Wrote:
> On some architectures (reported on arm64) commit 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
> causes a boot hang. This patch fixes the hang making sure the alignment
> never steps back.
>
> Link: http://lkml.kernel.org/r/0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com
> Fixes: 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
> Signed-off-by: Daniel Vacek <neelx@redhat.com>
> Tested-by: Sudeep Holla <sudeep.holla@arm.com>
> Tested-by: Naresh Kamboju <naresh.kamboju@linaro.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Paul Burton <paul.burton@imgtec.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: <stable@vger.kernel.org>
> ---
>   mm/page_alloc.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3d974cb2a1a1..e033a6895c6f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5364,9 +5364,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>   			 * is not. move_freepages_block() can shift ahead of
>   			 * the valid region but still depends on correct page
>   			 * metadata.
> +			 * Also make sure we never step back.
>   			 */
> -			pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
> +			unsigned long next_pfn;
> +
> +			next_pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>   					~(pageblock_nr_pages-1)) - 1;
> +			if (next_pfn > pfn)
> +				pfn = next_pfn;
It didn't resolve the booting hang issue in my arm64 server.
what if memblock_next_valid_pfn(pfn, end_pfn) is 32 and 
pageblock_nr_pages is 8196?
Thus, next_pfn will be (unsigned long)-1 and be larger than pfn.
So still there is an infinite loop here.

Cheers,
Jia He
>   #endif
>   			continue;
>   		}

-- 
Cheers,
Jia
