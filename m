Date: Mon, 27 Dec 2004 14:48:38 -0800
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Prezeroing V2 [2/4]: add second parameter to clear_page() for
 all arches
Message-Id: <20041227144838.41d1597f.davem@davemloft.net>
In-Reply-To: <20041224090539.40bba423.davem@davemloft.net>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	<41C20E3E.3070209@yahoo.com.au>
	<Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
	<20041224090539.40bba423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: clameter@sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Dec 2004 09:05:39 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 23 Dec 2004 11:33:59 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Modification made but it would be good to have some feedback from the arch maintainers:
> > 
>  ...
> > sparc64
> 
> I don't see any sparc64 bits in this patch, else I'd
> review them :-)

So I found time to implement the missing sparc64 clear_page()
changes, here they are:

===== arch/sparc64/lib/clear_page.S 1.1 vs edited =====
--- 1.1/arch/sparc64/lib/clear_page.S	2004-08-08 19:54:07 -07:00
+++ edited/arch/sparc64/lib/clear_page.S	2004-12-24 08:53:29 -08:00
@@ -28,9 +28,12 @@
 	.text
 
 	.globl		_clear_page
-_clear_page:		/* %o0=dest */
+_clear_page:		/* %o0=dest, %o1=order */
+	sethi		%hi(PAGE_SIZE/64), %o2
+	clr		%o4
+	or		%o2, %lo(PAGE_SIZE/64), %o2
 	ba,pt		%xcc, clear_page_common
-	 clr		%o4
+	 sllx		%o2, %o1, %o1
 
 	/* This thing is pretty important, it shows up
 	 * on the profiles via do_anonymous_page().
@@ -69,16 +72,16 @@ clear_user_page:	/* %o0=dest, %o1=vaddr 
 	flush		%g6
 	wrpr		%o4, 0x0, %pstate
 
+	sethi		%hi(PAGE_SIZE/64), %o1
 	mov		1, %o4
+	or		%o1, %lo(PAGE_SIZE/64), %o1
 
 clear_page_common:
 	VISEntryHalf
 	membar		#StoreLoad | #StoreStore | #LoadStore
 	fzero		%f0
-	sethi		%hi(PAGE_SIZE/64), %o1
 	mov		%o0, %g1		! remember vaddr for tlbflush
 	fzero		%f2
-	or		%o1, %lo(PAGE_SIZE/64), %o1
 	faddd		%f0, %f2, %f4
 	fmuld		%f0, %f2, %f6
 	faddd		%f0, %f2, %f8
===== include/asm-sparc64/page.h 1.19 vs edited =====
--- 1.19/include/asm-sparc64/page.h	2004-07-27 12:54:49 -07:00
+++ edited/include/asm-sparc64/page.h	2004-12-24 08:52:17 -08:00
@@ -14,8 +14,8 @@
 
 #ifndef __ASSEMBLY__
 
-extern void _clear_page(void *page);
-#define clear_page(X)	_clear_page((void *)(X))
+extern void _clear_page(void *page, unsigned long order);
+#define clear_page(X,Y)	_clear_page((void *)(X),(Y))
 struct page;
 extern void clear_user_page(void *addr, unsigned long vaddr, struct page *page);
 #define copy_page(X,Y)	memcpy((void *)(X), (void *)(Y), PAGE_SIZE)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
