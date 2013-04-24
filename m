Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9950E6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 15:33:13 -0400 (EDT)
Date: Wed, 24 Apr 2013 12:33:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-Id: <20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org>
In-Reply-To: <20130424154216.GA27929@redhat.com>
References: <1366643184-3627-1-git-send-email-dserrg@gmail.com>
	<20130422195138.GB31098@dhcp22.suse.cz>
	<20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com>
	<20130423155638.GJ8001@dhcp22.suse.cz>
	<20130424145514.GA24997@redhat.com>
	<20130424152236.GB7600@dhcp22.suse.cz>
	<20130424154216.GA27929@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, dserrg <dserrg@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

On Wed, 24 Apr 2013 17:42:16 +0200 Oleg Nesterov <oleg@redhat.com> wrote:

> On 04/24, Michal Hocko wrote:
> >
> > On Wed 24-04-13 16:55:14, Oleg Nesterov wrote:
> > >
> > > But I can't understand how this patch can fix the problem, I think it
> > > can't.
> > >
> > > From the changelog:
> > >
> > > 	When SIGKILL is sent to a task, it's also sent to all tasks in the same
> > > 	threadgroup. This information can be used to prevent triggering further
> > > 	oom killers for this threadgroup and avoid the infinite loop.
> > >                                              ^^^^^^^^^^^^^^^^^^^^^^^
> > >
> > > How??
> >
> > I guess it assumes that fatal_signal_pending() is still true even when
> > the process is unhashed already.
> 
> No, it is not (in general). The task can dequeue this SIGKIL and then
> exit. But this doesn't matter.
> 
> > Which sounds like a workaround to me.
> 
> The task can do everything after we check PF_EXITING or whatever else.
> Just suppose it is alive and running, but before we take tasklist_lock
> it exits and removes itself from list.
> 
> But wait, I forgot that "p" is not necessarily the main thread, so
> the patch I sent is not enough...
> 
> Oh, and this reminds me again but we can race with exec... but this
> is mostly theoretical. should be fixed anyway.
> 
> I'll try to think more tomorrow. I need to recall the previous discussion
> at least.

Where does this leave us with Sergey's patch?  "Still good, but
requires new changelog"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
