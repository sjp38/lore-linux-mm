Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B06C96B0062
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:06:09 -0400 (EDT)
Date: Thu, 11 Oct 2012 19:05:33 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 06/33] autonuma: teach gup_fast about pmd_numa
Message-ID: <20121011170533.GP1818@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-7-git-send-email-aarcange@redhat.com>
 <20121011122255.GS3317@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011122255.GS3317@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Oct 11, 2012 at 01:22:55PM +0100, Mel Gorman wrote:
> On Thu, Oct 04, 2012 at 01:50:48AM +0200, Andrea Arcangeli wrote:
> > In the special "pmd" mode of knuma_scand
> > (/sys/kernel/mm/autonuma/knuma_scand/pmd == 1), the pmd may be of numa
> > type (_PAGE_PRESENT not set), however the pte might be
> > present. Therefore, gup_pmd_range() must return 0 in this case to
> > avoid losing a NUMA hinting page fault during gup_fast.
> > 
> 
> So if gup_fast fails, presumably we fall back to taking the mmap_sem and
> calling get_user_pages(). This is a heavier operation and I wonder if the
> cost is justified. i.e. Is the performance loss from using get_user_pages()
> offset by improved NUMA placement? I ask because we always incur the cost of
> taking mmap_sem but only sometimes get it back from improved NUMA placement.
> How bad would it be if gup_fast lost some of the NUMA hinting information?

Good question indeed. Now, I agree it wouldn't be bad to skip NUMA
hinting page faults in gup_fast for no-virt usage like
O_DIRECT/ptrace, but the only problem is that we'd lose AutoNUMA on
the memory touched by the KVM vcpus.

I've been also asked if the vhost-net kernel thread (KVM in kernel
virtio backend) will be controlled by autonuma in between
use_mm/unuse_mm and answer is yes, but to do that, it also needs
this. (see also the flush to task_autonuma_nid and mm/task statistics in
unuse_mm to reset it back to regular kernel thread status,
uncontrolled by autonuma)

$ git grep get_user_pages
tcm_vhost.c:            ret = get_user_pages_fast((unsigned long)ptr, 1, write, &page);
vhost.c:        r = get_user_pages_fast(log, 1, 1, &page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
