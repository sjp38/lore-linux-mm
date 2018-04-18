Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4206B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 15:59:19 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 35-v6so1553348pla.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 12:59:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g124si1623149pgc.163.2018.04.18.12.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 12:59:18 -0700 (PDT)
Date: Wed, 18 Apr 2018 12:59:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [do_execve] attempted to set unsupported pgprot
Message-Id: <20180418125916.a8be1fac1ac017f41a10f0fb@linux-foundation.org>
In-Reply-To: <20180418135933.t3dyszi2phhsvaah@wfg-t540p.sh.intel.com>
References: <20180418135933.t3dyszi2phhsvaah@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Serge Hallyn <serge@hallyn.com>, James Morris <james.l.morris@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, lkp@01.org, Dave Hansen <dave.hansen@linux.intel.com>

On Wed, 18 Apr 2018 21:59:33 +0800 Fengguang Wu <fengguang.wu@intel.com> wrote:

> Hello,
> 
> FYI this happens in mainline kernel 4.17.0-rc1.
> It looks like a new regression.
> 
> It occurs in 4 out of 4 boots.
> 
> [   12.345562] Write protecting the kernel text: 14376k
> [   12.346649] Write protecting the kernel read-only data: 4740k
> [   12.347584] rodata_test: all tests were successful
> [   12.348499] ------------[ cut here ]------------
> [   12.349193] attempted to set unsupported pgprot: 8000000000000025 bits: 8000000000000000 supported: 7fffffffffffffff
> [   12.350792] WARNING: CPU: 0 PID: 1 at arch/x86/include/asm/pgtable.h:540 handle_mm_fault+0xfc1/0xfe0:
> 						check_pgprot at arch/x86/include/asm/pgtable.h:535
> 						 (inlined by) pfn_pte at arch/x86/include/asm/pgtable.h:549
> 						 (inlined by) do_anonymous_page at mm/memory.c:3169
> 						 (inlined by) handle_pte_fault at mm/memory.c:3961
> 						 (inlined by) __handle_mm_fault at mm/memory.c:4087
> 						 (inlined by) handle_mm_fault at mm/memory.c:4124
> [   12.352294] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.17.0-rc1 #172
> [   12.353357] EIP: handle_mm_fault+0xfc1/0xfe0:
> 						check_pgprot at arch/x86/include/asm/pgtable.h:535
> 						 (inlined by) pfn_pte at arch/x86/include/asm/pgtable.h:549
> 						 (inlined by) do_anonymous_page at mm/memory.c:3169
> 						 (inlined by) handle_pte_fault at mm/memory.c:3961
> 						 (inlined by) __handle_mm_fault at mm/memory.c:4087
> 						 (inlined by) handle_mm_fault at mm/memory.c:4124

Dave, fb43d6cb91ef57 ("x86/mm: Do not auto-massage page protections")
looks like a culprit?
