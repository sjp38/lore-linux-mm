Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id EBBDB6B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 18:40:19 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id x67so632116306ykd.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 15:40:19 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id i6si15945478ywb.86.2016.01.18.15.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 15:40:18 -0800 (PST)
Received: by mail-yk0-x22f.google.com with SMTP id x67so632115966ykd.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 15:40:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160118171328.GT6357@twins.programming.kicks-ass.net>
References: <20160118143345.GQ6357@twins.programming.kicks-ass.net>
	<1453130661-16573-1-git-send-email-gavin.guo@canonical.com>
	<20160118171328.GT6357@twins.programming.kicks-ass.net>
Date: Tue, 19 Jan 2016 07:40:18 +0800
Message-ID: <CA+eFSM1AUYLeGmmBgEzz8PCFMgsmCuztQpOSy3OiT1_3453ozg@mail.gmail.com>
Subject: Re: [PATCH V2] sched/numa: Fix use-after-free bug in the task_numa_compare
From: Gavin Guo <gavin.guo@canonical.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jay Vosburgh <jay.vosburgh@canonical.com>, Liang Chen <liang.chen@canonical.com>, mgorman@suse.de, mingo@redhat.com, riel@redhat.com

Hi Peter,

On Tue, Jan 19, 2016 at 1:13 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, Jan 18, 2016 at 11:24:21PM +0800, gavin.guo@canonical.com wrote:
>> From: Gavin Guo <gavin.guo@canonical.com>
>>
>> The following message can be observed on the Ubuntu v3.13.0-65 with KASan
>> backported:
>
> <snip>
>
>> As commit 1effd9f19324 ("sched/numa: Fix unsafe get_task_struct() in
>> task_numa_assign()") points out, the rcu_read_lock() cannot protect the
>> task_struct from being freed in the finish_task_switch(). And the bug
>> happens in the process of calculation of imp which requires the access of
>> p->numa_faults being freed in the following path:
>>
>> do_exit()
>>         current->flags |= PF_EXITING;
>>     release_task()
>>         ~~delayed_put_task_struct()~~
>>     schedule()
>>     ...
>>     ...
>> rq->curr = next;
>>     context_switch()
>>         finish_task_switch()
>>             put_task_struct()
>>                 __put_task_struct()
>>                   task_numa_free()
>>
>> The fix here to get_task_struct() early before end of dst_rq->lock to
>> protect the calculation process and also put_task_struct() in the
>> corresponding point if finally the dst_rq->curr somehow cannot be
>> assigned.
>>
>> v1->v2:
>> - Fix coding style suggested by Peter Zijlstra.
>>
>> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
>> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
>
> Argh, sorry for not noticing before; this SoB chain is not valid.
>
> Gavin wrote (per From) and send me the patch (per actual email headers),
> so Liang never touched it.
>
> Should that be a reviewed-by for him?

Liang is also the co-author of the original patch, we figured out the code
by parallel programming, part of the idea was came from him. If SoB is
not valid, can I change the line to the following?

Co-authored-by: Liang Chen <liangchen.linux@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
