Date: Sat, 25 Sep 1999 16:55:01 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909242002500.16745-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.4.10.9909251639140.1083-100000@laser.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Sep 1999, James Simmons wrote:

>Just out of curoisty how would one revoke all read-write to that page?

man mprotect (have a look to PROT_NONE)

>I know this would be expensive to do.

If you don't know how to do that how do you know it's expensive? ;)

But indeed you are right: it's a bit expensive as if the pages are just
allocated you'll have to change all their ptes.

>Also what does LockPage, TryLockPage(page), and UnlockPage(page) do
>exactly? I assume this also doesn't protect the memory contents either.

They have nothing to do with the ptes and vmas and with the userspaces
accesses synchronization.

They only deals with I/O of memory to disk (and with the recycling of
cache/buffer pages to disk: obviously if a page is locked because under
I/O, you can't free it).

>What I'm guessing at is it protects the page struct itself. If you are

It basically synchoronizes the I/O of whole pages from/to disk.

>changing the protections on a page you don't want a another process also
>attempting to do this. 

That is preserved using the mmap_sem as the mmap_sem serializes the
ptes/vmas writes. (mprotect grab the mmap sem of course)

>> then there is no page fault.  Otherwise you'd be doing massive amounts
>> of kernel work for every byte of data accessed by every process.
>
>Makes sense. I see its a clock algorithm that looks threw the pages and
>markes the pages as dirty that have been accessed. Thanks to the link

What Stephen wanted to tell is that if you have the pages just mapped and
allocated in the process space (pte_present(pte) == 1), then no page fault
will happen by touching such pages.

Only the _first_ time you'll touch a (not mlocked) anonymous mapping
(malloced region) you'll trigger a page-fault to effectively allocate and 
then map a zeroed page for the process.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
