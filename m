Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 9B9796B0134
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:38:38 -0400 (EDT)
Date: Thu, 4 Oct 2012 20:38:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 29/33] autonuma: page_autonuma
Message-ID: <20121004183819.GM25675@redhat.com>
References: <20121004165008.GF25675@redhat.com>
 <0000013a2cff3c3d-76e00716-2869-4dc8-8717-82f0136018d0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013a2cff3c3d-76e00716-2869-4dc8-8717-82f0136018d0-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi Christoph,

On Thu, Oct 04, 2012 at 06:17:37PM +0000, Christoph Lameter wrote:
> On Thu, 4 Oct 2012, Andrea Arcangeli wrote:
> 
> > So we could drop page_autonuma by creating a CONFIG_SLUB=y dependency
> > (AUTONUMA wouldn't be available in the kernel config if SLAB=y, and it
> > also wouldn't be available on 32bit archs but the latter isn't a
> > problem).
> 
> Nope it should depend on page struct alignment. Other kernel subsystems
> may be depeding on page struct alignment in the future (and some other
> arches may already have that requirement)

But currently only SLUB x86 64bit selects
CONFIG_HAVE_ALIGNED_STRUCT_PAGE:

arch/Kconfig:config HAVE_ALIGNED_STRUCT_PAGE
arch/x86/Kconfig:       select HAVE_ALIGNED_STRUCT_PAGE if SLUB && !M386
include/linux/mm_types.h:       defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
include/linux/mm_types.h:#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
mm/slub.c:    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
mm/slub.c:    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
mm/slub.c:    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)

So in practice a dependency on CONFIG_HAVE_ALIGNED_STRUCT_PAGE would
still mean the same: only available when SLUB enables it, and only on
x86 64bit (ppc64?).

If you mean CONFIG_AUTONUMA=y should select (not depend) on
CONFIG_HAVE_ALIGNED_STRUCT_PAGE, that would allow to enable it in all
.configs but it would have a worse cons: losing 8bytes per page
unconditionally (even when booting on non-NUMA hardware).

The current page_autonuma solution is substantially memory-cheaper
than selecting CONFIG_HAVE_ALIGNED_STRUCT_PAGE: it allocates 2bytes
per page at boot time but only if booting on real NUMA hardware
(without altering the page structure). So to me it looks still quite a
decent tradeoff.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
