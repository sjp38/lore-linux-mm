Date: Tue, 15 Feb 2005 20:22:14 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050215202214.4b833bf3.pj@sgi.com>
In-Reply-To: <20050216015622.GB28354@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com>
	<20050215165106.61fd4954.pj@sgi.com>
	<20050216015622.GB28354@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: raybry@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin wrote:
> If you do that for each job with the shared mapping and have overlapping
> node lists, you end up combining two nodes and not being able to seperate
> them.

I don't see the problem.  Just don't move a task onto a node
until you moved the one that was already there, if any, off.

Say, for example, you want to move a job from nodes 4, 5 and 6 to nodes
5, 6 and 7, respectively.  First move 6 to 7, then 5 to 6, then 4 to 5.
Or save some migration, and just move what's on 4 to 7, leaving 5 and
6 as is.

At any point, either there is at least one new node not currently
occupied by some not yet migrated task, or else you're just reshuffling
a set of tasks on the same set of nodes, which I presume would be
without purpose and so we don't need to support.  If we did need to
support shuffling a job on its current node set, I'd have to plead
insanity, and reintroduce the temporary node hack.


> Unfortunately it does happen often for stuff like shared file mappings
> that a different job is using in conjuction with this job.

This might be the essential detail I'm missing.  I'm not sure what you
mean here (see P.S., at end), but it seems that you are telling me you
must have the ability to avoid moving parts of a job.  That for a given
task, pinned to a given cpu, with various physical pages on the node
local to that cpu, some of those pages must not move, because they are
used in conjunction with some other job, that is not being migrated at
this time.

If that's the case, aren't you pretty much guaranteeing the migrated job
will not run as well as before the migration - some of the pages it was
using that were local are now remote.  And if that's the case, I take it
you are presuming that the server process doing the migration has
intimate knowledge of the tasks being migrated, and of the various
factors that determine which pages of those tasks should migrate and
which should not migrate.  Uggh.

I am working from the idea that you've got some job, running on some
nodes, and that you just want to jack up that job and put it back down
on an isomorphic set of nodes - same number of nodes, same (or at least
sufficient) amount of memory on the nodes, possibly an overlapping set
of nodes, but just not the self-same identical set of nodes.  I was
presuming that everything in the address spaces of the tasks in the job
should move, and should end up placed the same, relative to the tasks in
the job, as before, just on different node numbers.  Even shared library
pages can move -- if this job happened to be the one that paged that
portion of library in, then perhaps this job has the most use for that
page.  That or it's just a popular page left over from the dawn of time
and it doesn't matter much which node holds it.

Perhaps I have the wrong idea here?


> Unfortunately, userspace can not avoid this easily as it does not know
> which pages in the virtual address space are on which nodes.

Userspace doesn't need to know that.  It only needs to know at least one
node in the set of new nodes is not still occupied by an unmigrated task
in the job.  See the example above.


> Oh sure, we could add in ... 
> Oh yeah, we also need to add ...
> It could do some kludge work and only call ...

No need to spend too much effort elaborating such additions ... the mere
fact that you find them necessary means that either it's not as simple
as I think, or it's simpler than you think.  In other words, that one of
us (most likely me) doesn't understand the real requirements here.

P.S. - or perhaps what you're telling me with the bit about shared file
mappings is not that you must not move any such shared file pages as
well, but that you'd rather not, as there are perhaps many such pages,
and the time spent moving them would be wasted.  Are you saying that you
want to move some subset of a jobs pages, as an optimization, because
for a large chunk of pages, such as for some files and libraries shared
with other jobs, the expense of migrating them would not be paid back?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
