Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 29A029000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 22:39:24 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2] oom: do not live lock on frozen tasks
In-Reply-To: <20110926110559.GH10156@tiehlicka.suse.cz>
References: <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com> <20110826070946.GA7280@tiehlicka.suse.cz> <20110826085610.GA9083@tiehlicka.suse.cz> <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com> <20110826095356.GB9083@tiehlicka.suse.cz> <alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com> <20110926082837.GC10156@tiehlicka.suse.cz> <87sjnjk36l.fsf@rustcorp.com.au> <20110926110559.GH10156@tiehlicka.suse.cz>
Date: Tue, 27 Sep 2011 11:51:00 +0930
Message-ID: <87k48uk9o3.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Tejun Heo <tj@kernel.org>

On Mon, 26 Sep 2011 13:05:59 +0200, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 26-09-11 19:58:50, Rusty Russell wrote:
> > On Mon, 26 Sep 2011 10:28:37 +0200, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Fri 26-08-11 11:13:40, David Rientjes wrote:
> > > > I'd love to be able to do a thaw on a PF_FROZEN task in the oom killer 
> > > > followed by a SIGKILL if that task is selected for oom kill without an 
> > > > heuristic change.  Not sure if that's possible, so we'll wait for Rafael 
> > > > to chime in.
> > > 
> > > We have discussed that with Rafael and it should be safe to do that. See
> > > the patch bellow.
> > > The only place I am not entirely sure about is run_guest
> > > (drivers/lguest/core.c). It seems that the code is able to cope with
> > > signals but it also calls lguest_arch_run_guest after try_to_freeze.
> > 
> > Yes; if you want to kill things in the refrigerator(), then will a
> > 
> > 		if (cpu->lg->dead || task_is_dead(current))
> >                         break;
> > 
> > Work?  
> 
> The task is not dead yet. We should rather check for pending signals.
> Can we just move try_to_freeze up before the pending signals check?

Yep, that works.

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
