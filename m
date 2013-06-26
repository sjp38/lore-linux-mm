Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id CB31C6B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 09:44:53 -0400 (EDT)
Date: Wed, 26 Jun 2013 09:44:48 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] vmpressure: implement strict mode
Message-ID: <20130626094448.4375035e@redhat.com>
In-Reply-To: <20130626082040.GI29127@bbox>
References: <20130625175129.7c0d79e1@redhat.com>
	<20130626075051.GG29127@bbox>
	<20130626075921.GD28748@dhcp22.suse.cz>
	<20130626082040.GI29127@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, anton@enomsg.org, akpm@linux-foundation.org

On Wed, 26 Jun 2013 17:20:40 +0900
Minchan Kim <minchan@kernel.org> wrote:

> Hello Michal,
> 
> On Wed, Jun 26, 2013 at 09:59:21AM +0200, Michal Hocko wrote:
> > On Wed 26-06-13 16:50:51, Minchan Kim wrote:
> > > On Tue, Jun 25, 2013 at 05:51:29PM -0400, Luiz Capitulino wrote:
> > > > Currently, applications are notified for the level they registered for
> > > > _plus_ higher levels.
> > > > 
> > > > This is a problem if the application wants to implement different
> > > > actions for different levels. For example, an application might want
> > > > to release 10% of its cache on level low, 50% on medium and 100% on
> > > > critical. To do this, the application has to register a different fd
> > > > for each event. However, fd low is always going to be notified and
> > > > and all fds are going to be notified on level critical.
> > > > 
> > > > Strict mode solves this problem by strictly notifiying the event
> > > > an fd has registered for. It's optional. By default we still notify
> > > > on higher levels.
> > > > 
> > > > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> > > Acked-by: Minchan Kim <minchan@kernel.org>
> > > 
> > > Shouldn't we make this default?
> > 
> > The interface is not there for long but still, changing it is always
> > quite tricky. And the users who care can be modified really easily so I
> > would stick with the original default.
> 
> Yeb, I am not strong against to stick old at a moment but at least,
> this patch makes more sense to me so I'd like to know why we didn't do it
> from the beginning. Surely, Anton has a answer.

That's exactly my thinking too: I think strict mode should be the default
mode, and the current mode should be optional. But it's not a big deal.

I've discussed this issue with Anton some weeks ago, and iirc (Anton,
please correct/clarify where appropriate) the conclusion was that the
current schema makes sense for apps monitoring reclaim activity, as
they can hook on low only.

Hmm. Something just crossed my mind. Maybe we should have two
notification schemas:

 o memory.pressure_level: implements strict mode (this patch)

 o memory.reclaim_activity: apps are notified whenever there's reclaim
							activity

As for changing applications, it's better to get some breakage while
we're in -rc than regret the API later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
