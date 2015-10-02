Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCC082F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:59:21 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so82259456obb.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:59:21 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id sb10si6038533oeb.83.2015.10.02.06.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Oct 2015 06:59:20 -0700 (PDT)
Received: from localhost
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 2 Oct 2015 07:59:20 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 493773E40044
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 07:59:17 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t92DwKVa655762
	for <linux-mm@kvack.org>; Fri, 2 Oct 2015 06:58:20 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t92DxGFF019092
	for <linux-mm@kvack.org>; Fri, 2 Oct 2015 07:59:17 -0600
Date: Fri, 2 Oct 2015 06:59:18 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC v2 00/18] kthread: Use kthread worker API more widely
Message-ID: <20151002135918.GN4043@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <20150930050833.GA4412@linux.vnet.ibm.com>
 <20151001155943.GE9603@pathway.suse.cz>
 <20151001170053.GH4043@linux.vnet.ibm.com>
 <20151002120014.GG9603@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151002120014.GG9603@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Oct 02, 2015 at 02:00:14PM +0200, Petr Mladek wrote:
> On Thu 2015-10-01 10:00:53, Paul E. McKenney wrote:
> > On Thu, Oct 01, 2015 at 05:59:43PM +0200, Petr Mladek wrote:
> > > On Tue 2015-09-29 22:08:33, Paul E. McKenney wrote:
> > > > On Mon, Sep 21, 2015 at 03:03:41PM +0200, Petr Mladek wrote:
> > > > > My intention is to make it easier to manipulate kthreads. This RFC tries
> > > > > to use the kthread worker API. It is based on comments from the
> > > > > first attempt. See https://lkml.org/lkml/2015/7/28/648 and
> > > > > the list of changes below.
> > > > > 
> > If the point of these patches was simply to test your API, and if you are
> > not looking to get them upstream, we are OK.
> 
> I would like to eventually transform all kthreads into an API that
> will better define the kthread workflow. It need not be this one,
> though. I am still looking for a good API that will be acceptable[*]
> 
> One of the reason that I played with RCU, khugepaged, and ring buffer
> kthreads is that they are maintained by core developers. I hope that
> it will help to get better consensus.
> 
> 
> > If you want them upstream, you need to explain to me why the patches
> > help something.
> 
> As I said, RCU kthreads do not show a big win because they ignore
> freezer, are not parked, never stop, do not handle signals. But the
> change will allow to live patch them because they leave the main
> function on a safe place.
> 
> The ring buffer benchmark is much better example. It reduced
> the main function of the consumer kthread to two lines.
> It removed some error prone code that modified task state,
> called scheduler, handled kthread_should_stop. IMHO, the workflow
> is better and more safe now.
> 
> I am going to prepare and send more examples where the change makes
> the workflow easier.
> 
> 
> > And also how the patches avoid breaking things.
> 
> I do my best to keep the original functionality. If we decide to use
> the kthread worker API, my first attempt is much more safe, see
> https://lkml.org/lkml/2015/7/28/650. It basically replaces the
> top level for cycle with one self-queuing work. There are some more
> instructions to go back to the cycle but they define a common
> safe point that will be maintained on a single location for
> all kthread workers.
> 
> 
> [*] I have played with two APIs yet. They define a safe point
> for freezing, parking, stopping, signal handling, live patching.
> Also some non-trivial logic of the main cycle is maintained
> on a single location.
> 
> Here are some details:
> 
> 1. iterant API
> --------------
> 
>   It allows to define three callbacks that are called the following
>   way:
> 
>      init();
>      while (!stop)
> 	func();
>      destroy();
> 
>   See also https://lkml.org/lkml/2015/6/5/556.
> 
>   Advantages:
>     + simple and clear workflow
>     + simple use
>     + simple conversion from the current kthreads API
> 
>   Disadvantages:
>     + problematic solution of sleeping between events
>     + completely new API
> 
> 
> 2. kthread worker API
> ---------------------
> 
>   It is similar to workqueues. The difference is that the works
>   have a dedicated kthread, so we could better control the resources,
>   e.g. priority, scheduling policy, ...
> 
>   Advantages:
>     + already in use
>     + design proven to work (workqueues)
>     + nature way to wait for work in the common code (worker)
>       using event driven works and delayed works
>     + easy to convert to/from workqueues API
> 
>   Disadvantages:
>     + more code needed to define, initialize, and queue works
>     + more complicated conversion from the current API
>       if we want to make it a clean way (event driven)
>     + might need more synchronization in some cases[**]
> 
>   Questionable:
>     + event driven vs. procedural programming style
>     + allows more grained split of the functionality into
>       separate units (works) that might be queued
>       as needed
> 
> 
> [**] wake_up() is nope for empty waitqueue. But queuing a work
>      into non-existing worker might cause a crash. Well, this is
>      usually already synchronized.
> 
> 
> Any thoughts or preferences are highly appreciated.

For the RCU grace-period kthreads, I am not seeing the advantage of
either API over the current approach.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
