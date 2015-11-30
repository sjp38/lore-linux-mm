Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id C0A316B0255
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 10:18:50 -0500 (EST)
Received: by lfaz4 with SMTP id z4so201105168lfa.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:18:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v142si29114193lfd.153.2015.11.30.07.18.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 07:18:49 -0800 (PST)
Subject: Re: mm: BUG in __munlock_pagevec
References: <565C5C38.3040705@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565C68D3.7000001@suse.cz>
Date: Mon, 30 Nov 2015 16:18:43 +0100
MIME-Version: 1.0
In-Reply-To: <565C5C38.3040705@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/30/2015 03:24 PM, Sasha Levin wrote:
> Hi all,
> 
> I've hit the following while fuzzing with trinity on the latest -next kernel:
> 
> 
> [  850.305385] page:ffffea001a5a0f00 count:0 mapcount:1 mapping:dead000000000400 index:0x1ffffffffff
> [  850.306773] flags: 0x2fffff80000000()
> [  850.307175] page dumped because: VM_BUG_ON_PAGE(1 && PageTail(page))
> [  850.308027] page_owner info is not active (free page?)
> [  850.308925] ------------[ cut here ]------------
> [  850.309614] kernel BUG at include/linux/page-flags.h:326!
> [  850.310333] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> [  850.311176] Modules linked in:
> [  850.311650] CPU: 5 PID: 7051 Comm: trinity-c129 Not tainted 4.4.0-rc2-next-20151127-sasha-00012-gf0498ca-dirty #2661
> [  850.313115] task: ffff8806eaf08000 ti: ffff8806b1170000 task.ti: ffff8806b1170000
> [  850.314085] RIP: __munlock_pagevec (include/linux/page-flags.h:326 mm/mlock.c:296)

That's TestClearPageMlocked(page) which has PF_NO_TAIL.

The page dump suggests the page was freed between the check triggering,
and the page being dumped. But being on munlock's pagevec should pin the
page. So a pin/unpin mismatch somewhere, together with a race?

Moreover, a PageTail(page) shouldn't even get on the pagevec,
munlock_vma_pages_range() skips tail pages. So another race that made
the page a Tail after it was added to pagevec?

Or maybe __munlock_pagevec_fill() encountered a tail page, and since it
assumes that it can't happen, there's no check. Maybe a VM_BUG_ON_PAGE()
there would catch this earlier? Could be related to "thp: allow mlocked
THP again".

Ah, __munlock_pagevec_fill() does a get_page(), which would increase
page->count on the compound head, which could also explain the mismatch.

------8<------
diff --git a/mm/mlock.c b/mm/mlock.c
index af421d8bd6da..156d2840aa62 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -393,7 +393,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 		if (!page || page_zone_id(page) != zoneid)
 			break;
 
+		VM_BUG_ON_PAGE(PageTail(page), page);
 		get_page(page);
+
 		/*
 		 * Increase the address that will be returned *before* the
 		 * eventual break due to pvec becoming full by adding the page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
