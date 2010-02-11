Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2726B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:20:48 -0500 (EST)
Date: Thu, 11 Feb 2010 18:20:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 15214] New: Oops at __rmqueue+0x51/0x2b3
Message-ID: <20100211182031.GA5707@csn.ul.ie>
References: <bug-15214-10286@http.bugzilla.kernel.org/> <20100208111852.a0ada2b4.akpm@linux-foundation.org> <20100209144537.GA5098@csn.ul.ie> <201002101217.34131.ajlill@ajlc.waterloo.on.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201002101217.34131.ajlill@ajlc.waterloo.on.ca>
Sender: owner-linux-mm@kvack.org
To: Tony Lill <ajlill@ajlc.waterloo.on.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 10, 2010 at 12:17:28PM -0500, Tony Lill wrote:
> On Tuesday 09 February 2010 09:45:38 Mel Gorman wrote:
> 
> > Tony, can you generate the .s files for me please?  
> 
> Here they are

Thanks Tony,

I made a diff of the assember generated for __rmqueue and move_freepages_block
and wrote up some notes below. The problem is that I cannot spot where the
bad assembler is or why it causes bad references. At least, I cannot see
what sequence of events have to happen for the BUG_ON check to be triggered.

(adds Linus to cc)

Linus, the background to this bug
(http://bugzilla.kernel.org/show_bug.cgi?id=15214) is bad memory references in
2.6.31.* and a BUG_ON being triggered in mm/page_alloc.c#move_freepages_block()
in 2.6.32* with no problems in 2.6.30.10. The BUG_ON "shouldn't" happen as
discussed in http://marc.info/?l=linux-mm&m=126536882627752&w=2 so a suggestion
was made that the compiler might be at fault. Using a newer compiler was
reported to work fine at http://marc.info/?l=linux-mm&m=126556778403048&w=2

broken compiler:  gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
working compiler: gcc (Debian 4.3.2-1.1) 4.3.2

Tony posted the assember files (KCFLAGS=-save-temps) from
the broken and working compilers which a copy of is available at
http://www.csn.ul.ie/~mel/postings/bug-20100211/ . Have you any suggestions
on what the best way to go about finding where the badly generated code
might be so a warning can be added for gcc 4.1?  My strongest suspicion is
that the problem is in the assembler that looks up the struct page from a
PFN in sparsemem but I'm failing to prove it.

--- bad/__rmqueue.s	2010-02-11 14:48:10.000000000 +0000
+++ good/__rmqueue.s	2010-02-11 14:48:46.000000000 +0000
@@ -1,278 +1,315 @@
 __rmqueue:
+.L163:
 	pushl	%ebp
 	movl	%esp, %ebp
 	pushl	%edi
 	pushl	%esi
 	pushl	%ebx

					# Looks like normal entry stuff for
					# __rmqueue. There are differences
					# in the stack usage between the
					# compilers
-	subl	$36, %esp
-	movl	%eax, -40(%ebp)
-	movl	%edx, -44(%ebp)
-	movl	%ecx, -48(%ebp)
-	jmp	.L265
-.L266:
-	movl	$3, -48(%ebp)
-.L265:
-	movl	-44(%ebp), %ebx
-	movl	-48(%ebp), %ecx
-	movl	-40(%ebp), %esi
-	imull	$44, %ebx, %eax
-	sall	$3, %ecx
-	leal	544(%eax,%esi), %edx
-	jmp	.L267

					# This looks like __rmqueue_smallest
					# Main loop. There are significant
					# differences in the compiled code but
					# I couldn't spot anything obviously
					# wrong
-.L268:
-	leal	12(%edx), %esi
-	leal	(%esi,%ecx), %eax
-	cmpl	%eax, (%eax)
-	je	.L269
-	movl	-48(%ebp), %edx
-	movl	(%esi,%edx,8), %eax
-	leal	-24(%eax), %ecx
-	movl	%ecx, -16(%ebp)
-	movl	(%eax), %ecx
-	movl	4(%eax), %edx
-	movl	%edx, 4(%ecx)
-	movl	%ecx, (%edx)
-	movl	$2097664, 4(%eax)
-	movl	$1048832, (%eax)
+	subl	$76, %esp
+	movl	%eax, -56(%ebp)
+	imull	$44, %edx, %eax
+	movl	%edx, -60(%ebp)
+	movl	%eax, -84(%ebp)
+.L188:
+	movl	%ecx, -28(%ebp)
+.L187:
+	movl	-28(%ebp), %edx
+	movl	-84(%ebp), %ecx
+	movl	-56(%ebp), %ebx
+	movl	-60(%ebp), %esi
+	sall	$3, %edx
+	leal	544(%edx,%ecx), %eax
+	leal	12(%ebx,%eax), %ecx
+	movl	%esi, -24(%ebp)
+	movl	%edx, -80(%ebp)
+	jmp	.L164
+.L171:
+	imull	$44, -24(%ebp), %edi
+	movl	-56(%ebp), %eax
+	movl	-80(%ebp), %ebx
+	movl	-56(%ebp), %esi
+	leal	544(%eax,%edi), %eax
+	movl	%eax, -64(%ebp)
+	addl	$12, %eax
+	movl	%eax, -48(%ebp)
+	movl	(%ecx), %eax
+	leal	544(%edi,%ebx), %edx
+	leal	12(%esi,%edx), %edx
+	addl	$44, %ecx
+	cmpl	%edx, %eax
+	je	.L165
+	movl	-28(%ebp), %ebx
+	sall	$3, %ebx
+	leal	(%ebx,%edi), %eax
+	movl	556(%esi,%eax), %ecx
+	leal	-24(%ecx), %esi
+	movl	24(%esi), %edx
+	movl	28(%esi), %eax
+	movl	%eax, 4(%edx)
+	movl	%edx, (%eax)
+	movl	$2097664, 28(%esi)
+	movl	$1048832, 24(%esi)
 #APP
-	btr $18,-24(%eax)
+# 127 "/misc/m1/kernel/linux-2.6.32.7/arch/x86/include/asm/bitops.h" 1
+	btr $18,-24(%ecx)
+# 0 "" 2
 #NO_APP

					# More of __rmqueue_smallest I
					# think it's roughly in the
					# following place in the code.
					# The main differences appear to
					# be in how registers are used
					# and the stack is laid out.
					# Again, I can't actually see
					# anything wrong as such

static inline
struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
                                                int migratetype)
{
....
               	rmv_page_order(page);
                area->nr_free--;
....
}

					# rmv_page_order() ?
