Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id D68CB6B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 16:01:16 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id ks9so1232155vcb.40
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:01:16 -0800 (PST)
Received: from mail-ve0-x22b.google.com (mail-ve0-x22b.google.com [2607:f8b0:400c:c01::22b])
        by mx.google.com with ESMTPS id tj6si13195152vcb.43.2013.11.22.13.01.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 13:01:15 -0800 (PST)
Received: by mail-ve0-f171.google.com with SMTP id pa12so1347888veb.30
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:01:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131122203738.GC4138@linux.vnet.ibm.com>
References: <20131121225208.GJ4138@linux.vnet.ibm.com>
	<CA+55aFx3FSGAtdSTYmsZ8xtdpiSBM-XPSnxnMpRQY+S_v_72-g@mail.gmail.com>
	<20131122040856.GK4138@linux.vnet.ibm.com>
	<CA+55aFxSL96G_uuPSbJaXfGh7DpYZ1g0NcVfPKOFg1O0o0fyZg@mail.gmail.com>
	<20131122062314.GN4138@linux.vnet.ibm.com>
	<20131122151600.GA14988@gmail.com>
	<20131122184937.GX4138@linux.vnet.ibm.com>
	<CA+55aFyKKpf-i4pQ_dhy9gic74xtCbO+U8GXU6mCtQj1ZHy05A@mail.gmail.com>
	<20131122200620.GA4138@linux.vnet.ibm.com>
	<CA+55aFz0nP1_O8jO2UkX1DmDzcBm53-fFejvz=oY=x3cGNBJSQ@mail.gmail.com>
	<20131122203738.GC4138@linux.vnet.ibm.com>
Date: Fri, 22 Nov 2013 13:01:14 -0800
Message-ID: <CA+55aFwHUuaGzW_=xEWNcyVnHT-zW8-bs6Xi=M458xM3Y1qE0w@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 22, 2013 at 12:37 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Fri, Nov 22, 2013 at 12:09:31PM -0800, Linus Torvalds wrote:
>>
>> So? In order to get *into* that contention code, you will have to go
>> through the fast-case code. Which will contain a locked instruction.
>
> So you must also maintain ordering against the critical section that just
> ended on some other CPU.

But that's completely irrelevant to what you yourself have been saying
in this thread.

Your stated concern in this thread been whether the "unlock+lock"
sequence implies an ordering that is at least equivalent to a memory
barrier. And it clearly does, because the lock clearly contains a
memory barrier inside of it.

The fact that the locking sequence contains *other* things too is
irrelevant for that question. Those other things are at most relevant
then for *other* questions, ie from the standpoint of somebody wanting
to convince himself that the locking actually works as a lock, but
that wasn't what we were actually talking about earlier.

The x86 memory ordering doesn't follow the traditional theoretical
operations, no. Tough. It's generally superior than the alternatives
because of its somewhat unorthodox rules (in that it then makes the
many other common barriers generally be no-ops). If you try to
describe the x86 ops in terms of the theory, you will have pain. So
just don't do it. Think of them in the context of their own rules, not
somehow trying to translate them to non-x86 rules.

I think you can try to approximate the x86 rules as "every load is a
RCpc acquire, every store is a RCpc release", and then to make
yourself happier you can say that the lock sequence always starts out
with a serializing operation (which is obviously the actual locked
r-m-w op) so that on a lock/unlock level (as opposed to an individual
memory op level) you get the RCsc behavior of the acquire/releases not
re-ordering across separate locking events.

I'm not actually convinced that that is really a full and true
description of the x86 semantics, but it may _approximate_ being true
to the degree that you might translate it to some of the academic
papers that talk about these things.

(Side note: this is also true when the locked r-m-w instruction has
been replaced with a xbegin/xend. Intel documents that an RTM region
has the "same ordering semantics as a LOCK prefixed instruction": see
section 15.3.6 in the intel x86 architecture sw manual)

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
