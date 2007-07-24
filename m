Received: by ug-out-1314.google.com with SMTP id c2so220049ugf
        for <linux-mm@kvack.org>; Tue, 24 Jul 2007 09:15:03 -0700 (PDT)
Message-ID: <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
Date: Tue, 24 Jul 2007 09:15:01 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A58B49.3050508@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/23/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Ray Lee wrote:
> > That said, I'm willing to run my day to day life through both a swap
> > prefetch kernel and a normal one. *However*, before I go through all
> > the work of instrumenting the damn thing, I'd really like Andrew (or
> > Linus) to lay out his acceptance criteria on the feature. Exactly what
> > *should* I be paying attention to? I've suggested keeping track of
> > process swapin delay total time, and comparing with and without. Is
> > that reasonable? Is it incomplete?
>
> I don't feel it is so useful without more context. For example, in
> most situations where pages get pushed to swap, there will *also* be
> useful file backed pages being thrown out. Swap prefetch might
> improve the total swapin delay time very significantly but that may
> be just a tiny portion of the real problem.

Agreed, it's important to make sure we're not being penny-wise and
pound-foolish here.

> Also a random day at the desktop, it is quite a broad scope and
> pretty well impossible to analyse.

It is pretty broad, but that's also what swap prefetch is targetting.
As for hard to analyze, I'm not sure I agree. One can black-box test
this stuff with only a few controls. e.g., if I use the same apps each
day (mercurial, firefox, xorg, gcc), and the total I/O wait time
consistently goes down on a swap prefetch kernel (normalized by some
control statistic, such as application CPU time or total I/O, or
something), then that's a useful measurement.

> If we can first try looking at
> some specific problems that are easily identified.

Always easier, true. Let's start with "My mouse jerks around under
memory load." A Google Summer of Code student working on X.Org claims
that mlocking the mouse handling routines gives a smooth cursor under
load ([1]). It's surprising that the kernel would swap that out in the
first place.

[1] http://vignatti.wordpress.com/2007/07/06/xorg-input-thread-summary-or-something/

> Looking at your past email, you have a 1GB desktop system and your
> overnight updatedb run is causing stuff to get swapped out such that
> swap prefetch makes it significantly better. This is really
> intriguing to me, and I would hope we can start by making this
> particular workload "not suck" without swap prefetch (and hopefully
> make it even better than it currently is with swap prefetch because
> we'll try not to evict useful file backed pages as well).

updatedb is an annoying case, because one would hope that there would
be a better way to deal with that highly specific workload. It's also
pretty stat dominant, which puts it roughly in the same category as a
git diff. (They differ in that updatedb does a lot of open()s and
getdents on directories, git merely does a ton of lstat()s instead.)

Anyway, my point is that I worry that tuning for an unusual and
infrequent workload (which updatedb certainly is), is the wrong way to
go.

> After that we can look at other problems that swap prefetch helps
> with, or think of some ways to measure your "whole day" scenario.
>
> So when/if you have time, I can cook up a list of things to monitor
> and possibly a patch to add some instrumentation over this updatedb
> run.

That would be appreciated. Don't spend huge amounts of time on it,
okay? Point me the right direction, and we'll see how far I can run
with it.

> Anyway, I realise swap prefetching has some situations where it will
> fundamentally outperform even the page replacement oracle. This is
> why I haven't asked for it to be dropped: it isn't a bad idea at all.

<nod>

> However, if we can improve basic page reclaim where it is obviously
> lacking, that is always preferable. eg: being a highly speculative
> operation, swap prefetch is not great for power efficiency -- but we
> still want laptop users to have a good experience as well, right?

Absolutely. Disk I/O is the enemy, and the best I/O is one you never
had to do in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
