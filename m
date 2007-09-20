Date: Thu, 20 Sep 2007 15:12:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/9] oom: add per-zone locking
In-Reply-To: <Pine.LNX.4.64.0709201504320.11226@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709201508270.732@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com> <Pine.LNX.4.64.0709201458310.11226@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709201500250.32266@chino.kir.corp.google.com> <Pine.LNX.4.64.0709201504320.11226@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, Christoph Lameter wrote:

> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -27,6 +27,7 @@
> > > >  #include <linux/notifier.h>
> > > >  
> > > >  int sysctl_panic_on_oom;
> > > > +static DEFINE_MUTEX(zone_scan_mutex);
> > > >  /* #define DEBUG */
> > > 
> > > Use testset/testclear bitops instead of adding a lock?
> > > 
> > 
> > That doesn't work nicely, unfortunately, because then we need to unlock 
> > all zones that we've locked so far in try_set_zone_oom() if we find one 
> > that is alredy ZONE_OOM_LOCKED during the scan of the zonelist.
> 
> You need that lock release function anyways to when the oom killing is 
> done.
> 

It doesn't matter.  You would then need the following in __alloc_pages():

	if (!try_set_zone_oom(zonelist)) {
		clear_zonelist_oom(zonelist);
		schedule_timeout_uninterruptible(1);
		goto restart;
	}

or a call to clear_zonelist_oom() before returning 0 in 
try_set_zone_oom().

But that races with another thread that is also trying an allocation 
attempt and you end up clearing the ZONE_OOM_LOCKED bits that it has 
already set in its call to try_set_zone_oom().

try_set_zone_oom() is a critical section because all ZONE_OOM_LOCKED bits 
for each zone in the zonelist need to be set upon return, we can't allow 
it to race with an exiting OOM killer calling clear_zonelist_oom().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
