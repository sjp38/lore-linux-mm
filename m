Subject: Re: object based reverse mapping, fundamental problem
Message-ID: <OF5634140C.819A0F08-ON85256C17.00723FEE-85256C17.0073C82E@us.ibm.com>
From: Orran Y Krieger <okrieg@us.ibm.com>
Date: Fri, 16 Aug 2002 17:04:38 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: k42@watson.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

                                                                                                               
                                                                                                               
                                                                                                               


Sorry for the delay in responding, vacation... and recovery :-(

Couple of answers in a K42 specific context.  First, we support first
class  shared segments.  On PPC this would use HW support... on x86 you
would probably be talking about sharing second level page tables.  With a
shared segment, there is only a single mapping to be invalidated, so you
don't have to traverse the regions at all.  (Note, on PPC the HW maintains
the TLB consistency, there is an issue on x86, but we can defer this to
another discussion on shared segments.)   So, while we support multiple
regions mapping a file at arbitrary boundaries/alignments, if something is
widely shared it doesn't seem crazy to require reasonable
alignments/sizes/permissions so that we can have a more efficient
implementation.   Actually, the default operations for mapping a file in
K42 have the OS give you back the location and size of the region, so that
by default the OS will try to share the segment.   Does this seem like a
reasonable response, i.e., refuse to support more than X mappings of a
file at arbitrary algnments...?

If we assume that the first approach is not feasible, then the other
strategy would be to have an adaptive algorithm.   That is, within the
object, maintain per-page mappings until you hit a threshold, then get rid
of the per-page mappings and maintain just reverse mappings for the whole
object.  In K42, we would do this by hot-swapping from one implementation
to the other.  In Linux, one would probably want the object to internally
have both implementations and switch between them based on the amount of
meta-data being maintained and the number of pages mapped per region.

Makes sense?
          -- Orran



Rik van Riel <riel@conectiva.com.br> on 08/09/2002 01:11:20 PM

To:    k42@watson.ibm.com
cc:    linux-mm@kvack.org
Subject:    object based reverse mapping, fundamental problem



Hi,

Ben LaHaise pointed me at a fundamental problem with object
based reverse mappings, something which isn't relevant for
Linux yet but is certainly an interesting problem the k42
people could have fun with ;)

The problem scenario is as follows:
- a large file (say a database) is being mmap()d by
  multiple processes, say 100 processes
- each process maps multiple windows of that file,
  say 100 windows each

The result is that there are 10000 mappings of that file!

Now imagine the pageout code wanting to evict a few pages
from this file and having to track down the page tables
that map a certain physical page.

Having to walk all 10000 mappings is just not acceptable,
if we did that any user could effectively DoS the machine,
even with reasonable resource limits on the user.

How could we efficiently find all (start, length) mappings
of the file that have our particular (file, offset) page
covered ?

Do the K42 people have some efficient datastructure to fix
this potential DoS or is this something we still have to
find a solution for ?

Note that page table entry based reverse mappings don't suffer
from this problem, but of course those have a per-page overhead
on fork+exec, which may not be good for other purposes.

kind regards,

Rik
--
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/       http://distro.conectiva.com/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
