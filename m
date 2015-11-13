Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id DF06B6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:41:19 -0500 (EST)
Received: by iofh3 with SMTP id h3so91275611iof.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 00:41:19 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id u93si23749583ioi.92.2015.11.13.00.41.17
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 00:41:19 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
Date: Fri, 13 Nov 2015 16:41:03 +0800
Message-ID: <0ab001d11def$081c80d0$18558270$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: 'yalin wang' <yalin.wang2010@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> Instead of the condition, we could have:
> 
> 	__entry->pfn = page ? page_to_pfn(page) : -1;
> 
> 
> But if there's no reason to do the tracepoint if page is NULL, then
> this patch is fine. I'm just throwing out this idea.
> 
we trace only if page is valid

--- linux-next/mm/huge_memory.c	Fri Nov 13 16:00:22 2015
+++ b/mm/huge_memory.c	Fri Nov 13 16:26:19 2015
@@ -1987,7 +1987,8 @@ static int __collapse_huge_page_isolate(
 
 out:
 	release_pte_pages(pte, _pte);
-	trace_mm_collapse_huge_page_isolate(page_to_pfn(page), none_or_zero,
+	if (page)
+		trace_mm_collapse_huge_page_isolate(page_to_pfn(page), none_or_zero,
 					    referenced, writable, result);
 	return 0;
 }
--



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
