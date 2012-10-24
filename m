Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 62B5B6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 02:29:49 -0400 (EDT)
Date: Wed, 24 Oct 2012 08:29:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121024062938.GA6119@dhcp22.suse.cz>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121023164546.747e90f6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121023164546.747e90f6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 23-10-12 16:45:46, Andrew Morton wrote:
> On Fri, 12 Oct 2012 14:57:08 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi,
> > I would like to resurrect the following Dave's patch. The last time it
> > has been posted was here https://lkml.org/lkml/2010/9/16/250 and there
> > didn't seem to be any strong opposition. 
> > Kosaki was worried about possible excessive logging when somebody drops
> > caches too often (but then he claimed he didn't have a strong opinion
> > on that) but I would say opposite. If somebody does that then I would
> > really like to know that from the log when supporting a system because
> > it almost for sure means that there is something fishy going on. It is
> > also worth mentioning that only root can write drop caches so this is
> > not an flooding attack vector.
> > I am bringing that up again because this can be really helpful when
> > chasing strange performance issues which (surprise surprise) turn out to
> > be related to artificially dropped caches done because the admin thinks
> > this would help...
> > 
> > I have just refreshed the original patch on top of the current mm tree
> > but I could live with KERN_INFO as well if people think that KERN_NOTICE
> > is too hysterical.
> > ---
> > >From 1f4058be9b089bc9d43d71bc63989335d7637d8d Mon Sep 17 00:00:00 2001
> > From: Dave Hansen <dave@linux.vnet.ibm.com>
> > Date: Fri, 12 Oct 2012 14:30:54 +0200
> > Subject: [PATCH] add some drop_caches documentation and info messsge
> > 
> > There is plenty of anecdotal evidence and a load of blog posts
> > suggesting that using "drop_caches" periodically keeps your system
> > running in "tip top shape".  Perhaps adding some kernel
> > documentation will increase the amount of accurate data on its use.
> > 
> > If we are not shrinking caches effectively, then we have real bugs.
> > Using drop_caches will simply mask the bugs and make them harder
> > to find, but certainly does not fix them, nor is it an appropriate
> > "workaround" to limit the size of the caches.
> > 
> > It's a great debugging tool, and is really handy for doing things
> > like repeatable benchmark runs.  So, add a bit more documentation
> > about it, and add a little KERN_NOTICE.  It should help developers
> > who are chasing down reclaim-related bugs.
> > 
> > ...
> >
> > +		printk(KERN_NOTICE "%s (%d): dropped kernel caches: %d\n",
> > +			current->comm, task_pid_nr(current), sysctl_drop_caches);
> 
> urgh.  Are we really sure we want to do this?  The system operators who
> are actually using this thing will hate us :(

I have no problems with lowering the priority (how do you see
KERN_INFO?) but shouldn't this message kick them that they are doing
something wrong? Or if somebody uses that for "benchmarking" to have a
clean table before start is this really that invasive?

> More friendly alternatives might be:
> 
> - Taint the kernel.  But that will only become apparent with an oops
>   trace or similar.
> 
> - Add a drop_caches counter and make that available in /proc/vmstat,
>   show_mem() output and perhaps other places.

We would loose timing and originating process name in both cases which
can be really helpful while debugging. It is fair to say that we could
deduce the timing if we are collecting /proc/meminfo or /proc/vmstat
already and we do collect them often but this is not the case all of the
time and sometimes it is important to know _who_ is doing all this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
