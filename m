Received: from alogconduit1ah.ccr.net (root@alogconduit1ak.ccr.net [208.130.159.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06468
	for <linux-mm@kvack.org>; Sun, 30 May 1999 13:41:52 -0400
Subject: Re: [PATCH] cache large files in the page cache
References: <Pine.LNX.3.95.990526104127.14018K-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 May 1999 12:17:16 -0500
In-Reply-To: Linus Torvalds's message of "Wed, 26 May 1999 10:44:02 -0700 (PDT)"
Message-ID: <m1675a4gv7.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On Wed, 26 May 1999, Jakub Jelinek wrote:
>> 
>> I have minor suggestion to the patch. Instead of using vm_index <<
>> PAGE_SHIFT and page->key << PAGE_CACHE_SHIFT shifts either choose different
>> constant names for this shifting (VM_INDEX_SHIFT and PAGE_KEY_SHIFT) or hide
>> these shifts by some pretty macros (you'll need two for each for both
>> directions in that case - if you go the macro way, maybe it would be a good
>> idea to make vm_index and key type some structure with a single member like
>> mm_segment_t for more strict typechecking).

LT> Indeed. An dI would suggest that the shift be limited to at most 9 anyway:
LT> right now I applied the part that disallows non-page-aligned offsets, but
LT> I think that we may in the future allow anonymous mappings again at finer
LT> granularity (somebody made a really good argument about wine for this).

I'd love to hear the argument.   Something that would negate the disadvantage
of ntuple buffering, and the need for reverse page maps, and isn't portable.

LT> Thinking that the VM mapping shift has to be the same as the page shift is
LT> not necessarily the right thing. With just 9 bits of shift, you still get
LT> large files - 41 bits of files on a 32-bit architecture, and by the time
LT> you want more you _really_ can say that you had better upgrade your CPU. 

Well, currectly supporting non-aligned mappings needs more than just a
few extra bits.  The code to update all mappings on write, and the
ability to ensure that a given byte is only faulted in for a single
offset at a time.   (Admittedly if everything is a read mapping you
can be a smidge more lax).

My solution to the issue of potentials was the idea of the vm_store.
The idea of using something besides struct inode for the page cache.
For unaligned mappings or really huge files you could have multiple
vm_store's per inode, (plus the code to keep them in sync).  

And it shouldn't incur a noticeable performance penalty as it is in
an outer loop.

To date all I've implemented is the existence of such a structure.
And the seperation of what is the page cache from all the other junk
in filemap.c

My current patch follows seperately for review.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
