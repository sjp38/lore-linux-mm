Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 344AD6B0087
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:22:29 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G4MWYI009788
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 13:22:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E5C445DE54
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:22:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 93C9045DE51
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:22:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 815A11DB803C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:22:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 38D9AE1800D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:22:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
In-Reply-To: <20090715201654.550cb640.akpm@linux-foundation.org>
References: <20090716095119.9D0A.A69D9226@jp.fujitsu.com> <20090715201654.550cb640.akpm@linux-foundation.org>
Message-Id: <20090716131928.9D25.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 13:22:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 16 Jul 2009 09:52:34 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> >  	if (file)
> > -		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
> > +		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
> >  	else
> > -		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
> > +		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
> 
> we could have used __sub_zone_page_state() there.

__add_zone_page_state() and __sub_zone_page_state() are no user.

Instead, we can remove it?


==============================================
Subject: Kill __{add,sub}_zone_page_state()

Currently, __add_zone_page_state() and __sub_zone_page_state() are unused.
This patch remove it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/vmstat.h |    5 -----
 1 file changed, 5 deletions(-)

Index: b/include/linux/vmstat.h
===================================================================
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -210,11 +210,6 @@ extern void zone_statistics(struct zone 
 
 #endif /* CONFIG_NUMA */
 
-#define __add_zone_page_state(__z, __i, __d)	\
-		__mod_zone_page_state(__z, __i, __d)
-#define __sub_zone_page_state(__z, __i, __d)	\
-		__mod_zone_page_state(__z, __i,-(__d))
-
 #define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
