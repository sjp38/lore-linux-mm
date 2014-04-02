Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 99ACB6B00A3
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 08:52:53 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id bs8so438714wib.5
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 05:52:52 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1lp0014.outbound.protection.outlook.com. [213.199.154.14])
        by mx.google.com with ESMTPS id m2si764013wij.48.2014.04.02.05.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Apr 2014 05:52:51 -0700 (PDT)
Message-ID: <533C081D.9050202@mellanox.com>
Date: Wed, 2 Apr 2014 15:52:45 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmu_notifier: restore set_pte_at_notify semantics
References: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com> <20140122131046.GF14193@redhat.com> <52DFCF2B.1010603@mellanox.com> <20140330203328.GA4859@gmail.com>
In-Reply-To: <20140330203328.GA4859@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Izik Eidus <izik.eidus@ravellosystems.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>

On 03/30/2014 11:33 PM, Jerome Glisse wrote:
> On Wed, Jan 22, 2014 at 04:01:15PM +0200, Haggai Eran wrote:
>> I'm worried about the following scenario:
>>
>> Given a read-only page, suppose one host thread (thread 1) writes to
>> that page, and performs COW, but before it calls the
>> mmu_notifier_invalidate_page_if_missing_change_pte function another host
>> thread (thread 2) writes to the same page (this time without a page
>> fault). Then we have a valid entry in the secondary page table to a
>> stale page, and someone (thread 3) may read stale data from there.
>>
>> Here's a diagram that shows this scenario:
>>
>> Thread 1                                | Thread 2        | Thread 3
>> ========================================================================
>> do_wp_page(page 1)                      |                 |
>>    ...                                   |                 |
>>    set_pte_at_notify                     |                 |
>>    ...                                   | write to page 1 |
>>                                          |                 | stale access
>>    pte_unmap_unlock                      |                 |
>>    invalidate_page_if_missing_change_pte |                 |
>>
>> This is currently prevented by the use of the range start and range end
>> notifiers.
>>
>> Do you agree that this scenario is possible with the new patch, or am I
>> missing something?
>>
> I believe you are right, but of all the upstream user of the mmu_notifier
> API only xen would suffer from this ie any user that do not have a proper
> change_pte callback can see the bogus scenario you describe above.
Yes. I sent our RDMA paging RFC patch-set on linux-rdma [1] last month, 
and it would also suffer from this scenario, but it's not upstream yet.
> The issue i see is with user that want to/or might sleep when they are
> invalidation the secondary page table. The issue being that change_pte is
> call with the cpu page table locked (well at least for the affected pmd).
>
> I would rather keep the invalidate_range_start/end bracket around change_pte
> and invalidate page. I think we can fix the kvm regression by other means.
Perhaps another possibility would be to do the 
invalidate_range_start/end bracket only when the mmu_notifier is missing 
a change_pte implementation.

Best regards,
Haggai

[1] http://www.spinics.net/lists/linux-rdma/msg18906.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
