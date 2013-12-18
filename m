Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6B86B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:43:20 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so225781pbc.15
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 13:43:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pk8si966882pab.213.2013.12.18.13.43.17
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 13:43:18 -0800 (PST)
Date: Wed, 18 Dec 2013 13:43:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-Id: <20131218134316.977d5049209d9278e1dad225@linux-foundation.org>
In-Reply-To: <52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
	<20131218032329.GA6044@hacker.(null)>
	<52B11765.8030005@oracle.com>
	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
	<52B166CF.6080300@suse.cz>
	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Dec 2013 17:23:03 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> >>diff --git a/mm/rmap.c b/mm/rmap.c
> >>index 55c8b8d..1e24813 100644
> >>--- a/mm/rmap.c
> >>+++ b/mm/rmap.c
> >>@@ -1347,6 +1347,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
> >>  	unsigned long end;
> >>  	int ret = SWAP_AGAIN;
> >>  	int locked_vma = 0;
> >>+	int we_locked = 0;
> >>
> >>  	address = (vma->vm_start + cursor) & CLUSTER_MASK;
> >>  	end = address + CLUSTER_SIZE;
> >>@@ -1385,9 +1386,15 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
> >>  		BUG_ON(!page || PageAnon(page));
> >>
> >>  		if (locked_vma) {
> >>-			mlock_vma_page(page);   /* no-op if already mlocked */
> >>-			if (page == check_page)
> >>+			if (page != check_page) {
> >>+				we_locked = trylock_page(page);
> >
> >If it's not us who has the page already locked, but somebody else, he
> >might unlock it at this point and then the BUG_ON in mlock_vma_page()
> >will trigger again.

yes, this patch is pretty weak.

> Any better idea is appreciated. ;-)

Remove the BUG_ON() from mlock_vma_page()?  Why was it added?
isolate_lru_page() and putback_lru_page() and *might* require
the page be locked, but I don't immediately see issues?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
