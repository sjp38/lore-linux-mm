Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD7466B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 11:13:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so17267136wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 08:13:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si3680799wmf.47.2016.05.10.08.13.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 08:13:14 -0700 (PDT)
Subject: Re: [PATCH 3/6] mm/page_owner: copy last_migrate_reason in
 copy_page_owner()
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5731FA88.2060701@suse.cz>
Date: Tue, 10 May 2016 17:13:12 +0200
MIME-Version: 1.0
In-Reply-To: <1462252984-8524-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/03/2016 07:23 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Currently, copy_page_owner() doesn't copy all the owner information.
> It skips last_migrate_reason because copy_page_owner() is used for
> migration and it will be properly set soon. But, following patch
> will use copy_page_owner() and this skip will cause the problem that
> allocated page has uninitialied last_migrate_reason. To prevent it,
> this patch also copy last_migrate_reason in copy_page_owner().

Hmm it's a corner case, but if the "new" page was dumped e.g. due to a 
bug during the migration, is the copied migrate reason from the "old" 
page actually meaningful? I'd say it might be misleading and it's 
simpler to just make sure it's initialized to -1.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/page_owner.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 792b56d..6693959 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -101,6 +101,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
>
>   	new_ext->order = old_ext->order;
>   	new_ext->gfp_mask = old_ext->gfp_mask;
> +	new_ext->last_migrate_reason = old_ext->last_migrate_reason;
>   	new_ext->nr_entries = old_ext->nr_entries;
>
>   	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
