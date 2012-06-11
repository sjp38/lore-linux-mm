Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 07DA36B0149
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 11:02:20 -0400 (EDT)
Date: Mon, 11 Jun 2012 10:02:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/6] mempolicy: remove all mempolicy sharing
In-Reply-To: <1339406250-10169-3-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.00.1206110944120.31180@router.home>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com> <1339406250-10169-3-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Some more attempts to cleanup changelogs:

> The problem was created by a reference count imbalance. Example, In following case,
> mbind(addr, len) try to replace mempolicies of vma1 and vma2 and then they will
> be share the same mempolicy, and the new mempolicy has MPOL_F_SHARED flag.

The bug that we saw <where ? details?> was created by a refcount
imbalance. If mbind() replaces the memory policies of vma1 and vma and
they share the same shared mempolicy (MPOL_F_SHARED set) then an imbalance
may occur.

>   +-------------------+-------------------+
>   |     vma1          |     vma2(shmem)   |
>   +-------------------+-------------------+
>   |                                       |
>  addr                                 addr+len
>
> Look at alloc_pages_vma(), it uses get_vma_policy() and mpol_cond_put() pair
> for maintaining mempolicy refcount. The current rule is, get_vma_policy() does
> NOT increase a refcount if the policy is not attached shmem vma and mpol_cond_put()
> DOES decrease a refcount if mpol has MPOL_F_SHARED.

alloc_pages_vma() uses the two function get_vma_policy() and
mpol_cond_put() to maintain the refcount on the memory policies. However,
the current rule is that get_vma_policy() does *not* increase the refcount
if the policy is not attached to a shm vma. mpol_cond_put *does* decrease
the refcount if the memory policy has MPOL_F_SHARED set.

> In above case, vma1 is not shmem vma and vma->policy has MPOL_F_SHARED! then,
> get_vma_policy() doesn't increase a refcount and mpol_cond_put() decrease a
> refcount whenever alloc_page_vma() is called.
>
> The bug was introduced by commit 52cd3b0740 (mempolicy: rework mempolicy Reference
> Counting) at 4 years ago.
>
> More unfortunately mempolicy has one another serious broken. Currently,
> mempolicy rebind logic (it is called from cpuset rebinding) ignore a refcount
> of mempolicy and override it forcibly. Thus, any mempolicy sharing may
> cause mempolicy corruption. The bug was introduced by commit 68860ec10b
> (cpusets: automatic numa mempolicy rebinding) at 7 years ago.

Memory policies have another issue. Currently the mempolicy rebind logic
used for cpuset rebinding ignores the refcount of memory policies.
Therefore, any memory policy sharing can cause refcount mismatches. The
bug was ...

> To disable policy sharing solves user visible breakage and this patch does it.
> Maybe, we need to rewrite MPOL_F_SHARED and mempolicy rebinding code and aim
> to proper cow logic eventually, but I think this is good first step.

Disabling policy sharing solves the breakage and that is how this patch
fixes the issue for now. Rewriting the shared policy handling with proper
COW logic support will be necessary to cleanly address the
problem and allow proper sharing of memory policies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
