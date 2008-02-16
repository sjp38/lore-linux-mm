Date: Fri, 15 Feb 2008 19:37:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
 ranges
Message-Id: <20080215193730.709c67ea.akpm@linux-foundation.org>
In-Reply-To: <20080215064932.620773824@sgi.com>
References: <20080215064859.384203497@sgi.com>
	<20080215064932.620773824@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008 22:49:01 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> The invalidation of address ranges in a mm_struct needs to be
> performed when pages are removed or permissions etc change.

hm.  Do they?  Why?  If I'm in the process of zero-copy writing a hunk of
memory out to hardware then do I care if someone write-protects the ptes?

Spose so, but some fleshing-out of the various scenarios here would clarify
things.

> If invalidate_range_begin() is called with locks held then we
> pass a flag into invalidate_range() to indicate that no sleeping is
> possible. Locks are only held for truncate and huge pages.

This is so bad.

I supposed in the restricted couple of cases which you're focussed on it
works OK.  But is it generally suitable?  What if IO is in progress?  What
if other cluster nodes need to be talked to?  Does it suit RDMA?

> In two cases we use invalidate_range_begin/end to invalidate
> single pages because the pair allows holding off new references
> (idea by Robin Holt).

Assuming that there is a missing "within the range" in this description, I
assume that all clients will just throw up theior hands in horror and will
disallow all references to all parts of the mm.

Of course, to do that they will need to take a sleeping lock to prevent
other threads from establishing new references.  whoops.

> do_wp_page(): We hold off new references while we update the pte.
> 
> xip_unmap: We are not taking the PageLock so we cannot
> use the invalidate_page mmu_rmap_notifier. invalidate_range_begin/end
> stands in.

What does "stands in" mean?

> Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
> Signed-off-by: Robin Holt <holt@sgi.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/filemap_xip.c |    5 +++++
>  mm/fremap.c      |    3 +++
>  mm/hugetlb.c     |    3 +++
>  mm/memory.c      |   35 +++++++++++++++++++++++++++++------
>  mm/mmap.c        |    2 ++
>  mm/mprotect.c    |    3 +++
>  mm/mremap.c      |    7 ++++++-
>  7 files changed, 51 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6/mm/fremap.c
> ===================================================================
> --- linux-2.6.orig/mm/fremap.c	2008-02-14 18:43:31.000000000 -0800
> +++ linux-2.6/mm/fremap.c	2008-02-14 18:45:07.000000000 -0800
> @@ -15,6 +15,7 @@
>  #include <linux/rmap.h>
>  #include <linux/module.h>
>  #include <linux/syscalls.h>
> +#include <linux/mmu_notifier.h>
>  
>  #include <asm/mmu_context.h>
>  #include <asm/cacheflush.h>
> @@ -214,7 +215,9 @@ asmlinkage long sys_remap_file_pages(uns
>  		spin_unlock(&mapping->i_mmap_lock);
>  	}
>  
> +	mmu_notifier(invalidate_range_begin, mm, start, start + size, 0);
>  	err = populate_range(mm, vma, start, size, pgoff);
> +	mmu_notifier(invalidate_range_end, mm, start, start + size, 0);

To avoid off-by-one confusion the changelogs, documentation and comments
should be very careful to tell the reader whether the range includes the
byte at start+size.  I don't thik that was done?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
