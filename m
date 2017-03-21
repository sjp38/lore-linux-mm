Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 044716B0333
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 17:17:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so94571343lfg.5
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:16:59 -0700 (PDT)
Received: from tartarus.angband.pl (tartarus.angband.pl. [2a03:9300:10::8])
        by mx.google.com with ESMTPS id y13si11946962lfd.355.2017.03.21.14.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 Mar 2017 14:16:58 -0700 (PDT)
Date: Tue, 21 Mar 2017 22:16:48 +0100
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Message-ID: <20170321211648.xcgwigbv37ktxofx@angband.pl>
References: <20170321174711.29880-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="7djm4lj6yhu65nrj"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170321174711.29880-1-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>


--7djm4lj6yhu65nrj
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Mar 21, 2017 at 08:47:11PM +0300, Dmitry Safonov wrote:
> After my changes to mmap(), its code now relies on the bitness of
> performing syscall. According to that, it chooses the base of allocation:
> mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall.
> It was done by:
>   commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
> 32-bit mmap()").
> 
> The code afterwards relies on in_compat_syscall() returning true for
> 32-bit syscalls. It's usually so while we're in context of application
> that does 32-bit syscalls. But during exec() it is not valid for x32 ELF.
> The reason is that the application hasn't yet done any syscall, so x32
> bit has not being set.
> That results in -ENOMEM for x32 ELF files as there fired BAD_ADDR()
> in elf_map(), that is called from do_execve()->load_elf_binary().
> For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag.
> 
> Set x32 bit before first return to userspace, during setting personality
> at exec(). This way we can rely on in_compat_syscall() during exec().
> Do also the reverse: drop x32 syscall bit at SET_PERSONALITY for 64-bits.
> 
> Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
> 32-bit mmap()")

Tested:
with bash:x32, mksh:amd64, posh:i386, zsh:armhf (binfmt:qemu), fork+exec
works for every parent-child combination.

Contrary to my naive initial reading of your fix, mixing syscalls from a
process of the wrong ABI also works as it did before.  While using a glibc
wrapper will call the right version, x32 processes calling amd64 syscalls is
surprisingly common -- this brings seccomp joy.

I've attached a freestanding test case for write() and mmap(); it's
freestanding asm as most of you don't have an x32 toolchain at hand, sorry
for unfriendly error messages.

So with these two patches:
x86/tls: Forcibly set the accessed bit in TLS segments
x86/mm: set x32 syscall bit in SET_PERSONALITY()
everything appears to be fine.

-- 
ac?aGBP'a  3/4 a >>ac?aGBP|a ? Meow!
aGBP 3/4 a ?ac a ?a ?aGBP?a!?
ac?a!?a ?a .a ?a ?a ? Collisions shmolisions, let's see them find a collision or second
a ?a 3aGBP?a ?a ?a ?a ? preimage for double rot13!

--7djm4lj6yhu65nrj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="meow.s"

.globl _start
.data
msg:	.ascii "Meow!\n"
badmsg:	.ascii "syscall failed\n"
.text
_start:
	# x32
	mov	$0x40000001, %rax	# syscall: write
	mov	$1, %rdi
	mov	$msg, %rsi
	mov	$6, %rdx
	syscall

	# amd64
	mov	$1, %rax		# syscall: write
	mov	$1, %rdi
	mov	$msg, %rsi
	mov	$6, %rdx
	syscall

	# i386
	mov	$4, %eax		# syscall: write
	mov	$1, %ebx
	mov	$msg, %ecx
	mov	$6, %edx
	int	$0x80


	# x32
	mov	$0x40000009, %rax	# syscall: mmap
	mov	$0, %rdi
	mov	$0x10000, %rsi
	mov	$3, %rdx	# PROT_READ|PROT_WRITE
	mov	$0x62, %r10	# MAP_PRIVATE|MAP_ANON|MAP_32BIT
	mov	$-1, %r8
	mov	$0, %r9
	syscall
	or	%rax, %rax
	js	badness

	# amd64
	mov	$0x9, %rax		# syscall: mmap
	mov	$0, %rdi
	mov	$0x10000, %rsi
	mov	$3, %rdx	# PROT_READ|PROT_WRITE
	mov	$0x62, %r10	# MAP_PRIVATE|MAP_ANON|MAP_32BIT
	mov	$-1, %r8
	mov	$0, %r9
	syscall
	or	%rax, %rax
	js	badness

	jmp goodbye	# m'kay, this one doesn't work, no regression
	# i386
	mov	$0x90, %eax		# syscall: mmap
	mov	$0, %ebx
	mov	$0x10000, %ecx
	mov	$3, %edx	# PROT_READ|PROT_WRITE
	mov	$0x62, %esi	# MAP_PRIVATE|MAP_ANON|MAP_32BIT
	mov	$-1, %edi
	mov	$0, %ebp
	int	$0x80
	movslq	%eax, %rax
	or	%rax, %rax
	js	badness

goodbye:
	mov	$0x4000003c, %rax	# syscall: _exit
	xor	%rdi, %rdi
	syscall

badness:
	# I'm too lazy to printf this as a number...
	push	%rax
	mov	$0x40000001, %rax	# syscall: write
	mov	$1, %rdi
	mov	$badmsg, %rsi
	mov	$15, %rdx
	syscall
	
	mov	$0x4000003c, %rax	# syscall: _exit
	pop	%rdi
	syscall

--7djm4lj6yhu65nrj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=Makefile

# Any of amd64/x32/i386 will do.
X86=x86_64-linux-gnu

all: meow-x32 meow-amd64
clean:
	rm -f meow-*

meow-x32: meow.s
	$(X86)-as --x32 $^ -o $@.o
	$(X86)-ld -melf32_x86_64 -s $@.o -o $@

meow-amd64: meow.s
	$(X86)-as --64 $^ -o $@.o
	$(X86)-ld -melf_x86_64 -s $@.o -o $@

--7djm4lj6yhu65nrj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
