Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C83B66B000D
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 06:35:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s21so7142213pfm.15
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 03:35:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z14si5962871pfe.289.2018.03.30.03.35.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 03:35:11 -0700 (PDT)
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
In-Reply-To: <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
Message-Id: <201803301934.DHF12420.SOFFJQMLVtHOOF@I-love.SAKURA.ne.jp>
Date: Fri, 30 Mar 2018 19:34:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, mhocko@suse.com, riel@redhat.com

Andrew Morton wrote:
> On Thu, 29 Mar 2018 20:27:50 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > Theoretically it is possible that an mm_struct with 60000+ vmas loops
> > with potentially allocating memory, with mm->mmap_sem held for write by
> > the current thread. Unless I overlooked that fatal_signal_pending() is
> > somewhere in the loop, this is bad if current thread was selected as an
> > OOM victim, for the current thread will continue allocations using memory
> > reserves while the OOM reaper is unable to reclaim memory.
> 
> All of which implies to me that this patch fixes a problem which is not
> known to exist!

Yes.

The trigger which made me to check this loop is that it is not difficult to hit
"oom_reaper: unable to reap pid:" messages if the victim thread is blocked at
i_mmap_lock_write() in this loop.

Checking for SIGKILL in this loop will be nice. Doing so should to some degree help
faster termination by reducing possibility of being blocked at i_mmap_sem_write().
That is, if i_mmap_lock_write() against N'th vma would block, we can avoid needless
delay by escaping the loop via fatal_signal_pending() test before reaching
i_mmap_lock_write() against N'th vma. Even if we are already blocked at
i_mmap_lock_write() against N'th vma, we can still avoid needless delay if
i_mmap_lock_write() against subsequent vmas would also block.

> 
> > But there is no point with continuing the loop from the beginning if
> > current thread is killed. If there were __GFP_KILLABLE (or something
> > like memalloc_nofs_save()/memalloc_nofs_restore()), we could apply it
> > to all allocations inside the loop. But since we don't have such flag,
> > this patch uses fatal_signal_pending() check inside the loop.
> 
> Dumb question: if a thread has been oom-killed and then tries to
> allocate memory, should the page allocator just fail the allocation
> attempt?  I suppose there are all sorts of reasons why not :(

Maybe because allocation failure paths are not tested enough
( https://lwn.net/Articles/627419/ ). But that should not prevent the page
allocator from just failing the allocation attempt.

I do want a mechanism for telling the page allocator whether we want to
give up upon SIGKILL. I've been proposing it as __GFP_KILLABLE.

> 
> In which case, yes, setting a new
> PF_MEMALLOC_MAY_FAIL_IF_I_WAS_OOMKILLED around such code might be a
> tidy enough solution.  It would be a bit sad to add another test in the
> hot path (should_fail_alloc_page()?), but geeze we do a lot of junk
> already.

Maybe we can make "give up by default upon SIGKILL" and let callers
explicitly say "do not give up upon SIGKILL".

----------------------------------------
 include/linux/gfp.h            | 10 ++++++++++
 include/trace/events/mmflags.h |  1 +
 mm/page_alloc.c                | 15 +++++++++++++++
 tools/perf/builtin-kmem.c      |  1 +
 4 files changed, 27 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b..a0e8a9c 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -24,6 +24,7 @@
 #define ___GFP_HIGH		0x20u
 #define ___GFP_IO		0x40u
 #define ___GFP_FS		0x80u
+#define ___GFP_UNKILLABLE	0x100u
 #define ___GFP_NOWARN		0x200u
 #define ___GFP_RETRY_MAYFAIL	0x400u
 #define ___GFP_NOFAIL		0x800u
@@ -122,6 +123,14 @@
  *   allocator recursing into the filesystem which might already be holding
  *   locks.
  *
+ * __GFP_UNKILLABLE: The VM implementation does not fail by simply because
+ *   fatal_signal_pending(current) is true when the current thread in task
+ *   context is doing memory allocations. Those allocations which do not want
+ *   to be disturbed by SIGKILL can add this flag. But note that those
+ *   allocations which must not fail have to add __GFP_NOFAIL, for
+ *   __GFP_UNKILLABLE allocations can still fail by other reasons such as
+ *   __GFP_NORETRY, __GFP_RETRY_MAYFAIL, being selected as an OOM victim.
+ *
  * __GFP_DIRECT_RECLAIM indicates that the caller may enter direct reclaim.
  *   This flag can be cleared to avoid unnecessary delays when a fallback
  *   option is available.
@@ -181,6 +190,7 @@
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)
+#define __GFP_UNKILLABLE ((__force gfp_t)___GFP_UNKILLABLE)
 #define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
 #define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
 #define __GFP_RECLAIM ((__force gfp_t)(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM))
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a81cffb..6a21654 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -32,6 +32,7 @@
 	{(unsigned long)__GFP_ATOMIC,		"__GFP_ATOMIC"},	\
 	{(unsigned long)__GFP_IO,		"__GFP_IO"},		\
 	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
+	{(unsigned long)__GFP_UNKILLABLE,	"__GFP_UNKILLABLE"},	\
 	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
 	{(unsigned long)__GFP_RETRY_MAYFAIL,	"__GFP_RETRY_MAYFAIL"},	\
 	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d..c8af32e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4183,6 +4183,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (current->flags & PF_MEMALLOC)
 		goto nopage;
 
+	/* Can give up if caller is willing to give up upon fatal signals */
+	if (fatal_signal_pending(current) &&
+	    !(gfp_mask & (__GFP_UNKILLABLE | __GFP_NOFAIL))) {
+		gfp_mask |= __GFP_NOWARN;
+		goto nopage;
+	}
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
 							&did_some_progress);
