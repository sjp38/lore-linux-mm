Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 564DE6B0062
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 10:20:30 -0500 (EST)
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 7E8E0E9EC9
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 16:20:28 +0100 (CET)
From: "Henrik Rydberg" <rydberg@euromail.se>
Date: Thu, 6 Dec 2012 16:22:34 +0100
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206152234.GA5309@polaris.bitmath.org>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121206144821.GC18547@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, mgorman@suse.de, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Jan,

> > http://bitmath.org/test/oops-3.7-rc8.jpg
> > 
> > It seems to have to do with page migration. I run with transparent
> > hugepages configured, just for the fun of it.
> > 
> > I am happy to test any suggestions.
>
> Adding linux-mm and Mel as an author of compaction in particular to CC...
>
> It seems that while traversing struct page structures, we entered into a new
> huge page (note that RBX is 0xffffea0001c00000 - just the beginning of
> a huge page) and oopsed on PageBuddy test (_mapcount is at offset 0x18 in
> struct page). It might be useful if you provide disassembly of
> isolate_freepages_block() function in your kernel so that we can guess more
> from other register contents...

I had to recreate the vmlinux file, but it seems be at the right address, so here we go:

ffffffff810a6d00 <isolate_freepages_block>:
ffffffff810a6d00:	48 b8 00 00 00 00 00 	movabs $0xffffea0000000000,%rax
ffffffff810a6d07:	ea ff ff 
ffffffff810a6d0a:	41 57                	push   %r15
ffffffff810a6d0c:	41 56                	push   %r14
ffffffff810a6d0e:	49 89 fe             	mov    %rdi,%r14
ffffffff810a6d11:	41 55                	push   %r13
ffffffff810a6d13:	49 89 d5             	mov    %rdx,%r13
ffffffff810a6d16:	41 54                	push   %r12
ffffffff810a6d18:	55                   	push   %rbp
ffffffff810a6d19:	53                   	push   %rbx
ffffffff810a6d1a:	48 89 f3             	mov    %rsi,%rbx
ffffffff810a6d1d:	48 c1 e3 06          	shl    $0x6,%rbx
ffffffff810a6d21:	48 83 ec 58          	sub    $0x58,%rsp
ffffffff810a6d25:	48 01 c3             	add    %rax,%rbx
ffffffff810a6d28:	48 39 f2             	cmp    %rsi,%rdx
ffffffff810a6d2b:	48 89 74 24 30       	mov    %rsi,0x30(%rsp)
ffffffff810a6d30:	44 88 44 24 3b       	mov    %r8b,0x3b(%rsp)
ffffffff810a6d35:	0f 86 15 02 00 00    	jbe    ffffffff810a6f50 <isolate_freepages_block+0x250>
ffffffff810a6d3b:	48 8d 47 58          	lea    0x58(%rdi),%rax
ffffffff810a6d3f:	31 d2                	xor    %edx,%edx
ffffffff810a6d41:	48 8b 6c 24 30       	mov    0x30(%rsp),%rbp
ffffffff810a6d46:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
ffffffff810a6d4b:	48 8d 47 40          	lea    0x40(%rdi),%rax
ffffffff810a6d4f:	49 89 dc             	mov    %rbx,%r12
ffffffff810a6d52:	c7 44 24 3c 00 00 00 	movl   $0x0,0x3c(%rsp)
ffffffff810a6d59:	00 
ffffffff810a6d5a:	49 89 ce             	mov    %rcx,%r14
ffffffff810a6d5d:	41 89 d7             	mov    %edx,%r15d
ffffffff810a6d60:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
ffffffff810a6d65:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
ffffffff810a6d6a:	eb 1c                	jmp    ffffffff810a6d88 <isolate_freepages_block+0x88>
ffffffff810a6d6c:	0f 1f 40 00          	nopl   0x0(%rax)
ffffffff810a6d70:	48 83 c5 01          	add    $0x1,%rbp
ffffffff810a6d74:	48 83 c3 40          	add    $0x40,%rbx
ffffffff810a6d78:	49 39 ed             	cmp    %rbp,%r13
ffffffff810a6d7b:	0f 86 cf 00 00 00    	jbe    ffffffff810a6e50 <isolate_freepages_block+0x150>
ffffffff810a6d81:	4d 85 e4             	test   %r12,%r12
ffffffff810a6d84:	4c 0f 44 e3          	cmove  %rbx,%r12
ffffffff810a6d88:	8b 43 18             	mov    0x18(%rbx),%eax
ffffffff810a6d8b:	83 f8 80             	cmp    $0xffffff80,%eax
ffffffff810a6d8e:	75 e0                	jne    ffffffff810a6d70 <isolate_freepages_block+0x70>
ffffffff810a6d90:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
ffffffff810a6d95:	48 8d 74 24 48       	lea    0x48(%rsp),%rsi
ffffffff810a6d9a:	41 0f b6 d7          	movzbl %r15b,%edx
ffffffff810a6d9e:	4c 8b 44 24 20       	mov    0x20(%rsp),%r8
ffffffff810a6da3:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
ffffffff810a6da8:	48 8b 40 50          	mov    0x50(%rax),%rax
ffffffff810a6dac:	48 89 c7             	mov    %rax,%rdi
ffffffff810a6daf:	48 83 c7 50          	add    $0x50,%rdi
ffffffff810a6db3:	e8 a8 fe ff ff       	callq  ffffffff810a6c60 <compact_checklock_irqsave.isra.13>
ffffffff810a6db8:	84 c0                	test   %al,%al
ffffffff810a6dba:	41 89 c7             	mov    %eax,%r15d
ffffffff810a6dbd:	0f 84 8d 00 00 00    	je     ffffffff810a6e50 <isolate_freepages_block+0x150>
ffffffff810a6dc3:	80 7c 24 3b 00       	cmpb   $0x0,0x3b(%rsp)
ffffffff810a6dc8:	0f 84 c2 00 00 00    	je     ffffffff810a6e90 <isolate_freepages_block+0x190>
ffffffff810a6dce:	8b 43 18             	mov    0x18(%rbx),%eax
ffffffff810a6dd1:	83 f8 80             	cmp    $0xffffff80,%eax
ffffffff810a6dd4:	75 9a                	jne    ffffffff810a6d70 <isolate_freepages_block+0x70>
ffffffff810a6dd6:	48 89 df             	mov    %rbx,%rdi
ffffffff810a6dd9:	e8 32 db fe ff       	callq  ffffffff81094910 <split_free_page>
ffffffff810a6dde:	85 c0                	test   %eax,%eax
ffffffff810a6de0:	0f 84 81 01 00 00    	je     ffffffff810a6f67 <isolate_freepages_block+0x267>
ffffffff810a6de6:	01 44 24 3c          	add    %eax,0x3c(%rsp)
ffffffff810a6dea:	83 f8 00             	cmp    $0x0,%eax
ffffffff810a6ded:	0f 8e 48 01 00 00    	jle    ffffffff810a6f3b <isolate_freepages_block+0x23b>
ffffffff810a6df3:	4d 8b 06             	mov    (%r14),%r8
ffffffff810a6df6:	48 89 d9             	mov    %rbx,%rcx
ffffffff810a6df9:	31 ff                	xor    %edi,%edi
ffffffff810a6dfb:	4c 8d 5b 20          	lea    0x20(%rbx),%r11
ffffffff810a6dff:	90                   	nop
ffffffff810a6e00:	48 8d 51 20          	lea    0x20(%rcx),%rdx
ffffffff810a6e04:	48 89 ce             	mov    %rcx,%rsi
ffffffff810a6e07:	83 c7 01             	add    $0x1,%edi
ffffffff810a6e0a:	48 29 de             	sub    %rbx,%rsi
ffffffff810a6e0d:	48 83 c1 40          	add    $0x40,%rcx
ffffffff810a6e11:	39 c7                	cmp    %eax,%edi
ffffffff810a6e13:	49 89 50 08          	mov    %rdx,0x8(%r8)
ffffffff810a6e17:	4e 89 04 1e          	mov    %r8,(%rsi,%r11,1)
ffffffff810a6e1b:	49 89 d0             	mov    %rdx,%r8
ffffffff810a6e1e:	4e 89 74 1e 08       	mov    %r14,0x8(%rsi,%r11,1)
ffffffff810a6e23:	49 89 16             	mov    %rdx,(%r14)
ffffffff810a6e26:	75 d8                	jne    ffffffff810a6e00 <isolate_freepages_block+0x100>
ffffffff810a6e28:	8d 48 ff             	lea    -0x1(%rax),%ecx
ffffffff810a6e2b:	48 98                	cltq   
ffffffff810a6e2d:	48 83 e8 01          	sub    $0x1,%rax
ffffffff810a6e31:	48 63 c9             	movslq %ecx,%rcx
ffffffff810a6e34:	48 01 cd             	add    %rcx,%rbp
ffffffff810a6e37:	48 c1 e0 06          	shl    $0x6,%rax
ffffffff810a6e3b:	48 01 c3             	add    %rax,%rbx
ffffffff810a6e3e:	48 83 c5 01          	add    $0x1,%rbp
ffffffff810a6e42:	48 83 c3 40          	add    $0x40,%rbx
ffffffff810a6e46:	49 39 ed             	cmp    %rbp,%r13
ffffffff810a6e49:	0f 87 32 ff ff ff    	ja     ffffffff810a6d81 <isolate_freepages_block+0x81>
ffffffff810a6e4f:	90                   	nop
ffffffff810a6e50:	4c 8b 74 24 18       	mov    0x18(%rsp),%r14
ffffffff810a6e55:	44 89 fa             	mov    %r15d,%edx
ffffffff810a6e58:	48 63 44 24 3c       	movslq 0x3c(%rsp),%rax
ffffffff810a6e5d:	80 7c 24 3b 00       	cmpb   $0x0,0x3b(%rsp)
ffffffff810a6e62:	74 11                	je     ffffffff810a6e75 <isolate_freepages_block+0x175>
ffffffff810a6e64:	4c 89 e9             	mov    %r13,%rcx
ffffffff810a6e67:	48 2b 4c 24 30       	sub    0x30(%rsp),%rcx
ffffffff810a6e6c:	48 39 c1             	cmp    %rax,%rcx
ffffffff810a6e6f:	0f 87 b7 00 00 00    	ja     ffffffff810a6f2c <isolate_freepages_block+0x22c>
ffffffff810a6e75:	84 d2                	test   %dl,%dl
ffffffff810a6e77:	75 31                	jne    ffffffff810a6eaa <isolate_freepages_block+0x1aa>
ffffffff810a6e79:	4c 39 ed             	cmp    %r13,%rbp
ffffffff810a6e7c:	74 4d                	je     ffffffff810a6ecb <isolate_freepages_block+0x1cb>
ffffffff810a6e7e:	48 83 c4 58          	add    $0x58,%rsp
ffffffff810a6e82:	5b                   	pop    %rbx
ffffffff810a6e83:	5d                   	pop    %rbp
ffffffff810a6e84:	41 5c                	pop    %r12
ffffffff810a6e86:	41 5d                	pop    %r13
ffffffff810a6e88:	41 5e                	pop    %r14
ffffffff810a6e8a:	41 5f                	pop    %r15
ffffffff810a6e8c:	c3                   	retq   
ffffffff810a6e8d:	0f 1f 00             	nopl   (%rax)
ffffffff810a6e90:	48 89 df             	mov    %rbx,%rdi
ffffffff810a6e93:	e8 78 fd ff ff       	callq  ffffffff810a6c10 <suitable_migration_target>
ffffffff810a6e98:	84 c0                	test   %al,%al
ffffffff810a6e9a:	0f 85 2e ff ff ff    	jne    ffffffff810a6dce <isolate_freepages_block+0xce>
ffffffff810a6ea0:	4c 8b 74 24 18       	mov    0x18(%rsp),%r14
ffffffff810a6ea5:	48 63 44 24 3c       	movslq 0x3c(%rsp),%rax
ffffffff810a6eaa:	49 8b 7e 50          	mov    0x50(%r14),%rdi
ffffffff810a6eae:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
ffffffff810a6eb3:	48 8b 74 24 48       	mov    0x48(%rsp),%rsi
ffffffff810a6eb8:	48 83 c7 50          	add    $0x50,%rdi
ffffffff810a6ebc:	e8 1f 14 60 00       	callq  ffffffff816a82e0 <_raw_spin_unlock_irqrestore>
ffffffff810a6ec1:	4c 39 ed             	cmp    %r13,%rbp
ffffffff810a6ec4:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
ffffffff810a6ec9:	75 b3                	jne    ffffffff810a6e7e <isolate_freepages_block+0x17e>
ffffffff810a6ecb:	4d 85 e4             	test   %r12,%r12
ffffffff810a6ece:	49 8b 5e 50          	mov    0x50(%r14),%rbx
ffffffff810a6ed2:	74 aa                	je     ffffffff810a6e7e <isolate_freepages_block+0x17e>
ffffffff810a6ed4:	8b 4c 24 3c          	mov    0x3c(%rsp),%ecx
ffffffff810a6ed8:	85 c9                	test   %ecx,%ecx
ffffffff810a6eda:	75 a2                	jne    ffffffff810a6e7e <isolate_freepages_block+0x17e>
ffffffff810a6edc:	b9 03 00 00 00       	mov    $0x3,%ecx
ffffffff810a6ee1:	ba 03 00 00 00       	mov    $0x3,%edx
ffffffff810a6ee6:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff810a6eeb:	4c 89 e7             	mov    %r12,%rdi
ffffffff810a6eee:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
ffffffff810a6ef3:	e8 18 d1 fe ff       	callq  ffffffff81094010 <set_pageblock_flags_group>
ffffffff810a6ef8:	41 80 7e 42 00       	cmpb   $0x0,0x42(%r14)
ffffffff810a6efd:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
ffffffff810a6f02:	0f 85 76 ff ff ff    	jne    ffffffff810a6e7e <isolate_freepages_block+0x17e>
ffffffff810a6f08:	48 ba 00 00 00 00 00 	movabs $0x160000000000,%rdx
ffffffff810a6f0f:	16 00 00 
ffffffff810a6f12:	49 01 d4             	add    %rdx,%r12
ffffffff810a6f15:	49 c1 fc 06          	sar    $0x6,%r12
ffffffff810a6f19:	4c 3b 63 60          	cmp    0x60(%rbx),%r12
ffffffff810a6f1d:	0f 83 5b ff ff ff    	jae    ffffffff810a6e7e <isolate_freepages_block+0x17e>
ffffffff810a6f23:	4c 89 63 60          	mov    %r12,0x60(%rbx)
ffffffff810a6f27:	e9 52 ff ff ff       	jmpq   ffffffff810a6e7e <isolate_freepages_block+0x17e>
ffffffff810a6f2c:	31 c0                	xor    %eax,%eax
ffffffff810a6f2e:	c7 44 24 3c 00 00 00 	movl   $0x0,0x3c(%rsp)
ffffffff810a6f35:	00 
ffffffff810a6f36:	e9 3a ff ff ff       	jmpq   ffffffff810a6e75 <isolate_freepages_block+0x175>
ffffffff810a6f3b:	0f 84 2f fe ff ff    	je     ffffffff810a6d70 <isolate_freepages_block+0x70>
ffffffff810a6f41:	e9 e2 fe ff ff       	jmpq   ffffffff810a6e28 <isolate_freepages_block+0x128>
ffffffff810a6f46:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
ffffffff810a6f4d:	00 00 00 
ffffffff810a6f50:	48 89 f5             	mov    %rsi,%rbp
ffffffff810a6f53:	31 c0                	xor    %eax,%eax
ffffffff810a6f55:	c7 44 24 3c 00 00 00 	movl   $0x0,0x3c(%rsp)
ffffffff810a6f5c:	00 
ffffffff810a6f5d:	31 d2                	xor    %edx,%edx
ffffffff810a6f5f:	45 31 e4             	xor    %r12d,%r12d
ffffffff810a6f62:	e9 f6 fe ff ff       	jmpq   ffffffff810a6e5d <isolate_freepages_block+0x15d>
ffffffff810a6f67:	80 7c 24 3b 00       	cmpb   $0x0,0x3b(%rsp)
ffffffff810a6f6c:	0f 84 74 fe ff ff    	je     ffffffff810a6de6 <isolate_freepages_block+0xe6>
ffffffff810a6f72:	44 89 fa             	mov    %r15d,%edx
ffffffff810a6f75:	4c 8b 74 24 18       	mov    0x18(%rsp),%r14
ffffffff810a6f7a:	48 63 44 24 3c       	movslq 0x3c(%rsp),%rax
ffffffff810a6f7f:	e9 e0 fe ff ff       	jmpq   ffffffff810a6e64 <isolate_freepages_block+0x164>
ffffffff810a6f84:	66 66 66 2e 0f 1f 84 	data32 data32 nopw %cs:0x0(%rax,%rax,1)
ffffffff810a6f8b:	00 00 00 00 00 

Thanks,
Henrik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
