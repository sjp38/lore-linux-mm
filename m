From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/14] readahead: enforce full readahead size on async mmap readahead
Date: Tue, 07 Apr 2009 19:50:52 +0800
Message-ID: <20090407115235.234027334@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8A0E95F000A
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:54 -0400 (EDT)
Content-Disposition: inline; filename=readahead-mmap-full-async-readahead-size.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

We need this in one perticular case and two more general ones.

Now we do async readahead for sequential mmap reads, and do it with the help of
PG_readahead. For normal reads, PG_readahead is the sufficient condition to do
a sequential readahead. But unfortunately, for mmap reads, there is a tiny nuisance:

[11736.998347] readahead-init0(process: sh/23926, file: sda1/w3m, offset=0:4503599627370495, ra=0+4-3) = 4
[11737.014985] readahead-around(process: w3m/23926, file: sda1/w3m, offset=0:0, ra=290+32-0) = 17
[11737.019488] readahead-around(process: w3m/23926, file: sda1/w3m, offset=0:0, ra=118+32-0) = 32
[11737.024921] readahead-interleaved(process: w3m/23926, file: sda1/w3m, offset=0:2, ra=4+6-6) = 6
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                                 ~~~~~~~~~~~~~
An unfavorably small readahead. The original dumb read-around size could be more efficient.

That happened because ld-linux.so does a read(832) in L1 before mmap(),
which triggers a 4-page readahead, with the second page tagged PG_readahead.

L0: open("/lib/libc.so.6", O_RDONLY)        = 3
L1: read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\342"..., 832) = 832
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L2: fstat(3, {st_mode=S_IFREG|0755, st_size=1420624, ...}) = 0
L3: mmap(NULL, 3527256, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fac6e51d000
L4: mprotect(0x7fac6e671000, 2097152, PROT_NONE) = 0
L5: mmap(0x7fac6e871000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x154000) = 0x7fac6e871000
L6: mmap(0x7fac6e876000, 16984, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fac6e876000
L7: close(3)                                = 0

In general, the PG_readahead flag will also be hit in cases
- sequential reads
- clustered random reads
A full readahead size is desirable in both cases.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -1584,7 +1584,8 @@ static void do_async_mmap_readahead(stru
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
 	if (PageReadahead(page))
-		page_cache_async_readahead(mapping, ra, file, page, offset, 1);
+		page_cache_async_readahead(mapping, ra, file,
+					   page, offset, ra->ra_pages);
 }
 
 /**

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
