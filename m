Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 109366B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:23:55 -0500 (EST)
Received: by iofh3 with SMTP id h3so32628719iof.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:23:54 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id nu1si168249igb.0.2015.11.24.12.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 12:23:54 -0800 (PST)
Received: by igcto18 with SMTP id to18so22712599igc.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:23:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151123225823.GI19072@mtj.duckdns.org>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
	<1447853127-3461-10-git-send-email-pmladek@suse.com>
	<20151123225823.GI19072@mtj.duckdns.org>
Date: Tue, 24 Nov 2015 12:23:53 -0800
Message-ID: <CA+55aFyW=hp-myZGcL+5r2x+fUbpBJLmxDY66QB5VQj-nNsCxQ@mail.gmail.com>
Subject: Re: [PATCH v3 09/22] kthread: Allow to cancel kthread work
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Nov 23, 2015 at 2:58 PM, Tejun Heo <tj@kernel.org> wrote:
>
> And the timer can do (ignoring the multiple worker support, do we even
> need that?)
>
>         while (!trylock(worker)) {
>                 if (work->canceling)
>                         return;
>                 cpu_relax();
>         }

No no no!

People, you need to learn that code like the above is *not*
acceptable. It's busy-looping on a spinlock, and constantly trying to
*write* to the spinlock.

It will literally crater performance on a multi-socket SMP system if
it ever triggers. We're talking 10x slowdowns, and absolutely
unacceptable cache coherency traffic.

These kinds of loops absolutely *have* to have the read-only part. The
"cpu_relax()" above needs to be a loop that just tests the lock state
by *reading* it, so the cpu_relax() needs to be replaced with
something like

        while (spin_is_locked(lock)) cpu_relax();

instead (possibly just "spin_unlock_wait()" - but the explicit loop
might be worth it if you then want to check the "canceling" flag
independently of the lock state too).

In general, it's very dangerous to try to cook up your own locking
rules. People *always* get it wrong.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
