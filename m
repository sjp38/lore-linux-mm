Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 595826B006E
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 16:01:07 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hi8so4872900wib.14
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:01:06 -0800 (PST)
Received: from mail-ea0-x22b.google.com (mail-ea0-x22b.google.com [2a00:1450:4013:c01::22b])
        by mx.google.com with ESMTPS id gg4si4335815wjc.150.2014.01.21.13.01.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 13:01:06 -0800 (PST)
Received: by mail-ea0-f171.google.com with SMTP id h10so4007091eak.16
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:01:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1390267468.3138.37.camel@schen9-DESK>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
	<1390267468.3138.37.camel@schen9-DESK>
Date: Tue, 21 Jan 2014 13:01:05 -0800
Message-ID: <CAGQ1y=6SDNen_w4AVdbmvwat5RjuDb7OCtb_aUQzfqwJU3fMDw@mail.gmail.com>
Subject: Re: [PATCH v8 3/6] MCS Lock: optimizations and extra comments
From: Jason Low <jason.low2@hp.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Jan 20, 2014 at 5:24 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> From: Jason Low <jason.low2@hp.com>

> @@ -41,8 +47,11 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>
>         prev = xchg(lock, node);
>         if (likely(prev == NULL)) {
> -               /* Lock acquired */
> -               node->locked = 1;
> +               /* Lock acquired, don't need to set node->locked to 1
> +                * as lock owner and other contenders won't check this value.
> +                * If a debug mode is needed to audit lock status, then
> +                * set node->locked value here.
> +                */

It would also be good to mention why the value is not checked
in this comment. Perhaps something like the following:

/*
 * Lock acquired, don't need to set node->locked to 1. Threads
 * only spin on its own node->locked value for lock acquisition.
 * However, since this thread can immediately acquire the lock
 * and does not proceed to spin on its own node->locked, this
 * value won't be used. If a debug mode is needed to
 * audit lock status, then set node->locked value here.
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
