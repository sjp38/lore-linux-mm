Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E0CFB6B00E9
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 19:59:52 -0400 (EDT)
From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: [v3 VM_PAT PATCH 0/3] x86 VM_PAT series
Date: Thu,  5 Apr 2012 17:01:32 -0700
Message-Id: <1333670495-7016-1-git-send-email-suresh.b.siddha@intel.com>
In-Reply-To: <4F7D8860.3040008@openvz.org>
References: <4F7D8860.3040008@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Suresh Siddha <suresh.b.siddha@intel.com>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

On Thu, 2012-04-05 at 15:56 +0400, Konstantin Khlebnikov wrote:
> With this patches I see new ranges in /sys/kernel/debug/x86/pat_memtype_list
> This is 4k single-page vma mappged by X11. kernel fills them via vm_insert_pfn().
> Is this ok?

This is expected and I saw these new entries too (but not as many as you saw), as the
patch is tracking single page vma's coming from vm_insert_pfn() interface too.

Thinking a bit more about this in the context of your numbers, those new entries that
are getting tracked are not adding any new value. As the driver has already reserved the
whole aperture with write-combining attribute, tracking these single page vma's doesn't
help anymore.

> Maybe we shouldn't use PAT for small VMA?

For vm_insert_pfn(), expectation is that we just look up the memory attribute.
And for remap_pfn_range(), if the whole VMA is remapped, we reserve the new
attribute for the specified pfn-range, as typically drivers
call remap_pfn_range() for the whole VMA (can be a single page) with the desired
attribute (with out the prior reservation of the memory attribute for the pfn range).
So exposing two different API's for this behavior is probably the better way
to address this in a clean way. Revised patches follows.

Konstantin Khlebnikov (1):
  mm, x86, PAT: rework linear pfn-mmap tracking

Suresh Siddha (2):
  x86, pat: remove the dependency on 'vm_pgoff' in track/untrack pfn
    vma routines
  x86, pat: separate the pfn attribute tracking for remap_pfn_range and
    vm_insert_pfn

 arch/x86/mm/pat.c             |   80 ++++++++++++++++++++++++++++------------
 include/asm-generic/pgtable.h |   57 +++++++++++++++++------------
 include/linux/mm.h            |   15 +-------
 mm/huge_memory.c              |    7 ++--
 mm/memory.c                   |   23 +++++-------
 5 files changed, 104 insertions(+), 78 deletions(-)

-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
