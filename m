Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BFB566B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 04:37:23 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b14so19838006wmb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 01:37:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m189si350791wmb.98.2016.01.05.01.37.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 01:37:22 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, thp: clear PG_mlocked when last mapping gone
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-3-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568B8ECE.7020605@suse.cz>
Date: Tue, 5 Jan 2016 10:37:18 +0100
MIME-Version: 1.0
In-Reply-To: <1451421990-32297-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On 12/29/2015 09:46 PM, Kirill A. Shutemov wrote:
> I missed clear_page_mlock() in page_remove_anon_compound_rmap().
> It usually shouldn't cause any problems since we munlock pages
> explicitly, but in conjunction with missed munlock in __oom_reap_vmas()
> it causes problems:
>   http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
>
> Let's put it in place an mirror behaviour for small pages.
>
> NOTE: I'm not entirely sure why we ever need clear_page_mlock() in
> page_remove_rmap() codepath. It looks redundant to me as we munlock
> pages anyway. But this is out of scope of the patch.

Git blame actually quickly points to commit e6c509f854550 which explains 
it :)

>
> The patch can be folded into
>   "thp: allow mlocked THP again"
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Ack.

> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   mm/rmap.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 384516fb7495..68af2e32f7ed 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1356,6 +1356,9 @@ static void page_remove_anon_compound_rmap(struct page *page)
>   		nr = HPAGE_PMD_NR;
>   	}
>
> +	if (unlikely(PageMlocked(page)))
> +		clear_page_mlock(page);
> +
>   	if (nr) {
>   		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
>   		deferred_split_huge_page(page);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
