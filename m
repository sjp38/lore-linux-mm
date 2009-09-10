Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 422AC6B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 21:15:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8A1F89n015521
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Sep 2009 10:15:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B73245DE62
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 10:15:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 45CFE45DE57
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 10:15:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F1F21DB803E
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 10:15:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFD681DB8038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 10:15:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <20090910100057.a1375276.minchan.kim@barrios-desktop>
References: <20090910084602.9CBD.A69D9226@jp.fujitsu.com> <20090910100057.a1375276.minchan.kim@barrios-desktop>
Message-Id: <20090910101051.9CCC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 10 Sep 2009 10:15:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 10 Sep 2009 08:58:20 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Wed, Sep 9, 2009 at 1:27 PM, KOSAKI Motohiro
> > > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > >> The usefulness of a scheme like this requires:
> > > >>
> > > >> 1. There are cpus that continually execute user space code
> > > >> A  A without system interaction.
> > > >>
> > > >> 2. There are repeated VM activities that require page isolation /
> > > >> A  A migration.
> > > >>
> > > >> The first page isolation activity will then clear the lru caches of the
> > > >> processes doing number crunching in user space (and therefore the first
> > > >> isolation will still interrupt). The second and following isolation will
> > > >> then no longer interrupt the processes.
> > > >>
> > > >> 2. is rare. So the question is if the additional code in the LRU handling
> > > >> can be justified. If lru handling is not time sensitive then yes.
> > > >
> > > > Christoph, I'd like to discuss a bit related (and almost unrelated) thing.
> > > > I think page migration don't need lru_add_drain_all() as synchronous, because
> > > > page migration have 10 times retry.
> > > >
> > > > Then asynchronous lru_add_drain_all() cause
> > > >
> > > > A - if system isn't under heavy pressure, retry succussfull.
> > > > A - if system is under heavy pressure or RT-thread work busy busy loop, retry failure.
> > > >
> > > > I don't think this is problematic bahavior. Also, mlock can use asynchrounous lru drain.
> > > 
> > > I think, more exactly, we don't have to drain lru pages for mlocking.
> > > Mlocked pages will go into unevictable lru due to
> > > try_to_unmap when shrink of lru happens.
> > 
> > Right.
> > 
> > > How about removing draining in case of mlock?
> > 
> > Umm, I don't like this. because perfectly no drain often make strange test result.
> > I mean /proc/meminfo::Mlock might be displayed unexpected value. it is not leak. it's only lazy cull.
> > but many tester and administrator wiill think it's bug... ;)
> 
> I agree. I have no objection to your approach. :)
> 
> > Practically, lru_add_drain_all() is nearly zero cost. because mlock's page fault is very
> > costly operation. it hide drain cost. now, we only want to treat corner case issue. 
> > I don't hope dramatic change.
> 
> Another problem is as follow.
> 
> Although some CPUs don't have any thing to do, we do it. 
> HPC guys don't want to consume CPU cycle as Christoph pointed out.
> I liked Peter's idea with regard to this. 
> My approach can solve it, too. 
> But I agree it would be dramatic change. 

Is Perter's + mine approach bad?

It mean,

  - RT-thread binding cpu is not grabbing the page
	-> mlock successful by Peter's improvement
  - RT-thread binding cpu is grabbing the page
	-> mlock successful by mine approach
	   the page is culled later.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
