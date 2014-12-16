Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 21A606B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 16:37:01 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so14714019pdj.14
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 13:37:00 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id oc17si2814358pdb.97.2014.12.16.13.36.58
        for <linux-mm@kvack.org>;
        Tue, 16 Dec 2014 13:36:59 -0800 (PST)
Message-ID: <5490A5F8.6050504@sr71.net>
Date: Tue, 16 Dec 2014 13:36:56 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: post-3.18 performance regression in TLB flushing code
Content-Type: multipart/mixed;
 boundary="------------020303010007070204050006"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Simek <monstr@monstr.eu>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------020303010007070204050006
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

I'm running the 'brk1' test from will-it-scale:

> https://github.com/antonblanchard/will-it-scale/blob/master/tests/brk1.c

on a 8-socket/160-thread system.  It's seeing about a 6% drop in
performance (263M -> 247M ops/sec at 80-threads) from this commit:

	commit fb7332a9fedfd62b1ba6530c86f39f0fa38afd49
	Author: Will Deacon <will.deacon@arm.com>
	Date:   Wed Oct 29 10:03:09 2014 +0000

	 mmu_gather: move minimal range calculations into generic code

tlb_finish_mmu() goes up about 9x in the profiles (~0.4%->3.6%) and
tlb_flush_mmu_free() takes about 3.1% of CPU time with the patch
applied, but does not show up at all on the commit before.

This isn't a major regression, but it is rather unfortunate for a patch
that is apparently a code cleanup.  It also _looks_ to show up even when
things are single-threaded, although I haven't looked at it in detail.

I suspect the tlb->need_flush logic was serving some role that the
modified code isn't capturing like in this hunk:

>  void tlb_flush_mmu(struct mmu_gather *tlb)
>  {
> -       if (!tlb->need_flush)
> -               return;
>         tlb_flush_mmu_tlbonly(tlb);
>         tlb_flush_mmu_free(tlb);
>  }

tlb_flush_mmu_tlbonly() has tlb->end check (which replaces the
->need_flush logic), but tlb_flush_mmu_free() does not.

If we add a !tlb->end (patch attached) to tlb_flush_mmu(), that gets us
back up to ~258M ops/sec, but that's still ~2% down from where we started.

--------------020303010007070204050006
Content-Type: text/x-patch;
 name="fix-old-need_flush-logic.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="fix-old-need_flush-logic.patch"



---

 b/mm/memory.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN mm/memory.c~fix-old-need_flush-logic mm/memory.c
--- a/mm/memory.c~fix-old-need_flush-logic	2014-12-16 13:24:27.338557014 -0800
+++ b/mm/memory.c	2014-12-16 13:24:50.412598019 -0800
@@ -258,6 +258,9 @@ static void tlb_flush_mmu_free(struct mm
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
 {
+	if (!tlb->end)
+		return;
+
 	tlb_flush_mmu_tlbonly(tlb);
 	tlb_flush_mmu_free(tlb);
 }
_

--------------020303010007070204050006--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
