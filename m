Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11598
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:37:55 -0500
Date: Sat, 19 Dec 1998 17:37:03 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <Pine.LNX.3.96.981219172526.648A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981219173054.756A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Dec 1998, Andrea Arcangeli wrote:

>The only reason to add a bitflag in the page->flags field is to avoid
>us to play with the pte. Now the pte is used only to set the page readonly
>to allow us to remove the clean flag at the first page fault.

Ah but I just found a problem... When we set the PG_clean flag on the page
we should set the pte readonly for that page in all process vm and not
only in the process running. But if we must play with the page table it's
easier to directly set the page as clean as I was used to do with my
previous update_shared_mappings() patch. So I think we could drop
completly my last patch and return to my old code and solve the problem to
handle the mmap_sem locking right...

To get the locking right I think we could do something like:

if (sharedmapping)
{

	for_each_process_that_shares_the_mmap(p)
		down(&p->mm->mmap_sem);
} else {
	down(&current->mm->mmap_sem);
}

for_each_process_that_shares_the_mmap() will return processes always in
the same order relative to how the mappings are ordered in the the inode.

comments?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
