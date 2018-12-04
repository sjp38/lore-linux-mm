Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1CDB6B6F85
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 11:02:46 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id b18so10647715oii.1
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 08:02:46 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 96si7428378otq.153.2018.12.04.08.02.45
        for <linux-mm@kvack.org>;
        Tue, 04 Dec 2018 08:02:45 -0800 (PST)
Date: Tue, 4 Dec 2018 16:03:04 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Message-ID: <20181204160304.GB7195@arm.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
 <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, David Miller <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, ast@kernel.org, Daniel Borkmann <daniel@iogearbox.net>, jeyu@kernel.org, netdev@vger.kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, kristen@linux.intel.com, Dave Hansen <dave.hansen@intel.com>, deneen.t.dock@intel.com, Peter Zijlstra <peterz@infradead.org>

On Mon, Dec 03, 2018 at 05:43:11PM -0800, Nadav Amit wrote:
> > On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
> > 
> > Since vfree will lazily flush the TLB, but not lazily free the underlying pages,
> > it often leaves stale TLB entries to freed pages that could get re-used. This is
> > undesirable for cases where the memory being freed has special permissions such
> > as executable.
> 
> So I am trying to finish my patch-set for preventing transient W+X mappings
> from taking space, by handling kprobes & ftrace that I missed (thanks again for
> pointing it out).
> 
> But all of the sudden, I don’t understand why we have the problem that this
> (your) patch-set deals with at all. We already change the mappings to make
> the memory writable before freeing the memory, so why can’t we make it
> non-executable at the same time? Actually, why do we make the module memory,
> including its data executable before freeing it???

Yeah, this is really confusing, but I have a suspicion it's a combination
of the various different configurations and hysterical raisins. We can't
rely on module_alloc() allocating from the vmalloc area (see nios2) nor
can we rely on disable_ro_nx() being available at build time.

If we *could* rely on module allocations always using vmalloc(), then
we could pass in Rick's new flag and drop disable_ro_nx() altogether
afaict -- who cares about the memory attributes of a mapping that's about
to disappear anyway?

Is it just nios2 that does something different?

Will
