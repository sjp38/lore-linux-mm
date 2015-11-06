Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id E098C82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 20:05:14 -0500 (EST)
Received: by ykdv3 with SMTP id v3so74431985ykd.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 17:05:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 70si7000777vkp.135.2015.11.05.17.05.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 17:05:14 -0800 (PST)
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
 <20151105094615.GP8644@n2100.arm.linux.org.uk> <563B81DA.2080409@redhat.com>
 <20151105162719.GQ8644@n2100.arm.linux.org.uk>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <563BFCC4.8050705@redhat.com>
Date: Thu, 5 Nov 2015 17:05:08 -0800
MIME-Version: 1.0
In-Reply-To: <20151105162719.GQ8644@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Laura Abbott <labbott@fedoraproject.org>, Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/05/2015 08:27 AM, Russell King - ARM Linux wrote:
> On Thu, Nov 05, 2015 at 08:20:42AM -0800, Laura Abbott wrote:
>> On 11/05/2015 01:46 AM, Russell King - ARM Linux wrote:
>>> On Wed, Nov 04, 2015 at 05:00:39PM -0800, Laura Abbott wrote:
>>>> Currently, read only permissions are not being applied even
>>>> when CONFIG_DEBUG_RODATA is set. This is because section_update
>>>> uses current->mm for adjusting the page tables. current->mm
>>>> need not be equivalent to the kernel version. Use pgd_offset_k
>>>> to get the proper page directory for updating.
>>>
>>> What are you trying to achieve here?  You can't use these functions
>>> at run time (after the first thread has been spawned) to change
>>> permissions, because there will be multiple copies of the kernel
>>> section mappings, and those copies will not get updated.
>>>
>>> In any case, this change will probably break kexec and ftrace, as
>>> the running thread will no longer see the updated page tables.
>>>
>>
>> I think I was hitting that exact problem with multiple copies
>> not getting updated. The section_update code was being called
>> and I was seeing the tables get updated but nothing was being
>> applied when I tried to write to text or check the debugfs
>> page table. The current flow is:
>>
>> rest_init -> kernel_thread(kernel_init) and from that thread
>> mark_rodata_ro. So mark_rodata_ro is always going to happen
>> in a thread.
>>
>> Do we need to update for both init_mm and the first running
>> thread?
>
> The "first running thread" is merely coincidental for things like kexec.
>
> Hmm.  Actually, I think the existing code _should_ be fine.  At the
> point where mark_rodata_ro() is, we should still be using init_mm, so
> updating the current threads page tables should actually be updating
> the swapper_pg_dir.

That doesn't seem to hold true. Based on what I'm seeing, we lose
the the guarantee of init_mm after the first exec. If usermodehelper
gets called to load a module, that triggers an exec and the kernel
thread is no longer using init_mm after that. I'm testing with the
multi-v7 defconfig which uses the smsc911x driver which loads a
module during initcall. That gets called before mark_rodata_ro so
the init_mm is never updated. I verified that disabling smsc911x
makes things work as expected. I suspect the testing was never done
with a driver that tried to call usermodehelper during init time.

I got as far as narrowing it down that it happens after the usermodehelper
but I wasn't able to pinpoint where exactly the switch happened. It seems
like we need to have the page tables set up before any initcalls
happen otherwise we risk having an exec create stray processes which we
can't update.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
