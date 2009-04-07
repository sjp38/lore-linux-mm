Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EBD585F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:33:02 -0400 (EDT)
Date: Wed, 8 Apr 2009 00:35:45 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [10/16] POISON: Use bitmask/action code for try_to_unmap behaviour
Message-ID: <20090407223545.GC17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151007.71F3F1D046F@basil.firstfloor.org> <alpine.DEB.1.10.0904071714450.12192@qirst.com> <20090407215953.GA17934@one.firstfloor.org> <alpine.DEB.1.10.0904071802290.12192@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904071802290.12192@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Lee.Schermerhorn@hp.com, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 06:04:39PM -0400, Christoph Lameter wrote:
> On Tue, 7 Apr 2009, Andi Kleen wrote:
> 
> > > Ignoring MLOCK? This means we are violating POSIX which says that an
> > > MLOCKed page cannot be unmapped from a process?
> >
> > I'm sure if you can find sufficiently vague language in the document
> > to standards lawyer around that requirement @)
> >
> > The alternative would be to panic.
> 
> 
> If you unmmap a MLOCKed page then you may get memory corruption because
> f.e. the Infiniband layer is doing DMA to that page.

The page is not going away, it's poisoned in hardware and software 
and stays. There is currently no mechanism to unpoison pages without
rebooting.

DMA should actually cause a bus abort on the hardware level, 
at least for RMW.

I currently don't have a cancel mechanism for such kinds of mappings
though. It just does cancel_dirty_page(), but when IO is happening

In theory one could add a more forceful IO cancel mechanism using
special driver callbacks, but I'm not sure it's worth it. Normally the 
hardware should abort on hitting poison (although some might do strange things)
and you'll get some more (recoverable) machine checks.

> > > How does that work for the poisoning case? We substitute a fresh page?
> >
> > It depends on the state of the page. If it was a clean disk mapped
> > page yes (it's just invalidated and can be reloaded). If it's a dirty anon
> > page the process is normally killed first (with advisory mode on) or only
> > killed when it hits the corrupted page. The process can also
> > catch the signal if it choses so. The late killing works with
> > a special entry similar to the migration case, but that results
> > in a special SIGBUS.
> 
> I think a process needs to be killed if any MLOCKed page gets corrupted
> because the OS cannot keep the POSIX guarantees.

That's the default behaviour with vm.memory_failure_early_kill = 1
However the process can catch the signal if it wants.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
