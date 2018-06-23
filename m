Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 469C86B0010
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 21:01:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l2-v6so3961335pff.3
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:01:35 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id b24-v6si8418447pfl.223.2018.06.22.18.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 18:01:33 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
From: Yang Shi <yang.shi@linux.alibaba.com>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <c184031d-b1db-503e-1a32-7963b4bf3de0@linux.alibaba.com>
Message-ID: <94bdfcf0-68ea-404c-a60f-362f677884b6@linux.alibaba.com>
Date: Fri, 22 Jun 2018 18:01:08 -0700
MIME-Version: 1.0
In-Reply-To: <c184031d-b1db-503e-1a32-7963b4bf3de0@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Yes, this is true but I guess what Yang Shi meant was that an userspace
>> access racing with munmap is not well defined. You never know whether
>> you get your data, #PTF or SEGV because it depends on timing. The user
>> visible change might be that you lose content and get zero page instead
>> if you hit the race window while we are unmapping which was not possible
>> before. But whouldn't such an access pattern be buggy anyway? You need
>> some form of external synchronization AFAICS.
>>
>> But maybe some userspace depends on "getting right data or get SEGV"
>> semantic. If we have to preserve that then we can come up with a VM_DEAD
>> flag set before we tear it down and force the SEGV on the #PF path.
>> Something similar we already do for MMF_UNSTABLE.
>
> Set VM_DEAD with read mmap_sem held? It should be ok since this is the 
> only place to set this flag for this unique special case.

BTW, it looks the vm flags have used up in 32 bit. If we really need 
VM_DEAD, it should be for both 32-bit and 64-bit.

Any suggestion?

Thanks,
Yang

>
> Yang
>
>
