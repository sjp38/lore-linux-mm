Message-ID: <010a01c569fe$83899a10$0f01a8c0@max>
From: "Richard Purdie" <rpurdie@rpsys.net>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk> <008201c569c3$61b30ab0$0f01a8c0@max> <20050605124556.A23271@flint.arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Date: Sun, 5 Jun 2005 19:43:38 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrew Morton <akpm@osdl.org>, Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King:
>>     [PATCH] ARM: Move copy/clear user_page locking into implementation
>
> This one changes the way we do these operations on SA1100, but it got
> tested prior to submission on the Assabet which didn't show anything
> up.  However, if I had to pick one, it'd be this.

And testing confirms this patch is indeed at fault. Adding/removing the code 
below stabilises/destabilises the system (I'm defining instability as random 
segfaults, floating point errors, illegal instructions and alignment 
errors).

The test system is ARM PXA255 based (v5te core, preempt enabled) and its 
using copypage-xscale.S. I suspect the locking below is needed on the xscale 
for some reason.

Does that make sense and highlight a problem?

Richard


--- a/include/asm-arm/page.h
+++ b/include/asm-arm/page.h
@@ -114,19 +114,8 @@ extern void __cpu_copy_user_page(void *t
      unsigned long user);
 #endif

-#define clear_user_page(addr,vaddr,pg)   \
- do {      \
-  preempt_disable();   \
-  __cpu_clear_user_page(addr, vaddr); \
-  preempt_enable();   \
- } while (0)
-
-#define copy_user_page(to,from,vaddr,pg)  \
- do {      \
-  preempt_disable();   \
-  __cpu_copy_user_page(to, from, vaddr); \
-  preempt_enable();   \
- } while (0)
+#define clear_user_page(addr,vaddr,pg)  __cpu_clear_user_page(addr, vaddr)
+#define copy_user_page(to,from,vaddr,pg) __cpu_copy_user_page(to, from, 
vaddr)

 #define clear_page(page) memzero((void *)(page), PAGE_SIZE)
 extern void copy_page(void *to, const void *from); 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
