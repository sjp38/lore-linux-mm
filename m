Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E27269000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:03:32 -0400 (EDT)
Date: Tue, 27 Sep 2011 09:03:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] lguest: move process freezing before pending signals check
Message-ID: <20110927070326.GA24377@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz>
 <20110826085610.GA9083@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
 <20110826095356.GB9083@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
 <20110926082837.GC10156@tiehlicka.suse.cz>
 <87sjnjk36l.fsf@rustcorp.com.au>
 <20110926110559.GH10156@tiehlicka.suse.cz>
 <87k48uk9o3.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k48uk9o3.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Tejun Heo <tj@kernel.org>

On Tue 27-09-11 11:51:00, Rusty Russell wrote:
> On Mon, 26 Sep 2011 13:05:59 +0200, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 26-09-11 19:58:50, Rusty Russell wrote:
> > > On Mon, 26 Sep 2011 10:28:37 +0200, Michal Hocko <mhocko@suse.cz> wrote:
> > > > On Fri 26-08-11 11:13:40, David Rientjes wrote:
> > > > > I'd love to be able to do a thaw on a PF_FROZEN task in the oom killer 
> > > > > followed by a SIGKILL if that task is selected for oom kill without an 
> > > > > heuristic change.  Not sure if that's possible, so we'll wait for Rafael 
> > > > > to chime in.
> > > > 
> > > > We have discussed that with Rafael and it should be safe to do that. See
> > > > the patch bellow.
> > > > The only place I am not entirely sure about is run_guest
> > > > (drivers/lguest/core.c). It seems that the code is able to cope with
> > > > signals but it also calls lguest_arch_run_guest after try_to_freeze.
> > > 
> > > Yes; if you want to kill things in the refrigerator(), then will a
> > > 
> > > 		if (cpu->lg->dead || task_is_dead(current))
> > >                         break;
> > > 
> > > Work?  
> > 
> > The task is not dead yet. We should rather check for pending signals.
> > Can we just move try_to_freeze up before the pending signals check?
> 
> Yep, that works.
> 
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks.
The full patch bellow:
---
