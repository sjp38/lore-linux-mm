Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63AEE6B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 12:14:46 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ry6so47471827pac.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:14:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b125si6582139pga.222.2016.10.12.09.14.45
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 09:14:45 -0700 (PDT)
Date: Wed, 12 Oct 2016 17:14:41 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Ensure that the task stack is not freed
 during scanning
Message-ID: <20161012161441.GC21592@e104818-lin.cambridge.arm.com>
References: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
 <2086376822.528054.1476287657078.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2086376822.528054.1476287657078.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

On Wed, Oct 12, 2016 at 11:54:17AM -0400, CAI Qian wrote:
> ----- Original Message -----
> > From: "Catalin Marinas" <catalin.marinas@arm.com>
> > To: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org, "Andrew Morton" <akpm@linux-foundation.org>, "Andy Lutomirski" <luto@kernel.org>,
> > "CAI Qian" <caiqian@redhat.com>
> > Sent: Wednesday, October 12, 2016 5:57:03 AM
> > Subject: [PATCH] mm: kmemleak: Ensure that the task stack is not freed during scanning
> > 
> > Commit 68f24b08ee89 ("sched/core: Free the stack early if
> > CONFIG_THREAD_INFO_IN_TASK") may cause the task->stack to be freed
> > during kmemleak_scan() execution, leading to either a NULL pointer
> > fault (if task->stack is NULL) or kmemleak accessing already freed
> > memory. This patch uses the new try_get_task_stack() API to ensure that
> > the task stack is not freed during kmemleak stack scanning.
> > 
> > Fixes: 68f24b08ee89 ("sched/core: Free the stack early if
> > CONFIG_THREAD_INFO_IN_TASK")
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Andy Lutomirski <luto@kernel.org>
> > Cc: CAI Qian <caiqian@redhat.com>
> > Reported-by: CAI Qian <caiqian@redhat.com>
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> Tested-by: CAI Qian <caiqian@redhat.com>

Thanks.

BTW, I noticed a few false positives reported by kmemleak with the
CONFIG_VMAP_STACK enabled caused by the fact that kmemleak requires two
references (instead of one) to a vmalloc'ed object because of the
vm_struct already containing the address. The cached_stack[] array only
stores the vm_struct rather than the stack address, hence the kmemleak
report. I'll work on a fix/annotation.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
