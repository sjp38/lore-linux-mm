Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9F3F6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 13:49:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id s26so18649225qts.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 10:49:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 135si1449871qkh.134.2017.08.08.10.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 10:49:00 -0700 (PDT)
Date: Tue, 8 Aug 2017 19:48:55 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170808174855.GK25347@redhat.com>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807113839.16695-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hello,

On Mon, Aug 07, 2017 at 01:38:39PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Wenwei Tao has noticed that our current assumption that the oom victim
> is dying and never doing any visible changes after it dies, and so the
> oom_reaper can tear it down, is not entirely true.
> 
> __task_will_free_mem consider a task dying when SIGNAL_GROUP_EXIT
> is set but do_group_exit sends SIGKILL to all threads _after_ the
> flag is set. So there is a race window when some threads won't have
> fatal_signal_pending while the oom_reaper could start unmapping the
> address space. Moreover some paths might not check for fatal signals
> before each PF/g-u-p/copy_from_user.
> 
> We already have a protection for oom_reaper vs. PF races by checking
> MMF_UNSTABLE. This has been, however, checked only for kernel threads
> (use_mm users) which can outlive the oom victim. A simple fix would be
> to extend the current check in handle_mm_fault for all tasks but that
> wouldn't be sufficient because the current check assumes that a kernel
> thread would bail out after EFAULT from get_user*/copy_from_user and
> never re-read the same address which would succeed because the PF path
> has established page tables already. This seems to be the case for the
> only existing use_mm user currently (virtio driver) but it is rather
> fragile in general.
> 
> This is even more fragile in general for more complex paths such as
> generic_perform_write which can re-read the same address more times
> (e.g. iov_iter_copy_from_user_atomic to fail and then
> iov_iter_fault_in_readable on retry). Therefore we have to implement
> MMF_UNSTABLE protection in a robust way and never make a potentially
> corrupted content visible. That requires to hook deeper into the PF
> path and check for the flag _every time_ before a pte for anonymous
> memory is established (that means all !VM_SHARED mappings).
> 
> The corruption can be triggered artificially [1] but there doesn't seem
> to be any real life bug report. The race window should be quite tight
> to trigger most of the time.

The bug corrected by this patch 1/2 I pointed it out last week while
reviewing other oom reaper fixes so that looks fine.

However I'd prefer to dump MMF_UNSTABLE for good instead of adding
more of it. It can be replaced with unmap_page_range in
__oom_reap_task_mm with a function that arms a special migration entry
so that no branchs are added to the fast paths and it's all hidden
inside is_migration_entry slow paths. Instead of triggering a
wait_on_page_bit(TASK_UNINTERRUPTIBLE) when is_migration_entry(entry)
is true, it will do a:

   __set_current_state(TASK_KILLABLE);
   schedule();
   return VM_FAULT_SIGBUS;

Because the SIGKILL is already posted by the time it gets waken, the
sigbus handler cannot run because the process will exit before
returning to userland, and the error should prevent GUP to keep trying
in a loop (which would happen with a regular migration entry).

It will be a page-less migration entry, so a fake, fixed,
non-page-struct-backing page pointer, could be used to create the
migration entry. migration_entry_to_page will not return a page, but
such entry can be cleared fine during exit_mmap like a regular
migration entry. No pagetable will be established either during those
migration entry blocking events in do_swap_page.

The above however looks simple compared to the core dumping. That is
an additional trouble, and not just because it can call
handle_mm_fault without mmap_sem. Regardless of mmap_sem, I wonder if
SIGNAL_GROUP_COREDUMP can get set while __oom_reap_task_mm is already
running and then what happens?  It can't be ok if core dumping can run
in those page-less migration entries and if it does, there's no chance
to get a coherent coredump after that, the page contents are already
freed and reused by the time. There should be an explanation of how
this race against coredumping is controlled to be sure oom reaper
can't start during coredumping (of course there's the check already,
but I'm just wondering if such check leaves a window for the race, if
there was a race already in the main page faults).

Overall OOM killing to me was reliable also before the oom reaper was
introduced.

I just did a search in bz for RHEL7 and there's a single bugreport
related to OOM issues but it's hanging in a non-ext4 filesystem, and
not nested in alloc_pages (but in wait_for_completion) and it's not
reproducible with ext4. And it's happening only in an artificial
specific "eatmemory" stress test from QA, there seems to be zero
customer related bugreports about OOM hangs.

A couple of years ago I could trivially trigger OOM deadlocks on
various ext4 paths that loops or use GFP_NOFAIL, but that was just a
matter of letting GFP_NOIO/NOFS/NOFAIL kind of allocation go through
memory reserves below the low watermark.

It is also fine to kill a few more processes in fact. It's not the end
of the world if two tasks are killed because the first one couldn't
reach exit_mmap without oom reaper assistance. The fs kind of OOM
hangs in kernel threads are major issues if the whole filesystem in
the journal or something tends to prevent a multitude of tasks to
handle SIGKILL, so it has to be handled with reserves and it looked
like it was working fine already.

The main point of the oom reaper nowadays is to free memory fast
enough so a second task isn't killed as a false positive, but it's not
like anybody will notice much of a difference if a second task is
killed, it wasn't commonly happening either.

Certainly it's preferable to get two tasks killed than corrupted core
dumps or corrupted memory, so if oom reaper will stay we need to
document how we guarantee it's mutually exclusive against core dumping
and it'd better not slowdown page fault fast paths considering it's
possible to do so by arming page-less migration entries that can wait
for sigkill to be delivered in do_swap_page.

It's a big hammer feature that is nice to have but doing it safely and
without adding branches to the fast paths, is somewhat more complex
than current code.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
