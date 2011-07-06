Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 194469000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 09:36:40 -0400 (EDT)
Subject: Re: [PATCH 0/5] mm,debug: VM framework to capture memory reference
 pattern
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110706093146.GB19518@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
	 <20110706020103.53ed8706.akpm@linux-foundation.org>
	 <20110706093146.GB19518@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Jul 2011 08:36:34 -0500
Message-ID: <1309959394.11819.87.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

On Wed, 2011-07-06 at 15:01 +0530, Ankita Garg wrote:
> Hi,
> 
> On Wed, Jul 06, 2011 at 02:01:03AM -0700, Andrew Morton wrote:
> > On Tue,  5 Jul 2011 13:52:34 +0530 Ankita Garg <ankita@in.ibm.com> wrote:
> > 
> > > 
> > > This patch series is an instrumentation/debug infrastructure that captures
> > > the memory reference pattern of applications (workloads). 
> > 
> > Can't the interfaces described in Documentation/vm/pagemap.txt be used
> > for this?
> 
> The pagemap interface does not closely track the hardware reference bit
> of the pages. The 'REFERENCED' flag maintained in /proc/kpageflags
> only indicates if the page has been referenced since last LRU list
> enqueue/requeue. So estimating the rate at which a particular page of
> memory is referenced cannot be obtained. Further, it does not provide
> information on the amount of kernel memory referenced on behalf of
> the process.

Pagemap is good for measuring state and bad for measuring activity.

Computing state from activity via integration is generally impossible
due to the constant term and the possibility of event buffer overruns:

 state = integral(activity, t1, t2) + C

Doing the reverse is also generally impossible as it means collecting
extremely large samples at an extremely high resolution to avoid missing
events:

 activity = derivative(state, t1, t2)

If you want to measure activity, you want a tracing framework. If you
want to measure state, you want an inspection framework. Trying to build
one from the other just won't work reliably.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