-	movl	-16(%ebp), %eax
-	movb	%bl, %cl
-	movl	%ebx, %edi
-	movl	$0, 12(%eax)
					# area->nr_free--
-	decl	40(%esi)
-	movl	$1, -36(%ebp)
-	sall	%cl, -36(%ebp)
-	jmp	.L271
-.L272:
-	shrl	-36(%ebp)
-	movl	-16(%ebp), %ebx
-	movl	-36(%ebp), %eax
+	movl	$0, 12(%esi)
+	movl	-56(%ebp), %eax
+	decl	596(%eax,%edi)
+	movl	-64(%ebp), %edx
+	movl	-80(%ebp), %eax
+	movl	-24(%ebp), %edi
+	movl	$1, -52(%ebp)
+	movl	%ebx, -76(%ebp)
+	leal	-32(%edx,%eax), %eax
+	movl	%edi, %ecx
+	movl	%eax, -32(%ebp)
+	sall	%cl, -52(%ebp)
+	jmp	.L166
+.L169:
+	shrl	-52(%ebp)
+	movl	-52(%ebp), %eax
 	sall	$5, %eax
-	addl	%eax, %ebx
-	movl	-40(%ebp), %eax
+	leal	(%esi,%eax), %ebx
+	movl	-56(%ebp), %eax
 	movl	%ebx, %edx
 	call	bad_range
 	testl	%eax, %eax
-	je	.L273
+	je	.L167
 #APP
					# Think the following
					# means we are looking
					# in expand() which is
					# at line 665
+# 665 "/misc/m1/kernel/linux-2.6.32.7/mm/page_alloc.c" 1
 	1:	ud2
 .pushsection __bug_table,"a"
 2:	.long 1b, .LC0
 	.word 665, 0
 	.org 2b+12
 .popsection
+# 0 "" 2
 #NO_APP

-.L275:
-	jmp	.L275
-.L273:
-	movl	-48(%ebp), %edx
-	subl	$44, %esi
-	decl	%edi
-	leal	(%esi,%edx,8), %eax
-	movl	(%eax), %ecx
+.L168:
+	jmp	.L168
+.L167:
+	movl	-32(%ebp), %ecx
 	leal	24(%ebx), %edx
-	movl	%edx, 4(%ecx)
-	movl	%ecx, 24(%ebx)
-	movl	%eax, 4(%edx)
-	movl	%edx, (%eax)
-	incl	40(%esi)
+	decl	%edi
+	subl	$44, -48(%ebp)
+	movl	(%ecx), %eax
+	movl	%edx, 4(%eax)
+	movl	%eax, 24(%ebx)
+	movl	-48(%ebp), %eax
+	addl	-76(%ebp), %eax
+	movl	%edx, (%ecx)
+	movl	%eax, 28(%ebx)
+	movl	-48(%ebp), %eax
+	incl	40(%eax)
 	movl	%edi, 12(%ebx)
 #APP
