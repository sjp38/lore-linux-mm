Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF5D26B03AB
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:29:20 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id p66so20365058vkd.5
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 05:29:20 -0700 (PDT)
Received: from mail-vk0-x22e.google.com (mail-vk0-x22e.google.com. [2607:f8b0:400c:c05::22e])
        by mx.google.com with ESMTPS id b136si874376vkf.167.2017.03.30.05.29.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 05:29:19 -0700 (PDT)
Received: by mail-vk0-x22e.google.com with SMTP id d188so51695487vka.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 05:29:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170329141711.50c183a7bb1bfa75e24d4426@linux-foundation.org>
References: <1490821682-23228-1-git-send-email-mike.kravetz@oracle.com> <20170329141711.50c183a7bb1bfa75e24d4426@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 30 Mar 2017 14:28:58 +0200
Message-ID: <CACT4Y+bC_AfWkG3US3f1Bkm36S+1+U2dedyJyOGN77K5joK2ZA@mail.gmail.com>
Subject: Re: [PATCH RESEND] mm/hugetlb: Don't call region_abort if region_chg fails
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, Mar 29, 2017 at 11:17 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 29 Mar 2017 14:08:02 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> Resending because of typo in Andrew's e-mail when first sent
>>
>> Changes to hugetlbfs reservation maps is a two step process.  The first
>> step is a call to region_chg to determine what needs to be changed, and
>> prepare that change.  This should be followed by a call to call to
>> region_add to commit the change, or region_abort to abort the change.
>>
>> The error path in hugetlb_reserve_pages called region_abort after a
>> failed call to region_chg.  As a result, the adds_in_progress counter
>> in the reservation map is off by 1.  This is caught by a VM_BUG_ON
>> in resv_map_release when the reservation map is freed.
>>
>> syzkaller fuzzer found this bug, that resulted in the following:
>
> I'll change the above to
>
> : syzkaller fuzzer (when using an injected kmalloc failure) found this bug,
> : that resulted in the following:
>
> it's important, because this bug won't be triggered (at all easily, at
> least) in real-world workloads.

I wonder if memory-constrained cgroups make such bugs much easier to trigger.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
