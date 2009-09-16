Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C3F706B005A
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:51:45 -0400 (EDT)
Date: Wed, 16 Sep 2009 01:51:06 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] hwpoison: fix uninitialized warning
In-Reply-To: <20090916002329.GA8476@localhost>
Message-ID: <Pine.LNX.4.64.0909160137270.8639@sister.anvils>
References: <Pine.LNX.4.64.0909152206220.28874@sister.anvils>
 <20090916002329.GA8476@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009, Wu Fengguang wrote:
> On Wed, Sep 16, 2009 at 05:19:07AM +0800, Hugh Dickins wrote:
> > Fix mmotm build warning, presumably also in linux-next:
> > mm/memory.c: In function `do_swap_page':
> > mm/memory.c:2498: warning: `pte' may be used uninitialized in this function
> > 
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > ---
> > I've only noticed this warning on one machine, the powerpc: certainly it
> > needs CONFIG_MIGRATION or CONFIG_MEMORY_FAILURE to see it, but I thought
> > I had one of those set on other machines - just musing in case it's being
> > masked elsewhere by some other bug...

> The lines was introduced in this patch:
> 
>         entry = pte_to_swp_entry(orig_pte);
> -       if (is_migration_entry(entry)) {
> -               migration_entry_wait(mm, pmd, address);
> +       if (unlikely(non_swap_entry(entry))) {
> +               if (is_migration_entry(entry)) {
> +                       migration_entry_wait(mm, pmd, address);
> +               } else if (is_hwpoison_entry(entry)) {
> +                       ret = VM_FAULT_HWPOISON;
> +               } else {
> +                       print_bad_pte(vma, address, pte, NULL);
> +                       ret = VM_FAULT_OOM;
> +               }
>                 goto out;
>         }
> 
> Given that currently there are only two types of non swap entries:
> migration/hwpoison, the last 'else' block is in fact dead code..

Ah, yes, I think it is dead code on x86 (32 and 64), where the
swp_entry_t is well packed.  But not dead code on ppc64, which has

#define __swp_type(entry)	(((entry).val >> 1) & 0x3f)

which is allowing swap types up to 63, when in fact the highest
we use is 31: that leaves space for 32 more non_swap_entry types.

So the compiler was absolutely right to complain about the
uninitialized variable on ppc64, but not on x86.  It's a little
surprising that ppc64 allows 64 swap types, but nothing wrong.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
