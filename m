Date: Tue, 10 Jul 2007 20:42:59 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
In-Reply-To: <200707101412.19785.dave.mccracken@oracle.com>
Message-ID: <Pine.LNX.4.64.0707102030150.2063@blonde.wat.veritas.com>
References: <4692D616.4010004@oracle.com> <200707101219.29743.dave.mccracken@oracle.com>
 <Pine.LNX.4.64.0707101857310.20758@blonde.wat.veritas.com>
 <200707101412.19785.dave.mccracken@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: herbert.van.den.bergh@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Dave McCracken wrote:
> On Tuesday 10 July 2007, Hugh Dickins wrote:
> >
> > Mapped private readonly yes, but vm_stat_account() says
> > 	if (file) {
> > 		mm->shared_vm += pages;
> > 		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
> > 			mm->exec_vm += pages;
> 
> In that code shared_vm includes everything that's mmap()ed, including private 
> mappings.  But if you look at Herbert's patch he has the following change:
> 
>         if (file) {
> -               mm->shared_vm += pages;
> +               if (flags & VM_SHARED)
> +                       mm->shared_vm += pages;
>                 if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
>                         mm->exec_vm += pages;
> 
> This means that shared_vm now is truly only memory that's mapped VM_SHARED and 
> does not include VM_EXEC memory.  That necessitates the separate subtraction 
> of exec_vm in the data calculations.

Ah, I just noticed at the beginning of the patch, and didn't look for
a balancing change - thanks.  I'd strongly recommend that he not mess
around with these numbers, unless there's _very_ good reason: they're
not ideal, nothing ever will be, changing them around just causes pain.
shared_vm may not be a full description of what it counts, but it'll
do until you've a better name (readonly mappings share with the file
even when they're private).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
