Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ACA286B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:54:15 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P9sD5u025891
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Mar 2010 18:54:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 341B045DE54
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:54:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DD5B945DE5B
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:54:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A2BE38007
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:54:11 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CCA99EF800E
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:54:07 +0900 (JST)
Date: Thu, 25 Mar 2010 18:50:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-Id: <20100325185021.63e16884.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100325094826.GM2024@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-11-git-send-email-mel@csn.ul.ie>
	<20100324101927.0d54f4ad.kamezawa.hiroyu@jp.fujitsu.com>
	<20100324114056.GE21147@csn.ul.ie>
	<20100325093006.cd0361e6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100325094826.GM2024@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010 09:48:26 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> > In that case, compact_finished() can't
> > find there is a free chunk and do more work.  How about using a function like
> > 	 free_pcppages_bulk(zone, pcp->batch, pcp);
> > to bypass pcp list and freeing pages at once ?
> > 
> 
> I think you mean to drain the PCP lists while compaction is happening
> but is it justified? It's potentially a lot of IPI calls just to check
> if compaction can finish a little earlier. If the pages on the PCP lists
> are making that much of a difference to high-order page availability, it
> implies that the zone is pretty full and it's likely that compaction was
> avoided and we direct reclaimed.
> 
Ah, sorry for my short word again. I mean draining "local" pcp list because
a thread which run direct-compaction freed pages. IPI is not necessary and
overkill.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
