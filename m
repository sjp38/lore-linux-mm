Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D9316B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:19:50 -0400 (EDT)
Date: Thu, 28 Apr 2011 12:19:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: readahead and oom
Message-ID: <20110428041947.GA8761@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
 <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
In-Reply-To: <20110426124743.e58d9746.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 27, 2011 at 03:47:43AM +0800, Andrew Morton wrote:
> On Tue, 26 Apr 2011 17:20:29 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Pass __GFP_NORETRY|__GFP_NOWARN for readahead page allocations.
> > 
> > readahead page allocations are completely optional. They are OK to
> > fail and in particular shall not trigger OOM on themselves.
> 
> I have distinct recollections of trying this many years ago, finding
> that it caused problems then deciding not to do it.  But I can't find
> an email trail and I don't remember the reasons :(

The most possible reason can be page allocation failures even if there
are plenty of _global_ reclaimable pages.

> If the system is so stressed for memory that the oom-killer might get
> involved then the readahead pages may well be getting reclaimed before
> the application actually gets to use them.  But that's just an aside.

Yes, when direct reclaim is working as expected, readahead thrashing
should happen long before NORETRY page allocation failures and OOM.

With that assumption I think it's OK to do this patch.  As for
readahead, sporadic allocation failures are acceptable. But there is a
problem, see below.

> Ho hum.  The patch *seems* good (as it did 5-10 years ago ;)) but there
> may be surprising side-effects which could be exposed under heavy
> testing.  Testing which I'm sure hasn't been performed...

The NORETRY direct reclaim does tend to fail a lot more on concurrent
reclaims, where one task's reclaimed pages can be stoled by others
before it's able to get it.

        __alloc_pages_direct_reclaim()
        {
                did_some_progress = try_to_free_pages();

                // pages stolen by others

                page = get_page_from_freelist();
        }

Here are the tests to demonstrate this problem.

Out of 1000GB reads and page allocations,

        test-ra-thrash.sh: read 1000 1G files interleaved in 1 single task:

        nr_alloc_fail 733

        test-dd-sparse.sh: read 1000 1G files concurrently in 1000 tasks:

        nr_alloc_fail 11799


Thanks,
Fengguang
---

--- linux-next.orig/include/linux/mmzone.h	2011-04-27 21:58:27.000000000 +0800
+++ linux-next/include/linux/mmzone.h	2011-04-27 21:58:39.000000000 +0800
@@ -106,6 +106,7 @@ enum zone_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_ALLOC_FAIL,
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
--- linux-next.orig/mm/page_alloc.c	2011-04-27 21:58:27.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-04-27 21:58:39.000000000 +0800
@@ -2176,6 +2176,8 @@ rebalance:
 	}
 
 nopage:
+	inc_zone_state(preferred_zone, NR_ALLOC_FAIL);
+	/* count_zone_vm_events(PGALLOCFAIL, preferred_zone, 1 << order); */
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
 		unsigned int filter = SHOW_MEM_FILTER_NODES;
 
--- linux-next.orig/mm/vmstat.c	2011-04-27 21:58:27.000000000 +0800
+++ linux-next/mm/vmstat.c	2011-04-27 21:58:53.000000000 +0800
@@ -879,6 +879,7 @@ static const char * const vmstat_text[] 
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
+	"nr_alloc_fail",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",

--9amGYk9869ThD9tj
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-dd-sparse.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Amount /dev/sda7 /fs=0A=0Afor i in `seq 1000`=0Ado=0A	truncat=
e -s 1G /fs/sparse-$i=0A	dd if=3D/fs/sparse-$i of=3D/dev/null &=0Adone=0A
--9amGYk9869ThD9tj
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-ra-thrash.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Amount /dev/sda7 /fs=0A=0Afor i in `seq 1000`=0Ado=0A	truncat=
e -s 1G /fs/sparse-$i=0Adone=0A=0Ara-thrash /fs/sparse-*=0A
--9amGYk9869ThD9tj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
