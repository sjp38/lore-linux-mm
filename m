Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 26863600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 01:01:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAU61iO6009839
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 30 Nov 2009 15:01:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ED4445DE52
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:01:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF48645DE4E
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:01:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B6E5A1DB8043
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:01:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DF011DB803C
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:01:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/9] ksm: fix mlockfreed to munlocked
In-Reply-To: <Pine.LNX.4.64.0911271214040.4167@sister.anvils>
References: <20091126162011.GG13095@csn.ul.ie> <Pine.LNX.4.64.0911271214040.4167@sister.anvils>
Message-Id: <20091130143915.5BD1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 30 Nov 2009 15:01:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 26 Nov 2009, Mel Gorman wrote:
> > On Tue, Nov 24, 2009 at 04:40:55PM +0000, Hugh Dickins wrote:
> > > When KSM merges an mlocked page, it has been forgetting to munlock it:
> > > that's been left to free_page_mlock(), which reports it in /proc/vmstat
> > > as unevictable_pgs_mlockfreed instead of unevictable_pgs_munlocked (and
> > > whinges "Page flag mlocked set for process" in mmotm, whereas mainline
> > > is silently forgiving).  Call munlock_vma_page() to fix that.
> > > 
> > > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > 
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> Rik & Mel, thanks for the Acks.
> 
> But please clarify: that patch was for mmotm and hopefully 2.6.33,
> but the vmstat issue (minus warning message) is there in 2.6.32-rc.
> Should I
> 
> (a) forget it for 2.6.32
> (b) rush Linus a patch for 2.6.32 final
> (c) send a patch for 2.6.32.stable later on

I personally prefer (3). though I don't know ksm so detail.


> 
> ? I just don't have a feel for how important this is.
> 
> Typically, these pages are immediately freed, and the only issue is
> which stats they get added to; but if fork has copied them into other
> mms, then such pages might stay unevictable indefinitely, despite no
> longer being in any mlocked vma.
> 
> There's a remark in munlock_vma_page(), apropos a different issue,
> 			/*
> 			 * We lost the race.  let try_to_unmap() deal
> 			 * with it.  At least we get the page state and
> 			 * mlock stats right.  However, page is still on
> 			 * the noreclaim list.  We'll fix that up when
> 			 * the page is eventually freed or we scan the
> 			 * noreclaim list.
> 			 */
> which implies that sometimes we scan the unevictable list and resolve
> such cases.  But I wonder if that's nowadays the case?

We don't scan unevictable list at all. munlock_vma_page() logic is.

  1) clear PG_mlock always anyway
  2) isolate page
  3) scan related vma and remark PG_mlock if necessary

So, as far as I understand, the above comment describe the case when (2) is
failed. it mean another task already isolated the page. it makes the task
putback the page to evictable list and vmscan's try_to_unmap() move 
the page to unevictable list again.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
