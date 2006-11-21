Date: Tue, 21 Nov 2006 14:57:23 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: build error: sparsemem + SLOB
In-Reply-To: <20061120183632.GD4797@waste.org>
References: <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com> <20061120183632.GD4797@waste.org>
Message-Id: <20061121143253.51B5.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

> On Mon, Nov 20, 2006 at 05:28:24PM +0000, Hugh Dickins wrote:
> > On Mon, 20 Nov 2006, Christoph Lameter wrote:
> > > 
> > > As far as I can tell SLOB is fundamentally racy since it does not support 
> > > SLAB_DESTROY_BY_RCU correctly. F.e. The constructor for the anon_vma will 
> > > be called on alloc without regard for RCU, we free an item and reuse it 
> > > without regard to RCU. This can potentially mess up the anon_vma locking 
> > > state while we access it.
> > 
> > Good find!
> > 
> > > Is SLOB used at all or have we been lucky so far?
> >
> > Lucky so far.  Well, we'd actually have to be quite unlucky to ever
> > see what page_lock_anon_vma/SLAB_DESTROY_BY_RCU are guarding against.
> >
> > But you're absolutely right that users should not be exposed to such
> > unsafety.  I'd say SLOB should be disallowed if SMP.
> 
> SLOB is an O(N) allocator and is pretty poorly suited to running on
> anything like a modern desktop. Disallowing if SMP is probably
> reasonable, as even machines with multicore ARM or MIPS will probably
> have enough memory to make SLOB a bit painful.

Ok. It's simple. This is fix.

----

This is to disallow to make SLOB with SMP or SPARSEMEM.
This avoids latent troubles of SLOB with SLAB_DESTROY_BY_RCU.
And fix compile error.

This patch is for 2.6.19-rc5-mm2.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

----
 init/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: 19-rc5-mm2/init/Kconfig
===================================================================
--- 19-rc5-mm2.orig/init/Kconfig	2006-11-21 13:41:31.000000000 +0900
+++ 19-rc5-mm2/init/Kconfig	2006-11-21 14:21:31.000000000 +0900
@@ -465,7 +465,7 @@ config SHMEM
 
 config SLAB
 	default y
-	bool "Use full SLAB allocator" if EMBEDDED
+	bool "Use full SLAB allocator" if (EMBEDDED && !SMP && !SPARSEMEM)
 	help
 	  Disabling this replaces the advanced SLAB allocator and
 	  kmalloc support with the drastically simpler SLOB allocator.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
