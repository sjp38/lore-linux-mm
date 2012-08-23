Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 876B06B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:24:24 -0400 (EDT)
Date: Thu, 23 Aug 2012 17:23:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 33/36] autonuma: powerpc port
Message-ID: <20120823152331.GF3570@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
 <1345647560-30387-34-git-send-email-aarcange@redhat.com>
 <1345672907.2617.44.camel@pasglop>
 <20120822223542.GG8107@redhat.com>
 <1345698660.13399.23.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345698660.13399.23.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Tony Breeds <tbreeds@au1.ibm.com>, Kumar Gala <galak@kernel.crashing.org>

Hi Benjamin,

On Thu, Aug 23, 2012 at 03:11:00PM +1000, Benjamin Herrenschmidt wrote:
> Basically PROT_NONE turns into _PAGE_PRESENT without _PAGE_USER for us.

Maybe the simplest is to implement pte_numa as !_PAGE_USER too. No
need to clear the _PAGE_PRESENT bit and to alter pte_present() if
clearing _PAGE_USER already achieves it.

It should be trivial to add the vma parameter to pte_numa(pte, vma) so
you can implement pte_numa by checking the vma->vm_page_prot in the
inline pte_numa function, to be able to tell if it's a real prot none
(in which case pte_numa return false) or if it's the NUMA hinting page
fault. In the latter case pte_numa will return true.

> However, the embedded ppc situation is more interesting... and it looks
> like it is indeed broken, meaning that a user can coerce the kernel into
> accessing PROT_NONE on its behalf with copy_from_user & co (though read
> only really).
> 
> Looks like the SW TLB handlers used on embedded should also check
> whether the address is a user or kernel address, and enforce _PAGE_USER
> in the former case. They might have done in the past, it's possible that
> it's code we lost, but as it is, it's broken.
> 
> The case of HW loaded TLB embedded will need a different definition of
> PAGE_NONE as well I suspect. Kumar, can you have a look ?

Even if we can't track copy-user accesses with the NUMA
hinting page faults, AUTONUMA should still work fairly well. The
flakey PROTNONE on embedded, is more a problem in itself than it would
be for pte_numa on embedded.

OTOH AutoNUMA working on embedded isn't important so it may be just
better to disable it until !_PAGE_USER is reliable.

> I wasn't especially thinking of ppc32... there's also hash64-4k or
> embedded 64... Also pgtable.h is common, so all those added uses of
> _PAGE_NUMA_PTE to static inline functions are going to break the build
> unless _PAGE_NUMA_PTE is #defined to 0 when not used (we do that for a
> bunch of bits in pte-common.h already).

It'd be actually worse if it would build ;). But I guess using
_PAGE_USER to implement pte_numa will solve the problem for 4k page
size too.

We can discuss this during kernel summit ;).

Thanks a lot!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
