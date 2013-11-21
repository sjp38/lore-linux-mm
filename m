Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 08A546B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:27:03 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id x55so411194wes.12
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:27:03 -0800 (PST)
Received: from mail-ee0-x22c.google.com (mail-ee0-x22c.google.com [2a00:1450:4013:c00::22c])
        by mx.google.com with ESMTPS id d6si1565021wic.19.2013.11.21.14.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 14:27:03 -0800 (PST)
Received: by mail-ee0-f44.google.com with SMTP id d51so164931eek.3
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:27:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131121045333.GO4138@linux.vnet.ibm.com>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
	<1384911463.11046.454.camel@schen9-DESK>
	<20131120153123.GF4138@linux.vnet.ibm.com>
	<20131120154643.GG19352@mudshark.cambridge.arm.com>
	<20131120171400.GI4138@linux.vnet.ibm.com>
	<1384973026.11046.465.camel@schen9-DESK>
	<20131120190616.GL4138@linux.vnet.ibm.com>
	<1384979767.11046.489.camel@schen9-DESK>
	<20131120214402.GM4138@linux.vnet.ibm.com>
	<1384991514.11046.504.camel@schen9-DESK>
	<20131121045333.GO4138@linux.vnet.ibm.com>
Date: Thu, 21 Nov 2013 14:27:01 -0800
Message-ID: <CA+55aFyXzDUss55SjQBy+C-neRZbVsmVRR4aat+wiWfuSQJxaQ@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 20, 2013 at 8:53 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> The other option is to weaken lock semantics so that unlock-lock no
> longer implies a full barrier, but I believe that we would regret taking
> that path.  (It would be OK by me, I would just add a few smp_mb()
> calls on various slowpaths in RCU.  But...)

Hmm. I *thought* we already did that, exactly because some
architecture already hit this issue, and we got rid of some of the
more subtle "this works because.."

No?

Anyway, isn't "unlock+lock" fundamentally guaranteed to be a memory
barrier? Anything before the unlock cannot possibly migrate down below
the unlock, and anything after the lock must not possibly migrate up
to before the lock? If either of those happens, then something has
migrated out of the critical region, which is against the whole point
of locking..

It's the "lock+unlock" where it's possible that something before the
lock might migrate *into* the critical region (ie after the lock), and
something after the unlock might similarly migrate to precede the
unlock, so you could end up having out-of-order accesses across a
lock/unlock sequence (that both happen "inside" the lock, but there is
no guaranteed ordering between the two accesses themselves).

Or am I confused? The one major reason for strong memory ordering is
that weak ordering is too f*cking easy to get wrong on a software
level, and even people who know about it will make mistakes.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
