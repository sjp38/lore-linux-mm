Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 900096B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:16:30 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id w127so3918961iow.22
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 23:16:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x70si5748173ioi.296.2017.12.15.23.16.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 23:16:29 -0800 (PST)
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
 <20171215150429.f68862867392337f35a49848@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <cafa6cdb-886b-b010-753f-600ae86f5e71@I-love.SAKURA.ne.jp>
Date: Sat, 16 Dec 2017 16:14:07 +0900
MIME-Version: 1.0
In-Reply-To: <20171215150429.f68862867392337f35a49848@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2017/12/16 8:04, Andrew Morton wrote:
>> The implementation is steered toward an expensive slowpath, such as after
>> the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.
> 
> some tweakage, please review.
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix
> 
> make mm_has_blockable_invalidate_notifiers() return bool, use rwsem_is_locked()
> 

> @@ -240,13 +240,13 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_invalid
>   * Must be called while holding mm->mmap_sem for either read or write.
>   * The result is guaranteed to be valid until mm->mmap_sem is dropped.
>   */
> -int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> +bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> -	int ret = 0;
> +	bool ret = false;
>  
> -	WARN_ON_ONCE(down_write_trylock(&mm->mmap_sem));
> +	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
>  
>  	if (!mm_has_notifiers(mm))
>  		return ret;

rwsem_is_locked() test isn't equivalent with __mutex_owner() == current test, is it?
If rwsem_is_locked() returns true because somebody else has locked it, there is
no guarantee that current thread has locked it before calling this function.

down_write_trylock() test isn't equivalent with __mutex_owner() == current test, is it?
What if somebody else held it for read or write (the worst case is registration path),
down_write_trylock() will return false even if current thread has not locked it for
read or write.

I think this WARN_ON_ONCE() can not detect incorrect call to this function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
