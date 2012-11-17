Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 14C9C6B004D
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 03:35:39 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so4334014oag.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 00:35:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1353083121-4560-1-git-send-email-mingo@kernel.org>
References: <1353083121-4560-1-git-send-email-mingo@kernel.org>
Date: Sat, 17 Nov 2012 16:35:38 +0800
Message-ID: <CAGjg+kFUp_bACC-nze9og7+2XCXoURRunoTi4OY9-NgepU39mA@mail.gmail.com>
Subject: Re: [PATCH 00/19] latest numa/base patches
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>, Alex Shi <alex.shi@intel.com>

Just find imbalance issue on the patchset.

I write a one line program:
int main ()
{
	int i;
	for (i=0; i< 1; )
		__asm__ __volatile__ ("nop");
}
it was compiled with name pl and start it on my 2 socket * 4 cores *
HT NUMA machine:
the cpu domain top like this:
domain 0: span 4,12 level SIBLING
  groups: 4 (cpu_power = 589) 12 (cpu_power = 589)
  domain 1: span 0,2,4,6,8,10,12,14 level MC
   groups: 4,12 (cpu_power = 1178) 6,14 (cpu_power = 1178) 0,8
(cpu_power = 1178) 2,10 (cpu_power = 1178)
   domain 2: span 0,2,4,6,8,10,12,14 level CPU
    groups: 0,2,4,6,8,10,12,14 (cpu_power = 4712)
    domain 3: span 0-15 level NUMA
     groups: 0,2,4,6,8,10,12,14 (cpu_power = 4712) 1,3,5,7,9,11,13,15
(cpu_power = 4712)

$for ((i=0; i< I; i++)); do ./pl & done
when I = 2, they are running on cpu 0,12
I = 4, they are running on cpu 0,9,12,14
I = 8, they are running on cpu 0,4,9,10,11,12,13,14

Regards!
Alex
On Sat, Nov 17, 2012 at 12:25 AM, Ingo Molnar <mingo@kernel.org> wrote:
> This is the split-out series of mm/ patches that got no objections
> from the latest (v15) posting of numa/core. If everyone is still
> fine with these then these will be merge candidates for v3.8.
>
> I left out the more contentious policy bits that people are still
> arguing about.
>
> The numa/base tree can also be found here:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/base
>
> Thanks,
>
>     Ingo
>
> ------------------->
>
> Andrea Arcangeli (1):
>   numa, mm: Support NUMA hinting page faults from gup/gup_fast
>
> Gerald Schaefer (1):
>   sched, numa, mm, s390/thp: Implement pmd_pgprot() for s390
>
> Ingo Molnar (1):
>   mm/pgprot: Move the pgprot_modify() fallback definition to mm.h
>
> Lee Schermerhorn (3):
>   mm/mpol: Add MPOL_MF_NOOP
>   mm/mpol: Check for misplaced page
>   mm/mpol: Add MPOL_MF_LAZY
>
> Peter Zijlstra (7):
>   sched, numa, mm: Make find_busiest_queue() a method
>   sched, numa, mm: Describe the NUMA scheduling problem formally
>   mm/thp: Preserve pgprot across huge page split
>   mm/mpol: Make MPOL_LOCAL a real policy
>   mm/mpol: Create special PROT_NONE infrastructure
>   mm/migrate: Introduce migrate_misplaced_page()
>   mm/mpol: Use special PROT_NONE to migrate pages
>
> Ralf Baechle (1):
>   sched, numa, mm, MIPS/thp: Add pmd_pgprot() implementation
>
> Rik van Riel (5):
>   mm/generic: Only flush the local TLB in ptep_set_access_flags()
>   x86/mm: Only do a local tlb flush in ptep_set_access_flags()
>   x86/mm: Introduce pte_accessible()
>   mm: Only flush the TLB when clearing an accessible pte
>   x86/mm: Completely drop the TLB flush from ptep_set_access_flags()
>
>  Documentation/scheduler/numa-problem.txt | 230 +++++++++++++++++++++++++++++++
>  arch/mips/include/asm/pgtable.h          |   2 +
>  arch/s390/include/asm/pgtable.h          |  13 ++
>  arch/x86/include/asm/pgtable.h           |   7 +
>  arch/x86/mm/pgtable.c                    |   8 +-
>  include/asm-generic/pgtable.h            |   4 +
>  include/linux/huge_mm.h                  |  19 +++
>  include/linux/mempolicy.h                |   8 ++
>  include/linux/migrate.h                  |   7 +
>  include/linux/migrate_mode.h             |   3 +
>  include/linux/mm.h                       |  32 +++++
>  include/uapi/linux/mempolicy.h           |  16 ++-
>  kernel/sched/fair.c                      |  20 +--
>  mm/huge_memory.c                         | 174 +++++++++++++++--------
>  mm/memory.c                              | 119 +++++++++++++++-
>  mm/mempolicy.c                           | 143 +++++++++++++++----
>  mm/migrate.c                             |  85 ++++++++++--
>  mm/mprotect.c                            |  31 +++--
>  mm/pgtable-generic.c                     |   9 +-
>  19 files changed, 807 insertions(+), 123 deletions(-)
>  create mode 100644 Documentation/scheduler/numa-problem.txt
>
> --
> 1.7.11.7
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
