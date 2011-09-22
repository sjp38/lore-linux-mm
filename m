Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 37E029000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 19:13:47 -0400 (EDT)
Date: Thu, 22 Sep 2011 16:13:25 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [PATCH 0/8] idle page tracking / working set estimation
Message-Id: <20110922161325.f94f9c9e.akpm@google.com>
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 16 Sep 2011 20:39:05 -0700
Michel Lespinasse <walken@google.com> wrote:

> Please comment on the following patches (which are against the v3.0 kernel).
> We are using these to collect memory utilization statistics for each cgroup
> accross many machines, and optimize job placement accordingly.

Please consider updating /proc/kpageflags with the three new page
flags.  If "yes": update.  If "no": explain/justify.

Which prompts the obvious: the whole feature could have been mostly
implemented in userspace, using kpageflags.  Some additional kernel
support would presumably be needed, but I'm not sure how much.

If you haven't already done so, please sketch down what that
infrastructure would look like and have a think about which approach is
preferable?



What bugs me a bit about the proposal is its cgroups-centricity.  The
question "how much memory is my application really using" comes up
again and again.  It predates cgroups.  One way to answer that question
is to force a massive amount of swapout on the entire machine, then let
the system recover and take a look at your app's RSS two minutes later.
This is very lame.

It's a legitimate requirement, and the kstaled infrastructure puts a
lot of things in place to answer it well.  But as far as I can tell it
doesn't quite get over the line.  Then again, maybe it _does_ get
there: put the application into a memcg all of its own, just for
instrumentation purposes and then use kstaled to monitor it?

<later> OK, I'm surprised to discover that kstaled is doing a physical
scan and not a virtual one.  I assume it works, but I don't know why. 
But it makes the above requirement harder, methinks.



How does all this code get along with hugepages, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
