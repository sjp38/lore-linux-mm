Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA03163
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 01:29:35 -0500
Subject: Re: Update shared mappings
References: <Pine.LNX.3.96.981202191811.4720A-100000@dragon.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 02 Dec 1998 23:44:51 -0600
In-Reply-To: Andrea Arcangeli's message of "Wed, 2 Dec 1998 19:32:56 +0100 (CET)"
Message-ID: <m190gpixt8.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On Wed, 2 Dec 1998, Stephen C. Tweedie wrote:
>> else's mm semaphore.  If you have two processes doing that to each other
>> (ie. two processes mapping the same file r/w and doing msyncs), then you
>> can most certainly still deadlock.

AA> The thing would be trivially fixable if it would exists a down_trylock() 
AA> that returns 0 if the semaphore was just held. I rejected now the
AA> update_shared_mappings from my tree in the meantime though.

AA> I have a question. Please consider only the UP case (as if linux would not
AA> support SMP at all). Is it possible that while we are running inside
AA> sys_msync() and another process has the mmap semaphore held?

AA> Stephen I read some emails about a PG_dirty flag. Could you tell me some
AA> more about that flag? 

It used to be one of the flags defined for struct page.  It doesn't exist currently.

But more precisely it refers to handling tracking dirty pages by page, instead
of where they got dirty.

This could be done using using PG_dirty and having shrink_mmap (or a similiar function)
write out the pages.  The problem is that you lose all locality of reference in
the written pages.  A simple linked list order by time the page gets dirty does
much better.  

I have been working on this off and on for a while, but the code freeze went in
before I had anything I would be willing to integrate.  Also my code focuses on the
requirements on the filesystem code, and not on the requirements of process pages, so
we need a little more work.

Currently I'm leaning towards adding a struct mapping, that would perform
some of the work of the current struct vm_area_struct, and hold a list
of the vm_area_structs, that implement that mapping.  
inode->i_mmap would be replaced with inode->i_mappings which would
list the mappings. 

For dirty page handling I think walking the page tables instead of the
all of memory would give us easier access to dirty bits, and remove
the need to do reverse page table entries.  This assumes walking the
page tables won't be too expensive.

A process on a timer that kicks off periodically should be able to
handle updating all of the dirty bits, removing the dirty status from
the page tables, and then writing some dirty pages out to disk, before
it's good work is undone.

This idea needs to be explored with some actuall code, and isn't for
2.2 but with a little care hopefully we can have a working
implemenation op PG_dirty or similiar.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
