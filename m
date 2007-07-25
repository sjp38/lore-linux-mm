Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<200707102015.44004.kernel@kolivas.org>
	<9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46A57068.3070701@yahoo.com.au>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
From: Andi Kleen <andi@firstfloor.org>
Date: 25 Jul 2007 22:46:20 +0200
In-Reply-To: <46A6CC56.6040307@yahoo.com.au>
Message-ID: <p73abtkrz37.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> Ray Lee wrote:
> > On 7/23/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> >> Also a random day at the desktop, it is quite a broad scope and
> >> pretty well impossible to analyse.
> > It is pretty broad, but that's also what swap prefetch is targetting.
> > As for hard to analyze, I'm not sure I agree. One can black-box test
> > this stuff with only a few controls. e.g., if I use the same apps each
> > day (mercurial, firefox, xorg, gcc), and the total I/O wait time
> > consistently goes down on a swap prefetch kernel (normalized by some
> > control statistic, such as application CPU time or total I/O, or
> > something), then that's a useful measurement.
> 
> I'm not saying that we can't try to tackle that problem, but first of
> all you have a really nice narrow problem where updatedb seems to be
> causing the kernel to completely do the wrong thing. So we start on
> that.

One simple way to fix this would be to implement a fadvise() flag
that puts the dentry/inode on a "soon to be expired" list if there
are no other references. Then if a dentry allocation needs more
memory try to reuse dentries from that list (or better queue) first. Any other
access will remove the dentry from the list. 

Disadvantage would be that the userland would need to be patched,
but I guess it's better than adding very dubious heuristics to the
kernel.

Similar thing could be done for directory buffers although they
are probably less of a problem.

I expect that C.Lameter's directed dentry/inode freeing in slub will also
make a big difference. People who have problems with updatedb should
definitely try mm which has it I believe and enable SLUB.

-Andi (who always thought swap prefetch was just a workaround, not
a real solution) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
