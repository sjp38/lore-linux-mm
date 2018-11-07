Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 895FB6B04FF
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 07:00:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id r20-v6so6239746eds.18
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 04:00:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d19si431757edx.427.2018.11.07.04.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 04:00:15 -0800 (PST)
Date: Wed, 7 Nov 2018 13:00:13 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181107120012.b5qynrwikjtqp2zx@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
 <8354d714f6b6489d9003d6e04ee10618@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8354d714f6b6489d9003d6e04ee10618@AcuMS.aculab.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Wed 2018-11-07 11:01:05, David Laight wrote:
> From: Tetsuo Handa
> > Sent: 07 November 2018 10:53
> A though:
> 
> Why not make the printf lock slightly 'sticky'?
> - If the output line is incomplete save the cpuid.
> - If there is a saved cpuid that doesn't match the current cpu then spin for a bit.
> 
> Any callers of printk() have to assume they will spin on the buffer for the
> longest printk formatting (and symbol lookup might take a while) so a short
> additional delay won't matter.

Disabling preemption for a single printk() is questionable. We have
spent many years trying to find an acceptable solution to avoid
softlockups and we did not fully succeeded.

And this patchset is about continuous lines. Therefore we would need
to disable preemption for all code intermixed with the related
printks. This does not have much chances to get accepted.


> Then two calls to printk() for the same line won't (usually) get split and
> none of the callers need any changes.

It would require changes to disable the preemption around the related
calls.

We could not do this without a better API and inspecting all users.
Note that we could not detect this by "\n" because it is too
error-prone.

Best Regards,
Petr
