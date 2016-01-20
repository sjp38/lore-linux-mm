Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 20DAD6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 00:46:49 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id q21so9363225iod.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 21:46:49 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id fs8si40399453igb.27.2016.01.19.21.46.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jan 2016 21:46:48 -0800 (PST)
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 20 Jan 2016 15:46:44 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 357BE2CE8054
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:46:35 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0K5kRo55439690
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:46:35 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0K5k280016877
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:46:02 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: mm: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in split_huge_page_to_list
In-Reply-To: <20160118133852.GC14531@node.shutemov.name>
References: <CACT4Y+ayDrEmn31qyoVdnq6vpSbL=XzFWPM5_Ee4GH=Waf27eA@mail.gmail.com> <20160118133852.GC14531@node.shutemov.name>
Date: Wed, 20 Jan 2016 11:15:32 +0530
Message-ID: <87powwvm6b.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, jmarchan@redhat.com, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

......

>
> I think this should fix the issue:
>
> From 10859758dadfa249616870f63c1636ec9857c501 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 18 Jan 2016 16:28:12 +0300
> Subject: [PATCH] thp: fix interrupt unsafe locking in split_huge_page()
>
> split_queue_lock can be taken from interrupt context in some cases, but
> I forgot to convert locking in split_huge_page() to interrupt-safe
> primitives.
>
> Let's fix this.

Can you add the stack trace from the problem reported to the commit
message ?. That will help in identifying the interrupt context call path
easily.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> 
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  mm/huge_memory.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 50342eff7960..21fda6a10e89 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3357,6 +3357,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	struct anon_vma *anon_vma;
>  	int count, mapcount, ret;
>  	bool mlocked;
> +	unsigned long flags;
>
>  	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
>  	VM_BUG_ON_PAGE(!PageAnon(page), page);
> @@ -3396,7 +3397,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  		lru_add_drain();
>
>  	/* Prevent deferred_split_scan() touching ->_count */
> -	spin_lock(&split_queue_lock);
> +	spin_lock_irqsave(&split_queue_lock, flags);
>  	count = page_count(head);
>  	mapcount = total_mapcount(head);
>  	if (!mapcount && count == 1) {
> @@ -3404,11 +3405,11 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  			split_queue_len--;
>  			list_del(page_deferred_list(head));
>  		}
> -		spin_unlock(&split_queue_lock);
> +		spin_unlock_irqrestore(&split_queue_lock, flags);
>  		__split_huge_page(page, list);
>  		ret = 0;
>  	} else if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
> -		spin_unlock(&split_queue_lock);
> +		spin_unlock_irqrestore(&split_queue_lock, flags);
>  		pr_alert("total_mapcount: %u, page_count(): %u\n",
>  				mapcount, count);
>  		if (PageTail(page))
> @@ -3416,7 +3417,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  		dump_page(page, "total_mapcount(head) > 0");
>  		BUG();
>  	} else {
> -		spin_unlock(&split_queue_lock);
> +		spin_unlock_irqrestore(&split_queue_lock, flags);
>  		unfreeze_page(anon_vma, head);
>  		ret = -EBUSY;
>  	}
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
