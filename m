From: Mark_H_Johnson@Raytheon.com
Subject: Re: [RFC] RSS guarantees and limits
Message-ID: <OFA8CAC4C1.A4177D6C-ON86256906.006913F4@hou.us.ray.com>
Date: Thu, 22 Jun 2000 18:02:49 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

Controls on resident set size has been one of the items I really want to
see established. I have some concerns about what is suggested here and have
a few suggestions. I prefer user settable RSS limits that are enforced by
the kernel & use automated methods when the user doesn't set any such
limits.

My situation is this. I'm looking at deploying a large "real time"
simulation on a cluster of Linux machines. The main application will be
locked in memory and must have predictable execution patterns. To aid in
development, we will have a number of workstations. I want to be able to
run the main application at "slower than real time" on those workstations -
using paging & swapping as needed.
  [1] Our real time application(s) will lock lots [perhaps 1/2 to 3/4] of
physical memory.
    - The RSS for our application must be at least large enough to cover
the "locked" memory plus some additional space for TBD purposes.
    - The RSS for remaining processes must be "reasonable" - take into
consideration the locked memory as unavailable until released.
    - The transition from lots of memory is "free" to lots of memory is
"locked" has to be managed in some way.
    We know in advance what "reasonable" values are for RLIMIT_RSS & can
set them appropriately. I doubt an automatic system can do well in this
case.
  [2] On the workstation, we want good performance from the program under
test.
    - The RSS of our application must be large relative to the rest of the
system applications
    - There needs to be some balance between our application and other
applications - to run gdb, X, and other tools used during test
    This is a similar situation to above when I really do want a "memory
hog" to use most of the system memory. I think user settable RSS limits
would still be better than an automatic system.

Using the existing RSS limits would go a long way to enabling us to set the
system up and meet these diverse needs. At this time, I absolutely prefer
to initiate swapping of tasks to preserve the RSS of the application we're
delivering to our customer. On our development machines, some automatic
tuning would be OK, but I don't see how it will run "better" (as measured
by page fault rates) than with carefully selected values based on the
applications being run. If there's plenty of space available, I don't mind
automatic methods for a process have more than the RSS limit [if swapping
isn't necessary]. If all [or most] of the processes have "unlimited" for
the RSS limit, do something reasonable as well in an automated way. But if
the user has specified RSS limits [via the RLIMIT_RSS setting in
setrlimit(2)], please abide by them. Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


                                                                                                                    
                    Rik van Riel                                                                                    
                    <riel@conecti        To:     linux-mm@kvack.org                                                 
                    va.com.br>           cc:     "Stephen C. Tweedie" <sct@redhat.com>, (bcc: Mark H                
                                         Johnson/RTS/Raytheon/US)                                                   
                    06/21/00             Subject:     [RFC] RSS guarantees and limits                               
                    05:29 PM                                                                                        
                                                                                                                    
                                                                                                                    



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
http://www.conectiva.com/                      http://www.surriel.com/





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
