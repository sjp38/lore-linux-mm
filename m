Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 7C6086B002B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 03:36:42 -0500 (EST)
Message-ID: <50BC6491.70600@parallels.com>
Date: Mon, 3 Dec 2012 12:36:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
References: <50B8F2F4.6000508@parallels.com>
In-Reply-To: <50B8F2F4.6000508@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org

On 11/30/2012 09:55 PM, Pavel Emelyanov wrote:
> Hello,
> 
> This is an attempt to implement support for memory snapshot for the the
> checkpoint-restore project (http://criu.org).
> 
> To create a dump of an application(s) we save all the information about it
> to files. No surprise, the biggest part of such dump is the contents of tasks'
> memory. However, in some usage scenarios it's not required to get _all_ the
> task memory while creating a dump. For example, when doing periodical dumps
> it's only required to take full memory dump only at the first step and then
> take incremental changes of memory. Another example is live migration. In the
> simplest form it looks like -- create dump, copy it on the remote node then
> restore tasks from dump files. While all this dump-copy-restore thing goes all
> the process must be stopped. However, if we can monitor how tasks change their
> memory, we can dump and copy it in smaller chunks, periodically updating it 
> and thus freezing tasks only at the very end for the very short time to pick
> up the recent changes.
> 
> That said, some help from kernel to watch how processes modify the contents of
> their memory is required. I'd like to propose one possible solution of this
> task -- with the help of page-faults and trace events.
> 
> Briefly the approach is -- remap some memory regions as read-only, get the #pf
> on task's attempt to modify the memory and issue a trace event of that. Since
> we're only interested in parts of memory of some tasks, make it possible to mark
> the vmas we're interested in and issue events for them only. Also, to be aware
> of tasks unmapping the vma-s being watched, also issue an event when the marked
> vma is removed (and for symmetry -- an event when a vma is marked).
> 
> What do you think about this approach? Is this way of supporting mem snapshot
> OK for you, or should we invent some better one?
> 

The page fault mechanism is pretty obvious - anything that deals with
dirty pages will end up having to do this. So there is nothing crazy
about this.

What concerns me, however, is that should this go in, we'll have two
dirty mem loggers in the kernel: one to support CRIU, one to support
KVM. And the worst part: They have the exact the same purpose!!

So to begin with, I think one thing to consider, would be to generalize
KVM's dirty memory notification so it can work on a normal process
memory region. KVM api requires a "memory slot" to be passed, something
we are unlikely to have. But KVM can easily keep its API and use an
alternate mechanics, that's trivial...

Generally speaking, KVM will do polling with this ioctl. I prefer your
tracing mechanism better. The only difference, is that KVM tends to
transfer large chunks of memory in some loads - in the high gigs range.
So the proposal tracing API should be able to optionally batch requests
within a time frame.

It would also be good to hear what does the KVM guys think of it as well



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
