Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 035D66B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 14:09:17 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 96so76782081uaq.7
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:09:16 -0800 (PST)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id q195si3383759vke.77.2017.02.13.11.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 11:09:16 -0800 (PST)
Received: by mail-vk0-x22b.google.com with SMTP id r136so66931734vke.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:09:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170213175750.GJ6500@twins.programming.kicks-ass.net>
References: <20170209235103.GA1368@linux.vnet.ibm.com> <20170213122115.GO6515@twins.programming.kicks-ass.net>
 <20170213170104.GC30506@linux.vnet.ibm.com> <20170213175750.GJ6500@twins.programming.kicks-ass.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 13 Feb 2017 11:08:55 -0800
Message-ID: <CALCETrXwUeaRbDziA=7vgY3_r9u3E2wLLRwAU=GEiNhYq9jJwg@mail.gmail.com>
Subject: Re: [PATCH RFC v2 tip/core/rcu] Maintain special bits at bottom of
 ->dynticks counter
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Ingo Molnar <mingo@kernel.org>

On Mon, Feb 13, 2017 at 9:57 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, Feb 13, 2017 at 09:01:04AM -0800, Paul E. McKenney wrote:
>> > I think I've asked this before, but why does this live in the guts of
>> > RCU?
>> >
>> > Should we lift this state tracking stuff out and make RCU and
>> > NOHZ(_FULL) users of it, or doesn't that make sense (reason)?
>>
>> The dyntick-idle stuff is pretty specific to RCU.  And what precisely
>> would be helped by moving it?
>
> Maybe untangle the inter-dependencies somewhat. It just seems a wee bit
> odd to have arch TLB invalidate depend on RCU implementation details
> like this.

This came out of a courtyard discussion at KS/LPC.  The idea is that
this optimzation requires an atomic op that could be shared with RCU
and that we probably care a lot more about this optimization on
kernels with context tracking enabled, so putting it in RCU has nice
performance properties.  Other than that, it doesn't make a huge
amount of sense.

Amusingly, Darwin appears to do something similar without an atomic
op, and I have no idea why that's safe.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
