Date: Wed, 21 Jun 2000 19:29:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFC] RSS guarantees and limits
Message-ID: <Pine.LNX.4.21.0006211059410.5195-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

I think I have an idea to solve the following two problems:
- RSS guarantees and limits to protect applications from
  each other
- make sure streaming IO doesn't cause the RSS of the application
  to grow too large
- protect smaller apps from bigger memory hogs


The idea revolves around two concepts. The first idea is to
have an RSS guarantee and an RSS limit per application, which
is recalculated periodically. A process' RSS will not be shrunk
to under the guarantee and cannot be grown to over the limit.
The ratio between the guarantee and the limit is fixed (eg.
limit = 4 x guarantee).

The second concept is the keeping of statistics per mm. We will
keep statistics of both the number of page steals per mm and the
number of re-faults per mm. A page steal is when we forcefully
shrink the RSS of the mm, by swap_out. A re-fault is pretty similar
to a page fault, with the difference that re-faults only count the
pages that are 1) faulted in  and 2) were just stolen from the
application (and are still in the lru cache).


Every second (??) we walk the list of all tasks (mms?) and do
something very much like this:

if (mm->refaults * 2 > mm->steals) { 
	mm->rss_guarantee += (mm->rss_guarantee >> 4 + 1);
} else {
	mm->rss_guarantee -= (mm->rss_guarantee >> 4 + 1);
}
mm->refaults >>= 1;
mm->steals >>= 1;


This will have different effects on different kinds of tasks.
For example, an application which has a fixed working set will
fault *all* its pages back in and get a big rss_guarantee (and
rss_limit).

However, an application which is streaming tons of data (and
using the data only once) will find itself in the situation
where it does not reclaim most of the pages that get stolen from
it. This means that the RSS of a data streaming application will
remain limited to its working set. This should reduce the bad
effects this app has on the rest of the system. Also, when the
app hits its RSS limit and the page it releases from its VM is
dirty, we can apply write throttling.


One extra protection is needed in this scheme. We must make sure
that the RSS guarantees combined never get too big. We can do this
by simply making sure that all the RSS guarantees combined never
get bigger than 1/2 of physical memory. If we "need" more than that,
we can simply decrease the biggest RSS guarantees until we get below
1/2 of physical memory.


regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
