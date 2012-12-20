Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 45E346B0069
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 13:34:50 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hm9so2205751wib.14
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 10:34:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 20 Dec 2012 10:34:25 -0800
Message-ID: <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>

Going through some old emails before -rc1 rlease..

What is the status of this patch? The patch that is reported to cause
the problem hasn't been merged, but that mpol_misplaced() thing did
happen in commit 771fb4d806a9. And it looks like it's called from
numa_migrate_prep() under the pte map lock. Or am I missing something?
See commit 9532fec118d ("mm: numa: Migrate pages handled during a
pmd_numa hinting fault").

Am I missing something? Mel, please take another look.

I despise these kinds of dual-locking models, and am wondering if we
can't have *just* the spinlock?

            Linus

On Mon, Dec 3, 2012 at 4:56 PM, David Rientjes <rientjes@google.com> wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> Sasha was fuzzing with trinity and reported the following problem:
>
> BUG: sleeping function called from invalid context at kernel/mutex.c:269
> in_atomic(): 1, irqs_disabled(): 0, pid: 6361, name: trinity-main
> 2 locks held by trinity-main/6361:
>  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810aa314>] __do_page_fault+0x1e4/0x4f0
>  #1:  (&(&mm->page_table_lock)->rlock){+.+...}, at: [<ffffffff8122f017>] handle_pte_fault+0x3f7/0x6a0
> Pid: 6361, comm: trinity-main Tainted: G        W 3.7.0-rc2-next-20121024-sasha-00001-gd95ef01-dirty #74
> Call Trace:
>  [<ffffffff8114e393>] __might_sleep+0x1c3/0x1e0
>  [<ffffffff83ae5209>] mutex_lock_nested+0x29/0x50
>  [<ffffffff8124fc3e>] mpol_shared_policy_lookup+0x2e/0x90
>  [<ffffffff81219ebe>] shmem_get_policy+0x2e/0x30
>  [<ffffffff8124e99a>] get_vma_policy+0x5a/0xa0
>  [<ffffffff8124fce1>] mpol_misplaced+0x41/0x1d0
>  [<ffffffff8122f085>] handle_pte_fault+0x465/0x6a0
>
> do_numa_page() calls the new mpol_misplaced() function introduced by
> "sched, numa, mm: Add the scanning page fault machinery" in the page fault
> patch while holding mm->page_table_lock and then
> mpol_shared_policy_lookup() ends up trying to take the shared policy
> mutex.
>
> The fix is to protect the shared policy tree with both a spinlock and
> mutex; both must be held to modify the tree, but only one is required to
> read the tree.  This allows sp_lookup() to grab the spinlock for read.
>
> [rientjes@google.com: wrote changelog]
> Reported-by: Sasha Levin <levinsasha928@gmail.com>
> Tested-by: Sasha Levin <levinsasha928@gmail.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/mempolicy.h |    1 +
>  mm/mempolicy.c            |   23 ++++++++++++++++++-----
>  2 files changed, 19 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -133,6 +133,7 @@ struct sp_node {
>
>  struct shared_policy {
>         struct rb_root root;
> +       spinlock_t lock;
>         struct mutex mutex;
>  };
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2090,12 +2090,20 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
>   *
>   * Remember policies even when nobody has shared memory mapped.
>   * The policies are kept in Red-Black tree linked from the inode.
> - * They are protected by the sp->lock spinlock, which should be held
> - * for any accesses to the tree.
> + *
> + * The rb-tree is locked using both a mutex and a spinlock. Every modification
> + * to the tree must hold both the mutex and the spinlock, lookups can hold
> + * either to observe a stable tree.
> + *
> + * In particular, sp_insert() and sp_delete() take the spinlock, whereas
> + * sp_lookup() doesn't, this so users have choice.
> + *
> + * shared_policy_replace() and mpol_free_shared_policy() take the mutex
> + * and call sp_insert(), sp_delete().
>   */
>
>  /* lookup first element intersecting start-end */
> -/* Caller holds sp->mutex */
> +/* Caller holds either sp->lock and/or sp->mutex */
>  static struct sp_node *
>  sp_lookup(struct shared_policy *sp, unsigned long start, unsigned long end)
>  {
> @@ -2134,6 +2142,7 @@ static void sp_insert(struct shared_policy *sp, struct sp_node *new)
>         struct rb_node *parent = NULL;
>         struct sp_node *nd;
>
> +       spin_lock(&sp->lock);
>         while (*p) {
>                 parent = *p;
>                 nd = rb_entry(parent, struct sp_node, nd);
> @@ -2146,6 +2155,7 @@ static void sp_insert(struct shared_policy *sp, struct sp_node *new)
>         }
>         rb_link_node(&new->nd, parent, p);
>         rb_insert_color(&new->nd, &sp->root);
> +       spin_unlock(&sp->lock);
>         pr_debug("inserting %lx-%lx: %d\n", new->start, new->end,
>                  new->policy ? new->policy->mode : 0);
>  }
> @@ -2159,13 +2169,13 @@ mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
>
>         if (!sp->root.rb_node)
>                 return NULL;
> -       mutex_lock(&sp->mutex);
> +       spin_lock(&sp->lock);
>         sn = sp_lookup(sp, idx, idx+1);
>         if (sn) {
>                 mpol_get(sn->policy);
>                 pol = sn->policy;
>         }
> -       mutex_unlock(&sp->mutex);
> +       spin_unlock(&sp->lock);
>         return pol;
>  }
>
> @@ -2178,8 +2188,10 @@ static void sp_free(struct sp_node *n)
>  static void sp_delete(struct shared_policy *sp, struct sp_node *n)
>  {
>         pr_debug("deleting %lx-l%lx\n", n->start, n->end);
> +       spin_lock(&sp->lock);
>         rb_erase(&n->nd, &sp->root);
>         sp_free(n);
> +       spin_unlock(&sp->lock);
>  }
>
>  static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
> @@ -2264,6 +2276,7 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
>         int ret;
>
>         sp->root = RB_ROOT;             /* empty tree == default mempolicy */
> +       spin_lock_init(&sp->lock);
>         mutex_init(&sp->mutex);
>
>         if (mpol) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
