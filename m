Received: from fridge.bcc.co.uk ([213.105.108.11])
          by mta07-svc.ntlworld.com
          (InterMail vM.4.01.02.27 201-229-119-110) with ESMTP
          id <20010402215508.GMDJ281.mta07-svc.ntlworld.com@fridge.bcc.co.uk>
          for <linux-mm@kvack.org>; Mon, 2 Apr 2001 22:55:08 +0100
Received: from ntlworld.com (kettle.bcc.co.uk [192.168.1.2])
	by fridge.bcc.co.uk (Postfix on SuSE Linux 7.1 (i386)) with ESMTP id BD3B4318
	for <linux-mm@kvack.org>; Mon,  2 Apr 2001 22:55:07 +0100 (BST)
Message-ID: <3AC8F53B.4003E0A8@ntlworld.com>
Date: Mon, 02 Apr 2001 22:55:07 +0100
From: Leigh Brown <l.b.brown@ntlworld.com>
MIME-Version: 1.0
Subject: Controlling buffer cache and page cache (long)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,

(NB for easily bored readers -> scroll to the bottom for my questions)

I have a couple of questions about the buffer cache and page cache and
was hoping that someone might be able to point me in the right
direction, but first some background.

When I, for example, perform a recursive grep of the kernel source tree
the mm will allocate lots of pages for the page cache and buffer cache,
which is nice.  However, when it runs out it decides to take a few more
by swapping out some pages that maybe aren't being used.  This is okay
too - I understand the arguments for doing this.  Now, I'm using mozilla
and am browsing while the search completes.  However, when I finish the
page I was reading and click on a hyperlink I find bits of mozilla have
been swapped out and it is now very unresponsive.  This I don't like.
Other things such as clicking on desktop menus take several seconds to
complete.  The system has typically allocated over 86% of physical
memory to the buffer and page caches, and in doing so has swapped out my
desktop apps.

Let me move to a hypothetical scenario.  Several months ago I
encountered a system running (some major commercial Unix O/S) hosting a
datawarehouse running on (some major commercial DBMS) and it was
performing terribly.  Now, it doesn't matter what they were precisely,
but the performance problem was an interesting one, because I think the
same problem will affect Linux.  Basically, the DBMS was configured with
a fairly large pool of memory for storing cached database
information (I'm trying to use generic terms here to avoid giving the
game away :-) but a lot of the jobs running on the system were inserting
and extracting data from the database to flat files.  The MM on that O/S
was similar to Linux in that it would swap out other pages to allocate
file cache pages.  Unfortunately, the pages that the O/S selected
happened to be the pages in the pool of memory that the DBMS was using.
Even more unfortunately (you could say, catastrophically!) those were
the very pages that the DBMS would next use when it needed some free
pages from its own cache.  The LRU strategies of the MM and the DBMS
were working 100% against each other.

Once I'd worked out what the problem was, a quick read of the manuals
turned up a simple solution.  The O/S could be configured to only
allocate a maximum percentage of physical RAM for file cache pages.  I
knocked this percentage down to ensure that there was enough memory for
the DBMS and its big cache pool and the system burst into life (it was
amazing).  It turned out the O/S was quite clever, in that it could
exceed the limits set if memory was totally free, so if the DBMS wasn't
running then the huge amounts of free RAM could still be used as file
cache by whatever programs were left.

On to the questions.

My first question is: can I do this in Linux?  I was quite pleased when
I saw the /proc/sys/vm/buffermem and /proc/sys/vm/pagecache entries.
Unfortunately they seem to be obsolete (I commented them out and the
kernel still compiles and boots!)  I've read the source and now my head
is spinning so that's why I'm writing this note.

This leads me to my next question:  if this can't be configured now,
where would I put the code?  In other words, can anyone provide any
pointers as to where to start looking?

Any help would be gratefully received.  Also, let me know if you
disagree violently with my assumption that Linux will suffer the same
problem as that "other O/S" (with no cure unless someone answers
question one).

Cheers,

Leigh.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
