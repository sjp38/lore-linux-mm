Message-ID: <4460EDCA.3000301@free.fr>
Date: Tue, 09 May 2006 21:30:18 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
MIME-Version: 1.0
Subject: Re: Any reason for passing "tlb" to "free_pgtables()" by address?
References: <445B2EBD.4020803@bull.net> <Pine.LNX.4.64.0605051337520.6945@blonde.wat.veritas.com> <445FBD1B.6080404@free.fr> <Pine.LNX.4.64.0605091207030.19410@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605091207030.19410@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, nickpiggin@yahoo.com.au
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh, Nick,

Thank you for the information.

> Nick uses the pagetables themselves as buffering, I allocate a
> temporary buffer: in each case we abandon the per-cpu arrays which
> need preemption disabled.  But neither patch is good enough yet.

I'd like to note that the page table walking:

	TLB = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]

is not safe on some of the architectures which load TLB entries
"by hand", i.e. by use of some low level assembly routines,
e.g. IA64, Power.
Please refer to the thread "RFC: RCU protected page table walking".

Only some "careful programming" in the PUD / PMD / PTE page removal
code can help.
I propose a way to make sure that the page table walkers will be
able to finish their walks in safety; we release a directory page
when no more walker can reference the page.

Therefore I'd appreciate much a solution that would not use the
directory pages themselves as buffering. I'll need to preserve them
until the RCU based reclaim side.

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
