Received: from dolphin.chromatix.org.uk ([192.168.239.105])
	by helium.chromatix.org.uk with esmtp (Exim 3.15 #5)
	id 14qF21-0002Aa-00
	for linux-mm@kvack.org; Thu, 19 Apr 2001 15:03:38 +0100
Message-Id: <l03130303b704a08b5dde@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 19 Apr 2001 15:03:28 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> THIS is why we need process suspension in the kernel.
>
>Not necessarily.  Creating a minimal working set guarantee for small
>tasks is one way to avoid the need for process suspension.  Creating a
>dynamic working set upper limit for large, thrashing tasks is a way to
>avoid the thrashing tasks from impacting everybody else too much.
>There are many possible ways forward, and I am not yet convinced that
>process suspension is necessary.

Let's stop arguing at such an abstract level, and try to get some
algorithms down so we can analyse this properly.  Below, I outline a
possible algorithm for handling the working-set model I outlined yesterday.
Those of you who still believe in process suspension, please do likewise
(exactly which process do you suspend, and for how long?).

My proposal is to introduce a better approximation to LRU in the VM, solely
for the purpose of determining the working set.  No alterations to the page
replacement policy are needed per se, except to honour the "allowed working
set" for each process as calculated below.

As I understand things (correct me if I'm wrong), there is a list of VM
pages associated with each process (current->mm).  There is also a number
of lists of pages, classifying them into "active", "inactive/clean",
"inactive/dirty" and so on.  There are routines which know when and how to
move pages between these lists (precisely when and how these are called is
an area I haven't investigated yet).  When a process accesses memory, there
must be a routine which moves the relevant page onto the active list.  The
page may already be on the active list, in which case nothing is done at
present.

During the act of moving a page onto the active list (or determining that
it already is there and doesn't need to be moved), I think it would be
appropriate to associate the time of last access with the page, and the
page access order with the process.  From maintenance of a list of such
associations, the working set of the process can be calculated quite easily.

struct working_set_list {
	struct working_set_list *next;
	page_id id;
	unsigned short accessed;
};

Suppose the page list current->mm is extended to contain the above in some
manner.  The 'accessed' field is set to the LSW of jiffies, and old entries
are purged from the working set when 0x8000 jiffies have passed (about 5.5
minutes on x86 and other 100Hz systems, probably shorter on some
architectures).  By keeping head, tail and possibly 'oldness threshold'
pointers in current->mm, list maintenance should become O(1) for most
common operations.

The working set is simply the number of entries in the list which are newer
than the oldness threshold.  Calculation of this value can be made trivial
by keeping a separate counter (similar to current->mm.total_vm) which is
updated whenever the list is maintained.  Note that the working set can
contain pages which are not in the active list - removal of a page from the
active list does not remove it from the working set.

Since the sum of all the working sets in the system can be greater than the
physical memory in the system (this is what thrashing means, after all), a
"physical quota" needs to be calculated for each process.  The calculation
of the physical quota is based heavily on the working set, and should
probably be done at scan-for-swap-out time.  This calculation is roughly as
I described yesterday:

- Calculate the total physical quota for all processes as the sum of all
working sets (plus unswappable memory such as kernel, mlock(), plus a small
chunk to handle buffers, cache, etc.)
- If this total is within the physical memory of the system, the physical
quota for each process is the same as it's working set.  (fast common case)
- Otherwise, locate the process with the largest quota and remove it from
the total quota.  Add in "a few" pages to ensure this process always has
*some* memory to work in.  Repeat this step until the physical quota is
within physical memory or no processes remain.
- Any remaining processes after this step get their full working set as
physical quota.  Processes removed from the list get equal share of
(remaining physical memory, minus the chunk for buffers, cache and so on).

Now we turn to the page replacement policy.  At present, AFAICT, this is a
"not recently used" policy - pages are swapped out if they are not actually
in the active list.  The act of scanning memory for swappable pages also
removes pages from the active list (presumably so they will be swapped out
anyway if nothing could be found on the first scan).

A simple modification is needed here - if a page is "not recently used" AND
all of the page's users are processes which currently have more
physically-resident pages than it's "physical quota" as calculated above,
it is swapped out.

For the special case where the physical quota of a process equals it's
working set, the replacement algorithm might check if the candidate page is
in the working set for the process, as a hint not to page it out.

Comments?

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
