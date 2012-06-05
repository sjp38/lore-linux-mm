Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 120AA6B0070
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:52:07 -0400 (EDT)
Date: Tue, 5 Jun 2012 16:51:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
Message-ID: <20120605145123.GG21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-14-git-send-email-aarcange@redhat.com>
 <1338297385.26856.74.camel@twins>
 <4FC4D58A.50800@redhat.com>
 <1338303251.26856.94.camel@twins>
 <4FC5D973.3080108@gmail.com>
 <1338368763.26856.207.camel@twins>
 <20120530134953.GD21339@redhat.com>
 <1338488339.28384.106.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338488339.28384.106.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Hi,

On Thu, May 31, 2012 at 08:18:59PM +0200, Peter Zijlstra wrote:
> On Wed, 2012-05-30 at 15:49 +0200, Andrea Arcangeli wrote:
> > 
> > I'm thinking about it but probably reducing the page_autonuma to one
> > per pmd is going to be the simplest solution considering by default we
> > only track the pmd anyway. 
> 
> Do also consider that some archs have larger base page size. So their
> effective PMD size is increased as well.

With a larger PAGE_SIZE like 64k I doubt this would be a concern, it's
just 4k is too small.

Now I did a number of cleanups and already added a number of comments,
I'll write proper badly needed docs on the autonuma_balance() function
ASAP, but at least a number of cleanups are already committed in the
autonuma branch of my git tree.

>From my side, the thing that annoys me the most at the moment is the
page_autonuma size.

So I gave more thought about the idea outlined above but well I gave
up in less than a minute of thinking what I could run into doing
that. The fact we do pmd tracking in knuma_scand by default (possible
to disable with sysfs) is irrelevant. Unless I'm only going to track
THP pages, 1 page_autonuma per pmd won't work, when the pmd_numa fault
triggers it's all nonlinear on whatever scattered 4k page is pointed
by the pte, not shared pagecache especially.

I kept thinking more on it, I should have now figured how to reduce
the page_autonuma to 12 bytes per 4k page on both 32bit and 64bit
without losing information (no code written yet but this one should
work). I just couldn't shrink it below 12 bytes without going into
ridiculous high and worthless complexities.

After this change AutoNUMA will bail out if any of the two below
conditions is true:

1) MAX_NUMNODES >= 65536
2) any NUMA node pgdat.node_spanned_pages >= 16TB/PAGE_SIZE

That means AutoNUMA will disengage itself automatically on boot on x86
NUMA systems with more than 1152921504606846976 of ram, that's 60bit
of physical address space and no x86 CPU even gets that far in terms
of physical address space.

Other archs requiring more memory than that, will hopefully have a
PAGE_SIZE > 4KB (in turn doubling up the per-node limit of ram at
every doubling of the PAGE_SIZE without having to increase the size of
the page_autonuma even on 64bit from 12bytes).

A packed 12 bytes per page should be all I need (maybe some arch with
alignment troubles may prefer to make it a 16 bytes, but on x86 packed
should work). So on x86 that's 0.29% of RAM used for autonuma and only
spent when booting on NUMA hardware (and trivial to get rid of by
passing "noatuonuma" on the command line).

If I leave the anti false sharing last_nid information in the page
structure plus a pointer to a dynamic structure, that would be still
about 12 bytes. So I rather spend those 12 bytes to avoid having to
point to a dynamic object which in fact would waste even more memory
in addition to the 12 bytes of pointer+last_nid.

The details of the solution:

struct page_autonuma {
    short autonuma_last_nid;
    short autonuma_migrate_nid;
    unsigned int pfn_offset_next;
    unsigned int pfn_offset_prev;
} __attribute__((packed));

page_autonuma can only point to a page that belongs to the same node
(page_autonuma is queued into the
NODE_DATA(autonuma_migrate_nid)->autonuma_migrate_head[src_nid]) where
src_nid is the source node that page_autonuma belongs to, so all pages
in the autonuma_migrate_head[src_nid] lru must come from the same
src_nid. So the next page_autonuma in the list will be
lookup_page_autonuma(pfn_to_page(NODE_DATA(src_nid)->node_start_pfn +
page_autonuma->pfn_offset_next)) etc..

Of course all list_add/del must be hardcoded specially for this, but
it's not a conceptually difficult solution, just we can't use list.h
and stright pointers anymore and some conversion must happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
