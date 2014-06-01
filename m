Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 32A516B0031
	for <linux-mm@kvack.org>; Sun,  1 Jun 2014 10:08:58 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id tp5so3511508ieb.11
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 07:08:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ip7si16033472igb.37.2014.06.01.07.08.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 01 Jun 2014 07:08:57 -0700 (PDT)
Message-ID: <538B33D5.8070002@oracle.com>
Date: Sun, 01 Jun 2014 10:08:21 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm,console: circular dependency between console_sem and zone
 lock
References: <536AE5DC.6070307@oracle.com> <20140512162811.GD3685@quack.suse.cz>
In-Reply-To: <20140512162811.GD3685@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 05/12/2014 12:28 PM, Jan Kara wrote:
> On Wed 07-05-14 22:03:08, Sasha Levin wrote:
>> > Hi all,
>> > 
>> > While fuzzing with trinity inside a KVM tools guest running the latest -next
>> > kernel I've stumbled on the following spew:
>   Thanks for report. So the problem seems to be maginally valid but I'm not
> 100% sure whom to blame :). So printk() code calls up() which calls
> try_to_wake_up() under console_sem.lock spinlock. That function can take
> rq->lock which is all expected.
> 
> The next part of the chain is that during CPU initialization we call
> __sched_fork() with rq->lock which calls into hrtimer_init() which can
> allocate memory which creates a dependency rq->lock => zone.lock.rlock.
> 
> And memory management code calls printk() which zone.lock.rlock held which
> closes the loop. Now I suspect the second link in the chain can happen only
> while CPU is booting and might even happen only if some debug options are
> enabled. But I don't really know scheduler code well enough. Steven?

I've cc'ed Peter and Ingo who may be able to answer that, as it still happens
on -next.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
