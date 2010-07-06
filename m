Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 209A26B01AF
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 07:13:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o66BDfwt023850
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Jul 2010 20:13:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BE7145DE60
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 20:13:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1875345DE4D
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 20:13:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 021F91DB8037
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 20:13:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B5711DB8040
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 20:13:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
In-Reply-To: <20100706101235.GE13780@csn.ul.ie>
References: <20100706093529.CCD1.A69D9226@jp.fujitsu.com> <20100706101235.GE13780@csn.ul.ie>
Message-Id: <20100706200310.CD06.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Jul 2010 20:13:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jul 06, 2010 at 09:36:41AM +0900, KOSAKI Motohiro wrote:
> > Hello,
> > 
> > > Ok, that's reasonable as I'm still working on that patch. For example, the
> > > patch disabled anonymous page writeback which is unnecessary as the stack
> > > usage for anon writeback is less than file writeback. 
> > 
> > How do we examine swap-on-file?
> > 
> 
> Anything in particular wrong with the following?
> 
> /*
>  * For now, only kswapd can writeback filesystem pages as otherwise
>  * there is a stack overflow risk
>  */
> static inline bool reclaim_can_writeback(struct scan_control *sc,
>                                         struct page *page)
> {
>         return !page_is_file_cache(page) || current_is_kswapd();
> }
> 
> Even if it is a swapfile, I didn't spot a case where the filesystems
> writepage would be called. Did I miss something?

Hmm...

Now, I doubt I don't understand your mention. Do you mean you intend to swtich task
stack when every writepage? It seems a bit costly. but otherwise write-page for anon
makes filesystem IO and stack-overflow.

Can you please elaborate your plan?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
