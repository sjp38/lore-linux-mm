Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9797B6B00A1
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 12:36:48 -0400 (EDT)
Message-ID: <4A328444.3010301@zytor.com>
Date: Fri, 12 Jun 2009 09:37:24 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when	feature
 is disabled
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu> <alpine.LFD.2.01.0906120827020.3237@localhost.localdomain> <20090612153501.GA5737@elte.hu>
In-Reply-To: <20090612153501.GA5737@elte.hu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> So i think hwpoison simply does not affect our ability to get log 
> messages out - but it sure allows crappier hardware to be used.
> Am i wrong about that for some reason?
> 

Crappy hardware isn't the kind of hardware that is likely to have the
hwpoison features, just like crappy hardware generally doesn't even have
ECC -- or even basic parity checking (I personally think non-ECC memory
should be considered a crime against humanity in this day and age.)

You're making the fundamental assumption that failover and hardware
replacement is a relatively cheap and fast operation.  In high
reliability applications, of course, failover is always an option -- it
*HAS* to be an option -- but that doesn't mean that hardware replacement
is cheap, fast or even possible -- and now you've blown your failover
option.

These kinds of features are used when extremely high reliability is
required, think for example a telco core router.  A page error may have
happened due to stray radiation or through power supply glitches (which
happen even in the best of systems), but if they are a pattern, a box
needs to be replaced.  *How quickly* a box can be taken out of service
and replaced can vary greatly, and its urgency depend on patterns;
furthermore, in the meantime the device has to work the best it can.

Consider, for example, a control computer on the Hubble Space Telescope
-- the only way to replace it is by space shuttle, and you can safely
guarantee that *that* won't happen in a heartbeat.  On the new Herschel
Space Observatory, not even the space shuttle can help: if the computers
die, *or* if bad data gets fed to its control system, the spacecraft is
lost.  As such, it's of paramount importance for the computers to (a)
continue to provide service at the level the hardware is capable of
doing, (b) as accurately as possible continually assess and report that
level of service, and (c) not allow a failure to pass undetected.  A lot
of failures are simple one-time events (especially in space, a high-rad
environment), others reflect decaying hardware but can be isolated (e.g.
a RAM cell which has developed a short circuit, or a CPU core which has
a damaged ALU), while others yet reflect a general ill health of the
system that cannot be recovered.

What these kinds of features do is it gives the overall-system designers
and the administrators more options.

(Note: this is an hpa position statement, not necessarily an Intel one.)

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
