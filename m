Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 26D776B00D6
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:56:05 -0500 (EST)
Message-ID: <50B8F2F4.6000508@parallels.com>
Date: Fri, 30 Nov 2012 21:55:00 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

Hello,

This is an attempt to implement support for memory snapshot for the the
checkpoint-restore project (http://criu.org).

To create a dump of an application(s) we save all the information about it
to files. No surprise, the biggest part of such dump is the contents of tasks'
memory. However, in some usage scenarios it's not required to get _all_ the
task memory while creating a dump. For example, when doing periodical dumps
it's only required to take full memory dump only at the first step and then
take incremental changes of memory. Another example is live migration. In the
simplest form it looks like -- create dump, copy it on the remote node then
restore tasks from dump files. While all this dump-copy-restore thing goes all
the process must be stopped. However, if we can monitor how tasks change their
memory, we can dump and copy it in smaller chunks, periodically updating it 
and thus freezing tasks only at the very end for the very short time to pick
up the recent changes.

That said, some help from kernel to watch how processes modify the contents of
their memory is required. I'd like to propose one possible solution of this
task -- with the help of page-faults and trace events.

Briefly the approach is -- remap some memory regions as read-only, get the #pf
on task's attempt to modify the memory and issue a trace event of that. Since
we're only interested in parts of memory of some tasks, make it possible to mark
the vmas we're interested in and issue events for them only. Also, to be aware
of tasks unmapping the vma-s being watched, also issue an event when the marked
vma is removed (and for symmetry -- an event when a vma is marked).

What do you think about this approach? Is this way of supporting mem snapshot
OK for you, or should we invent some better one?

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
