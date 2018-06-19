Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F16586B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 18:17:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o7-v6so345886pgc.23
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 15:17:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h23-v6sor232498pfn.51.2018.06.19.15.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 15:17:20 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
Date: Tue, 19 Jun 2018 15:17:16 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

at 4:34 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:

> When running some mmap/munmap scalability tests with large memory (i.e.
>> 300GB), the below hung task issue may happen occasionally.
> 
> INFO: task ps:14018 blocked for more than 120 seconds.
>       Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> message.
> ps              D    0 14018      1 0x00000004
> 
(snip)

> 
> Zapping pages is the most time consuming part, according to the
> suggestion from Michal Hock [1], zapping pages can be done with holding
> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
> mmap_sem to manipulate vmas.

Does munmap() == MADV_DONTNEED + munmap() ?

For example, what happens with userfaultfd in this case? Can you get an
extra #PF, which would be visible to userspace, before the munmap is
finished?

In addition, would it be ok for the user to potentially get a zeroed page in
the time window after the MADV_DONTNEED finished removing a PTE and before
the munmap() is done?

Regards,
Nadav
