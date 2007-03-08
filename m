From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Date: Thu, 8 Mar 2007 13:39:29 +0100
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070307092821.GB8609@wotan.suse.de> <20070307094420.GL18774@holomorphy.com>
In-Reply-To: <20070307094420.GL18774@holomorphy.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200703081339.30372.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 07 March 2007 10:44, Bill Irwin wrote:
> On Wed, Mar 07, 2007 at 10:28:21AM +0100, Nick Piggin wrote:
> > Depending on whether anyone wants it, and what features they want, we
> > could emulate the old syscall, and make a new restricted one which is
> > much less intrusive.
> > For example, if we can operate only on MAP_ANONYMOUS memory and specify
> > that nonlinear mappings effectively mlock the pages, then we can get
> > rid of all the objrmap and unmap_mapping_range handling, forget about
> > the writeout and msync problems...
>
> Anonymous-only would make it a doorstop for Oracle, since its entire
> motive for using it is to window into objects larger than user virtual
> address spaces (this likely also applies to UML, though they should
> really chime in to confirm).

We need it for shared file mappings (for tmpfs only).

Our scenario is:
RAM is implemented through a shared mapped file, kept on tmpfs (except by dumb 
users); various processes share an fd for this file (it's opened and 
immediately deleted).

We maintain page tables in x86 style, and TLB flush is implemented through 
mmap()/munmap()/mprotect().

Having a VMA per each 4K is not the intended VMA usage: for instance, the 
default /proc/sys/vm/max_map_count (64K) is saturated by a UML process with 
64K * 4K = 256M of resident memory.

> Restrictions to tmpfs and/or ramfs would 
> likely be liveable, though I suspect some things might want to do it to
> shm segments (I'll ask about that one).

> There's definitely no need for a 
> persistent backing store for the object to be remapped in Oracle's case,
> in any event. It's largely the in-core destination and source of IO, not
> something saved on-disk itself.
>
>
> -- wli

-- 
Inform me of my mistakes, so I can add them to my list!
Paolo Giarrusso, aka Blaisorblade
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
