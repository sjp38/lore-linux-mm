Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 979066B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:28:22 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u89so30844552wrc.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:28:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si10343598wra.384.2017.07.26.00.28.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 00:28:20 -0700 (PDT)
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
 <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
Date: Wed, 26 Jul 2017 09:28:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25/07/17 11:05, Kirill A. Shutemov wrote:
> On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
>> Xen PV guests will never run with 5-level-paging enabled. So I guess you
>> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.
> 
> There is more code to drop from mmu_pv.c.
> 
> But while there, I thought if with boot-time 5-level paging switching we
> can allow kernel to compile with XEN_PV and XEN_PVH, so the kernel image
> can be used in these XEN modes with 4-level paging.
> 
> Could you check if with the patch below we can boot in XEN_PV and XEN_PVH
> modes?

We can't. I have used your branch:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
la57/boot-switching/v2

with this patch applied on top.

Doesn't boot PV guest with X86_5LEVEL configured (very early crash).
Doesn't build with X86_5LEVEL not configured:

  AS      arch/x86/kernel/head_64.o
/home/gross/linux/arch/x86/kernel/head_64.S: Assembler messages:
/home/gross/linux/arch/x86/kernel/head_64.S:350: Error: attempt to move
.org backwards
/home/gross/linux/arch/x86/kernel/head_64.S:352: Error: attempt to move
.org backwards
/home/gross/linux/arch/x86/kernel/head_64.S:43: Error: invalid operands
(*ABS* and *UND* sections) for `>>'
/home/gross/linux/arch/x86/kernel/head_64.S:44: Error: invalid operands
(*ABS* and *UND* sections) for `>>'
/home/gross/linux/scripts/Makefile.build:403: recipe for target
'arch/x86/kernel/head_64.o' failed
make[7]: *** [arch/x86/kernel/head_64.o] Error 1


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
