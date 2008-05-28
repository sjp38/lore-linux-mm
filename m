Date: Wed, 28 May 2008 19:36:07 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] Re: bad pmd ffff810000207238(9090909090909090).
In-Reply-To: <483CBCDD.10401@lugmen.org.ar>
Message-ID: <Pine.LNX.4.64.0805281922530.7959@blonde.site>
References: <483CBCDD.10401@lugmen.org.ar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fede <fedux@lugmen.org.ar>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jan Engelhardt <jengelh@medozas.de>, Willy Tarreau <w@1wt.eu>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2008, Fede wrote:
> 
> Today I tried to start a firewalling script and failed due to an unrelated
> issue, but when I checked the log I saw this:
> 
> May 27 20:38:15 kaoz ip_tables: (C) 2000-2006 Netfilter Core Team
> May 27 20:38:28 kaoz Netfilter messages via NETLINK v0.30.
> May 27 20:38:28 kaoz nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> May 27 20:38:28 kaoz ctnetlink v0.93: registering with nfnetlink.
> May 27 20:38:28 kaoz ClusterIP Version 0.8 loaded successfully
> May 27 20:38:28 kaoz mm/memory.c:127: bad pmd
> ffff810000207238(9090909090909090).
> 
> I also found another post with a very similar issue. The other post had almost
> the same message (*mm*/*memory*.*c*:*127*: *bad* *pmd*
> ffff810000207808(9090909090909090).)
> 
> Does anyone know what is it?

Thanks a lot for re-reporting this: it was fun to work it out.
It's not a rootkit, it's harmless, but we ought to fix the noise.
Simple patch below, but let me explain more verbosely first.

What was really interesting in your report was that the address
is so close to that in OGAWA-San's report.  I had a look at that
page on my x86_64 boxes, and they have lots of 0x90s there too.
It's just some page alignment filler that x86_64 kernel startup
has missed cleaning up - patch below fixes that.  There's no
security aspect to it: the entries were already not-present,
they just generate this noise by triggering the pmd_bad test.

But why do you occasionally see those messages (I never have)?
I was puzzled awhile because those tests are usually for user
address space, but this is up in kernel address space: in the
modules area.  Ah, vmalloc.c uses them: it's almost coincidence,
but those user space tests do work on the vmalloc and modules
areas, though they'd fail on many other parts of the kernel
address space (because of pse and global and nx bits).

Those messages come just occasionally from unloading a module.
There's a years-old anomaly in vmalloc.c, that the allocation
routines add an empty guard page slot to the size, then the
freeing routines include that empty slot.  (I've always thought
the guard page should be private to vmalloc.c, consistently left
out of the public size; but that would need wider changes.)  When
it would occupy the first slot of a new page table, allocation won't
have assigned one, and freeing will then hit this "bad" pmd entry.

Hugh

[PATCH] x86: fix bad pmd ffff810000207xxx(9090909090909090)

OGAWA Hirofumi and Fede have reported rare pmd_ERROR messages:
mm/memory.c:127: bad pmd ffff810000207xxx(9090909090909090).

Initialization's cleanup_highmap was leaving alignment filler
behind in the pmd for MODULES_VADDR: when vmalloc's guard page
would occupy a new page table, it's not allocated, and then
module unload's vfree hits the bad 9090 pmd entry left over.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 arch/x86/mm/init_64.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.26-rc4/arch/x86/mm/init_64.c	2008-05-03 21:54:41.000000000 +0100
+++ linux/arch/x86/mm/init_64.c	2008-05-28 17:38:19.000000000 +0100
@@ -206,7 +206,7 @@ void __init cleanup_highmap(void)
 	pmd_t *last_pmd = pmd + PTRS_PER_PMD;
 
 	for (; pmd < last_pmd; pmd++, vaddr += PMD_SIZE) {
-		if (!pmd_present(*pmd))
+		if (pmd_none(*pmd))
 			continue;
 		if (vaddr < (unsigned long) _text || vaddr > end)
 			set_pmd(pmd, __pmd(0));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
