Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB27F6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 14:02:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 198so707910wmg.6
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 11:02:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z81si2191268wmb.226.2017.11.03.11.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 11:02:48 -0700 (PDT)
Date: Fri, 3 Nov 2017 11:02:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Message-Id: <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
In-Reply-To: <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
	<20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
	<ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Michal Hocko <mhocko@kernel.org>, mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>

On Fri, 03 Nov 2017 01:44:44 +0800 "Yang Shi" <yang.s@alibaba-inc.com> wrote:

> I may not articulate it in the commit log

You should have done so ;)

Here's the changelog I ended up with:

: From: "Yang Shi" <yang.s@alibaba-inc.com>
: Subject: mm: use in_atomic() in print_vma_addr()
: 
: 3e51f3c4004c9b ("sched/preempt: Remove PREEMPT_ACTIVE unmasking off
: in_atomic()") uses in_atomic() just check the preempt count, so it is not
: necessary to use preempt_count() in print_vma_addr() any more.  Replace
: preempt_count() to in_atomic() which is a generic API for checking atomic
: context.
: 
: in_atomic() is the preferred API for checking atomic context instead of
: preempt_count() which should be used for retrieving the preemption count
: value.
: 
: If we go through the kernel code, almost everywhere "in_atomic" is used
: for such use case already, except two places:
: 
: - print_vma_addr()
: - debug_smp_processor_id()
: 
: Both came from Ingo long time ago before 3e51f3c4004c9b01 ("sched/preempt:
: Remove PREEMPT_ACTIVE unmasking off in_atomic()").  But, after this commit
: was merged, use in_atomic() to follow the convention.
: 
: Link: http://lkml.kernel.org/r/1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com
: Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
: Acked-by: Michal Hocko <mhocko@suse.com>
: Cc: Frederic Weisbecker <fweisbec@gmail.com>
: Cc: Ingo Molnar <mingo@elte.hu>



Also, checkpatch says

WARNING: use of in_atomic() is incorrect outside core kernel code
#43: FILE: mm/memory.c:4491:
+       if (in_atomic())

I don't recall why we did that, but perhaps this should be revisited?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
