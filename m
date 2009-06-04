Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 306C26B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 21:42:17 -0400 (EDT)
Subject: Re: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
References: <m1oct739xu.fsf@fess.ebiederm.org>
	<1243893048-17031-18-git-send-email-ebiederm@xmission.com>
	<alpine.DEB.1.10.0906020944540.12866@makko.or.mcafeemobile.com>
	<m1eiu2qqho.fsf@fess.ebiederm.org>
	<alpine.DEB.1.10.0906021429570.12866@makko.or.mcafeemobile.com>
	<m13aaintb1.fsf@fess.ebiederm.org>
	<alpine.DEB.1.10.0906030754550.17143@makko.or.mcafeemobile.com>
	<m1tz2xox7n.fsf@fess.ebiederm.org>
	<alpine.DEB.1.10.0906031708480.18001@makko.or.mcafeemobile.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 03 Jun 2009 18:42:07 -0700
In-Reply-To: <alpine.DEB.1.10.0906031708480.18001@makko.or.mcafeemobile.com> (Davide Libenzi's message of "Wed\, 3 Jun 2009 17\:50\:01 -0700 \(PDT\)")
Message-ID: <m11vq0bwr4.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

Davide Libenzi <davidel@xmailserver.org> writes:

> On Wed, 3 Jun 2009, Eric W. Biederman wrote:
>
>> What code are you talking about?
>> 
>> To the open path a few memory writes and a smp_wmb.  No atomics and no
>> spin lock/unlocks.
>> 
>> Are you complaining because I retain the file_list?
>
> Sorry, did I overlook the patch? Weren't a couple of atomic ops and a spin 
> lock/unlock couple present in __dentry_open() (same sort of the release 
> path)?

You might be remembering v1.  In v2 I have operations like file_hotplug_read_trylock
that implement a lock but use an rcu like algorithm.  So there are no atomic
operations involved with their associated pipeline stalls.  Over my previous
version this made a reasonable performance benefit.

> And that's only like 5% of the code touched by the new special handling of 
> the file operations structure (basically, every f_op access ends up being 
> wrapped by two atomic ops and other extra code).

Yes there is a single extra wrapping of every file in the syscall path.  So
we know that someone is using it. 

> The question, that I'd like to reiterate is, is this stuff really needed?
> Anyway, my complaint ends here and I'll let others evaluate if merging 
> this patchset is worth the cost.

Sure.  My apologies for not answering that question earlier.

My perspective is that every subsystem that winds up supporting hotplug
hardware winds up rolling it's own version of something like this,
and they each have a different set of bugs.

So one generic version is definitely worth implementing.

Similarly there is a case for a generic revoke facility in the kernel.
Alan at least has made the case that there are certain security problems
that can not be solved in userspace without revoke.

>From an implementation point of view doing the generic implementation at
the vfs level has significant benefits.

The extra locking appears reasonable from a code maintenance and
comprehensibility point of view.  A real pain to find all of the entry
points into the vfs, and get other code to use the right vfs helpers
they should always have been using but I am volunteering to do that
work.

The practical question I see is are the performance overheads of my
primitives low enough that I do not cause performance regressions
on anyone's fast path.  As far as I have been able to measure is that 
the performance overhead is low enough, because I have been able to
avoid the use of atomics and have been able to use fairly small code
with predictable branches.  Which is why I pressed you to be certain
I understood where you are coming from.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
