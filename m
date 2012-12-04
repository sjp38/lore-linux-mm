Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D21B96B002B
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 00:16:05 -0500 (EST)
Message-ID: <50BD86DE.6050700@parallels.com>
Date: Tue, 04 Dec 2012 09:15:10 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
References: <50B8F2F4.6000508@parallels.com> <20121203144310.7ccdbeb4.akpm@linux-foundation.org>
In-Reply-To: <20121203144310.7ccdbeb4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On 12/04/2012 02:43 AM, Andrew Morton wrote:
> On Fri, 30 Nov 2012 21:55:00 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> This is an attempt to implement support for memory snapshot for the the
>> checkpoint-restore project (http://criu.org).
>>
>> To create a dump of an application(s) we save all the information about it
>> to files. No surprise, the biggest part of such dump is the contents of tasks'
>> memory. However, in some usage scenarios it's not required to get _all_ the
>> task memory while creating a dump. For example, when doing periodical dumps
>> it's only required to take full memory dump only at the first step and then
>> take incremental changes of memory. Another example is live migration. In the
>> simplest form it looks like -- create dump, copy it on the remote node then
>> restore tasks from dump files. While all this dump-copy-restore thing goes all
>> the process must be stopped. However, if we can monitor how tasks change their
>> memory, we can dump and copy it in smaller chunks, periodically updating it 
>> and thus freezing tasks only at the very end for the very short time to pick
>> up the recent changes.
>>
>> That said, some help from kernel to watch how processes modify the contents of
>> their memory is required. I'd like to propose one possible solution of this
>> task -- with the help of page-faults and trace events.
>>
>> Briefly the approach is -- remap some memory regions as read-only, get the #pf
>> on task's attempt to modify the memory and issue a trace event of that. Since
>> we're only interested in parts of memory of some tasks, make it possible to mark
>> the vmas we're interested in and issue events for them only. Also, to be aware
>> of tasks unmapping the vma-s being watched, also issue an event when the marked
>> vma is removed (and for symmetry -- an event when a vma is marked).
>>
>> What do you think about this approach? Is this way of supporting mem snapshot
>> OK for you, or should we invent some better one?
> 
> The patches look pretty simple.
> 
> Some performance numbers would be useful.
> 
> Is it reliable?  Under what circumstances will the trace system drop
> events?

AFAIS when the buffer for events overflows, but the buffer size can be
tuned. I will write some mode descriptive text about it if the tracing
approach will be considered to be the way to go.

> Please cc Steven Rostedt on tracing stuff - he is a diligent reviewer.

OK.

> The proposed interface might be useful to things other than c/r.  But
> it hasn't actually been described.  Please include a full description
> of the proposed kernel/usersapce interface.

OK, will try to address that.

> Two alternatives come to mind:
> 
> 1)  Use /proc/pid/pagemap (Documentation/vm/pagemap.txt) in some
>     fashion to determine which pages have been touched.

I thought about this. Unfortunately there's no free bits left in the pagemap
entry. What can we do about it (other than introducing the pagemap2 file)?

> 2)  At pagefault time, don't send an event: just mark the vma as
>     "touched".  Then add a userspace interface to sweep the vma tree
>     testing, clearing and reporting the touched flags.

Per-vma granularity is not enough. In OpenVZ we've observed Oracle touching
several pages in a hundred-megs anon mapping. Marking _part_ of the vma with
the "node write-faults" bit would help, but there's currently no APIs that
modifies vma and report some info back at the same time. Can you propose how
it could look like?

> 2a) Avoid the full linear search by propagating the "touched" flag
>     up the rbtree and do the sweep in a fashion similar to
>     radix_tree_for_each_tagged().
> .

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
