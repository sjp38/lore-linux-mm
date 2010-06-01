Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0586B01DD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:36:24 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o51IaIfG025535
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:36:20 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by hpaq11.eem.corp.google.com with ESMTP id o51IaGs4008932
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:36:17 -0700
Received: by pxi5 with SMTP id 5so1895446pxi.9
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 11:36:16 -0700 (PDT)
Date: Tue, 1 Jun 2010 11:36:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <AANLkTil5gnDaVt9FXtGnPgQQQ2XLl4MYbNS_hsjdcsVa@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006011132130.32024@chino.kir.corp.google.com>
References: <20100528152842.GH11364@uudg.org> <20100528154549.GC12035@barrios-desktop> <20100528164826.GJ11364@uudg.org> <20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
 <20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTil75ziCd6bivhpmwojvhaJ2LVxwEaEaBEmZf2yN@mail.gmail.com> <20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTilcuY5e1DNmLhUWfXtiQgPUafz2zRTUuTVl-88l@mail.gmail.com>
 <20100531155102.9a122772.kamezawa.hiroyu@jp.fujitsu.com> <20100531135227.GC19784@uudg.org> <AANLkTil5gnDaVt9FXtGnPgQQQ2XLl4MYbNS_hsjdcsVa@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, Minchan Kim wrote:

> Secondly, as Kame pointed out, we have to raise whole thread's
> priority to kill victim process for reclaiming pages. But I think it
> has deadlock problem.

Agreed, this has the potential to actually increase the amount of time for 
an oom killed task to fully exit: the exit path takes mm->mmap_sem on exit 
and if that is held by another thread waiting for the oom killed task to 
exit (i.e. reclaim has failed and the oom killer becomes a no-op because 
it sees an already killed task) then there's a livelock.  That's always 
been a problem, but is compounded with increasing the priority of a task 
not holding mm->mmap_sem if the thread holding the writelock actually 
isn't looking for memory but simply doesn't get a chance to release 
because it fails to run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
