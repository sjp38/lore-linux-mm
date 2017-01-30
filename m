Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id B72EB6B026E
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:48:30 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id k127so189742891vke.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:48:30 -0800 (PST)
Received: from mail-ua0-x22d.google.com (mail-ua0-x22d.google.com. [2607:f8b0:400c:c08::22d])
        by mx.google.com with ESMTPS id j34si3888669uad.92.2017.01.30.07.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 07:48:29 -0800 (PST)
Received: by mail-ua0-x22d.google.com with SMTP id 96so252519636uaq.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:48:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 30 Jan 2017 16:48:08 +0100
Message-ID: <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Jan 29, 2017 at 6:22 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 29.1.2017 13:44, Dmitry Vyukov wrote:
>> Hello,
>>
>> I've got the following deadlock report while running syzkaller fuzzer
>> on f37208bc3c9c2f811460ef264909dfbc7f605a60:
>>
>> [ INFO: possible circular locking dependency detected ]
>> 4.10.0-rc5-next-20170125 #1 Not tainted
>> -------------------------------------------------------
>> syz-executor3/14255 is trying to acquire lock:
>>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff814271c7>]
>> get_online_cpus+0x37/0x90 kernel/cpu.c:239
>>
>> but task is already holding lock:
>>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
>> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
>>
>> which lock already depends on the new lock.
>
> I suspect the dependency comes from recent changes in drain_all_pages(). They
> were later redone (for other reasons, but nice to have another validation) in
> the mmots patch [1], which AFAICS is not yet in mmotm and thus linux-next. Could
> you try if it helps?

It happened only once on linux-next, so I can't verify the fix. But I
will watch out for other occurrences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
