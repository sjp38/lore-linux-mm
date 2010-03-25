Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A90696B01C7
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 22:47:21 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P2lJKb018806
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Mar 2010 11:47:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F9D245DE51
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:47:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 16C8145DE4F
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:47:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CDC8E1DB8013
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:47:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EF541DB8014
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:47:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 06/11] Export fragmentation index via /proc/extfrag_index
In-Reply-To: <20100323120329.GE9590@csn.ul.ie>
References: <20100323050910.A473.A69D9226@jp.fujitsu.com> <20100323120329.GE9590@csn.ul.ie>
Message-Id: <20100325102342.945A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Mar 2010 11:47:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, Mar 23, 2010 at 09:22:04AM +0900, KOSAKI Motohiro wrote:
> > > > > +	/*
> > > > > +	 * Index is between 0 and 1 so return within 3 decimal places
> > > > > +	 *
> > > > > +	 * 0 => allocation would fail due to lack of memory
> > > > > +	 * 1 => allocation would fail due to fragmentation
> > > > > +	 */
> > > > > +	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
> > > > > +}
> > > > 
> > > > Dumb question.
> > > > your paper (http://portal.acm.org/citation.cfm?id=1375634.1375641) says
> > > > fragmentation_index = 1 - (TotalFree/SizeRequested)/BlocksFree
> > > > but your code have extra '1000+'. Why?
> > > 
> > > To get an approximation to three decimal places.
> > 
> > Do you mean this is poor man's round up logic?
> 
> Not exactly.
> 
> The intention is to have a value of 968 instead of 0.968231. i.e.
> instead of a value between 0 and 1, it'll be a value between 0 and 1000
> that matches the first three digits after the decimal place.

Let's consider extream case.

free_pages: 1
requested: 1
free_blocks_total: 1

frag_index = 1000  - ((1000 + 1*1000/1))/1 = -1000

This is not your intension, I guess. 
Probably we don't need any round_up/round_down logic. because fragmentation_index
is only used "if (fragindex >= 0 && fragindex <= 500)" check in try_to_compact_pages().
+1 or -1 inaccurate can be ignored. iow, I think we can remove '1000+' expression.


> > Why don't you use DIV_ROUND_UP? likes following,
> > 
> > return 1000 - (DIV_ROUND_UP(info->free_pages * 1000 / requested) /  info->free_blocks_total);
> > 
> 
> Because it's not doing the same thing unless I missed something.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
