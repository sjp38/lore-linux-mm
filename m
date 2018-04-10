Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7E936B0008
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:21:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o33-v6so9850786plb.16
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:21:31 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id e4si2388272pfb.204.2018.04.10.09.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 09:21:30 -0700 (PDT)
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180410090917.GZ21835@dhcp22.suse.cz> <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz> <20180410110242.GC2041@uranus.lan>
 <20180410111001.GD21835@dhcp22.suse.cz> <20180410122804.GD2041@uranus.lan>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <097488c7-ab18-367b-c435-7c26d149c619@linux.alibaba.com>
Date: Tue, 10 Apr 2018 09:21:19 -0700
MIME-Version: 1.0
In-Reply-To: <20180410122804.GD2041@uranus.lan>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/10/18 5:28 AM, Cyrill Gorcunov wrote:
> On Tue, Apr 10, 2018 at 01:10:01PM +0200, Michal Hocko wrote:
>>> Because do_brk does vma manipulations, for this reason it's
>>> running under down_write_killable(&mm->mmap_sem). Or you
>>> mean something else?
>> Yes, all we need the new lock for is to get a consistent view on brk
>> values. I am simply asking whether there is something fundamentally
>> wrong by doing the update inside the new lock while keeping the original
>> mmap_sem locking in the brk path. That would allow us to drop the
>> mmap_sem lock in the proc path when looking at brk values.
> Michal gimme some time. I guess  we might do so, but I need some
> spare time to take more precise look into the code, hopefully today
> evening. Also I've a suspicion that we've wracked check_data_rlimit
> with this new lock in prctl. Need to verify it again.

I see you guys points. We might be able to move the drop of mmap_sem 
before setting mm->brk in sys_brk since mmap_sem should be used to 
protect vma manipulation only, then protect the value modify with the 
new arg_lock. Then we can eliminate mmap_sem stuff in prctl path, and it 
also prevents from wrecking check_data_rlimit.

At the first glance, it looks feasible to me. Will look into deeper later.

Thanks,
Yang
