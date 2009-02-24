Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E8C4A6B00AE
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 08:00:35 -0500 (EST)
From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: Banning checkpoint (was: Re: What can OpenVZ do?)
Reply-To: 7eggert@gmx.de
Date: Tue, 24 Feb 2009 14:00:27 +0100
References: <c6GC9-3l7-11@gated-at.bofh.it> <c6GLN-3xO-31@gated-at.bofh.it> <c6IDT-6AZ-9@gated-at.bofh.it> <c6INu-6Ol-1@gated-at.bofh.it> <c6MR7-54s-3@gated-at.bofh.it> <c6ZbG-hF-13@gated-at.bofh.it> <c729F-5gF-21@gated-at.bofh.it> <c73S1-8dJ-19@gated-at.bofh.it> <c7mrC-4YD-3@gated-at.bofh.it> <c7mBk-5b2-23@gated-at.bofh.it> <c8Xp3-3TH-3@gated-at.bofh.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Message-Id: <E1Lbwtf-0001Zc-Uq@be1.7eggert.dyndns.org>
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>, Ingo Molnar <mingo@elte.hu>, Nathan Lynch <nathanl@austin.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Alexey Dobriyan <adobriyan@gmail.com> wrote:
> On Thu, Feb 19, 2009 at 11:11:54AM -0800, Dave Hansen wrote:
>> On Thu, 2009-02-19 at 22:06 +0300, Alexey Dobriyan wrote:

>> Alexey, I agree with you here.  I've been fighting myself internally
>> about these two somewhat opposing approaches.  Of *course* we can
>> determine the "checkpointability" at sys_checkpoint() time by checking
>> all the various bits of state.
>> 
>> The problem that I think Ingo is trying to address here is that doing it
>> then makes it hard to figure out _when_ you went wrong.  That's the
>> single most critical piece of finding out how to go address it.
>> 
>> I see where you are coming from.  Ingo's suggestion has the *huge*
>> downside that we've got to go muck with a lot of generic code and hook
>> into all the things we don't support.
>> 
>> I think what I posted is a decent compromise.  It gets you those
>> warnings at runtime and is a one-way trip for any given process.  But,
>> it does detect in certain cases (fork() and unshare(FILES)) when it is
>> safe to make the trip back to the "I'm checkpointable" state again.
> 
> "Checkpointable" is not even per-process property.
> 
> Imagine, set of SAs (struct xfrm_state) and SPDs (struct xfrm_policy).
> They are a) per-netns, b) persistent.
> 
> You can hook into socketcalls to mark process as uncheckpointable,
> but since SAs and SPDs are persistent, original process already exited.
> You're going to walk every process with same netns as SA adder and mark
> it as uncheckpointable. Definitely doable, but ugly, isn't it?
> 
> Same for iptable rules.
> 
> "Checkpointable" is container property, OK?

IMO: Everything around the process may change as long as you can do the same
using 'kill -STOP $PID; ...; kill -CONT $PID;'. E.g. changing iptables rules
can be done to a normal process, so this should not prevent checkpointing
(unless you checkpoint iptables, but don't do that then?).

BTW1: I might want to checkpoint something like seti@home. It will connect
to a server from time to time, and send/receive a packet. If having opened
a socket once in a lifetime would prevent checkpointing, this won't be
possible. I see the benefit of the one-way-flag forcing to make all
syscalls be checkpointable, but this won't work on sockets.

Therefore I think you need something inbetween. Some syscalls (etc.) are not
supported, so just make the process be uncheckpointable. But some syscalls
will enter and leave non-checkpointable states by design, they need at least
counters.

Maybe you'll want to let the application decide if it's OK to be checkpointed
on some conditions, too. The Seti client might know how to handle broken
connections, and doing duplicate transfers or skipping them is expected, too.
So the Seti client might declare the socket to be checkpointable, instead of
making the do-the-checkpoint application wait until it's closed.

BTW2: There is the problem of invalidating checkpoints, too. If a browser did
a HTTP PUT, you don't want to restore the checkpoint where it was just about
to start the PUT request. The application should be able to signal this to
a checkpointing daemon. There will be a race, so having a signal "Invalidate
checkpoints" won't work, but if the application sends a stable hash value,
the duplicate can be detected. (Off cause you'd say "don't do that then" for
browsers, but it's just an example. Off cause 2, the checkpoint daemon is
only needed for advanced setups, a simple "checkpoint $povray --store jobfile"
should just work.)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
