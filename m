Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA62E6B0069
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 01:22:21 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id p204so3879724iod.16
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 22:22:21 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n14si3749076iod.231.2017.12.15.22.22.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 22:22:20 -0800 (PST)
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
 <20171215162534.GA16951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <0c555671-9214-5cb9-0121-5da04faf5329@I-love.SAKURA.ne.jp>
Date: Sat, 16 Dec 2017 15:21:51 +0900
MIME-Version: 1.0
In-Reply-To: <20171215162534.GA16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2017/12/16 1:25, Michal Hocko wrote:
>>  struct mmu_notifier_ops {
>> +	/*
>> +	 * Flags to specify behavior of callbacks for this MMU notifier.
>> +	 * Used to determine which context an operation may be called.
>> +	 *
>> +	 * MMU_INVALIDATE_DOES_NOT_BLOCK: invalidate_{start,end} does not
>> +	 *				  block
>> +	 */
>> +	int flags;
> 
> This should be more specific IMHO. What do you think about the following
> wording?
> 
> invalidate_{start,end,range} doesn't block on any locks which depend
> directly or indirectly (via lock chain or resources e.g. worker context)
> on a memory allocation.

I disagree. It needlessly complicates validating the correctness.

What if the invalidate_{start,end} calls schedule_timeout_idle(10 * HZ) ?
schedule_timeout_idle() will not block on any locks which depend directly or
indirectly on a memory allocation, but we are already blocking other memory
allocating threads at mutex_trylock(&oom_lock) in __alloc_pages_may_oom().

This is essentially same with "sleeping forever due to schedule_timeout_killable(1) by
SCHED_IDLE thread with oom_lock held" versus "looping due to mutex_trylock(&oom_lock)
by all other allocating threads" lockup problem. The OOM reaper does not want to get
blocked for so long.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