+# 84 "/misc/m1/kernel/linux-2.6.32.7/arch/x86/include/asm/bitops.h" 1
 	bts $18,(%ebx)
+# 0 "" 2
 #NO_APP

				# Looks like more of expand. Think the
				# cmpl and jgs towards the end of this
				# section for the bad compiler are the
				# while (high > low) {}
				# part.
				#
-.L271:
-	cmpl	-44(%ebp), %edi
-	jg	.L272
-	jmp	.L316
-.L269:
-	incl	%ebx
-	addl	$44, %edx
-.L267:
-	cmpl	$10, %ebx
-	jbe	.L268
-	movl	$0, -16(%ebp)
-	jmp	.L310
-.L316:
-	cmpl	$0, -16(%ebp)
-	jne	.L278
-.L310:
-	cmpl	$3, -48(%ebp)
-	je	.L278
-	movl	$10, -32(%ebp)
-	jmp	.L280
-.L281:
-	movl	(%ecx), %ebx
-	cmpl	$3, %ebx
-	movl	%ebx, -20(%ebp)
-	je	.L282
-	imull	$44, -32(%ebp), %eax
-	movl	-40(%ebp), %esi
-	leal	556(%eax,%esi), %eax
-	movl	%eax, -28(%ebp)
-	leal	(%eax,%ebx,8), %eax
-	cmpl	%eax, (%eax)
-	je	.L282
-	movl	-32(%ebp), %eax
-	movl	-28(%ebp), %edx
-	movl	%eax, -24(%ebp)
-	movl	(%edx,%ebx,8), %esi
-	subl	$24, %esi
-	movl	%esi, -16(%ebp)
-	decl	40(%edx)
-	cmpl	$4, -32(%ebp)
-	jg	.L285
-	cmpl	$1, -48(%ebp)
-	je	.L285
+	subl	$44, %ecx
+	movl	%ecx, -32(%ebp)
+.L166:
+	cmpl	-60(%ebp), %edi
+	jg	.L169
+	jmp	.L202
+.L165:
+	incl	-24(%ebp)
+.L164:
+	cmpl	$10, -24(%ebp)
+	jbe	.L171
+	xorl	%esi, %esi
+	jmp	.L199
+.L202:
+	testl	%esi, %esi
+	jne	.L172
+.L199:
+	cmpl	$3, -28(%ebp)
+	je	.L172
+	movl	-28(%ebp), %eax
+	movl	$10, %edi
+	sall	$4, %eax
+	addl	$fallbacks, %eax
+	movl	%eax, -72(%ebp)
+	movl	-28(%ebp), %eax
+	sall	$4, %eax
+	addl	$fallbacks+16, %eax
+	movl	%eax, -88(%ebp)
+	jmp	.L173
+.L185:
+	movl	(%ecx), %edx
+	cmpl	$3, %edx
+	movl	%edx, -20(%ebp)
+	je	.L174
+	imull	$44, %edi, %edx
+	movl	-20(%ebp), %ebx
+	movl	-56(%ebp), %esi
+	leal	(%edx,%ebx,8), %eax
+	leal	544(%esi,%eax), %ebx
+	leal	556(%esi,%eax), %eax
+	cmpl	%eax, 12(%ebx)
+	je	.L174
+	movl	-56(%ebp), %eax
+	movl	%edi, -16(%ebp)
+	movl	12(%ebx), %ebx
+	decl	596(%eax,%edx)
+	cmpl	$4, %edi
+	leal	-24(%ebx), %esi
+	jg	.L175
+	cmpl	$1, -28(%ebp)
+	je	.L175
 	cmpl	$0, page_group_by_mobility_disabled


					# This is the section that
					# actually calls move_freepages_block
					# presumably with bad parameters in
					# the bad compiler
-	je	.L287
-.L285:
-	movl	-48(%ebp), %ecx
+	je	.L176
+.L175:
+	movl	-28(%ebp), %ecx
 	movl	%esi, %edx
-	movl	-40(%ebp), %eax
+	movl	-56(%ebp), %eax

<SNIP>

Cutting the rest of the differences from __rmqueue and seeing what
move_freepages_block looks like


--- bad/move_freepages_block.s	2010-02-11 16:36:15.000000000 +0000
+++ good/move_freepages_block.s	2010-02-11 16:36:49.000000000 +0000
@@ -1,18 +1,15 @@
-	.size	split_page, .-split_page
-	.type	move_freepages_block, @function
 move_freepages_block:
 	pushl	%ebp
 	movl	%esp, %ebp
 	pushl	%edi
-	movl	%edx, %edi
 	pushl	%esi
+	movl	%ecx, %esi
 	pushl	%ebx
+	movl	%edx, %ecx
 	subl	$16, %esp
 	movl	%eax, -24(%ebp)
