Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5CE7B6B0082
	for <linux-mm@kvack.org>; Tue, 19 May 2009 22:58:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K2wvZ6009772
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 May 2009 11:58:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6580145DE63
	for <linux-mm@kvack.org>; Wed, 20 May 2009 11:58:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C6CD45DE5D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 11:58:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B334E3800F
	for <linux-mm@kvack.org>; Wed, 20 May 2009 11:58:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BEA0CE38009
	for <linux-mm@kvack.org>; Wed, 20 May 2009 11:58:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class  citizen
In-Reply-To: <20090520023101.GA8186@localhost>
References: <20090520105159.743B.A69D9226@jp.fujitsu.com> <20090520023101.GA8186@localhost>
Message-Id: <20090520114958.743E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 May 2009 11:58:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> > > > I think smem can show which library evicted.  Can you try it?
> > > > 
> > > > download:  http://www.selenic.com/smem/
> > > > usage:   ./smem -m -r --abbreviate
> > > 
> > > Sure, but I don't see much change in its output (see attachments).
> > > 
> > > smem-console-0 is collected after fresh boot,
> > > smem-console-1 is collected after the big IO.
> > 
> > hmmmm, your result has following characatistics.
> > 
> > - no graphics component
> > - very few mapped library
> >   (it is almost only zsh library)
> > 
> > Can you try test on X environment?
> 
> Sure, see the attached smem-x-0/1. This time we see sufficient differences.

thanks. hm, major shrinking item are 

/usr/lib/xulrunner-1.9/libxul.so	11.0M	=>	2.1M 
/usr/lib/libgtk-x11-2.0.so.0.1600.1	1.8M 	=>	88.0K 
/usr/lib/libperl.so.5.10.0		1.2M 	=>	36.0K 

IOW, inactive firefox's page were dropped.

I think that's sane. the latency of background window is not so important
on low memory desktop system.
user hope to use memory for foreground application.
Thus, droppint inactive application memory is sane behavior, I think.



> 
> > > > We can't decide 9/10 is important or not. we need know actual evicted file list.
> > > 
> > > Right. But what I measured is the activeness. Almost zero major page
> > > faults means the evicted 90% mapped pages are inactive during the
> > > long 300 seconds of IO.
> > 
> > Agreed.
> > IOW, I don't think your test environment is typical desktop...
> 
> Kind of :)  It's fluxbox + terminal + firefox, a bare desktop for
> testing things out.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
