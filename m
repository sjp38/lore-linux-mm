Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D7C226B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 02:50:46 -0400 (EDT)
Date: Thu, 18 Jul 2013 15:50:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/hugetlb: per-vma instantiation mutexes
Message-ID: <20130718065045.GB9425@lge.com>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
 <20130715072432.GA28053@voom.fritz.box>
 <51E4A719.4020703@redhat.com>
 <20130716053424.GB30116@lge.com>
 <20130716100146.GC8925@voom.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130716100146.GC8925@voom.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Rik van Riel <riel@redhat.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 16, 2013 at 08:01:46PM +1000, David Gibson wrote:
> On Tue, Jul 16, 2013 at 02:34:24PM +0900, Joonsoo Kim wrote:
> > On Mon, Jul 15, 2013 at 09:51:21PM -0400, Rik van Riel wrote:
> > > On 07/15/2013 03:24 AM, David Gibson wrote:
> > > >On Sun, Jul 14, 2013 at 08:16:44PM -0700, Davidlohr Bueso wrote:
> > > 
> > > >>>Reading the existing comment, this change looks very suspicious to me.
> > > >>>A per-vma mutex is just not going to provide the necessary exclusion, is
> > > >>>it?  (But I recall next to nothing about these regions and
> > > >>>reservations.)
> > > >
> > > >A per-VMA lock is definitely wrong.  I think it handles one form of
> > > >the race, between threads sharing a VM on a MAP_PRIVATE mapping.
> > > >However another form of the race can and does occur between different
> > > >MAP_SHARED VMAs in the same or different processes.  I think there may
> > > >be edge cases involving mremap() and MAP_PRIVATE that will also be
> > > >missed by a per-VMA lock.
> > > >
> > > >Note that the libhugetlbfs testsuite contains tests for both PRIVATE
> > > >and SHARED variants of the race.
> > > 
> > > Can we get away with simply using a mutex in the file?
> > > Say vma->vm_file->mapping->i_mmap_mutex?
> > 
> > I totally agree with this approach :)
> > 
> > > 
> > > That might help with multiple processes initializing
> > > multiple shared memory segments at the same time, and
> > > should not hurt the case of a process mapping its own
> > > hugetlbfs area.
> > > 
> > > It might have the potential to hurt when getting private
> > > copies on a MAP_PRIVATE area, though.  I have no idea
> > > how common it is for multiple processes to MAP_PRIVATE
> > > the same hugetlbfs file, though...
> > 
> > Currently, getting private copies on a MAP_PRIVATE area is also
> > serialized by hugetlb_instantiation_mutex.
> > How do we get worse with your approach?
> > 
> > BTW, we have one race problem related to hugetlb_instantiation_mutex.
> > It is not right protection for region structure handling. We map the
> > area without holding a hugetlb_instantiation_mutex, so there is
> > race condition between mapping a new area and faulting the other area.
> > Am I missing?
> 
> The hugetlb_instantiation_mutex has nothing to do with protecting
> region structures.  It exists only to address one very specific and
> frequently misunderstood race.

Yes, it was introduced for that purpose, but, currently, it is also
used for protecting region structure. You can see below comment in
mm/hugetlb.c

 * The region data structures are protected by a combination of the mmap_sem
 * and the hugetlb_instantion_mutex.  To access or modify a region the caller
 * must either hold the mmap_sem for write, or the mmap_sem for read and
 * the hugetlb_instantiation mutex:
 *
 *      down_write(&mm->mmap_sem);
 * or
 *      down_read(&mm->mmap_sem);
 *      mutex_lock(&hugetlb_instantiation_mutex);
 */

Thanks.

> 
> -- 
> David Gibson			| I'll have my music baroque, and my code
> david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
> 				| _way_ _around_!
> http://www.ozlabs.org/~dgibson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
