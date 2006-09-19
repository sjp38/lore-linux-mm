Date: Mon, 18 Sep 2006 17:31:34 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Get rid of zone_table V2
Message-Id: <20060918173134.d3850903.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
	<20060918132818.603196e2.akpm@osdl.org>
	<Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
	<20060918161528.9714c30c.akpm@osdl.org>
	<Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
	<20060918165808.c410d1d4.akpm@osdl.org>
	<Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006 17:14:20 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> i386 code for __inc_zone_page_state which does
> 
> void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
> {
>         __inc_zone_state(page_zone(page), item);
> }
> EXPORT_SYMBOL(__inc_zone_page_state);
> 
> objdump
> 
> 0000078f <__inc_zone_page_state>:
>  78f:   8b 00                   mov    (%eax),%eax
>  791:   c1 e8 19                shr    $0x19,%eax
>  794:   83 e0 01                and    $0x1,%eax
>  797:   69 c0 80 04 00 00       imul   $0x480,%eax,%eax
>  79d:   05 00 00 00 00          add    $0x0,%eax
>  7a2:   e9 50 fe ff ff          jmp    5f7 <__inc_zone_state>
> Disassembly of section .altinstr_replacement:
> 
> note no lookup anymore.

With the mm tree up to but not including get-rid-of-zone_table.patch:


.globl __inc_zone_page_state
	.type	__inc_zone_page_state, @function
__inc_zone_page_state:
.LFB669:
	.loc 1 259 0
.LVL183:
	pushl	%ebp	#
.LCFI113:
	movl	%esp, %ebp	#,
.LCFI114:
	.loc 1 260 0
	movl	8(%ebp), %eax	# page, page
	movl	12(%ebp), %edx	# item, item
	movl	(%eax), %eax	# <variable>.flags, <variable>.flags
	shrl	$30, %eax	#, <variable>.flags
	movl	zone_table(,%eax,4), %eax	# zone_table, tmp64
	call	__inc_zone_state	#
	.loc 1 261 0
	popl	%ebp	#
	ret

With the mm tree up to and including get-rid-of-zone_table.patch:

.globl __inc_zone_page_state
	.type	__inc_zone_page_state, @function
__inc_zone_page_state:
.LFB669:
	.loc 1 259 0
.LVL183:
	pushl	%ebp	#
.LCFI113:
	movl	%esp, %ebp	#,
.LCFI114:
	.loc 1 260 0
	movl	8(%ebp), %eax	# page, page
	movl	12(%ebp), %edx	# item, item
	movl	(%eax), %eax	# <variable>.flags, <variable>.flags
	shrl	$30, %eax	#, <variable>.flags
	leal	(%eax,%eax,2), %eax	#, tmp65
	leal	(%eax,%eax,8), %eax	#, tmp67
	sall	$5, %eax	#, tmp67
	addl	$contig_page_data, %eax	#, tmp69
	call	__inc_zone_state	#
	.loc 1 261 0
	popl	%ebp	#
	ret


Which is pretty much the same thing.  I assume your objdump was of
an unlinked .o file, so contig_page_data shows up as 0x0.

The code looks OK though.

It would be nice to be able to reclaim a few bits from page->flags - we're
awfully short on them.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
