Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F2D846B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 06:04:54 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o82A4qUG012131
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Sep 2010 19:04:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4384E45DE51
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 19:04:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FBFA45DE4F
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 19:04:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 086631DB803C
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 19:04:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B87101DB8038
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 19:04:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan,tmpfs: treat used once pages on tmpfs as used once
In-Reply-To: <AANLkTikKYFkvtAktnwzrmGPf7RNVdakWn0UbcJnc5w_a@mail.gmail.com>
References: <20100901103653.974C.A69D9226@jp.fujitsu.com> <AANLkTikKYFkvtAktnwzrmGPf7RNVdakWn0UbcJnc5w_a@mail.gmail.com>
Message-Id: <20100902185926.B64E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Sep 2010 19:04:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Hi KOSAKI,
> 
> On Wed, Sep 1, 2010 at 10:37 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > When a page has PG_referenced, shrink_page_list() discard it only
> > if it is no dirty. This rule works completely fine if the backend
> > filesystem is regular one. PG_dirty is good signal that it was used
> > recently because flusher thread clean pages periodically. In addition,
> > page writeback is costly rather than simple page discard.
> >
> > However, When a page is on tmpfs, this heuristic don't works because
> > flusher thread don't writeback tmpfs pages. then, tmpfs pages always
> > rotate lru twice at least and it makes unnecessary lru churn. Merely
> > tmpfs streaming io shouldn't cause large anonymous page swap-out.
> 
> It seem to make sense.
> But the why admin use tmps is to keep the contents in memory as far as
> possible than other's file system.
> But this patch has a possibility for tmpfs pages to reclaim early than
> old behavior.
> 
> I admit this routine's goal is not to protect tmpfs page from too early reclaim.
> But at least, it would have affected until now.
> If it is, we might need other demotion prevent mechanism to protect tmpfs pages.
> Is split LRU enough? (I mean we consider tmpfs pages as anonymous
> which is hard to reclaim than file backed pages).

I think so. Split-LRU provide priotize anon rather than regular file. and old behavior is
obvious strange. streaming io tolerance is one of fundamental VM requirement.
So, I think current one is only historical reason.


> 
> I don't mean to oppose this patch and I don't have a any number to
> insist on my opinion.
> Just what I want is that let's think about it more carefully and
> listen other's opinions. :)
> 
> Thanks for good suggestion.
> 
> -- 
> Kind regards,
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
