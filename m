Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 04D1A6B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 00:40:16 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so473895bkw.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 21:40:15 -0700 (PDT)
Message-ID: <4F7BD0AB.1000401@openvz.org>
Date: Wed, 04 Apr 2012 08:40:11 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [x86 PAT PATCH 0/2] x86 PAT vm_flag code refactoring
References: <20120331170947.7773.46399.stgit@zurg>  <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>  <4F7A92AB.5010809@openvz.org> <1333494871.12400.10.camel@sbsiddha-desk.sc.intel.com>
In-Reply-To: <1333494871.12400.10.camel@sbsiddha-desk.sc.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

Suresh Siddha wrote:
> On Tue, 2012-04-03 at 10:03 +0400, Konstantin Khlebnikov wrote:
>> Suresh Siddha wrote:
>>> Konstantin,
>>>
>>> On Sat, 2012-03-31 at 21:09 +0400, Konstantin Khlebnikov wrote:
>>>> v2: Do not use batched pfn reserving for single-page VMA. This is not optimal
>>>> and breaks something, because I see glitches on the screen with i915/drm driver.
>>>> With this version glitches are gone, and I see the same regions in
>>>> /sys/kernel/debug/x86/pat_memtype_list as before patch. So, please review this
>>>> carefully, probably I'm wrong somewhere, or I have triggered some hidden bug.
>>>
>>> Actually it is not a hidden bug. In the original code, we were setting
>>> VM_PFN_AT_MMAP only for remap_pfn_range() but not for the vm_insert_pfn().
>>> Also the value of 'vm_pgoff' depends on the driver/mmap_region() in the case of
>>> vm_insert_pfn(). But with your proposed code, you were setting
>>> the VM_PAT for the single-page VMA also and end-up using wrong vm_pgoff in
>>> untrack_pfn_vma().
>>
>> But I set correct vma->vm_pgoff together with VM_PAT. But, it shouldn't work if vma is expandable...
>>
>
> Also, I am not sure if we can override vm_pgoff in the fault handling
> path. For example, looking at unmap_mapping_range_tree() it does depend
> on the vm_pgoff value and it might break if we change the vm_pgoff in
> track_pfn_vma_new() (which gets called from vm_insert_pfn() as part of
> the i915_gem_fault()).

Yes, and we shouldn't change vma under mm->mmap_sem read-lock.

>
> thanks,
> suresh
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
