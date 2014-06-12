Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 461F96B0062
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:02:12 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so1883880wes.21
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 15:02:11 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w1si3768191wjz.45.2014.06.12.15.02.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 15:02:10 -0700 (PDT)
Date: Thu, 12 Jun 2014 18:02:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
Message-ID: <20140612220200.GA25344@cmpxchg.org>
References: <20140505233358.GC19914@cmpxchg.org>
 <5368227D.7060302@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5368227D.7060302@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>

On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> >Hi Oliver,
> >
> >On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> >>Hello,
> >>
> >>1) Attached a full function-trace log + other SysRq outputs, see [1]
> >>attached.
> >>
> >>I saw bdi_...() calls in the s2disk paths, but didn't check in detail
> >>Probably more efficient when one of you guys looks directly.
> >Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> >bdi_wq workqueue as it should:
> >
> >[  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
> >[  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
> >[  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
> >[  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> >[  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited

> >but the worker wakeup doesn't actually do anything:

> >[  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
> >[  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
> >[  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
> >[  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
> >[  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
> >[  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
> >[  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
> >
> >My suspicion is that this fails because the bdi_wq is frozen at this
> >point and so the flush work never runs until resume, whereas before my
> >patch the effective dirty limit was high enough so that image could be
> >written in one go without being throttled; followed by an fsync() that
> >then writes the pages in the context of the unfrozen s2disk.
> >
> >Does this make sense?  Rafael?  Tejun?
> 
> Well, it does seem to make sense to me.

>From what I see, this is a deadlock in the userspace suspend model and
just happened to work by chance in the past.

Can we patch suspend-utils as follows?  Alternatively, suspend-utils
could clear the dirty limits before it starts writing and restore them
post-resume.

---
