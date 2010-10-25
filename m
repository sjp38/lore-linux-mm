Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 601BF6B00A3
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 23:55:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P3ttZW001703
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 12:55:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D800445DE6E
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:55:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B26A945DE60
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:55:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 988BC1DB803A
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:55:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5295A1DB8037
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:55:54 +0900 (JST)
Date: Mon, 25 Oct 2010 12:50:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-Id: <20101025125027.30582c0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101025032827.GA15933@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
	<20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025025703.GA13858@localhost>
	<20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20101025032827.GA15933@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 11:28:27 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Mon, Oct 25, 2010 at 11:05:50AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Mon, 25 Oct 2010 10:57:03 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > On Mon, Oct 25, 2010 at 10:40:17AM +0800, KAMEZAWA Hiroyuki wrote:
> > > > On Mon, 25 Oct 2010 10:47:31 +0800
> > > > Bob Liu <lliubbo@gmail.com> wrote:
> > > > 
> > > > > It's normal for isolate_lru_page() to fail at times. The failures are
> > > > > typically temporal and may well go away when offline_pages() retries
> > > > > the call. So it seems more reasonable to migrate as much as possible
> > > > > to increase the chance of complete success in next retry.
> > > > > 
> > > > > This patch remove page_count() check and remove putback_lru_pages() and
> > > > > call migrate_pages() regardless of not_managed to reduce failure as much
> > > > > as possible.
> > > > > 
> > > > > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> > > > 
> > > > -EBUSY should be returned.
> > > 
> > > It does return -EBUSY when ALL pages cannot be isolated from LRU (or
> > > is non-LRU pages at all). That means offline_pages() will repeat calls
> > > to do_migrate_range() as fast as possible as long as it can make
> > > progress.
> > > 
> > I read the patch wrong ? "ret = -EBUSY" is dropped and "ret" will be
> > 0 or just a return code of migrate_page().
> 
>         for () {
>                 ret = isolate_lru_page(page);
>         }
> 
>         if (list_empty(&source))
>                 goto out;
> 
> out:
>         return ret;
> 
> So do_migrate_range() will return -EBUSY if the last isolate_lru_page() returns
> -EBUSY.
> 

Then this patch should be put onto "immediately quit loop when not_managed++" patch.
Please write it in description or make a patch series which other guys can see it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
