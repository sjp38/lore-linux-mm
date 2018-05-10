Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 428016B05BC
	for <linux-mm@kvack.org>; Thu, 10 May 2018 02:32:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z1-v6so661734pfh.3
        for <linux-mm@kvack.org>; Wed, 09 May 2018 23:32:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a36-v6si116339pla.73.2018.05.09.23.32.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 23:32:54 -0700 (PDT)
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update() preemption
 BUG
References: <20180504104451.20278-1-bigeasy@linutronix.de>
 <513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
 <20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org>
 <20180509223539.43aznhri72ephluc@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <524ecef9-e513-fec4-1178-ac1a87452e57@suse.cz>
Date: Thu, 10 May 2018 08:32:50 +0200
MIME-Version: 1.0
In-Reply-To: <20180509223539.43aznhri72ephluc@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>

On 05/10/2018 12:35 AM, Sebastian Andrzej Siewior wrote:
> On 2018-05-08 16:02:57 [-0700], Andrew Morton wrote:
>> On Mon, 7 May 2018 09:31:05 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>> In any case I agree that the revert should be done immediately even
>>> before fixing the underlying bug. The preempt_disable/enable doesn't
>>> prevent the bug, it only prevents the debugging code from actually
>>> reporting it! Note that it's debugging code (CONFIG_DEBUG_PREEMPT) that
>>> production kernels most likely don't have enabled, so we are not even
>>> helping them not crash (while allowing possible data corruption).
>>
>> Grumble.
>>
>> I don't see much benefit in emitting warnings into end-users' logs for
>> bugs which we already know about.
> 
> not end-users (not to mention that neither Debian Stretch nor F28 has
> preemption enabled in their kernels). And if so, they may provide
> additional information for someone to fix the bug in the end. I wasn't

Even if end-users have enabled preemption, they likely won't have
enabled CONFIG_DEBUG_PREEMPT anyway.

> able to reproduce the bug but I don't have access to anything MIPSish
> where I can boot my own kernels. At least two people were looking at the
> code after I posted the revert and nobody spotted the bug.
> 
>> The only thing this buys us is that people will hassle us if we forget
>> to fix the bug, and how pathetic is that?  I mean, we may as well put
>>
>> 	printk("don't forget to fix the vmstat_update() bug!\n");
> 
> No that is different. That would be seen by everyone. The bug was only
> reported by Steven J. Hill which did not respond since. This message
> would also imply that we know how to fix the bug but didn't do it yet
> which is not the case. We seen that something was wrong but have no idea
> *how* it got there.
> 
> The preempt_disable() was added by the end of v4.16. The
> smp_processor_id() in vmstat_update() was added in commit 7cc36bbddde5
> ("vmstat: on-demand vmstat workers V8") which was in v3.18-rc1. The
> hotplug rework took place in v4.10-rc1. And it took (counting from the
> hotplug rework) 6 kernel releases for someone to trigger that warning
> _if_ this was related to the hotplug rework.
> 
> What we have *now* is way worse: We have a possible bug that triggered
> the warning. As we see in report the code in question was _already_
> invoked on the wrong CPU. The preempt_disable() just silences the
> warning, hiding the real issue so nobody will do a thing about it since
> it will be never reported again (in a kernel with preemption and debug
> enabled).

Fully agree with everything you said!

We could extend the warning to e.g. print affinity mask of the thread,
and e.g. state of cpus that are subject to ongoing hotplug/hotremove.
But maybe it's not so useful in general, as the common case is likely
indeed a missing preempt_disable, and this is an exception? In any case,
I would hope that Steven applies some patch locally and we get more
details about what's going on at that MIPS machine.
