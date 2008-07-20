Date: Sun, 20 Jul 2008 17:24:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC] x86 fix for stable
Message-ID: <20080720152403.GA8449@elte.hu>
References: <6101e8c40807200815x68da6731t210b8fbbbe510673@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6101e8c40807200815x68da6731t210b8fbbbe510673@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Pinter <oliver.pntr@gmail.com>
Cc: stable@kernel.org, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Oliver Pinter <oliver.pntr@gmail.com> wrote:

> git id: e22146e610bb7aed63282148740ab1d1b91e1d90
> 
> commit e22146e610bb7aed63282148740ab1d1b91e1d90
> Author: Jack Steiner <steiner@sgi.com>
> Date:   Wed Jul 16 11:11:59 2008 -0500
> 
>     x86: fix kernel_physical_mapping_init() for large x86 systems
> 
>     Fix bug in kernel_physical_mapping_init() that causes kernel
>     page table to be built incorrectly for systems with greater
>     than 512GB of memory.
> 
>     Signed-off-by: Jack Steiner <steiner@sgi.com>
>     Cc: linux-mm@kvack.org
>     Signed-off-by: Ingo Molnar <mingo@elte.hu>

correct. It wont apply thought - below is a quick backport to v2.6.26.

	Ingo

--------------------->
Author: Ingo Molnar <mingo@elte.hu>
Date:   Sun Jul 20 17:22:50 2008 +0200

    x86: fix kernel_physical_mapping_init() for large x86 systems
    
    Fix bug in kernel_physical_mapping_init() that causes kernel
    page table to be built incorrectly for systems with greater
    than 512GB of memory.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Cc: linux-mm@kvack.org
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    
    Conflicts:
    
    	arch/x86/mm/init_64.c
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/mm/init_64.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 819dad9..7b27710 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -579,7 +579,7 @@ unsigned long __init_refok init_memory_mapping(unsigned long start, unsigned lon
 		else
 			pud = alloc_low_page(&pud_phys);
 
-		next = start + PGDIR_SIZE;
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
 		if (next > end)
 			next = end;
 		last_map_addr = phys_pud_init(pud, __pa(start), __pa(next));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
