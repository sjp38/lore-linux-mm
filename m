Date: Thu, 7 Apr 2005 22:18:07 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Excessive memory trapped in pageset lists
In-Reply-To: <20050408023436.GA1927@sgi.com>
Message-ID: <Pine.LNX.4.58.0504072207080.6964@schroedinger.engr.sgi.com>
References: <20050407211101.GA29069@sgi.com> <1112923481.21749.88.camel@localhost>
 <20050408023436.GA1927@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Apr 2005, Jack Steiner wrote:

> On Thu, Apr 07, 2005 at 06:24:41PM -0700, Dave Hansen wrote:
> > On Thu, 2005-04-07 at 16:11 -0500, Jack Steiner wrote:
> > >    28 pages/node/cpu * 512 cpus * 256nodes * 16384 bytes/page = 60GB  (Yikes!!!)
> > ...
> > > I have a couple of ideas for fixing this but it looks like Christoph is
> > > actively making changes in this area. Christoph do you want to address
> > > this issue or should I wait for your patch to stabilize?
> >
> > What about only keeping the page lists populated for cpus which can
> > locally allocate from the zone?
> >
> > 	cpu_to_node(cpu) == page_nid(pfn_to_page(zone->zone_start_pfn))
>
> Exactly. That is at the top of my list. What I haven't decided is whether to:

<list of options where to keep the pagesets....,>

Maybe its best to keep only pageset for each cpu for the zone that is
local to the cpu? That may allow simplified locking.

The pageset could be defined as a per cpu variable.

I would like to add a list of zeroed pages to the hot and cold list. If a
page can be obtained with some inline code from the per cpu lists from the
local zone then we would be able to bypass the unlock, page alloc, page
zero, relock, verify pte not changed sequence during page faults.

F.e. do_anonymous page could try to obtain an entry from the quicklist
and only drop the lock if the allocation is off node or no pages are on
the quicklist of zeroed pages.


> > There certainly aren't a lot of cases where frequent, persistent
> > single-page allocations are occurring off-node, unless a node is empty.
>
> Hmmmm. True, but one of our popular configurations consists of memory-only nodes.
> I know of one site that has 240 memory-only nodes & 16 nodes with
> both cpus & memory. For this configuration, most memory if offnode
> to EVERY cpu. (But I still don't want to cache offnode pages).

We could have an additional pageset in the remote zone for remote
accesses only. This means we would have to manage one remote pageset
and a set of cpu local pagesets for the cpu to which the zone is the
primary local node.

The off node pageset would require a spinlock
whereas the node local pagesets could work very quickly w/o locking. We
would need some easy way to distinguish off node accesses from on node.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
