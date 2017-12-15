Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDDD6B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 13:54:42 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id x204so4407577oif.18
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 10:54:42 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r69si2435308ota.125.2017.12.15.10.54.41
        for <linux-mm@kvack.org>;
        Fri, 15 Dec 2017 10:54:41 -0800 (PST)
Message-ID: <5A3419F3.1030804@arm.com>
Date: Fri, 15 Dec 2017 18:52:35 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [Question ]: Avoid kernel panic when killing an application if
 happen RAS page table error
References: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com> <20171205165727.GG3070@tassilo.jf.intel.com> <0276f3b3-94a5-8a47-dfb7-8773cd2f99c5@huawei.com> <dedf9af6-7979-12dc-2a52-f00b2ec7f3b6@huawei.com> <0b7bb7b3-ae39-0c97-9c0a-af37b0701ab4@huawei.com> <eab54efe-0ab4-bf6a-5831-128ff02a018b@huawei.com>
In-Reply-To: <eab54efe-0ab4-bf6a-5831-128ff02a018b@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gengdongjiu <gengdongjiu@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Huangshaoyu <huangshaoyu@huawei.com>, Wuquanming <wuquanming@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi gengdongjiu,

On 15/12/17 02:00, gengdongjiu wrote:
> change the mail title and resend.

(please don't do this, we all got the first version)


> If the user space application happen page table RAS error,Memory error handler(memory_failure()) will
> do nothing except making a poisoned page flag,

Yes, because user-space process's page tables are kernel memory.

memory_failure() depends on the system being able to contain these faults,
giving us another RAS exception if we touch the page again.


> and fault handler in arch/arm64/mm/fault.c
> will deliver a signal to kill this application. when this application exits, it will call unmap_vmas ()
> to release his vma resource, but here it will touch the error page table
again, then will
> trigger RAS error again, so this application cannot be killed and system will be panic, the log is shown in [2].

Kernel memory is corrupt, we panic().

You want to add a distinction to handle user-space process's page tables:

> As shown the stack in [1], unmap_page_range() will touch the error page table, so system will panic,
> there are some simple way to avoid this panic and avoid change much about
> the memory management.
> 1. put the tasks to dead status, not run it again.
> 2. not release the page table for this task.
> 
> Of cause, above methods may happen memory leakage. do you have good suggestion about how to solve it?, or do you think this panic is expected behavior? thanks.

I don't think this is worth the effort, the page tables are small compared to
the memory they map. Even if this were fixed, you still have the chance of other
kernel memory being corrupted.

Leaking any memory that isn't marked as poisoned isn't a good idea.

What you would need is a way to know from the struct_page that: this page is
is page-table, and which struct_mm it belongs to. (If its the kernel's init_mm:
panic()).
Next you need a way to find all the other pages of page-table without walking
them. With these three pieces of information you can free all the unaffected
memory, with even more work you can probably regenerate the corrupted page.

It's going to be complicated to do, I don't think its worth the effort.


Thanks,

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
