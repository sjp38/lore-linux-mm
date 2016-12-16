Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E36536B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:44:26 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id i145so22148518qke.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 01:44:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l128si2750198qkf.269.2016.12.16.01.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 01:44:26 -0800 (PST)
Subject: Re: [PATCH 4/4] [RFC!] mm: 'struct mm_struct' reference counting
 debugging
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
Date: Fri, 16 Dec 2016 10:43:52 +0100
MIME-Version: 1.0
In-Reply-To: <20161216090157.GA13940@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 10:01 AM, Michal Hocko wrote:
> On Fri 16-12-16 09:22:02, Vegard Nossum wrote:
>> Reference counting bugs are hard to debug by their nature since the actual
>> manifestation of one can occur very far from where the error is introduced
>> (e.g. a missing get() only manifest as a use-after-free when the reference
>> count prematurely drops to 0, which could be arbitrarily long after where
>> the get() should have happened if there are other users). I wrote this patch
>> to try to track down a suspected 'mm_struct' reference counting bug.
>
> I definitely agree that hunting these bugs is a royal PITA, no question
> about that. I am just wondering whether this has been motivated by any
> particular bug recently. I do not seem to remember any such an issue for
> quite some time.

Yes, I've been hitting a use-after-free with trinity that happens when
the OOM killer reaps a task. I can reproduce it reliably within a few
seconds, but with the amount of refs and syscalls going on I haven't
been able to figure out what's actually going wrong (to put things into
perspective the refcounts goes into the thousands before eventually
dropping down to 0 and trying to trace_printk() each get/put results in
several hundred megabytes of log files).

The UAF itself (sometimes a NULL pointer deref) is on a struct file
(sometimes in the page fault path, sometimes in clone(), sometimes in
execve()), and my initial debugging lead me to believe it was actually a
problem with mm_struct getting freed prematurely (hence this patch). But
disappointingly this patch didn't turn up anything so I must reevaluate
my suspicion of an mm_struct leak.

I don't think it's a bug in the OOM reaper itself, but either of the
following two patches will fix the problem (without my understand how or
why):

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..37b14b2e2af4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -485,7 +485,7 @@ static bool __oom_reap_task_mm(struct task_struct 
*tsk, struct mm_struct *mm)
  	 */
  	mutex_lock(&oom_lock);

-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!down_write_trylock(&mm->mmap_sem)) {
  		ret = false;
  		goto unlock_oom;
  	}
@@ -496,7 +496,7 @@ static bool __oom_reap_task_mm(struct task_struct 
*tsk, struct mm_struct *mm)
  	 * and delayed __mmput doesn't matter that much
  	 */
  	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
  		goto unlock_oom;
  	}

@@ -540,7 +540,7 @@ static bool __oom_reap_task_mm(struct task_struct 
*tsk, struct mm_struct *mm)
  			K(get_mm_counter(mm, MM_ANONPAGES)),
  			K(get_mm_counter(mm, MM_FILEPAGES)),
  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-	up_read(&mm->mmap_sem);
+	up_write(&mm->mmap_sem);

  	/*
  	 * Drop our reference but make sure the mmput slow path is called from a

--OR--

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..559aec0acd21 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -508,6 +508,7 @@ static bool __oom_reap_task_mm(struct task_struct 
*tsk, struct mm_struct *mm)
  	 */
  	set_bit(MMF_UNSTABLE, &mm->flags);

+#if 0
  	tlb_gather_mmu(&tlb, mm, 0, -1);
  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
  		if (is_vm_hugetlb_page(vma))
@@ -535,6 +536,7 @@ static bool __oom_reap_task_mm(struct task_struct 
*tsk, struct mm_struct *mm)
  					 &details);
  	}
  	tlb_finish_mmu(&tlb, 0, -1);
+#endif
  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, 
file-rss:%lukB, shmem-rss:%lukB\n",
  			task_pid_nr(tsk), tsk->comm,
  			K(get_mm_counter(mm, MM_ANONPAGES)),

Maybe it's just the fact that we're not releasing the memory and so some
other bit of code is not able to make enough progress to trigger the
bug, although curiously, if I just move the #if 0..#endif inside
tlb_gather_mmu()..tlb_finish_mmu() itself (so just calling tlb_*()
without doing the for-loop), it still reproduces the crash.

Another clue, although it might just be a coincidence, is that it seems
the VMA/file in question is always a mapping for the exe file itself
(the reason I think this might be a coincidence is that the exe file
mapping is the first one and we usually traverse VMAs starting with this
one, that doesn't mean the other VMAs aren't affected by the same
problem, just that we never hit them).

I really wanted to figure out and fix the bug myself, it's a great way
to learn, after all, instead of just sending crash logs and letting
somebody else figure it out. But maybe I have to admit defeat on this one.

>> The basic idea is to keep track of all references, not just with a reference
>> counter, but with an actual reference _list_. Whenever you get() or put() a
>> reference, you also add or remove yourself, respectively, from the reference
>> list. This really helps debugging because (for example) you always put a
>> specific reference, meaning that if that reference was not yours to put, you
>> will notice it immediately (rather than when the reference counter goes to 0
>> and you still have an active reference).
>
> But who is the owner of the reference? A function/task? It is not all
> that uncommon to take an mm reference from one context and release it
> from a different one. But I might be missing your point here.

An owner is somebody who knows the pointer and increments the reference
counter for it.

You'll notice a bunch of functions just take a temporary on-stack
reference (e.g. struct mm_struct *mm = get_task_mm(tsk); ...
mmput(&mm)), in which case it's the function that owns the reference
until the mmput.

Some functions take a reference and stash it in some heap object, an
example from the patch could be 'struct vhost_dev' (which has a ->mm
field), and it does get_task_mm() in an init function and mmput() in a
cleanup function. In this case, it's the struct which is the owner of
the reference, for as long as ->mm points to something non-NULL. This
would be an example of taking the reference in one context and releasing
it in a different one. I guess the point is that we must always release
a _specific_ reference when we decrement a reference count. Yes, it's a
number, but that number does refer to a specific reference that was
taken at some point in the past (and we should know
which reference this is, otherwise we don't actually "have it").

We may not be used to thinking of reference counts as actual places of
reference, but that's what it is, fundamentally. This patch just makes
it very explicit what the owners are and where ownership transfers take
place.

>> The main interface is in <linux/mm_ref_types.h> and <linux/mm_ref.h>, while
>> the implementation lives in mm/mm_ref.c. Since 'struct mm_struct' has both
>> ->mm_users and ->mm_count, we introduce helpers for both of them, but use
>> the same data structure for each (struct mm_ref). The low-level rules (i.e.
>> the ones we have to follow, but which nobody else should really have to
>> care about since they use the higher-level interface) are:
[...]
>
> This all sounds way too intrusive to me so I am not really sure this is
> something we really want. A nice thing for debugging for sure but I am
> somehow skeptical whether it is really worth it considering how many
> those ref. count bugs we've had.

Yeah, I agree it's intrusive. And it did start out as just a debugging
patch, but I figured after having done all the work I might as well
slap on a changelog and submit it to see what people think.

However, it may have some value as documentation of who is the owner of
each reference and where/when those owners change. Maybe I should just
extract that knowledge and add it in as comments instead.

Thanks for your comments!


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
