Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 539416B0099
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 23:37:17 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 12 Sep 2012 09:07:13 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8C3b9Q86619424
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 09:07:10 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8C96jwt017428
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:36:45 +0530
Message-ID: <50500360.5020700@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2012 11:37:04 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and khugepaged_alloc_page
References: <5028E12C.70101@linux.vnet.ibm.com> <5028E20C.3080607@linux.vnet.ibm.com> <alpine.LSU.2.00.1209111807030.21798@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1209111807030.21798@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 09/12/2012 10:03 AM, Hugh Dickins wrote:

> What brought me to look at it was hitting "BUG at mm/huge_memory.c:1842!"
> running tmpfs kbuild swapping load (with memcg's memory.limit_in_bytes
> forcing out to swap), while I happened to have CONFIG_NUMA=y.
> 
> That's the VM_BUG_ON(*hpage) on entry to khugepaged_alloc_page().

> 
> So maybe 9/12 is just obscuring what was already a BUG, either earlier
> in your series or elsewhere in mmotm (I've never seen it on 3.6-rc or
> earlier releases, nor without CONFIG_NUMA).  I've not spent any time
> looking for it, maybe it's obvious - can you spot and fix it?

Hugh,

I think i have already found the reason, if i am correct, the bug was existing
before my patch.

Could you please try below patch? And, could please allow me to fix the bug first,
then post another patch to improve the things you dislike?


Subject: [PATCH] thp: fix forgetting to reset the page alloc indicator

If NUMA is enabled, the indicator is not reset if the previous page
request is failed, then it will trigger the BUG_ON in khugepaged_alloc_page

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e366ca5..66d2bc6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1825,6 +1825,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 			return false;

 		*wait = false;
+		*hpage = NULL;
 		khugepaged_alloc_sleep();
 	} else if (*hpage) {
 		put_page(*hpage);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
