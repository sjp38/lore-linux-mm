Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FE538D0012
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 00:06:08 -0400 (EDT)
Date: Mon, 25 Oct 2010 12:06:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-ID: <20101025040604.GA18268@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
 <20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025025703.GA13858@localhost>
 <20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025120901.88fdbd17.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025034833.GB15933@localhost>
 <20101025124816.330846a5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025124816.330846a5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 11:48:16AM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 25 Oct 2010 11:48:33 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Mon, Oct 25, 2010 at 11:09:01AM +0800, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 25 Oct 2010 12:05:50 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > This changes behavior.
> > > > 
> > > > This "ret" can be > 0 because migrate_page()'s return code is
> > > > "Return: Number of pages not migrated or error code."
> > > > 
> > > > Then, 
> > > > ret < 0  ===> maybe ebusy
> > > > ret > 0  ===> some pages are not migrated. maybe PG_writeback or some
> > > > ret == 0 ===> ok, all condition green. try next chunk soon.
> > > > 
> > > > Then, I added "yield()" and --retrym_max for !ret cases.
> > >                                                ^^^^^^^^
> > > 						wrong.
> > > 
> > > The code here does
> > > 
> > > ret == 0 ==> ok, all condition green, try next chunk.
> > 
> > It seems reasonable to remove the drain operations for "ret == 0"
> > case.  That would help large NUMA boxes noticeably I guess.
> > 
> Maybe.
> 
> > > ret > 0  ==> all pages are isolated but some pages cannot be migrated. maybe under I/O
> > > 	     do yield.
> > 
> > Don't know how to deal with the possible "migration fail" pages --
> > sorry I have no idea about that situation at all.
> > 
> 
> In typical case, page_count() > 0 by get_user_pages() or PG_writeback is set.
> All we can do is just waiting.

OK.

> > Perhaps, OOM while offlining pages?
> > 
> 
> I never see that..because memory offline is scheduled to be done only when
> there are free memory.

OK.

On OOM migrate_page() will return -ENOMEM, which will be handled in
the "ret < 0" case. So it will give up after some retries.

migrate_page() has a comment /* Permanent failure */ when returning
positive ret. So it looks safer not to retry indefinitely on the
"ret > 0" case?

Then it's reduced to two cases: "ret != 0, cannot make smooth
progress, unconditional retries may livelock" and "ret ==0, makes some
progress, safe to retry".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
