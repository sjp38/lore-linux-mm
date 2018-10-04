Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49E0B6B000D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:05:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t8-v6so7710980plo.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:05:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21-v6sor3024251pgl.36.2018.10.04.01.05.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 01:05:11 -0700 (PDT)
Date: Thu, 4 Oct 2018 17:05:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181004080506.GB12879@jagdpanzerIV>
References: <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
 <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181004074442.GA12879@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: rostedt@goodmis.org, Petr Mladek <pmladek@suse.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (10/04/18 16:44), Sergey Senozhatsky wrote:
> So... Just an idea. Can you try a very dirty hack? Forcibly increase
> oops_in_progress in panic() before console_flush_on_panic(), so 8250
> serial8250_console_write() will use spin_trylock_irqsave() and maybe
> avoid deadlock.

E.g. something like below?
[this is not a patch; just a theory]:

---

diff --git a/kernel/panic.c b/kernel/panic.c
index 8b2e002d52eb..188338a55d1c 100644
--- a/kernel/panic.c
+++ b/kernel/panic.c
@@ -233,7 +233,13 @@ void panic(const char *fmt, ...)
 	if (_crash_kexec_post_notifiers)
 		__crash_kexec(NULL);
 
+	/*
+	 * Decrement oops_in_progress and let bust_spinlocks() to
+	 * unblank_screen(), console_unblank() and wake_up_klogd()
+	 */
 	bust_spinlocks(0);
+	/* Set oops_in_progress, so we can reenter serial console driver*/
+	bust_spinlocks(1);
 
 	/*
 	 * We may have ended up stopping the CPU holding the lock (in
