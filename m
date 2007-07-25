Received: by nz-out-0506.google.com with SMTP id s1so76666nze
        for <linux-mm@kvack.org>; Tue, 24 Jul 2007 23:09:02 -0700 (PDT)
Message-ID: <b21f8390707242309r4a925737p777e507e473df1ab@mail.gmail.com>
Date: Wed, 25 Jul 2007 16:09:01 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6CC56.6040307@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 7/25/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> I'm not saying that we can't try to tackle that problem, but first of
> all you have a really nice narrow problem where updatedb seems to be
> causing the kernel to completely do the wrong thing. So we start on
> that.

updatedb isn't the only problem, its just an obvious one.  I like the
idea of looking into the vfs for this and other one-shot applications
(rather than looking at updatedb itself specifically)

Many modern applications have a lot of open file handles.  For
example, I just fired up my usual audio player and sys/fs/file-nr
showed another 600 open files (funnily enough, I have roughly that
many audio files :)  I'm not exactly sure what happens when this one
gets swapped out for whatever reason (firefox/java/vmware/etc chews
ram, updatedb, whatever) but I'm fairly confident what happens between
kswapd and the vfs and whatever else we're caching is not optimal come
time for this process to context-switch back in.  We're not running a
highly-optimised number-crunching scientific app on desktops, we're
running a full herd of poorly-coded hogs simultaneously through
smaller pens.

I don't think anyone is trying to claim that swap prefetch is the be
all and end all of this problem's solution, however without it the
effects are an order of magnitude worse (I've cited numbers elsewhere,
as have several others); its relatively non-intrusive (600+ lines of
the 755 changed ones are self-contained), is compile and runtime
selectable, and still has a maintainer now that Con has retired.  If
there was a better solution, it should have been developed sometime in
the past 23 months that swap prefetch has addressed it.  That's how we
got rmap versus aa, and so on.  But nobody chose to do so, and
continuing to hold out on merging it on the promise of vapourware is
ridiculous.  That has never been the way linux kernel development has
operated.

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
