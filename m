Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9OJKWOn389570
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 19:20:32 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9OJKWeZ3838094
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 21:20:32 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9OJKVwp018144
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 21:20:32 +0200
Date: Fri, 24 Oct 2008 21:20:31 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use
	schedule_on_each_cpu()
Message-ID: <20081024192031.GA4155@osiris.boeblingen.de.ibm.com>
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com> <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com> <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 12:00:17AM +0900, KOSAKI Motohiro wrote:
> Hi Heiko,
> > This bug is caused by folloing dependencys.
> > 
> > some VM place has
> >       mmap_sem -> kevent_wq
> > 
> > net/core/dev.c::dev_ioctl()  has
> >      rtnl_lock  ->  mmap_sem        (*) almost ioctl has
> > copy_from_user() and it cause page fault.
> > 
> > linkwatch_event has
> >     kevent_wq -> rtnl_lock
> > 
> > 
> > So, I think VM subsystem shouldn't use kevent_wq because many driver
> > use ioctl and work queue combination.
> > then drivers fixing isn't easy.
> > 
> > I'll make the patch soon.
> 
> My box can't reproduce this issue.
> Could you please test on following patch?

Your patch seems to fix the issue. At least I don't see the warning anymore ;)

Thanks,
Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
