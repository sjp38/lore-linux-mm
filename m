Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD816B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 05:06:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so216814836pfz.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 02:06:30 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id h9si17202447pap.227.2016.05.06.02.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 02:06:29 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id bt5so45331225pac.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 02:06:29 -0700 (PDT)
Date: Fri, 6 May 2016 18:08:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160506090801.GA488@swordfish>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
 <20160505100329.GA497@swordfish>
 <20160506030935.GA18573@bbox>
 <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On (05/06/16 12:25), Ganesh Mahendran wrote:
[..]
> > I agree with Sergey.
> > First of al, I appreciates your patch, Ganesh! But as Sergey pointed
> > out, I don't see why it improves current zsmalloc.
> 
> This patch does not obviously improve zsmalloc.
> It just reduces unnecessary code path.
> 
> From data provided by Sergey, 15 * (4 -  1) = 45 times loop will be avoided.
> So 45 times of below caculation will be reduced:
> ---
> zspage_size = i * PAGE_SIZE;
> waste = zspage_size % class_size;
> usedpc = (zspage_size - waste) * 100 / zspage_size;
> 
> if (usedpc > max_usedpc) {
> ---

Hello,

I kinda believe we end up doing more work (instruction-count-wise),
actually. it adds 495 `cmp' for false case + 15 `cmp je' for true
case to eliminate 15 `mov cltd idiv mov sub imul cltd idiv cmp' *.

and it's not 45 iterations that we are getting rid of, but around 31:
not every class reaches it's ideal 100% ratio on the first iteration.
so, no, sorry, I don't think the patch really does what we want.



* by the way, we don't even need `cltd' in those calculations. the
reason why gcc puts cltd is because ZS_MAX_PAGES_PER_ZSPAGE has the
'wrong' data type. the patch to correct it is below (not a formal
patch).

** well, we force gcc to generate `worse' code in several more places.
for example, there is no need for `obj_idx' and `obj_offset' to be
`unsigned long', it can easly (and probably must) be `unsigned int',
or simply `int'. that can save some instructions in very-very hot paths:

add/remove: 0/0 grow/shrink: 1/6 up/down: 1/-27 (-26)
function                                     old     new   delta
obj_free                                     234     235      +1
obj_to_location                               45      44      -1
obj_malloc                                   234     233      -1
zs_malloc                                    817     815      -2
obj_idx_to_offset                             32      28      -4
zs_unmap_object                              556     551      -5
zs_compact                                  1611    1597     -14

I can cook a trivial patch later.

/*
 * on x86_64, gcc 6.1. no idea what does the picture look like on ARM32.
 * but smells like these two patches combined can make CPU a little less
 * busy.
 */

=====================================================================

ZS_MAX_PAGES_PER_ZSPAGE defined as 'unsigned long' which forces
the compiler to generate unneeded signed extension instructions
`cltd' in several places. for instance:

     711:       44 89 d0                mov    %r10d,%eax
     714:       99                      cltd
     715:       41 f7 fe                idiv   %r14d
     718:       44 89 d0                mov    %r10d,%eax
     71b:       29 d0                   sub    %edx,%eax
     71d:       6b c0 64                imul   $0x64,%eax,%eax
     720:       99                      cltd
     721:       41 f7 fa                idiv   %r10d

there is no reason to do this and ZS_MAX_PAGES_PER_ZSPAGE can
simply be 'int'.

the patch reduces the code size, a bit:

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-25 (-25)
function                                     old     new   delta
zs_malloc                                    842     817     -25

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f9b58d1..1c28e0f6 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -78,7 +78,7 @@
  * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
  */
 #define ZS_MAX_ZSPAGE_ORDER 2
-#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
+#define ZS_MAX_PAGES_PER_ZSPAGE (1 << ZS_MAX_ZSPAGE_ORDER)
 
 #define ZS_HANDLE_SIZE (sizeof(unsigned long))
 
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
