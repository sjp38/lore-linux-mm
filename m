Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 388D24402EE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 08:00:17 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so29606541wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 05:00:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ek9si9300081wid.124.2015.10.02.05.00.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 05:00:15 -0700 (PDT)
Date: Fri, 2 Oct 2015 14:00:14 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 00/18] kthread: Use kthread worker API more widely
Message-ID: <20151002120014.GG9603@pathway.suse.cz>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <20150930050833.GA4412@linux.vnet.ibm.com>
 <20151001155943.GE9603@pathway.suse.cz>
 <20151001170053.GH4043@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151001170053.GH4043@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 2015-10-01 10:00:53, Paul E. McKenney wrote:
> On Thu, Oct 01, 2015 at 05:59:43PM +0200, Petr Mladek wrote:
> > On Tue 2015-09-29 22:08:33, Paul E. McKenney wrote:
> > > On Mon, Sep 21, 2015 at 03:03:41PM +0200, Petr Mladek wrote:
> > > > My intention is to make it easier to manipulate kthreads. This RFC tries
> > > > to use the kthread worker API. It is based on comments from the
> > > > first attempt. See https://lkml.org/lkml/2015/7/28/648 and
> > > > the list of changes below.
> > > > 
> If the point of these patches was simply to test your API, and if you are
> not looking to get them upstream, we are OK.

I would like to eventually transform all kthreads into an API that
will better define the kthread workflow. It need not be this one,
though. I am still looking for a good API that will be acceptable[*]

One of the reason that I played with RCU, khugepaged, and ring buffer
kthreads is that they are maintained by core developers. I hope that
it will help to get better consensus.


> If you want them upstream, you need to explain to me why the patches
> help something.

As I said, RCU kthreads do not show a big win because they ignore
freezer, are not parked, never stop, do not handle signals. But the
change will allow to live patch them because they leave the main
function on a safe place.

The ring buffer benchmark is much better example. It reduced
the main function of the consumer kthread to two lines.
It removed some error prone code that modified task state,
called scheduler, handled kthread_should_stop. IMHO, the workflow
is better and more safe now.

I am going to prepare and send more examples where the change makes
the workflow easier.


> And also how the patches avoid breaking things.

I do my best to keep the original functionality. If we decide to use
the kthread worker API, my first attempt is much more safe, see
https://lkml.org/lkml/2015/7/28/650. It basically replaces the
top level for cycle with one self-queuing work. There are some more
instructions to go back to the cycle but they define a common
safe point that will be maintained on a single location for
all kthread workers.


[*] I have played with two APIs yet. They define a safe point
for freezing, parking, stopping, signal handling, live patching.
Also some non-trivial logic of the main cycle is maintained
on a single location.

Here are some details:

1. iterant API
--------------

  It allows to define three callbacks that are called the following
  way:

     init();
     while (!stop)
	func();
     destroy();

  See also https://lkml.org/lkml/2015/6/5/556.

  Advantages:
    + simple and clear workflow
    + simple use
    + simple conversion from the current kthreads API

  Disadvantages:
    + problematic solution of sleeping between events
    + completely new API


2. kthread worker API
---------------------

  It is similar to workqueues. The difference is that the works
  have a dedicated kthread, so we could better control the resources,
  e.g. priority, scheduling policy, ...

  Advantages:
    + already in use
    + design proven to work (workqueues)
    + nature way to wait for work in the common code (worker)
      using event driven works and delayed works
    + easy to convert to/from workqueues API

  Disadvantages:
    + more code needed to define, initialize, and queue works
    + more complicated conversion from the current API
      if we want to make it a clean way (event driven)
    + might need more synchronization in some cases[**]

  Questionable:
    + event driven vs. procedural programming style
    + allows more grained split of the functionality into
      separate units (works) that might be queued
      as needed


[**] wake_up() is nope for empty waitqueue. But queuing a work
     into non-existing worker might cause a crash. Well, this is
     usually already synchronized.


Any thoughts or preferences are highly appreciated.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
