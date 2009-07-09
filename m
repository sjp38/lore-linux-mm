Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C9BAC6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 00:54:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6958dea027774
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 14:08:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 67BB645DE70
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:08:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E20D45DE60
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:08:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 216D31DB803E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:08:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFE331DB8037
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 14:08:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH 2/2] Don't continue reclaim if the system have plenty  free memory
In-Reply-To: <28c262360907070620n3e22801egd4493c149a263ecd@mail.gmail.com>
References: <20090707184714.0C73.A69D9226@jp.fujitsu.com> <28c262360907070620n3e22801egd4493c149a263ecd@mail.gmail.com>
Message-Id: <20090709140234.239F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 14:08:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> Hi, Kosaki.
> 
> On Tue, Jul 7, 2009 at 6:48 PM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> > Subject: [PATCH] Don't continue reclaim if the system have plenty free memory
> >
> > On concurrent reclaim situation, if one reclaimer makes OOM, maybe other
> > reclaimer can stop reclaim because OOM killer makes enough free memory.
> >
> > But current kernel doesn't have its logic. Then, we can face following accidental
> > 2nd OOM scenario.
> >
> > 1. System memory is used by only one big process.
> > 2. memory shortage occur and concurrent reclaim start.
> > 3. One reclaimer makes OOM and OOM killer kill above big process.
> > 4. Almost reclaimable page will be freed.
> > 5. Another reclaimer can't find any reclaimable page because those pages are
> > ? already freed.
> > 6. Then, system makes accidental and unnecessary 2nd OOM killer.
> >
> 
> Did you see the this situation ?
> Why I ask is that we have already a routine for preventing parallel
> OOM killing in __alloc_pages_may_oom.
>
> Couldn't it protect your scenario ?

Can you please see actual code of this patch?
Those two patches fix different problem.

1/2 fixes the issue of that concurrent direct reclaimer makes
too many isolated pages.
2/2 fixes the issue of that reclaim and exit race makes accidental oom.


> If it can't, Could you explain the scenario in more detail ?

__alloc_pages_may_oom() check don't effect the threads of already
entered reclaim. it's obvious.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
