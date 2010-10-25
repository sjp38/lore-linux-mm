Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 52E786B00A3
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 23:53:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P3rmv5028702
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 12:53:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16D5945DE7B
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:53:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31BE545DE70
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:53:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D36A51DB8037
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:53:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A5A81DB803A
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:53:43 +0900 (JST)
Date: Mon, 25 Oct 2010 12:48:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-Id: <20101025124816.330846a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101025034833.GB15933@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
	<20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025025703.GA13858@localhost>
	<20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025120901.88fdbd17.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025034833.GB15933@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 11:48:33 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Mon, Oct 25, 2010 at 11:09:01AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Mon, 25 Oct 2010 12:05:50 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > This changes behavior.
> > > 
> > > This "ret" can be > 0 because migrate_page()'s return code is
> > > "Return: Number of pages not migrated or error code."
> > > 
> > > Then, 
> > > ret < 0  ===> maybe ebusy
> > > ret > 0  ===> some pages are not migrated. maybe PG_writeback or some
> > > ret == 0 ===> ok, all condition green. try next chunk soon.
> > > 
> > > Then, I added "yield()" and --retrym_max for !ret cases.
> >                                                ^^^^^^^^
> > 						wrong.
> > 
> > The code here does
> > 
> > ret == 0 ==> ok, all condition green, try next chunk.
> 
> It seems reasonable to remove the drain operations for "ret == 0"
> case.  That would help large NUMA boxes noticeably I guess.
> 
Maybe.

> > ret > 0  ==> all pages are isolated but some pages cannot be migrated. maybe under I/O
> > 	     do yield.
> 
> Don't know how to deal with the possible "migration fail" pages --
> sorry I have no idea about that situation at all.
> 

In typical case, page_count() > 0 by get_user_pages() or PG_writeback is set.
All we can do is just waiting.


> Perhaps, OOM while offlining pages?
> 

I never see that..because memory offline is scheduled to be done only when
there are free memory.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
