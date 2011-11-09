Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 94C286B006E
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 12:33:17 -0500 (EST)
Date: Wed, 9 Nov 2011 18:33:08 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109173308.GK5075@redhat.com>
References: <4EB8E969.6010502@suse.cz>
 <1320766151-2619-1-git-send-email-aarcange@redhat.com>
 <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
 <20111109155342.GA1260@google.com>
 <20111109165201.GI5075@redhat.com>
 <20111109165925.GC1260@google.com>
 <20111109170657.GE1260@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109170657.GE1260@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 09, 2011 at 09:06:57AM -0800, Tejun Heo wrote:
> Ah, crap, still waking up.  Sorry about that.  So, yes, there's a race
> condition above.  You need to set TASK_INTERRUPTIBLE before testing
> freezing and use schedule_timeout() instead of

Yep that's the race I was thinking about. I see the wakeup in the
no-signal case avoids the race in wait_even_freezable_timeout so that
is ok but it'd race if I were just to add try_to_freeze before calling
schedule_timeout_interruptible.

> schedule_timeout_interruptible().  Was getting confused with
> prepare_to_wait().  That said, why not use prepare_to_wait() instead?

Because I don't need to wait on a waitqueue there. A THP failure
occurred, that caused some CPU overload and it's usually happening at
time of heavy VM stress, so I don't want to retry and cause more CPU
load from khugepaged until after some time even if more wakeups come
by. khugepaged is a very low cost background op, so it shouldn't cause
unnecessary CPU usage at times of VM pressure, waiting a better time
later is better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
