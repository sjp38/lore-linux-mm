Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 620576B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 20:44:39 -0400 (EDT)
From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: [x86 PAT PATCH 0/2] x86 PAT vm_flag code refactoring
Date: Mon,  2 Apr 2012 17:46:07 -0700
Message-Id: <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>
In-Reply-To: <20120331170947.7773.46399.stgit@zurg>
References: <20120331170947.7773.46399.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Suresh Siddha <suresh.b.siddha@intel.com>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

Konstantin,

On Sat, 2012-03-31 at 21:09 +0400, Konstantin Khlebnikov wrote:
> v2: Do not use batched pfn reserving for single-page VMA. This is not optimal
> and breaks something, because I see glitches on the screen with i915/drm driver.
> With this version glitches are gone, and I see the same regions in
> /sys/kernel/debug/x86/pat_memtype_list as before patch. So, please review this
> carefully, probably I'm wrong somewhere, or I have triggered some hidden bug.

Actually it is not a hidden bug. In the original code, we were setting
VM_PFN_AT_MMAP only for remap_pfn_range() but not for the vm_insert_pfn().
Also the value of 'vm_pgoff' depends on the driver/mmap_region() in the case of
vm_insert_pfn(). But with your proposed code, you were setting
the VM_PAT for the single-page VMA also and end-up using wrong vm_pgoff in
untrack_pfn_vma().

We can simplify the track/untrack pfn routines and can remove the
dependency on vm_pgoff completely. Am appending a patch which does this
and also modified your x86 PAT patch based on this. Can you please
check and if you are ok, merge these bits with the rest of your patches.

thanks,
suresh
---

Konstantin Khlebnikov (1):
  mm, x86, PAT: rework linear pfn-mmap tracking

Suresh Siddha (1):
  x86, pat: remove the dependency on 'vm_pgoff' in track/untrack pfn
    vma routines

 arch/x86/mm/pat.c             |   38 ++++++++++++++++++++++++--------------
 include/asm-generic/pgtable.h |    4 ++--
 include/linux/mm.h            |   15 +--------------
 mm/huge_memory.c              |    7 +++----
 mm/memory.c                   |   15 ++++++++-------
 5 files changed, 38 insertions(+), 41 deletions(-)

-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
