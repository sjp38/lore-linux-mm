Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8A86B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 05:53:14 -0500 (EST)
Date: Fri, 13 Feb 2009 11:53:02 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: What can OpenVZ do?
Message-ID: <20090213105302.GC4608@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090212141014.2cd3d54d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> Now, we've gone in blind before - most notably on the
> containers/cgroups/namespaces stuff.  That hail mary pass worked out
> acceptably, I think.  Maybe we got lucky.  I thought that
> net-namespaces in particular would never get there, but it did.
> 
> That was a very large and quite long-term-important user-visible
> feature.
> 
> checkpoint/restart/migration is also a long-term-...-feature.  But if
> at all possible I do think that we should go into it with our eyes a
> little less shut.

IMO, s/.../important/

More important than containers in fact. Being able to detach all
software state from the hw state and being able to reattach it:

   1) at a later point in time,                   or
   2) in a different piece of hardware,           or
   3) [future] in a different kernel

... is powerful stuff on a very conceptual level IMO.

The only reason we dont have it in every OS is not because it's not
desired and not wanted, but because it's very, very hard to do it on
a wide scale. But people would love it even if it adds (some) overhead.

This kind of featureset is actually the main motivator for virtualization.

If the native kernel was able to do checkpointing we'd have not only
near-zero-cost virtualization done at the right abstraction level
(when combined with containers/control-groups), but we'd also have
a few future feature items like:

  1) Kernel upgrades done intelligently: transparent reboot into an
     upgraded kernel.

  2) Downgrade-on-regressions done sanely: transparent downgrade+reboot
     to a known-working kernel. (as long as the regression is app
     misbehavior or a performance problem - not a kernel crash. Most
     regressions on kernel upgrades are not actual crashes or data
     corruption but functional and performance regressions - i.e. it's
     safely checkpointable and downgradeable.)

  3) Hibernation done intelligently: checkpoint everything, turn off
     system. Turn on system, restore everything from the checkpoint.

  4) Backups done intelligently: full "backups" of long-running
     computational jobs, maybe even of complex things like databases
     or desktop sessions.

  5) Remote debugging done intelligently: got a crashed session?
     Checkpoint the whole app in its anomalous state and upload the
     image (as long as you can trust the developer with that image
     and with the filesystem state that goes with it).

I dont see many long-term dragons here. The kernel is obviously always
able to do near-zero-overhead checkpointing: it knows about all its
own data structures, can enumerate them and knows how they map to
user-space objects.

The rest is performance considerations: do we want to embedd
checkpointing helpers in certain runtime codepaths, to make
checkpointing faster? But if that is undesirable (serialization,
etc.), we can always fall back to the dumbest, zero-overhead methods.

There is _one_ interim runtime cost: the "can we checkpoint or not"
decision that the kernel has to make while the feature is not complete.

That, if this feature takes off, is just a short-term worry - as
basically everything will be checkpointable in the long run.

In any case, by designing checkpointing to reuse the existing LSM
callbacks, we'd hit multiple birds with the same stone. (One of
which is the constant complaints about the runtime costs of the LSM
callbacks - with checkpointing we get an independent, non-security
user of the facility which is a nice touch.)

So all things considered it does not look like a bad deal to me - but
i might be missing something nasty.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
