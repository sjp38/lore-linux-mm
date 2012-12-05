Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E46DB6B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 00:11:03 -0500 (EST)
Received: by mail-ye0-f169.google.com with SMTP id l13so822349yen.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 21:11:02 -0800 (PST)
Date: Tue, 4 Dec 2012 21:11:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/5] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
In-Reply-To: <20121204141501.GA2797@suse.de>
Message-ID: <alpine.LNX.2.00.1212042042130.13895@eggly.anvils>
References: <1349801921-16598-1-git-send-email-mgorman@suse.de> <1349801921-16598-6-git-send-email-mgorman@suse.de> <CA+ydwtqQ7iK_1E+7ctLxYe8JZY+SzMfuRagjyHJ12OYsxbMcaA@mail.gmail.com> <20121204141501.GA2797@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Tommi Rantala <tt.rantala@gmail.com>, Stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, 4 Dec 2012, Mel Gorman wrote:
> On Tue, Dec 04, 2012 at 02:54:08PM +0200, Tommi Rantala wrote:
> > 2012/10/9 Mel Gorman <mgorman@suse.de>:
> > > commit 00442ad04a5eac08a98255697c510e708f6082e2 upstream.
> > >
> > > Commit cc9a6c877661 ("cpuset: mm: reduce large amounts of memory barrier
> > > related damage v3") introduced a potential memory corruption.
> > > shmem_alloc_page() uses a pseudo vma and it has one significant unique
> > > combination, vma->vm_ops=NULL and vma->policy->flags & MPOL_F_SHARED.
> > >
> > > get_vma_policy() does NOT increase a policy ref when vma->vm_ops=NULL
> > > and mpol_cond_put() DOES decrease a policy ref when a policy has
> > > MPOL_F_SHARED.  Therefore, when a cpuset update race occurs,
> > > alloc_pages_vma() falls in 'goto retry_cpuset' path, decrements the
> > > reference count and frees the policy prematurely.
> > 
> > Hello,
> > 
> > kmemleak is complaining about memory leaks that point to the mbind()
> > syscall. I've seen this only in v3.7-rcX, so I bisected this, and
> > found that this patch is the first mainline commit where I'm able to
> > reproduce it with Trinity.
> > 
> 
> Uncool.
> 
> I'm writing this from an airport so am not in the position to test properly
> but at a glance I'm not seeing what drops the reference count taken by
> mpol_shared_policy_lookup() in all cases.  vm_ops->get_policy() probably
> gets it right but what about shmem_alloc_page() and shmem_swapin()?
> 
> This patch is only compile tested. If the reference counts are dropped
> somewhere I did not spot quickly then it'll cause a use-after-free bug
> instead but is worth trying anyway.
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 89341b6..6229a43 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -912,6 +912,7 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
>  {
>  	struct mempolicy mpol, *spol;
>  	struct vm_area_struct pvma;
> +	struct page *page;
>  
>  	spol = mpol_cond_copy(&mpol,
>  			mpol_shared_policy_lookup(&info->policy, index));
> @@ -922,13 +923,19 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
>  	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
>  	pvma.vm_ops = NULL;
>  	pvma.vm_policy = spol;
> -	return swapin_readahead(swap, gfp, &pvma, 0);
> +	page = swapin_readahead(swap, gfp, &pvma, 0);
> +
> +	/* Drop reference taken by mpol_shared_policy_lookup() */
> +	mpol_cond_put(pvma.vm_policy);
> +
> +	return page;
>  }
>  
>  static struct page *shmem_alloc_page(gfp_t gfp,
>  			struct shmem_inode_info *info, pgoff_t index)
>  {
>  	struct vm_area_struct pvma;
> +	struct page *page;
>  
>  	/* Create a pseudo vma that just contains the policy */
>  	pvma.vm_start = 0;
> @@ -940,7 +947,12 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>  	/*
>  	 * alloc_page_vma() will drop the shared policy reference
>  	 */
> -	return alloc_page_vma(gfp, &pvma, 0);
> +	page = alloc_page_vma(gfp, &pvma, 0);
> +
> +	/* Drop reference taken by mpol_shared_policy_lookup() */
> +	mpol_cond_put(pvma.vm_policy);
> +
> +	return page;
>  }
>  #else /* !CONFIG_NUMA */
>  #ifdef CONFIG_TMPFS

Thank you, Tommi and Mel.  Easy enough for me to reproduce without
kmemleak and trinity, by mounting a tmpfs with mpol= and keeping an
eye on numa_policy in /proc/slabinfo while building a tree there.

Yes, your patch fixes it Mel, but I prefer it as below, with a couple
of mods: removing the no longer true comment, and leaving shmem_swapin()
alone with just a comment.  It appears to be the job of the rather weird
mpol_cond_copy() to drop the reference on the original mempolicy, and
clear MPOL_F_SHARED so the copy won't need one (it's trying to cope with
the fact that swapin_readahead will make an unknown number of calls to
alloc_page_vma).  So I'd rather not add another mpol_cond_put there,
whose cond will never be met.

I don't much like the result, but that's because it's adding further
cruft on top of the onstack pseudo-vma stuff: more impetus for me to
revisit the alloc_page_mpol() patch I worked on years ago, but gave
up when I couldn't understand the mpol refcounting: hopefully I'll
find that Kosaki's changes have made it all clearer now.

Please consent to the addition of your signoff: thanks!


[PATCH] tmpfs: fix shared mempolicy leak

From: Mel Gorman <mgorman@suse.de>

Commit 00442ad04a5e ("mempolicy: fix a memory corruption by refcount
imbalance in alloc_pages_vma()") changed get_vma_policy() to raise the
refcount on a shmem shared mempolicy; whereas shmem_alloc_page() went
on expecting alloc_page_vma() to drop the refcount it had acquired.
This deserves a rework: but for now fix the leak in shmem_alloc_page().

Reported-by: Tommi Rantala <tt.rantala@gmail.com>
Awaiting-Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---

 mm/shmem.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

--- 3.7-rc8/mm/shmem.c	2012-11-16 19:26:56.388459961 -0800
+++ linux/mm/shmem.c	2012-12-04 20:00:44.556241603 -0800
@@ -922,13 +922,17 @@ static struct page *shmem_swapin(swp_ent
 	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
+
 	return swapin_readahead(swap, gfp, &pvma, 0);
+
+	/* mpol_cond_copy already dropped ref from mpol_shared_policy_lookup */
 }
 
 static struct page *shmem_alloc_page(gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
 	struct vm_area_struct pvma;
+	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
@@ -937,10 +941,12 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
-	/*
-	 * alloc_page_vma() will drop the shared policy reference
-	 */
-	return alloc_page_vma(gfp, &pvma, 0);
+	page = alloc_page_vma(gfp, &pvma, 0);
+
+	/* Drop reference taken by mpol_shared_policy_lookup() */
+	mpol_cond_put(pvma.vm_policy);
+
+	return page;
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
