Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2155E6B020C
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 01:44:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D5icFm005308
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Apr 2010 14:44:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F0CB45DE4F
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 14:44:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 10DCE45DE4E
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 14:44:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E14711DB8014
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 14:44:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B1E11DB8013
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 14:44:34 +0900 (JST)
Date: Tue, 13 Apr 2010 14:40:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
Message-Id: <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	<20100412164335.GQ25756@csn.ul.ie>
	<i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010 13:34:52 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Apr 13, 2010 at 1:43 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Sat, Apr 10, 2010 at 07:49:32PM +0800, Bob Liu wrote:
> >> Since alloc_pages_exact_node() is not for allocate page from
> >> exact node but just for removing check of node's valid,
> >> rename it to alloc_pages_from_valid_node(). Else will make
> >> people misunderstanding.
> >>
> >
> > I don't know about this change either but as I introduced the original
> > function name, I am biased. My reading of it is - allocate me pages and
> > I know exactly which node I need. I see how it it could be read as
> > "allocate me pages from exactly this node" but I don't feel the new
> > naming is that much clearer either.
> 
> Tend to agree.
> Then, don't change function name but add some comment?
> 
> /*
>  * allow pages from fallback if page allocator can't find free page in your nid.
>  * If you want to allocate page from exact node, please use
> __GFP_THISNODE flags with
>  * gfp_mask.
>  */
> static inline struct page *alloc_pages_exact_node(....
> 
I vote for this rather than renaming.

There are two functions
	allo_pages_node()
	alloc_pages_exact_node().

Sane progmrammers tend to see implementation details if there are 2
similar functions.

If I name the function,
	alloc_pages_node_verify_nid() ?

I think /* This doesn't support nid=-1, automatic behavior. */ is necessary
as comment.

OFF_TOPIC

If you want renaming,  I think we should define NID=-1 as

#define ARBITRARY_NID		(-1) or
#define CURRENT_NID		(-1) or
#define AUTO_NID		(-1)

or some. Then, we'll have concensus of NID=-1 support.
(Maybe some amount of programmers don't know what NID=-1 means.)

The function will be
	alloc_pages_node_no_auto_nid() /* AUTO_NID is not supported by this */
or
	alloc_pages_node_veryfy_nid()

Maybe patch will be bigger and may fail after discussion. But it seems
worth to try.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
