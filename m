Date: Wed, 31 Jul 2002 13:10:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: How did paging_init ever work with PAE?
In-Reply-To: <536090000.1028076330@flay>
Message-ID: <Pine.LNX.4.21.0207311255100.980-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jul 2002, Martin J. Bligh wrote:
> We're crashing in paging_init under certain circumstances, but on
> closer inspection, I'm unsure how this ever could have worked.
> Obviously it does most of the time, so I'm missing something ....
> 
> With PAE on, the code path looks like this:
> 
>         pagetable_init();
>         load_cr3(swapper_pg_dir);
>         if (cpu_has_pae)
>                 set_in_cr4(X86_CR4_PAE);
> 
> Hmmm .... pagetable_init sets up a PGD for PAE use, then we load
> cr3 with this table .... then we turn on PAE mode.
> 
> How are we surviving in this limbo state between the point when
> we reload cr3 and when we turn on PAE? If we take a page fault
> (which we will, since reloading cr3 flushes the tlb) is the PGD 
> somehow dual purpose and works for non-PAE systems as well?

Yes.

> Are we relying on the global bit on entries on the TLB cache which
> we're just praying aren't going to fall out?

No.

See swapper_pg_dir in arch/i386/kernel/head.S: at swapper_pg_dir+0xc00
there's a couple of 32-bit non-PAE entries to map 0xc0000000-0xc07fffff
where the kernel is; whereas pagetable_init sets up four 64-bit PAE
entries at swapper_pg_dir (overwriting the non-PAE identity mappings,
yes, but they won't be needed during changeover from non-PAE to PAE).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
