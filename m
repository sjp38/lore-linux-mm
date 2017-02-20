Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 258106B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 03:38:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o64so105814817pfb.2
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 00:38:45 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i15si12841446pgp.147.2017.02.20.00.38.42
        for <linux-mm@kvack.org>;
        Mon, 20 Feb 2017 00:38:44 -0800 (PST)
Date: Mon, 20 Feb 2017 17:38:36 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 00/13] lockdep: Implement crossrelease feature
Message-ID: <20170220083836.GA3817@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:26PM +0900, Byungchul Park wrote:
> I checked if crossrelease feature works well on my qemu-i386 machine.
> There's no problem at all to work on mine. But I wonder if it's also
> true even on other machines. Especially, on large system. Could you
> let me know if it doesn't work on yours? Or Could you let me know if
> crossrelease feature is useful? Please let me know if you need to
> backport it to another version but it's not easy. Then I can provide
> the backported version after working it.

Hello peterz,

I don't want to rush you, but I think enough time has passed. Could you
check this? I tried to apply what you recommanded at the previous spin
as much as possible. Could you?

Thanks,
Byungchul

> 
> -----8<-----
> 
> Change from v4
> 	- rebase on vanilla v4.9 tag
> 	- re-name pend_lock(plock) to hist_lock(xhlock)
> 	- allow overwriting ring buffer for hist_lock
> 	- unwind ring buffer instead of tagging id for each irq
> 	- introduce lockdep_map_cross embedding cross_lock
> 	- make each work of workqueue distinguishable
> 	- enhance comments
> 	(I will update the document at the next spin.)
> 
> Change from v3
> 	- reviced document
> 
> Change from v2
> 	- rebase on vanilla v4.7 tag
> 	- move lockdep data for page lock from struct page to page_ext
> 	- allocate plocks buffer via vmalloc instead of in struct task
> 	- enhanced comments and document
> 	- optimize performance
> 	- make reporting function crossrelease-aware
> 
> Change from v1
> 	- enhanced the document
> 	- removed save_stack_trace() optimizing patch
> 	- made this based on the seperated save_stack_trace patchset
> 	  https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1182242.html
> 
> Can we detect deadlocks below with original lockdep?
> 
> Example 1)
> 
> 	PROCESS X	PROCESS Y
> 	--------------	--------------
> 	mutext_lock A
> 			lock_page B
> 	lock_page B
> 			mutext_lock A // DEADLOCK
> 	unlock_page B
> 			mutext_unlock A
> 	mutex_unlock A
> 			unlock_page B
> 
> where A and B are different lock classes.
> 
> No, we cannot.
> 
> Example 2)
> 
> 	PROCESS X	PROCESS Y	PROCESS Z
> 	--------------	--------------	--------------
> 			mutex_lock A
> 	lock_page B
> 			lock_page B
> 					mutext_lock A // DEADLOCK
> 					mutext_unlock A
> 					unlock_page B
> 					(B was held by PROCESS X)
> 			unlock_page B
> 			mutex_unlock A
> 
> where A and B are different lock classes.
> 
> No, we cannot.
> 
> Example 3)
> 
> 	PROCESS X	PROCESS Y
> 	--------------	--------------
> 			mutex_lock A
> 	mutex_lock A
> 			wait_for_complete B // DEADLOCK
> 	mutex_unlock A
> 	complete B
> 			mutex_unlock A
> 
> where A is a lock class and B is a completion variable.
> 
> No, we cannot.
> 
> Not only lock operations, but also any operations causing to wait or
> spin for something can cause deadlock unless it's eventually *released*
> by someone. The important point here is that the waiting or spinning
> must be *released* by someone.
> 
> Using crossrelease feature, we can check dependency and detect deadlock
> possibility not only for typical lock, but also for lock_page(),
> wait_for_xxx() and so on, which might be released in any context.
> 
> See the last patch including the document for more information.
> 
> Byungchul Park (13):
>   lockdep: Refactor lookup_chain_cache()
>   lockdep: Fix wrong condition to print bug msgs for
>     MAX_LOCKDEP_CHAIN_HLOCKS
>   lockdep: Add a function building a chain between two classes
>   lockdep: Refactor save_trace()
>   lockdep: Pass a callback arg to check_prev_add() to handle stack_trace
>   lockdep: Implement crossrelease feature
>   lockdep: Make print_circular_bug() aware of crossrelease
>   lockdep: Apply crossrelease to completions
>   pagemap.h: Remove trailing white space
>   lockdep: Apply crossrelease to PG_locked locks
>   lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
>   lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
>   lockdep: Crossrelease feature documentation
> 
>  Documentation/locking/crossrelease.txt | 1053 ++++++++++++++++++++++++++++++++
>  include/linux/completion.h             |  118 +++-
>  include/linux/irqflags.h               |   24 +-
>  include/linux/lockdep.h                |  129 ++++
>  include/linux/mm_types.h               |    4 +
>  include/linux/page-flags.h             |   43 +-
>  include/linux/page_ext.h               |    4 +
>  include/linux/pagemap.h                |  124 +++-
>  include/linux/sched.h                  |    9 +
>  kernel/exit.c                          |    9 +
>  kernel/fork.c                          |   23 +
>  kernel/locking/lockdep.c               |  763 ++++++++++++++++++++---
>  kernel/sched/completion.c              |   54 +-
>  kernel/workqueue.c                     |    1 +
>  lib/Kconfig.debug                      |   30 +
>  mm/filemap.c                           |   76 ++-
>  mm/page_ext.c                          |    4 +
>  17 files changed, 2324 insertions(+), 144 deletions(-)
>  create mode 100644 Documentation/locking/crossrelease.txt
> 
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
