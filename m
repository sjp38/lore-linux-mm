Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D2D316B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:33:44 -0400 (EDT)
Date: Fri, 10 Jul 2009 19:34:06 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [BUG 2.6.30] Bad page map in process
In-Reply-To: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
Message-ID: <Pine.LNX.4.64.0907101900570.27223@sister.anvils>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Cc: linux-kernel@vger.kernel.org, kernel@avr32linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009, Guennadi Liakhovetski wrote:
> 
> with a 2.6.30 kernel with only platform-specific modifications and this 
> avr32 patch:
> 
> http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commitdiff;h=bb6e647051a59dca5a72b3deef1e061d7c1c34da
> 
> we're seeing kernel BUGs following an application segfault. Here's an 
> example:
> 
> [60254.432000] application[465]: segfault at 4377f876 pc 2aaabbde sp 7faa77f0 ecr 24
> [60255.396000] BUG: Bad page map in process application  pte:13f26ed4 pmd:92fdd000
> [60255.404000] page:902c44c0 flags:0000002c count:1 mapcount:-1 mapping:9345765c index:5
> [60255.412000] addr:2ae4f000 vm_flags:08000075 anon_vma:(null) mapping:93454dd4 index:0

This is the first time I've seen one of these messages since putting it
into 2.6.29, and nice to see that it's doing its job: the info amidst the
data is that mapcount is -1 when it ought to be 0, and the mapping,index
of the page the pte points to doesn't match up with the mapping,index
which the vma intends at that address: probably the pte is corrupt.

I've not looked up avr32 pte layout, is 13f26ed4 good or bad?
I hope avr32 people can tell more about the likely cause.

Also, the addr mapped by this pte (2ae4f000) is not the address
which segfaulted (4377f876): it would have been satisfying if those
had matched up, but I don't think we can conclude anything from the
fact that they don't.

> [60255.420000] vma->vm_ops->fault: filemap_fault+0x0/0x26c
> [60255.424000] vma->vm_file->f_op->mmap: generic_file_readonly_mmap+0x0/0x18
> [60255.432000] Call trace: (exiting)
> 
> Questions: can this BUG be caused by the segfault (it better not)?

It better not.

> If not, what can be the reason?

It looks like page table corruption.

> The problem occurs sporadically, I've only had one 
> such case since yesterday. Yet one more application segfault last night 
> didn't produce a BUG.

I think page table corruption is causing segfaults, and page table
corruption is causing "Bad page map"s when the app exits.  Yes,
sometimes you'll see one, sometimes the other, sometimes both.

More might be learnt by comparing all the different such messages
you've seen: for example, we're now printing the "pmd" there, in
case it emerges that all such errors occur in or near the same
physical address.

> This is with a kernel configured with SLAB. With 
> SLUB we also observed similar BUGs on application exit but without signal 
> handling path in the backtrace. But, I think, I've had other problems with 
> SLUB before, so, we switched back to SLAB for now...

I wouldn't read too much into the SLAB versus SLUB difference here,
suspect just coincidence; but I could be horribly wrong.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
