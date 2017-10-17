Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9C66B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:50:49 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 31so1037721qtz.20
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 00:50:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u83si551276wmu.6.2017.10.17.00.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 00:50:48 -0700 (PDT)
Date: Tue, 17 Oct 2017 09:50:04 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900:
 BUG:unable_to_handle_kernel
In-Reply-To: <20171017073326.GA23865@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.20.1710170948550.1932@nanos>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble> <20171011170120.7flnk6r77dords7a@treble> <20171017073326.GA23865@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Tue, 17 Oct 2017, Joonsoo Kim wrote:
> On Wed, Oct 11, 2017 at 12:01:20PM -0500, Josh Poimboeuf wrote:
> > > Looking at the panic, the code in slob_free() was:
> > > 
> > >    0:	e8 8d f7 ff ff       	callq  0xfffffffffffff792
> > >    5:	48 ff 05 c9 8c 91 02 	incq   0x2918cc9(%rip)        # 0x2918cd5
> > >    c:	85 c0                	test   %eax,%eax
> > >    e:	75 51                	jne    0x61
> > >   10:	49 0f bf c5          	movswq %r13w,%rax
> > >   14:	48 ff 05 c2 8c 91 02 	incq   0x2918cc2(%rip)        # 0x2918cdd
> > >   1b:	48 8d 3c 43          	lea    (%rbx,%rax,2),%rdi
> > >   1f:	48 39 ef             	cmp    %rbp,%rdi
> > >   22:	75 3d                	jne    0x61
> > >   24:	48 ff 05 ba 8c 91 02 	incq   0x2918cba(%rip)        # 0x2918ce5
> > >   2b:*	8b 6d 00             	mov    0x0(%rbp),%ebp		<-- trapping instruction
> > >   2e:	66 85 ed             	test   %bp,%bp
> > >   31:	7e 09                	jle    0x3c
> > >   33:	48 ff 05 b3 8c 91 02 	incq   0x2918cb3(%rip)        # 0x2918ced
> > >   3a:	eb 05                	jmp    0x41
> > >   3c:	bd                   	.byte 0xbd
> > >   3d:	01 00                	add    %eax,(%rax)
> > > 
> > > The slob_free() code tried to read four bytes at ffff88001c4afffe, and
> > > ended up reading past the page into a bad area.  I think the bad address
> > > (ffff88001c4afffe) was returned from slob_next() and it panicked trying
> > > to read s->units in slob_units().
> 
> Hello,
> 
> It looks like a compiler bug. The code of slob_units() try to read two
> bytes at ffff88001c4afffe. It's valid. But the compiler generates
> wrong code that try to read four bytes.
> 
> static slobidx_t slob_units(slob_t *s) 
> {
>   if (s->units > 0)
>     return s->units;
>   return 1;
> }
> 
> s->units is defined as two bytes in this setup.
> 
> Wrongly generated code for this part.
> 
> 'mov 0x0(%rbp), %ebp'
> 
> %ebp is four bytes.
> 
> I guess that this wrong four bytes read cross over the valid memory
> boundary and this issue happend.
> 
> Proper code (two bytes read) is generated if different version of gcc
> is used.

Which version fails to generate proper code and which versions work?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
