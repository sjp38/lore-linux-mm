Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DCCD26B0032
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 20:59:32 -0400 (EDT)
Date: Mon, 22 Jul 2013 09:59:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] hugepage: allow parallelization of the hugepage fault
 path
Message-ID: <20130722005940.GA7506@lge.com>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
 <20130715072432.GA28053@voom.fritz.box>
 <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
 <1374090625.15271.2.camel@buesod1.americas.hpqcorp.net>
 <20130718084235.GA9761@lge.com>
 <20130719071432.GB19634@voom.fritz.box>
 <1374269055.9305.19.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374269055.9305.19.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>

On Fri, Jul 19, 2013 at 02:24:15PM -0700, Davidlohr Bueso wrote:
> On Fri, 2013-07-19 at 17:14 +1000, David Gibson wrote:
> > On Thu, Jul 18, 2013 at 05:42:35PM +0900, Joonsoo Kim wrote:
> > > On Wed, Jul 17, 2013 at 12:50:25PM -0700, Davidlohr Bueso wrote:
> > > > From: David Gibson <david@gibson.dropbear.id.au>
> > > > 
> > > > At present, the page fault path for hugepages is serialized by a
> > > > single mutex. This is used to avoid spurious out-of-memory conditions
> > > > when the hugepage pool is fully utilized (two processes or threads can
> > > > race to instantiate the same mapping with the last hugepage from the
> > > > pool, the race loser returning VM_FAULT_OOM).  This problem is
> > > > specific to hugepages, because it is normal to want to use every
> > > > single hugepage in the system - with normal pages we simply assume
> > > > there will always be a few spare pages which can be used temporarily
> > > > until the race is resolved.
> > > > 
> > > > Unfortunately this serialization also means that clearing of hugepages
> > > > cannot be parallelized across multiple CPUs, which can lead to very
> > > > long process startup times when using large numbers of hugepages.
> > > > 
> > > > This patch improves the situation by replacing the single mutex with a
> > > > table of mutexes, selected based on a hash, which allows us to know
> > > > which page in the file we're instantiating. For shared mappings, the
> > > > hash key is selected based on the address space and file offset being faulted.
> > > > Similarly, for private mappings, the mm and virtual address are used.
> > > > 
> > > 
> > > Hello.
> > > 
> > > With this table mutex, we cannot protect region tracking structure.
> > > See below comment.
> > > 
> > > /*
> > >  * Region tracking -- allows tracking of reservations and instantiated pages
> > >  *                    across the pages in a mapping.
> > >  *
> > >  * The region data structures are protected by a combination of the mmap_sem
> > >  * and the hugetlb_instantion_mutex.  To access or modify a region the caller
> > >  * must either hold the mmap_sem for write, or the mmap_sem for read and
> > >  * the hugetlb_instantiation mutex:
> > >  *
> > >  *      down_write(&mm->mmap_sem);
> > >  * or
> > >  *      down_read(&mm->mmap_sem);
> > >  *      mutex_lock(&hugetlb_instantiation_mutex);
> > >  */
> > 
> > Ugh.  Who the hell added that.  I guess you'll need to split of
> > another mutex for that purpose, afaict there should be no interaction
> > with the actual, intended purpose of the instantiation mutex.
> 
> This was added in commit 84afd99b. One way to go would be to add a
> spinlock to protect changes to the regions - however reading the
> changelog, and based on David's previous explanation for the
> instantiation mutex, I don't see why it was added. In fact several
> places modify regions without holding the instantiation mutex, ie:
> hugetlb_reserve_pages()
> 
> Am I missing something here?

hugetlb_reserve_pages() is called with down_write(mmap_sem),
so fault flow which require down_read(mmap_sem) cannot interfere
to change the region.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
