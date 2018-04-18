Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1106B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 16:33:58 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id c11-v6so1621542pll.13
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 13:33:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r7-v6si1871857ple.401.2018.04.18.13.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 13:33:57 -0700 (PDT)
Subject: Re: [do_execve] attempted to set unsupported pgprot
References: <20180418135933.t3dyszi2phhsvaah@wfg-t540p.sh.intel.com>
 <20180418125916.a8be1fac1ac017f41a10f0fb@linux-foundation.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <361242c4-261c-1ddb-b948-c71f672779a8@linux.intel.com>
Date: Wed, 18 Apr 2018 13:33:55 -0700
MIME-Version: 1.0
In-Reply-To: <20180418125916.a8be1fac1ac017f41a10f0fb@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Serge Hallyn <serge@hallyn.com>, James Morris <james.l.morris@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, lkp@01.org

On 04/18/2018 12:59 PM, Andrew Morton wrote:
>> [   12.348499] ------------[ cut here ]------------
>> [   12.349193] attempted to set unsupported pgprot: 8000000000000025 bits: 8000000000000000 supported: 7fffffffffffffff
>> [   12.350792] WARNING: CPU: 0 PID: 1 at arch/x86/include/asm/pgtable.h:540 handle_mm_fault+0xfc1/0xfe0:
>> 						check_pgprot at arch/x86/include/asm/pgtable.h:535
>> 						 (inlined by) pfn_pte at arch/x86/include/asm/pgtable.h:549
>> 						 (inlined by) do_anonymous_page at mm/memory.c:3169
>> 						 (inlined by) handle_pte_fault at mm/memory.c:3961
>> 						 (inlined by) __handle_mm_fault at mm/memory.c:4087
>> 						 (inlined by) handle_mm_fault at mm/memory.c:4124
>> [   12.352294] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.17.0-rc1 #172
>> [   12.353357] EIP: handle_mm_fault+0xfc1/0xfe0:
>> 						check_pgprot at arch/x86/include/asm/pgtable.h:535
>> 						 (inlined by) pfn_pte at arch/x86/include/asm/pgtable.h:549
>> 						 (inlined by) do_anonymous_page at mm/memory.c:3169
>> 						 (inlined by) handle_pte_fault at mm/memory.c:3961
>> 						 (inlined by) __handle_mm_fault at mm/memory.c:4087
>> 						 (inlined by) handle_mm_fault at mm/memory.c:4124
> Dave, fb43d6cb91ef57 ("x86/mm: Do not auto-massage page protections")
> looks like a culprit?


This looks like NX somehow getting set on a system where it is
unsupported.  Any idea what kind of VMA it is?  We probably should have
kept NX from getting set in vm_page_prot to begin with.
>         entry = mk_pte(page, vma->vm_page_prot);
>         if (vma->vm_flags & VM_WRITE)
>                 entry = pte_mkwrite(pte_mkdirty(entry));
> 
