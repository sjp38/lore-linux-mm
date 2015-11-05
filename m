Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3742D82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:27:37 -0500 (EST)
Received: by wicll6 with SMTP id ll6so13614076wic.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:27:36 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id m135si10895803wmb.68.2015.11.05.08.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 08:27:36 -0800 (PST)
Date: Thu, 5 Nov 2015 16:27:19 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
Message-ID: <20151105162719.GQ8644@n2100.arm.linux.org.uk>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
 <20151105094615.GP8644@n2100.arm.linux.org.uk>
 <563B81DA.2080409@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563B81DA.2080409@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 05, 2015 at 08:20:42AM -0800, Laura Abbott wrote:
> On 11/05/2015 01:46 AM, Russell King - ARM Linux wrote:
> >On Wed, Nov 04, 2015 at 05:00:39PM -0800, Laura Abbott wrote:
> >>Currently, read only permissions are not being applied even
> >>when CONFIG_DEBUG_RODATA is set. This is because section_update
> >>uses current->mm for adjusting the page tables. current->mm
> >>need not be equivalent to the kernel version. Use pgd_offset_k
> >>to get the proper page directory for updating.
> >
> >What are you trying to achieve here?  You can't use these functions
> >at run time (after the first thread has been spawned) to change
> >permissions, because there will be multiple copies of the kernel
> >section mappings, and those copies will not get updated.
> >
> >In any case, this change will probably break kexec and ftrace, as
> >the running thread will no longer see the updated page tables.
> >
> 
> I think I was hitting that exact problem with multiple copies
> not getting updated. The section_update code was being called
> and I was seeing the tables get updated but nothing was being
> applied when I tried to write to text or check the debugfs
> page table. The current flow is:
> 
> rest_init -> kernel_thread(kernel_init) and from that thread
> mark_rodata_ro. So mark_rodata_ro is always going to happen
> in a thread.
> 
> Do we need to update for both init_mm and the first running
> thread?

The "first running thread" is merely coincidental for things like kexec.

Hmm.  Actually, I think the existing code _should_ be fine.  At the
point where mark_rodata_ro() is, we should still be using init_mm, so
updating the current threads page tables should actually be updating
the swapper_pg_dir.

The other cases (kexec and ftrace) I think are also fine as they
stand - we want to be changing the currently active page tables
there.

So, I really think we do not want to be using pgd_offset_k() here at
all - but we need to find out what's changed to cause (presumably)
mark_rodata_ro() not to be hitting the swapper page tables.  Maybe
some debug in mark_rodata_ro() to find out what current->mm is?

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
