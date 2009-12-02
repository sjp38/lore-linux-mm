Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BD8F460021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:41:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB22fuad031854
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Dec 2009 11:41:57 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF7F445DE79
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:41:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8413E45DE60
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:41:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 69EEB1DB8040
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:41:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AE801DB803A
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:41:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] high system time & lock contention running large mixed workload
In-Reply-To: <4B15CEE0.2030503@redhat.com>
References: <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com> <4B15CEE0.2030503@redhat.com>
Message-Id: <20091202113809.5C4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Dec 2009 11:41:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> On 12/01/2009 11:41 AM, Larry Woodman wrote:
> >
> > Agreed.  The attached updated patch only does a trylock in the
> > page_referenced() call from shrink_inactive_list() and only for
> > anonymous pages when the priority is either 10, 11 or
> > 12(DEF_PRIORITY-2).  I have never seen a problem like this with active
> > pagecache pages and it does not alter the existing shrink_page_list
> > behavior.  What do you think about this???
> This is reasonable, except for the fact that pages that are moved
> to the inactive list without having the referenced bit cleared are
> guaranteed to be moved back to the active list.
> 
> You'll be better off without that excess list movement, by simply
> moving pages directly back onto the active list if the trylock
> fails.
> 
> Yes, this means that page_referenced can now return 3 different
> return values (not accessed, accessed, lock contended), which
> should probably be an enum so we can test for the values
> symbolically in the calling functions.
> 
> That way only pages where we did manage to clear the referenced bit
> will be moved onto the inactive list.  This not only reduces the
> amount of excess list movement, it also makes sure that the pages
> which do get onto the inactive list get a fair chance at being
> referenced again, instead of potentially being flooded out by pages
> where the trylock failed.

Agreed.


> A minor nitpick: maybe it would be good to rename the "try" parameter
> to "noblock".  That more closely matches the requested behaviour.

Another minor nit: probably we have to rename page_referenced(). it imply test
reference bit. but we use it for clear reference bit in shrink_active_list.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
