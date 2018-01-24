Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD6E6800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 05:35:00 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 33so2148602wrs.3
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 02:35:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 193si2123wmb.120.2018.01.24.02.34.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 02:34:59 -0800 (PST)
Date: Wed, 24 Jan 2018 11:34:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz>
References: <20171030124358.GF23278@quack2.suse.cz>
 <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz>
 <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com>
 <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com>
 <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>, Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 22-01-18 22:31:20, Amir Goldstein wrote:
> On Fri, Jan 19, 2018 at 5:02 PM, Shakeel Butt <shakeelb@google.com> wrote:
> > On Wed, Nov 15, 2017 at 1:31 AM, Jan Kara <jack@suse.cz> wrote:
> >> On Wed 15-11-17 01:32:16, Yang Shi wrote:
> >>> On 11/14/17 1:39 AM, Michal Hocko wrote:
> >>> >On Tue 14-11-17 03:10:22, Yang Shi wrote:
> >>> >>
> >>> >>
> >>> >>On 11/9/17 5:54 AM, Michal Hocko wrote:
> >>> >>>[Sorry for the late reply]
> >>> >>>
> >>> >>>On Tue 31-10-17 11:12:38, Jan Kara wrote:
> >>> >>>>On Tue 31-10-17 00:39:58, Yang Shi wrote:
> >>> >>>[...]
> >>> >>>>>I do agree it is not fair and not neat to account to producer rather than
> >>> >>>>>misbehaving consumer, but current memcg design looks not support such use
> >>> >>>>>case. And, the other question is do we know who is the listener if it
> >>> >>>>>doesn't read the events?
> >>> >>>>
> >>> >>>>So you never know who will read from the notification file descriptor but
> >>> >>>>you can simply account that to the process that created the notification
> >>> >>>>group and that is IMO the right process to account to.
> >>> >>>
> >>> >>>Yes, if the creator is de-facto owner which defines the lifetime of
> >>> >>>those objects then this should be a target of the charge.
> >>> >>>
> >>> >>>>I agree that current SLAB memcg accounting does not allow to account to a
> >>> >>>>different memcg than the one of the running process. However I *think* it
> >>> >>>>should be possible to add such interface. Michal?
> >>> >>>
> >>> >>>We do have memcg_kmem_charge_memcg but that would require some plumbing
> >>> >>>to hook it into the specific allocation path. I suspect it uses kmalloc,
> >>> >>>right?
> >>> >>
> >>> >>Yes.
> >>> >>
> >>> >>I took a look at the implementation and the callsites of
> >>> >>memcg_kmem_charge_memcg(). It looks it is called by:
> >>> >>
> >>> >>* charge kmem to memcg, but it is charged to the allocator's memcg
> >>> >>* allocate new slab page, charge to memcg_params.memcg
> >>> >>
> >>> >>I think this is the plumbing you mentioned, right?
> >>> >
> >>> >Maybe I have misunderstood, but you are using slab allocator. So you
> >>> >would need to force it to use a different charging context than current.
> >>>
> >>> Yes.
> >>>
> >>> >I haven't checked deeply but this doesn't look trivial to me.
> >>>
> >>> I agree. This is also what I explained to Jan and Amir in earlier
> >>> discussion.
> >>
> >> And I also agree. But the fact that it is not trivial does not mean that it
> >> should not be done...
> >>
> >
> > I am currently working on directed or remote memcg charging for a
> > different usecase and I think that would be helpful here as well.
> >
> > I have two questions though:
> >
> > 1) Is fsnotify_group the right structure to hold the reference to
> > target mem_cgroup for charging?
> 
> I think it is. The process who set up the group and determined the unlimited
> events queue size and did not consume the events from the queue in a timely
> manner is the process to blame for the OOM situation.

Agreed here.

> > 2) Remote charging can trigger an OOM in the target memcg. In this
> > usecase, I think, there should be security concerns if the events
> > producer can trigger OOM in the memcg of the monitor. We can either
> > change these allocations to use __GFP_NORETRY or some new gfp flag to
> > not trigger oom-killer. So, is this valid concern or am I
> > over-thinking?
> >
> 
> I think that is a very valid concern, but not sure about the solution.
> For an inotify listener and fanotify listener of class FAN_CLASS_NOTIF
> (group->priority == 0), I think it makes sense to let oom-killer kill
> the listener which is not keeping up with consuming events.

Agreed.

> For fanotify listener of class FAN_CLASS_{,PRE_}CONTENT
> (group->priority > 0) allowing an adversary to trigger oom-killer
> and kill the listener could bypass permission event checks.
> 
> So we could use different allocation flags for permission events
> or for groups with high priority or for groups that have permission
> events in their mask, so an adversary could not use non-permission
> events to oom-kill a listener that is also monitoring permission events.
> 
> Generally speaking, permission event monitors should not be
> setting  FAN_UNLIMITED_QUEUE and should not be causing oom
> (because permission events are not queued they are blocking), but
> there is nothing preventing a process to setup a FAN_CLASS_CONTENT
> group with FAN_UNLIMITED_QUEUE and also monitor non-permission
> events.
> 
> There is also nothing preventing a process from setting up one
> FAN_CLASS_CONTENT listener for permission events and another
> FAN_CLASS_NOTIF listener for non-permission event.
> Maybe it is not wise, but we don't know that there are no such processes
> out there.

So IMHO there are different ways to setup memcgs and processes in them and
you cannot just guess what desired outcome is. The facts are:

1) Process has setup queue with unlimited length.
2) Admin has put the process into memcg with limited memory.
3) The process cannot keep up with event producer.

These three facts are creating conflicting demands and it depends on the
eye of the beholder what is correct. E.g. you may not want to take the
whole hosting machine down because something bad happened in one container.
OTOH you might what that to happen if that particular container is
responsible for maintaining security - but then IMHO it is not a clever
setup to constrain memory of the security sensitive application.

So my stance on this is that we should define easy to understand semantics
and let the admins deal with it. IMO that semantics should follow how we
currently behave on system-wide OOM - i.e., simply trigger OOM killer when
cgroup is going over limits.

If we wanted to create safer API for fanotify from this standpoint, we
could allow new type of fanotify groups where queue would be limited in
length but tasks adding events to queue would get throttled as the queue
fills up. Something like dirty page cache throttling. But I'd go for this
complexity only once we have clear indications from practice that current
scheme is not enough.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