-	movl	%ecx, -28(%ebp)
-	movl	%edx, %ecx
-	movl	-24(%ebp), %esi
 	movl	(%edx), %eax
+	movl	-24(%ebp), %edi
 	shrl	$25, %eax
 	sall	$4, %eax
 	movl	mem_section(%eax), %eax
@@ -21,23 +18,25 @@
 	sarl	$5, %ecx
 	andl	$-1024, %ecx
 	movl	%ecx, %eax
+	movl	%ecx, %ebx
 	shrl	$17, %eax
 	sall	$4, %eax

					# This is looking up the page in
					# the sparsemem section map.
					# While there are differences, I
					# don't see where it goes wrong
					# although this is the most
					# likely problem code
-	movl	mem_section(%eax), %ebx
-	movl	%ecx, %eax
-	sall	$5, %eax
-	andl	$-4, %ebx
-	addl	%eax, %ebx
-	movl	1264(%esi), %eax
+	movl	mem_section(%eax), %eax
+	sall	$5, %ebx
+	andl	$-4, %eax
+	leal	(%eax,%ebx), %ebx
+	movl	1264(%edi), %eax
+	movl	%edx, %edi
+	movl	-24(%ebp), %edx
 	cmpl	%eax, %ecx
 	cmovae	%ebx, %edi
 	addl	$1023, %ecx
-	addl	1268(%esi), %eax
+	addl	1268(%edx), %eax
 	movl	$0, -16(%ebp)
 	cmpl	%eax, %ecx
-	jae	.L218
-	leal	32736(%ebx), %eax
-	movl	%eax, -20(%ebp)
+	jae	.L20
+	leal	32736(%ebx), %ecx
+	movl	%ecx, -20(%ebp)
 	movl	(%edi), %edx
 	movl	32736(%ebx), %eax
 	shrl	$23, %edx
@@ -46,55 +45,61 @@
 	andl	$3, %eax
 	imull	$1280, %edx, %edx
 	imull	$1280, %eax, %eax
-	addl	$contig_page_data, %edx
-	addl	$contig_page_data, %eax
 	cmpl	%eax, %edx
-	je	.L235
+	jne	.L21
+	sall	$3, %esi
+	movl	$0, -16(%ebp)
+	movl	%esi, -28(%ebp)
+	jmp	.L27
+.L21:
 #APP
+# 775 "/misc/m1/kernel/linux-2.6.32.7/mm/page_alloc.c" 1
 	1:	ud2
 .pushsection __bug_table,"a"
 2:	.long 1b, .LC0
 	.word 775, 0
 	.org 2b+12
 .popsection
+# 0 "" 2
 #NO_APP
-.L222:
-	jmp	.L222
-.L223:
+.L23:
+	jmp	.L23
+.L25:
 	movl	(%edi), %eax
 	testl	$262144, %eax
-	jne	.L226
+	jne	.L24
 	addl	$32, %edi
-	jmp	.L235
-.L226:
-	leal	24(%edi), %ecx
+	jmp	.L27
+.L24:
+	movl	12(%edi), %ebx
+	leal	24(%edi), %esi
 	movl	24(%edi), %edx
-	movl	4(%ecx), %eax
-	movl	12(%edi), %esi
-	movl	%eax, 4(%edx)
+	movl	28(%edi), %eax
 	movl	%edx, (%eax)
-	imull	$44, %esi, %eax
+	movl	%eax, 4(%edx)
+	imull	$44, %ebx, %eax
 	movl	$1048832, 24(%edi)
-	movl	-28(%ebp), %edx
-	leal	544(%eax,%edx,8), %eax
-	addl	-24(%ebp), %eax
-	movl	12(%eax), %edx
-	leal	12(%eax), %ebx
-	movl	%ecx, 4(%edx)
+	movl	-24(%ebp), %edx
+	addl	-28(%ebp), %eax
+	leal	544(%edx,%eax), %ecx
+	movl	12(%ecx), %edx
 	movl	%edx, 24(%edi)
-	movl	%ebx, 4(%ecx)
-	movl	%ecx, 12(%eax)
-	movl	%esi, %ecx
+	movl	%esi, 4(%edx)
+	movl	-24(%ebp), %edx
+	movl	%esi, 12(%ecx)
+	movb	%bl, %cl
+	leal	556(%edx,%eax), %eax
+	movl	%eax, 28(%edi)
 	movl	$32, %eax
 	sall	%cl, %eax
 	addl	%eax, %edi
 	movl	$1, %eax
 	sall	%cl, %eax
 	addl	%eax, -16(%ebp)
-.L235:
+.L27:
 	cmpl	-20(%ebp), %edi
-	jbe	.L223
-.L218:
+	jbe	.L25
+.L20:
 	movl	-16(%ebp), %eax
 	addl	$16, %esp
 	popl	%ebx
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
