Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E7F566B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 19:51:07 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so1471055pdi.4
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:51:07 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qf8si2712217pac.12.2014.06.12.16.51.06
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 16:51:06 -0700 (PDT)
Message-ID: <539A3CD7.6080100@intel.com>
Date: Fri, 13 Jun 2014 01:50:47 +0200
From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
MIME-Version: 1.0
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com> <20140612220200.GA25344@cmpxchg.org>
In-Reply-To: <20140612220200.GA25344@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, =?ISO-8859-1?Q?=22Rodolfo_Gar?= =?ISO-8859-1?Q?c=EDa_Pe=F1as_=28kix=29=22?= <kix@kix.es>
Cc: Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>

On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
>>> Hi Oliver,
>>>
>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
>>>> Hello,
>>>>
>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
>>>> attached.
>>>>
>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
>>>> Probably more efficient when one of you guys looks directly.
>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
>>> bdi_wq workqueue as it should:
>>>
>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
>>> but the worker wakeup doesn't actually do anything:
>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
>>>
>>> My suspicion is that this fails because the bdi_wq is frozen at this
>>> point and so the flush work never runs until resume, whereas before my
>>> patch the effective dirty limit was high enough so that image could be
>>> written in one go without being throttled; followed by an fsync() that
>>> then writes the pages in the context of the unfrozen s2disk.
>>>
>>> Does this make sense?  Rafael?  Tejun?
>> Well, it does seem to make sense to me.
>  From what I see, this is a deadlock in the userspace suspend model and
> just happened to work by chance in the past.

Well, it had been working for quite a while, so it was a rather large 
opportunity
window it seems. :-)

> Can we patch suspend-utils as follows?

Perhaps we can.  Let's ask the new maintainer.

Rodolfo, do you think you can apply the patch below to suspend-utils?

> Alternatively, suspend-utils
> could clear the dirty limits before it starts writing and restore them
> post-resume.

That (and the patch too) doesn't seem to address the problem with 
existing suspend-utils
binaries, however.

Rafael


> ---
>  From 73d6546d5e264130e3d108c97d8317f86dc11149 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 12 Jun 2014 17:43:05 -0400
> Subject: [patch] s2disk: fix buffered IO throttling deadlock in frozen state
>
> s2disk uses buffered IO when writing the snapshot image to disk.  If
> it runs into the dirty limits, the kernel forces it to wait until the
> flusher threads clean some of the dirty pages.  However, at this point
> s2disk already froze the system, including the flusher infrastructure,
> and the whole operation deadlocks.
>
> Open the resume device with O_SYNC to force flushing any dirty pages
> directly from the write() context before they accumulate and engage
> dirty throttling.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   suspend.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/suspend.c b/suspend.c
> index 479ce58555f7..1b9bed81f58a 100644
> --- a/suspend.c
> +++ b/suspend.c
> @@ -2436,7 +2436,7 @@ int main(int argc, char *argv[])
>   		suspend_error("Could not create %s/%s.", chroot_path, "resume");
>   		goto Umount;
>   	}
> -	resume_fd = open("resume", O_RDWR);
> +	resume_fd = open("resume", O_RDWR | O_SYNC);
>   	if (resume_fd < 0) {
>   		ret = errno;
>   		suspend_error("Could not open the resume device.");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