@@ -4301,6 +4308,14 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct alloc_context *ac, gfp_t *alloc_mask,
 		unsigned int *alloc_flags)
 {
+	/*
+	 * Can give up if caller in task context is willing to give up upon
+	 * fatal signals
+	 */
+	if (in_task() && fatal_signal_pending(current) &&
+	    (gfp_mask & (__GFP_UNKILLABLE | __GFP_NOFAIL)))
+		return false;
+
 	ac->high_zoneidx = gfp_zone(gfp_mask);
 	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
 	ac->nodemask = nodemask;
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index ae11e4c..b36d945 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -641,6 +641,7 @@ static int gfpcmp(const void *a, const void *b)
 	{ "__GFP_ATOMIC",		"_A" },
 	{ "__GFP_IO",			"I" },
 	{ "__GFP_FS",			"F" },
+	{ "__GFP_UNKILLABLE",		"UK" },
 	{ "__GFP_NOWARN",		"NWR" },
 	{ "__GFP_RETRY_MAYFAIL",	"R" },
 	{ "__GFP_NOFAIL",		"NF" },
----------------------------------------

> 
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -440,6 +440,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
> >  			continue;
> >  		}
> >  		charge = 0;
> > +		if (fatal_signal_pending(current)) {
> > +			retval = -EINTR;
> > +			goto out;
> > +		}
> >  		if (mpnt->vm_flags & VM_ACCOUNT) {
> >  			unsigned long len = vma_pages(mpnt);
> 
> I think a comment explaining why we're doing this would help.

I think such comment can go to patch description like commit d1908f52557b3230
("fs: break out of iomap_file_buffered_write on fatal signals") did.

> 
> Better would be to add a new function "current_is_oom_killed()" or
> such, which becomes self-documenting.  Because there are other reasons
> why a task may have a fatal signal pending.
> 

current_is_oom_killed() is already there as tsk_is_oom_victim(current)
except that tsk_is_oom_victim(current) is not accurate because the OOM
killer sets ->signal->oom_mm field to only one thread group even when
the OOM victim consists of multiple thread groups.

But I don't think we need to distinguish "killed by the OOM killer" and
"killed by other than the OOM killer" if we can tell the page allocator
whether we want to give up upon SIGKILL. Any allocation which does not
want to give up upon SIGKILL could get preferred access to memory reserves
if SIGKILL is pending.
