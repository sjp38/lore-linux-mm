Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id E4D876B0069
	for <linux-mm@kvack.org>; Fri, 16 May 2014 09:52:21 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so1599987eek.12
        for <linux-mm@kvack.org>; Fri, 16 May 2014 06:52:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x44si6925408eeo.79.2014.05.16.06.52.19
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 06:52:20 -0700 (PDT)
Date: Fri, 16 May 2014 15:51:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] ptrace: task_clear_jobctl_trapping()->wake_up_bit()
	needs mb()
Message-ID: <20140516135116.GA19210@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net> <20140514161152.GA2615@redhat.com> <20140514161755.GQ30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140514161755.GQ30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 05/14, Peter Zijlstra wrote:
>
> On Wed, May 14, 2014 at 06:11:52PM +0200, Oleg Nesterov wrote:
> >
> > I mean, we do not need mb() before __wake_up(). We need it only because
> > __wake_up_bit() checks waitqueue_active().
> >
> >
> > And at least
> >
> > 	fs/cachefiles/namei.c:cachefiles_delete_object()
> > 	fs/block_dev.c:blkdev_get()
> > 	kernel/signal.c:task_clear_jobctl_trapping()
> > 	security/keys/gc.c:key_garbage_collector()
> >
> > look obviously wrong.
> >
> > I would be happy to send the fix, but do I need to split it per-file?
> > Given that it is trivial, perhaps I can send a single patch?
>
> Since its all the same issue a single patch would be fine I think.

Actually blkdev_get() is fine, it relies on bdev_lock. But bd_prepare_to_claim()
is the good example of abusing bit_waitqueue(). Not only it is itself suboptimal,
this doesn't allow to optimize wake_up_bit-like paths. And there are more, say,
inode_sleep_on_writeback(). Plus we have wait_on_atomic_t() which I think should
be generalized or even unified with the regular wait_on_bit(). Perhaps I'll try
to do this later, fortunately the recent patch from Neil greatly reduced the
number of "action" functions.

As for cachefiles_walk_to_object() and key_garbage_collector(), it still seems
to me they need smp_mb__after_clear_bit() but I'll leave this to David, I am
not comfortable to change the code I absolutely do not understand. In particular,
I fail to understand why key_garbage_collector() does smp_mb() before clear_bit().
At least it could be smp_mb__before_clear_bit().

So let me send a trivial patch which only changes task_clear_jobctl_trapping().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
