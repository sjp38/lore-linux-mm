Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6A7636B009D
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 23:14:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P3EPLK017644
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 12:14:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 416F145DE51
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:14:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E1121EF081
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:14:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EFA60E38002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:14:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A3DA81DB8014
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:14:24 +0900 (JST)
Date: Mon, 25 Oct 2010 12:09:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-Id: <20101025120901.88fdbd17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
	<20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025025703.GA13858@localhost>
	<20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 12:05:50 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This changes behavior.
> 
> This "ret" can be > 0 because migrate_page()'s return code is
> "Return: Number of pages not migrated or error code."
> 
> Then, 
> ret < 0  ===> maybe ebusy
> ret > 0  ===> some pages are not migrated. maybe PG_writeback or some
> ret == 0 ===> ok, all condition green. try next chunk soon.
> 
> Then, I added "yield()" and --retrym_max for !ret cases.
                                               ^^^^^^^^
						wrong.

The code here does

ret == 0 ==> ok, all condition green, try next chunk.
ret > 0  ==> all pages are isolated but some pages cannot be migrated. maybe under I/O
	     do yield.
ret < 0  ==> some pages may not be able to be isolated. reduce retrycount and yield()

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
