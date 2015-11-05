Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2127A82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:20:46 -0500 (EST)
Received: by ykba4 with SMTP id a4so139350771ykb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:20:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si1570463vkd.7.2015.11.05.08.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:20:45 -0800 (PST)
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
 <20151105094615.GP8644@n2100.arm.linux.org.uk>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <563B81DA.2080409@redhat.com>
Date: Thu, 5 Nov 2015 08:20:42 -0800
MIME-Version: 1.0
In-Reply-To: <20151105094615.GP8644@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>
Cc: Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/05/2015 01:46 AM, Russell King - ARM Linux wrote:
> On Wed, Nov 04, 2015 at 05:00:39PM -0800, Laura Abbott wrote:
>> Currently, read only permissions are not being applied even
>> when CONFIG_DEBUG_RODATA is set. This is because section_update
>> uses current->mm for adjusting the page tables. current->mm
>> need not be equivalent to the kernel version. Use pgd_offset_k
>> to get the proper page directory for updating.
>
> What are you trying to achieve here?  You can't use these functions
> at run time (after the first thread has been spawned) to change
> permissions, because there will be multiple copies of the kernel
> section mappings, and those copies will not get updated.
>
> In any case, this change will probably break kexec and ftrace, as
> the running thread will no longer see the updated page tables.
>

I think I was hitting that exact problem with multiple copies
not getting updated. The section_update code was being called
and I was seeing the tables get updated but nothing was being
applied when I tried to write to text or check the debugfs
page table. The current flow is:

rest_init -> kernel_thread(kernel_init) and from that thread
mark_rodata_ro. So mark_rodata_ro is always going to happen
in a thread.

Do we need to update for both init_mm and the first running
thread?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
