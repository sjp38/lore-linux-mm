Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 713716200AA
	for <linux-mm@kvack.org>; Thu,  6 May 2010 21:11:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o471BTZo027937
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 10:11:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEADB45DE4F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:11:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ACAEF45DE4E
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:11:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4C71DB803C
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:11:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 513831DB8038
	for <linux-mm@kvack.org>; Fri,  7 May 2010 10:11:29 +0900 (JST)
Date: Fri, 7 May 2010 10:07:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: memcontrol - uninitialised return value
Message-Id: <20100507100729.a6589d8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100506142417.6d317068.akpm@linux-foundation.org>
References: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
	<20100506142417.6d317068.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Phil Carmody <ext-phil.2.carmody@nokia.com>, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 May 2010 14:24:17 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed,  5 May 2010 14:21:49 +0300
> Phil Carmody <ext-phil.2.carmody@nokia.com> wrote:
> 
> > From: Phil Carmody <ext-phil.2.carmody@nokia.com>
> > 
> > Only an out of memory error will cause ret to be set.
> > 
> > Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> > Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
> > ---
> >  mm/memcontrol.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 90e32b2..09af773 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3464,7 +3464,7 @@ static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
> >  	int type = MEMFILE_TYPE(cft->private);
> >  	u64 usage;
> >  	int size = 0;
> > -	int i, j, ret;
> > +	int i, j, ret = 0;
> >  
> >  	mutex_lock(&memcg->thresholds_lock);
> >  	if (type == _MEM)
> 
> afacit the return value of cftype.unregister_event() is always ignored
> anyway.  Perhaps it should be changed to void-returning, or fixed.
> 
> 
Ah, it's now "TODO". But hmm...."unregister_event()" is called by workqueue.
(for avoiding race?)

I think unregister_event should be "void" and mem_cgroup_unregister_event()
should be implemented as "never fail" function.

I'll try by myself....but if someone knows this event notifier implementation well,
please.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
