Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE666B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 03:34:37 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so1210812wiw.1
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 00:34:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si7783946wiy.73.2015.01.30.00.34.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 00:34:35 -0800 (PST)
Message-ID: <54CB4218.6000209@suse.cz>
Date: Fri, 30 Jan 2015 09:34:32 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v4] mm: incorporate read-only pages into transparent huge
 pages
References: <1422543547-12591-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1422543547-12591-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, zhangyanfei.linux@aliyun.com

On 01/29/2015 03:59 PM, Ebru Akagunduz wrote:
> This patch aims to improve THP collapse rates, by allowing
> THP collapse in the presence of read-only ptes, like those
> left in place by do_swap_page after a read fault.
> 
> Currently THP can collapse 4kB pages into a THP when
> there are up to khugepaged_max_ptes_none pte_none ptes
> in a 2MB range. This patch applies the same limit for
> read-only ptes.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all but 190MB of the program by
> touching other memory. Afterwards, the test program does
> a mix of reads and writes to its memory, and the memory
> gets swapped back in.
> 
> Without the patch, only the memory that did not get
> swapped out remained in THPs, which corresponds to 24% of
> the memory of the program. The percentage did not increase
> over time.
> 
> With this patch, after 5 minutes of waiting khugepaged had
> collapsed 60% of the program's memory back into THPs.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
> Changes in v2:
>  - Remove extra code indent (Vlastimil Babka)
>  - Add comment line for check condition of page_count() (Vlastimil Babka)
>  - Add fast path optimistic check to
>    __collapse_huge_page_isolate() (Andrea Arcangeli)
>  - Move check condition of page_count() below to trylock_page() (Andrea Arcangeli)
> 
> Changes in v3:
>  - Add a at-least-one-writable-pte check (Zhang Yanfei)
>  - Debug page count (Vlastimil Babka, Andrea Arcangeli)
>  - Increase read-only pte counter if pte is none (Andrea Arcangeli)
> 
> Changes in v4:
>  - Remove read-only counter (Andrea Arcangeli)
>  - Remove debug page count  (Andrea Arcangeli)
>  - Change type of writable as bool (Andrea Arcangeli)
>  - Change type of referenced as bool (Vlastimil Babka)
>  - Change comment line (Vlastimil Babka, Zhang Yanfei)

Looks good, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
