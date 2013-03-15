Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 234C96B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:32:29 -0400 (EDT)
Date: Fri, 15 Mar 2013 17:32:20 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Kernel oops on mmap ?
Message-ID: <20130315173220.GP4977@n2100.arm.linux.org.uk>
References: <51409575.9060304@mimc.co.uk> <CAJd=RBB=2XRwN-eCQDnBjwnm57-2C+OSairhyUrPdVMoLCfj1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBB=2XRwN-eCQDnBjwnm57-2C+OSairhyUrPdVMoLCfj1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mark Jackson <mpfj-list@mimc.co.uk>, lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Mar 14, 2013 at 09:38:02AM +0800, Hillf Danton wrote:
> [cc Russell]
> On Wed, Mar 13, 2013 at 11:04 PM, Mark Jackson <mpfj-list@mimc.co.uk> wrote:
> > Can any help diagnose what my userspace task is doing to get the followings oops ?
> >
> > [   42.587772] Unable to handle kernel paging request at virtual address bfac6004
> > [   42.595431] pgd = cf748000
> > [   42.598291] [bfac6004] *pgd=00000000
> 
> None pgd, why is pgd_none_or_clear_bad() not triggered?

I think you're misunderstanding what's happened here.

> > [   42.602079] Internal error: Oops: 5 [#1] ARM
> > [   42.606592] CPU: 0    Not tainted  (3.8.0-next-20130225-00001-g2d0ce24-dirty #38)
> > [   42.614509] PC is at unmap_single_vma+0x2d8/0x5bc
> > [   42.619476] LR is at unmap_single_vma+0x29c/0x5bc
> > [   42.624447] pc : [<c00aed0c>]    lr : [<c00aecd0>]    psr: 60000013
> > [   42.624447] sp : cf685d88  ip : 8f9523cd  fp : cf680004
> > [   42.636567] r10: 00000000  r9 : bfac6000  r8 : 00200000
> > [   42.642079] r7 : cf685e00  r6 : cf5e93a8  r5 : cf5e93ac  r4 : 000ea000
> > [   42.648969] r3 : 00000001  r2 : 00000000  r1 : 00000040  r0 : 00000000
...
> > [   42.935472] Code: 0affffa4 e59d000c e3500000 1a0000a2 (e5993004)

That disassembles to this:
   0:	0affffa4 	beq	0xfffffe98
   4:	e59d000c 	ldr	r0, [sp, #12]
   8:	e3500000 	cmp	r0, #0
   c:	1a0000a2 	bne	0x29c
  10:	e5993004 	ldr	r3, [r9, #4]

and r9 = 0xbfac6000, which is _not_ the address of a page table.

Unfortunately, the above doesn't tie up with the output from my
compiler, so I've no idea what that corresponds with in
unmap_single_vma().

The other surprising thing about this oops dump is the lack of
backtrace...

I think I need to see the disassembly of this function before
there can be any further diagnosis of what's going on here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
