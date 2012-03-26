Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7B4666B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 16:40:27 -0400 (EDT)
Date: Mon, 26 Mar 2012 22:39:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
Message-ID: <20120326203951.GZ5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
 <1332783986-24195-12-git-send-email-aarcange@redhat.com>
 <1332786353.16159.173.camel@twins>
 <4F70C365.8020009@redhat.com>
 <20120326194435.GW5906@redhat.com>
 <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hillf Danton <dhillf@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dan Smith <danms@us.ibm.com>, Paul Turner <pjt@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, Bharata B Rao <bharata.rao@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

Hi,

On Mon, Mar 26, 2012 at 12:58:05PM -0700, Linus Torvalds wrote:
> On Mar 26, 2012 12:45 PM, "Andrea Arcangeli" <aarcange@redhat.com> wrote:
> >
> > As I wrote in the comment before the function, math speaking, this
> > looks like O(N) but it is O(1), not O(N) nor O(N^2). This is because N
> > = NR_CPUS = 1.
> 
> That's just stupid sophistry.

I agree, this is why I warned everyone in the comment before the
function with the adjective "misleading":

 * O(1) misleading math
 * aside, the number of cachelines touched with thousands of CPU might
 * make it measurable.

> No, you can't just say that it's limited to some large constant, and thus
> the same as O(1).

I pointed out it is O(1) just because if we use the O notation we may
as well do the math right about it.

I may not have been clear but I never meant that because it is O(1)
(NR_CPUS constant) it means it's already ok as it is now.

> 
> That's the worst kind of lie: something that's technically true if you look
> at it a certain stupid way, but isn't actually true in practice.
> 
> It's clearly O(n) in number of CPUs, and people told you it can't go into
> the scheduler. Stop arguing idiotic things. Just say you'll fix it, instead
> of looking like a tool.

About fixing it, this can be called at a regular interval like
load_balance() (which also has an higher cost than the per-cpu
schedule fast path, in having to walk over the other CPU runqueues) or
to be more integrated within CFS so it doesn't need to be called at
all.

I didn't think it was urgent to fix (also because it has a debug
benefit to keep it like this in the short term), but I definitely
intended to fix it.

I also would welcome people who knows the scheduler so much better
than me to rewrite or fix it as they like it.

To be crystal clear: I totally agree to fix this, in the comment
before the code I wrote:

 * it's good in the
 * short term for stressing the algorithm.

I probably wasn't clear enough, but I already implicitly meant it
shall be optimized further later.

If there's a slight disagreement is only on the "urgency" to fix it but
I will certainly change my priorities on this after reading your
comments!

Thanks for looking into this.
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
