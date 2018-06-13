Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF0A36B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 09:21:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v134-v6so1664012oia.15
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 06:21:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d70-v6si965907oic.398.2018.06.13.06.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 06:21:00 -0700 (PDT)
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <20180525072636.GE11881@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
 <20180528081345.GD1517@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
 <20180531063212.GF15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com>
 <20180601074642.GW15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806042100200.71129@chino.kir.corp.google.com>
 <20180605085707.GV19202@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <56138495-fd91-62f8-464a-db9960bfeb28@i-love.sakura.ne.jp>
Date: Wed, 13 Jun 2018 22:20:49 +0900
MIME-Version: 1.0
In-Reply-To: <20180605085707.GV19202@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/06/05 17:57, Michal Hocko wrote:
>> For this reason, we see testing harnesses often oom killed immediately 
>> after running a unittest that stresses reclaim or compaction by inducing a 
>> system-wide oom condition.  The harness spawns the unittest which spawns 
>> an antagonist memory hog that is intended to be oom killed.  When memory 
>> is mlocked or there are a large number of threads faulting memory for the 
>> antagonist, the unittest and the harness itself get oom killed because the 
>> oom reaper sets MMF_OOM_SKIP; this ends up happening a lot on powerpc.  
>> The memory hog has mm->mmap_sem readers queued ahead of a writer that is 
>> doing mmap() so the oom reaper can't grab the sem quickly enough.
> 
> How come the writer doesn't back off. mmap paths should be taking an
> exclusive mmap sem in killable sleep so it should back off. Or is the
> holder of the lock deep inside mmap path doing something else and not
> backing out with the exclusive lock held?
> 
 
Here is an example where the writer doesn't back off.

  http://lkml.kernel.org/r/20180607150546.1c7db21f70221008e14b8bb8@linux-foundation.org

down_write_killable(&mm->mmap_sem) is nothing but increasing the possibility of
successfully back off. There is no guarantee that the owner of that exclusive
mmap sem will not be blocked by other unkillable waits.
