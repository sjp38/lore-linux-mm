Message-ID: <3D3F9103.FFC79916@zip.com.au>
Date: Wed, 24 Jul 2002 22:47:47 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page_add/remove_rmap costs
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com> <3D3F893D.4074CDE5@zip.com.au> <20020725051552.GA48429@compsoc.man.ac.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Levon <levon@movementarian.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

John Levon wrote:
> 
> On Wed, Jul 24, 2002 at 10:14:37PM -0700, Andrew Morton wrote:
> 
> > > c0135667 1095488  16.8865     .text.lock.page_alloc   /boot/vmlinux-2.5.28-3
> >
> > zone->lock?
> 
> I wrote a patch some time ago to remove all this guesswork on lock call
> sites :
> 

Me too, but I just killed all the out-of-line gunk, so the cost
is shown at the actual callsite.


--- 2.5.24/include/asm-i386/spinlock.h~spinlock-inline	Fri Jun 21 13:12:01 2002
+++ 2.5.24-akpm/include/asm-i386/spinlock.h	Fri Jun 21 13:18:12 2002
@@ -46,13 +46,13 @@ typedef struct {
 	"\n1:\t" \
 	"lock ; decb %0\n\t" \
 	"js 2f\n" \
-	LOCK_SECTION_START("") \
+	"jmp 3f\n" \
 	"2:\t" \
 	"cmpb $0,%0\n\t" \
 	"rep;nop\n\t" \
 	"jle 2b\n\t" \
 	"jmp 1b\n" \
-	LOCK_SECTION_END
+	"3:\t" \
 
 /*
  * This works. Despite all the confusion.
--- 2.5.24/include/asm-i386/rwlock.h~spinlock-inline	Fri Jun 21 13:18:33 2002
+++ 2.5.24-akpm/include/asm-i386/rwlock.h	Fri Jun 21 13:22:09 2002
@@ -22,25 +22,19 @@
 
 #define __build_read_lock_ptr(rw, helper)   \
 	asm volatile(LOCK "subl $1,(%0)\n\t" \
-		     "js 2f\n" \
-		     "1:\n" \
-		     LOCK_SECTION_START("") \
-		     "2:\tcall " helper "\n\t" \
-		     "jmp 1b\n" \
-		     LOCK_SECTION_END \
+		     "jns 1f\n\t" \
+		     "call " helper "\n\t" \
+		     "1:\t" \
 		     ::"a" (rw) : "memory")
 
 #define __build_read_lock_const(rw, helper)   \
 	asm volatile(LOCK "subl $1,%0\n\t" \
-		     "js 2f\n" \
-		     "1:\n" \
-		     LOCK_SECTION_START("") \
-		     "2:\tpushl %%eax\n\t" \
+		     "jns 1f\n\t" \
+		     "pushl %%eax\n\t" \
 		     "leal %0,%%eax\n\t" \
 		     "call " helper "\n\t" \
 		     "popl %%eax\n\t" \
-		     "jmp 1b\n" \
-		     LOCK_SECTION_END \
+		     "1:\t" \
 		     :"=m" (*(volatile int *)rw) : : "memory")
 
 #define __build_read_lock(rw, helper)	do { \
@@ -52,25 +46,19 @@
 
 #define __build_write_lock_ptr(rw, helper) \
 	asm volatile(LOCK "subl $" RW_LOCK_BIAS_STR ",(%0)\n\t" \
-		     "jnz 2f\n" \
+		     "jz 1f\n\t" \
+		     "call " helper "\n\t" \
 		     "1:\n" \
-		     LOCK_SECTION_START("") \
-		     "2:\tcall " helper "\n\t" \
-		     "jmp 1b\n" \
-		     LOCK_SECTION_END \
 		     ::"a" (rw) : "memory")
 
 #define __build_write_lock_const(rw, helper) \
 	asm volatile(LOCK "subl $" RW_LOCK_BIAS_STR ",%0\n\t" \
-		     "jnz 2f\n" \
-		     "1:\n" \
-		     LOCK_SECTION_START("") \
-		     "2:\tpushl %%eax\n\t" \
+		     "jz 1f\n\t" \
+		     "pushl %%eax\n\t" \
 		     "leal %0,%%eax\n\t" \
 		     "call " helper "\n\t" \
 		     "popl %%eax\n\t" \
-		     "jmp 1b\n" \
-		     LOCK_SECTION_END \
+		     "1:\n" \
 		     :"=m" (*(volatile int *)rw) : : "memory")
 
 #define __build_write_lock(rw, helper)	do { \

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
