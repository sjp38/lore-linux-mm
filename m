Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E2126B021A
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 21:01:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P11KfS005837
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Mar 2010 10:01:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A48BE45DE69
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 10:01:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74BD445DE64
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 10:01:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B217E38001
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 10:01:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3775E3800C
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 10:01:19 +0900 (JST)
Date: Thu, 25 Mar 2010 09:57:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-Id: <20100325095732.107fe878.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100324134816.529778bd.akpm@linux-foundation.org>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-11-git-send-email-mel@csn.ul.ie>
	<20100324134816.529778bd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 13:48:16 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 23 Mar 2010 12:25:45 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:

> > +	/*
> > +	 * We will not stall if the necessary conditions are not met for
> > +	 * migration but direct reclaim seems to account stalls similarly
> > +	 */
> > +	count_vm_event(COMPACTSTALL);
> > +
> > +	/* Compact each zone in the list */
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> > +								nodemask) {
> 
> Will all of this code play nicely with memory hotplug?
> 

If your concern is a race with memory hotplug, I have no concern about that
because memory hotplug makes a range of pages as "not for use" before starting.
If your concern is "code sharing", shared codes between memory hotplug and
compaction is "migrate_pages()".

Other parts are independent from each other.

IIUC.
Memory Hotremove does

	1. select a range for removal [start ....end)
	2. mark free pages as "not for use" by migrate_type
	3. move all used pages to other range.
	4. Finally, all pages in the range will be "not for use"

Compaction does
	1. select a target order
	2. move some free pages to private list
	3. move some used pages to pages in private list.
        4. free pages.

So, techniques to isolate freed pages is different. 
I think it's from their purpose.
 
"freed pages" by compaction is
	- for use
	- a chunk of page from anywhere is ok.

but "freed pages" by memory unplug is 
	- not for use
	- a chunk of page should be in specified range.

For using memory hotplug's code for compaction, we have to specify
"not for use" range. It will make low order compaction innefficient
and it seems not easy to find the best range for compaction.

For compaction, logic used in memory hotplug is too big hummer, I guess.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
