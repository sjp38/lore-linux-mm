Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C90DB6B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:08:17 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hm4so7553804wib.8
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 15:08:16 -0700 (PDT)
Message-ID: <5077434D.7080008@suse.cz>
Date: Fri, 12 Oct 2012 00:08:13 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu>            <50770905.5070904@suse.cz> <119175.1349979570@turing-police.cc.vt.edu>
In-Reply-To: <119175.1349979570@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/11/2012 08:19 PM, Valdis.Kletnieks@vt.edu wrote:
> # zgrep COMPAC /proc/config.gz
> CONFIG_COMPACTION=y
> 
> Hope that tells you something useful.

It just supports my another theory. This seems to fix it for me:
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1830,8 +1830,8 @@ static inline bool should_continue_reclaim(struct
lruvec *lruvec,
         */
        pages_for_compaction = (2UL << sc->order);

-       pages_for_compaction = scale_for_compaction(pages_for_compaction,
-                                                   lruvec, sc);
+/*     pages_for_compaction = scale_for_compaction(pages_for_compaction,
+                                                   lruvec, sc);*/
        inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
        if (nr_swap_pages > 0)
                inactive_lru_pages += get_lru_size(lruvec,
LRU_INACTIVE_ANON);

And for you?

(It's an effective revert of "mm: vmscan: scale number of pages
reclaimed by reclaim/compaction based on failures".)

regards,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
