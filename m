Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 405666B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:06:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so400853534pfv.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 20:06:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x72si24908087pfk.277.2016.09.12.20.06.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 20:06:56 -0700 (PDT)
Subject: Re: [PATCH v2] mm, proc: Fix region lost in /proc/self/smaps
References: <1473649964-20191-1-git-send-email-guangrong.xiao@linux.intel.com>
 <20160912125447.GM14524@dhcp22.suse.cz> <57D6C332.4000409@intel.com>
 <20160912191035.GD14997@dhcp22.suse.cz>
From: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Message-ID: <a244d7f9-762e-6f26-a537-0524765c6815@linux.intel.com>
Date: Tue, 13 Sep 2016 11:01:09 +0800
MIME-Version: 1.0
In-Reply-To: <20160912191035.GD14997@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Oleg Nesterov <oleg@redhat.com>



On 09/13/2016 03:10 AM, Michal Hocko wrote:
> On Mon 12-09-16 08:01:06, Dave Hansen wrote:
>> On 09/12/2016 05:54 AM, Michal Hocko wrote:
>>>>> In order to fix this bug, we make 'file->version' indicate the end address
>>>>> of current VMA
>>> Doesn't this open doors to another weird cases. Say B would be partially
>>> unmapped (tail of the VMA would get unmapped and reused for a new VMA.
>>
>> In the end, this interface isn't about VMAs.  It's about addresses, and
>> we need to make sure that the _addresses_ coming out of it are sane.  In
>> the case that a VMA was partially unmapped, it doesn't make sense to
>> show the "new" VMA because we already had some output covering the
>> address of the "new" VMA from the old one.
>
> OK, that is a fair point and it speaks for caching the vm_end rather
> than vm_start+skip.
>
>>> I am not sure we provide any guarantee when there are more read
>>> syscalls. Hmm, even with a single read() we can get inconsistent results
>>> from different threads without any user space synchronization.
>>
>> Yeah, very true.  But, I think we _can_ at least provide the following
>> guarantees (among others):
>> 1. addresses don't go backwards
>> 2. If there is something at a given vaddr during the entirety of the
>>    life of the smaps walk, we will produce some output for it.
>
> I guess we also want
>   3. no overlaps with previously printed values (assuming two subsequent
>      reads without seek).
>
> the patch tries to achieve the last part as well AFAICS but I guess this
> is incomplete because at least /proc/<pid>/smaps will report counters
> for the full vma range while the header (aka show_map_vma) will report
> shorter (non-overlapping) range. I haven't checked other files which use
> m_{start,next}

You are right. Will fix both /proc/PID/smaps and /proc/PID/maps in
the next version.

>
> Considering how this all can be tricky and how partial reads can be
> confusing and even misleading I am really wondering whether we
> should simply document that only full reads will provide a sensible
> results.

Make sense. Will document the guarantee in
Documentation/filesystems/proc.txt

Thank you, Dave and Michal, for figuring out the right direction. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
