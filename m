Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3FA676B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 17:58:22 -0500 (EST)
Date: Wed, 27 Jan 2010 23:58:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 31] Transparent Hugepage support #7
Message-ID: <20100127225800.GB24242@random.random>
References: <patchbomb.1264513915@v2.random>
 <20100126175532.GA3359@redhat.com>
 <20100127000029.GC30452@random.random>
 <20100127003202.GF30452@random.random>
 <20100127004718.GG30452@random.random>
 <20100127202019.GA2294@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100127202019.GA2294@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Apparently that wasn't enough to fix the bug, it removed the crash but
it still trips on vm_normal_page.

What happens is that khugepaged is scanning pagetables and validating
them. So if something's wrong it finds it and bugs out (not sure why
munmap doesn't though, but maybe app only quits at reboot time and
printk is lost in the noise, dunno).

Anyway the broken invariant is pte_special is set and nor PFNMAP nor
MIXEDMAP is set. I tracked the pfn pointing inside the 256M memory of
the graphics card, so it's likely drm_vm calling remap_pfn_range that
leaves corruption in X pagetables (but again not sure why X doesn't
trip on exit). Maybe it calls it with different arguments at different
times.

The only suspicious thing I found so far is the below, so it'd help if
you could review. khugepaged was wrong before not using
vm_normal_page, but I don't think it's my bug anymore, though not
guaranteed, which is why I hope somebody can help me if below fix is
right or not. I don't know if this makes the error go away, I can't
reproduce here on my laptop also with drm. But this is the only place
I found that clears PFNMAP so it has to be this one...

---------------------
Subject: fix remap_pfn_range pte corruption

From: Andrea Arcangeli <aarcange@redhat.com>

This line would leave pte_special ptes instantiated, on a vma without VM_PFNMAP
set. khugepaged would then trip on this calling vm_normal_page on such a
special pte.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memory.c b/mm/memory.c
index 09e4b1b..763c028 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1792,7 +1792,6 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		 * To indicate that track_pfn related cleanup is not
 		 * needed from higher level routine calling unmap_vmas
 		 */
-		vma->vm_flags &= ~(VM_IO | VM_RESERVED | VM_PFNMAP);
 		vma->vm_flags &= ~VM_PFN_AT_MMAP;
 		return -EINVAL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
