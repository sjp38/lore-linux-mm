Date: Fri, 9 Aug 2002 13:11:20 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: object based reverse mapping, fundamental problem
Message-ID: <Pine.LNX.4.44L.0208091302570.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: k42@watson.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
