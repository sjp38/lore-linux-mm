Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 728016B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 20:46:33 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 13 May 2012 18:46:32 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 64AA7C9005A
	for <linux-mm@kvack.org>; Sun, 13 May 2012 20:46:27 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4E0kU70132088
	for <linux-mm@kvack.org>; Sun, 13 May 2012 20:46:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4E0kTuv015566
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:46:29 -0300
Date: Mon, 14 May 2012 08:46:23 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] MM: cleanup on addition to bootmem data list
Message-ID: <20120514004623.GB8465@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1336612620-7596-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336612620-7596-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Hi Andrew,

Not sure you got chance to having quick look on this?

Thanks,
Gavin

>The objects of "struct bootmem_data_t" are being linked together
>to form double-linked list sequentially based on its minimal page
>frame number. Current implementation implicitly supports the
>following cases, which means the inserting point for current bootmem
>data depends on how "list_for_each" works. That makes the code a
>little hard to read. Besides, "list_for_each" and "list_entry" can
>be replaced with "list_for_each_entry".
>
>        - The linked list is empty.
>        - There has no entry in the linked list, whose minimal page
>          frame number is bigger than current one.
>
>Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>---
> mm/bootmem.c |   16 ++++++++--------
> 1 files changed, 8 insertions(+), 8 deletions(-)
>
>diff --git a/mm/bootmem.c b/mm/bootmem.c
>index 0131170..5a04536 100644
>--- a/mm/bootmem.c
>+++ b/mm/bootmem.c
>@@ -77,16 +77,16 @@ unsigned long __init bootmem_bootmap_pages(unsigned long pages)
>  */
> static void __init link_bootmem(bootmem_data_t *bdata)
> {
>-	struct list_head *iter;
>+	bootmem_data_t *ent;
>
>-	list_for_each(iter, &bdata_list) {
>-		bootmem_data_t *ent;
>-
>-		ent = list_entry(iter, bootmem_data_t, list);
>-		if (bdata->node_min_pfn < ent->node_min_pfn)
>-			break;
>+	list_for_each_entry(ent, &bdata_list, list) {
>+		if (bdata->node_min_pfn < ent->node_min_pfn) {
>+			list_add_tail(&bdata->list, &ent->list);
>+			return;
>+		}
> 	}
>-	list_add_tail(&bdata->list, iter);
>+
>+	list_add_tail(&bdata->list, &bdata_list);
> }
>
> /*
>-- 
>1.7.5.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
