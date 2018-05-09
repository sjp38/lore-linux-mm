Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C74526B0597
	for <linux-mm@kvack.org>; Wed,  9 May 2018 18:35:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 70-v6so199880wmb.2
        for <linux-mm@kvack.org>; Wed, 09 May 2018 15:35:44 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y132si4248634wmy.27.2018.05.09.15.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 15:35:43 -0700 (PDT)
Date: Thu, 10 May 2018 00:35:40 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update()
 preemption BUG
Message-ID: <20180509223539.43aznhri72ephluc@linutronix.de>
References: <20180504104451.20278-1-bigeasy@linutronix.de>
 <513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
 <20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>

On 2018-05-08 16:02:57 [-0700], Andrew Morton wrote:
> On Mon, 7 May 2018 09:31:05 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > In any case I agree that the revert should be done immediately even
> > before fixing the underlying bug. The preempt_disable/enable doesn't
> > prevent the bug, it only prevents the debugging code from actually
> > reporting it! Note that it's debugging code (CONFIG_DEBUG_PREEMPT) that
> > production kernels most likely don't have enabled, so we are not even
> > helping them not crash (while allowing possible data corruption).
> 
> Grumble.
> 
> I don't see much benefit in emitting warnings into end-users' logs for
> bugs which we already know about.

not end-users (not to mention that neither Debian Stretch nor F28 has
preemption enabled in their kernels). And if so, they may provide
additional information for someone to fix the bug in the end. I wasn't
able to reproduce the bug but I don't have access to anything MIPSish
where I can boot my own kernels. At least two people were looking at the
code after I posted the revert and nobody spotted the bug.

> The only thing this buys us is that people will hassle us if we forget
> to fix the bug, and how pathetic is that?  I mean, we may as well put
> 
> 	printk("don't forget to fix the vmstat_update() bug!\n");

No that is different. That would be seen by everyone. The bug was only
reported by Steven J. Hill which did not respond since. This message
would also imply that we know how to fix the bug but didn't do it yet
which is not the case. We seen that something was wrong but have no idea
*how* it got there.

The preempt_disable() was added by the end of v4.16. The
smp_processor_id() in vmstat_update() was added in commit 7cc36bbddde5
("vmstat: on-demand vmstat workers V8") which was in v3.18-rc1. The
hotplug rework took place in v4.10-rc1. And it took (counting from the
hotplug rework) 6 kernel releases for someone to trigger that warning
_if_ this was related to the hotplug rework.

What we have *now* is way worse: We have a possible bug that triggered
the warning. As we see in report the code in question was _already_
invoked on the wrong CPU. The preempt_disable() just silences the
warning, hiding the real issue so nobody will do a thing about it since
it will be never reported again (in a kernel with preemption and debug
enabled).

> into start_kernel().

Sebastian
