From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [v5][PATCH 6/6] mm: vmscan: drain batch list during long
 operations
Date: Mon, 15 Jul 2013 07:51:08 +0800
Message-ID: <22571.456738706$1373845885@news.gmane.org>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200210.259954C3@viggo.jf.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UyW4S-0006q0-3i
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Jul 2013 01:51:16 +0200
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 6A7E56B0068
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 19:51:14 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 20:46:47 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 804732BB0053
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:51:10 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ENZmaa55115876
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:35:48 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6ENp9ID016167
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:51:10 +1000
Content-Disposition: inline
In-Reply-To: <20130603200210.259954C3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, minchan@kernel.org, Dave Hansen <dave@sr71.net>

On Mon, Jun 03, 2013 at 01:02:10PM -0700, Dave Hansen wrote:
>
>From: Dave Hansen <dave.hansen@linux.intel.com>
>
>This was a suggestion from Mel:
>
>	http://lkml.kernel.org/r/20120914085634.GM11157@csn.ul.ie
>
>Any pages we collect on 'batch_for_mapping_removal' will have
>their lock_page() held during the duration of their stay on the
>list.  If some other user is trying to get at them during this
>time, they might end up having to wait.
>
>This ensures that we drain the batch if we are about to perform a
>pageout() or congestion_wait(), either of which will take some
>time.  We expect this to help mitigate the worst of the latency
>increase that the batching could cause.
>
>I added some statistics to the __remove_mapping_batch() code to
>track how large the lists are that we pass in to it.  With this
>patch, the average list length drops about 10% (from about 4.1 to
>3.8).  The workload here was a make -j4 kernel compile on a VM
>with 200MB of RAM.
>
>I've still got the statistics patch around if anyone is
>interested.
>
>Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>---
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

> linux.git-davehans/mm/vmscan.c |   10 ++++++++++
> 1 file changed, 10 insertions(+)
>
>diff -puN mm/vmscan.c~drain-batch-list-during-long-operations mm/vmscan.c
>--- linux.git/mm/vmscan.c~drain-batch-list-during-long-operations	2013-06-03 12:41:31.661762522 -0700
>+++ linux.git-davehans/mm/vmscan.c	2013-06-03 12:41:31.665762700 -0700
>@@ -1001,6 +1001,16 @@ static unsigned long shrink_page_list(st
> 			if (!sc->may_writepage)
> 				goto keep_locked;
>
>+			/*
>+			 * We hold a bunch of page locks on the batch.
>+			 * pageout() can take a while, so drain the
>+			 * batch before we perform pageout.
>+			 */
>+			nr_reclaimed +=
>+		               __remove_mapping_batch(&batch_for_mapping_rm,
>+		                                      &ret_pages,
>+		                                      &free_pages);
>+
> 			/* Page is dirty, try to write it out here */
> 			switch (pageout(page, mapping, sc)) {
> 			case PAGE_KEEP:
>_
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
