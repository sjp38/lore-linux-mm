Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9911E6B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:40:27 -0500 (EST)
Date: Wed, 14 Jan 2009 12:40:12 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090114155923.GC1616@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901141219140.26507@quilx.com>
References: <20090114090449.GE2942@wotan.suse.de>
 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
 <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
 <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
 <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de>
 <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
 <20090114155923.GC1616@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009, Nick Piggin wrote:

> Well if you would like to consider SLQB as a fix for SLUB, that's
> fine by me ;) Actually I guess it is a valid way to look at the problem:
> SLQB solves the OLTP regression, so the only question is "what is the
> downside of it?".

The downside is that it brings the SLAB stuff back that SLUB was
designed to avoid. Queue expiration. The use of timers to expire at
uncontrollable intervals for user space. Object dispersal
in the kernel address space. Memory policy handling in the slab
allocator. Even seems to include periodic moving of objects between
queues. The NUMA stuff is still a bit foggy to me since it seems to assume
a mapping between cpus and nodes. There are cpuless nodes as well as
memoryless cpus.

SLQB maybe a good cleanup for SLAB. Its good that it is based on the
cleaned up code in SLUB but the fundamental design is SLAB (or rather the
Solaris allocator from which we got the design for all the queuing stuff
in the first place). It preserves many of the drawbacks of that code.

If SLQB would replace SLAB then there would be a lot of shared code
(debugging for example). Having a generic slab allocator framework may
then be possible within which a variety of algorithms may be implemented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
