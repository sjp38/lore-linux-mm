Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4104F6B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:30:32 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so1309523pdb.11
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:30:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id iy1si11468680pbb.115.2014.06.16.09.30.30
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 09:30:31 -0700 (PDT)
Message-ID: <539F1B66.2020006@intel.com>
Date: Mon, 16 Jun 2014 18:29:26 +0200
From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
MIME-Version: 1.0
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com> <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com> <20140613045557.GL2878@cmpxchg.org>
In-Reply-To: <20140613045557.GL2878@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: =?ISO-8859-1?Q?=22Rodolfo_Garc=EDa_Pe=F1as_=28kix=29=22?= <kix@kix.es>, Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
>> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
>>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
>>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
>>>>> Hi Oliver,
>>>>>
>>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
>>>>>> Hello,
>>>>>>
>>>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
>>>>>> attached.
>>>>>>
>>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
>>>>>> Probably more efficient when one of you guys looks directly.
>>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
>>>>> bdi_wq workqueue as it should:
>>>>>
>>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
>>>>> but the worker wakeup doesn't actually do anything:
>>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
>>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
>>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
>>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
>>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
>>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
>>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
>>>>>
>>>>> My suspicion is that this fails because the bdi_wq is frozen at this
>>>>> point and so the flush work never runs until resume, whereas before my
>>>>> patch the effective dirty limit was high enough so that image could be
>>>>> written in one go without being throttled; followed by an fsync() that
>>>>> then writes the pages in the context of the unfrozen s2disk.
>>>>>
>>>>> Does this make sense?  Rafael?  Tejun?
>>>> Well, it does seem to make sense to me.
>>>  From what I see, this is a deadlock in the userspace suspend model and
>>> just happened to work by chance in the past.
>> Well, it had been working for quite a while, so it was a rather large
>> opportunity
>> window it seems. :-)
> No doubt about that, and I feel bad that it broke.  But it's still a
> deadlock that can't reasonably be accommodated from dirty throttling.
>
> It can't just put the flushers to sleep and then issue a large amount
> of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> the messenger, this bug needs to be addressed, not get papered over.
>
>>> Can we patch suspend-utils as follows?
>> Perhaps we can.  Let's ask the new maintainer.
>>
>> Rodolfo, do you think you can apply the patch below to suspend-utils?
>>
>>> Alternatively, suspend-utils
>>> could clear the dirty limits before it starts writing and restore them
>>> post-resume.
>> That (and the patch too) doesn't seem to address the problem with existing
>> suspend-utils
>> binaries, however.
> It's userspace that freezes the system before issuing buffered IO, so
> my conclusion was that the bug is in there.  This is arguable.  I also
> wouldn't be opposed to a patch that sets the dirty limits to infinity
> from the ioctl that freezes the system or creates the image.

OK, that sounds like a workable plan.

How do I set those limits to infinity?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
