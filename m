Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 82F506B005A
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 09:01:36 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id t10so4946766eei.12
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:01:35 -0800 (PST)
Received: from eu1sys200aog118.obsmtp.com (eu1sys200aog118.obsmtp.com [207.126.144.145])
        by mx.google.com with SMTP id p9si17565989eew.244.2014.01.22.06.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 06:01:35 -0800 (PST)
Message-ID: <52DFCF2B.1010603@mellanox.com>
Date: Wed, 22 Jan 2014 16:01:15 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmu_notifier: restore set_pte_at_notify semantics
References: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com> <20140122131046.GF14193@redhat.com>
In-Reply-To: <20140122131046.GF14193@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Izik Eidus <izik.eidus@ravellosystems.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>

On 22/01/2014 15:10, Andrea Arcangeli wrote:
> On Wed, Jan 15, 2014 at 11:40:34AM +0200, Mike Rapoport wrote:
>> Commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 (mm: wrap calls to
>> set_pte_at_notify with invalidate_range_start and invalidate_range_end)
>> breaks semantics of set_pte_at_notify. When calls to set_pte_at_notify
>> are wrapped with mmu_notifier_invalidate_range_start and
>> mmu_notifier_invalidate_range_end, KVM zaps pte during
>> mmu_notifier_invalidate_range_start callback and set_pte_at_notify has
>> no spte to update and therefore it's called for nothing.
>>
>> As Andrea suggested (1), the problem is resolved by calling
>> mmu_notifier_invalidate_page after PT lock has been released and only
>> for mmu_notifiers that do not implement change_ptr callback.
>>
>> (1) http://thread.gmane.org/gmane.linux.kernel.mm/111710/focus=111711
>>
>> Reported-by: Izik Eidus <izik.eidus@ravellosystems.com>
>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Haggai Eran <haggaie@mellanox.com>
>> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> ---
>>  include/linux/mmu_notifier.h | 31 ++++++++++++++++++++++++++-----
>>  kernel/events/uprobes.c      | 12 ++++++------
>>  mm/ksm.c                     | 15 +++++----------
>>  mm/memory.c                  | 14 +++++---------
>>  mm/mmu_notifier.c            | 24 ++++++++++++++++++++++--
>>  5 files changed, 64 insertions(+), 32 deletions(-)
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> 

Hi Andrea, Mike,

Did you get a chance to consider the scenario I wrote about in the other
thread?

I'm worried about the following scenario:

Given a read-only page, suppose one host thread (thread 1) writes to
that page, and performs COW, but before it calls the
mmu_notifier_invalidate_page_if_missing_change_pte function another host
thread (thread 2) writes to the same page (this time without a page
fault). Then we have a valid entry in the secondary page table to a
stale page, and someone (thread 3) may read stale data from there.

Here's a diagram that shows this scenario:

Thread 1                                | Thread 2        | Thread 3
========================================================================
do_wp_page(page 1)                      |                 |
  ...                                   |                 |
  set_pte_at_notify                     |                 |
  ...                                   | write to page 1 |
                                        |                 | stale access
  pte_unmap_unlock                      |                 |
  invalidate_page_if_missing_change_pte |                 |

This is currently prevented by the use of the range start and range end
notifiers.

Do you agree that this scenario is possible with the new patch, or am I
missing something?

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
