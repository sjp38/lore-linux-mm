Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 13F306B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 19:58:17 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id ru5so374925obc.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 16:58:17 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b188si1194688ite.101.2016.06.17.16.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 16:58:16 -0700 (PDT)
Subject: Re: kernel, mm: NULL deref in copy_process while OOMing
References: <57618763.5010201@oracle.com>
 <20160616093951.GD6836@dhcp22.suse.cz>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <57648E92.3070703@oracle.com>
Date: Fri, 17 Jun 2016 19:58:10 -0400
MIME-Version: 1.0
In-Reply-To: <20160616093951.GD6836@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/16/2016 05:39 AM, Michal Hocko wrote:
> On Wed 15-06-16 12:50:43, Sasha Levin wrote:
>> Hi all,
>>
>> I'm seeing the following NULL ptr deref in copy_process right after a bunch
>> of OOM killing activity on -next kernels:
>>
>> Out of memory (oom_kill_allocating_task): Kill process 3477 (trinity-c159) score 0 or sacrifice child
>> Killed process 3477 (trinity-c159) total-vm:3226820kB, anon-rss:36832kB, file-rss:1640kB, shmem-rss:444kB
>> oom_reaper: reaped process 3477 (trinity-c159), now anon-rss:0kB, file-rss:0kB, shmem-rss:444kB
>> Out of memory (oom_kill_allocating_task): Kill process 3450 (trinity-c156) score 0 or sacrifice child
>> Killed process 3450 (trinity-c156) total-vm:3769768kB, anon-rss:36832kB, file-rss:1652kB, shmem-rss:508kB
>> oom_reaper: reaped process 3450 (trinity-c156), now anon-rss:0kB, file-rss:0kB, shmem-rss:572kB
>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000150
>> IP: copy_process (./arch/x86/include/asm/atomic.h:103 kernel/fork.c:484 kernel/fork.c:964 kernel/fork.c:1018 kernel/fork.c:1484)
>> PGD 1ff944067 PUD 1ff929067 PMD 0
>> Oops: 0002 [#1] PREEMPT SMP KASAN
>> Modules linked in:
>> CPU: 18 PID: 8761 Comm: trinity-main Not tainted 4.7.0-rc3-sasha-02101-g1e1b9fa #3108
> 
> Is this a common parent of the oom killed children?

Yup, it's trying to spawn new ones while existing children are getting killed.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
