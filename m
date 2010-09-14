Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 83EEE6B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 04:44:42 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8E8ie6P018533
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Sep 2010 17:44:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E032245DE52
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:44:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F1145DE50
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:44:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FEC21DB803F
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:44:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A9251DB803B
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:44:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/17] writeback: quit throttling when signal pending
In-Reply-To: <20100914083338.GA20295@localhost>
References: <20100914172028.C9B2.A69D9226@jp.fujitsu.com> <20100914083338.GA20295@localhost>
Message-Id: <20100914174017.C9BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Sep 2010 17:44:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Neil Brown <neilb@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Sep 14, 2010 at 04:23:56PM +0800, KOSAKI Motohiro wrote:
> > > Subject: writeback: quit throttling when fatal signal pending
> > > From: Wu Fengguang <fengguang.wu@intel.com>
> > > Date: Wed Sep 08 17:40:22 CST 2010
> > > 
> > > This allows quick response to Ctrl-C etc. for impatient users.
> > > 
> > > It mainly helps the rare bdi/global dirty exceeded cases.
> > > In the normal case of not exceeded, it will quit the loop anyway. 
> > > 
> > > CC: Neil Brown <neilb@suse.de>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  mm/page-writeback.c |    3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > --- linux-next.orig/mm/page-writeback.c	2010-09-12 13:25:23.000000000 +0800
> > > +++ linux-next/mm/page-writeback.c	2010-09-13 11:39:33.000000000 +0800
> > > @@ -552,6 +552,9 @@ static void balance_dirty_pages(struct a
> > >  		__set_current_state(TASK_INTERRUPTIBLE);
> > >  		io_schedule_timeout(pause);
> > >  
> > > +		if (fatal_signal_pending(current))
> > > +			break;
> > > +
> > >  check_exceeded:
> > >  		/*
> > >  		 * The bdi thresh is somehow "soft" limit derived from the
> > 
> > I think we need to change callers (e.g. generic_perform_write) too.
> > Otherwise, plenty write + SIGKILL combination easily exceed dirty limit.
> > It mean we can see strange OOM.
> 
> If it's dangerous, we can do without this patch.  

How?


> The users can still
> get quick response in normal case after all.
> 
> However, I suspect the process is guaranteed to exit on
> fatal_signal_pending, so it won't dirty more pages :)

Process exiting is delayed until syscall exiting. So, we exit write syscall
manually if necessary.

Am I missing anything?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
