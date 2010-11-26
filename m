Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1A318D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 03:42:00 -0500 (EST)
Date: Fri, 26 Nov 2010 09:41:49 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH] Cross Memory Attach v2 (resend)
Message-ID: <20101126084149.GB26764@elte.hu>
References: <20101122122847.3585b447@lilo>
 <20101122130527.c13c99d3.akpm@linux-foundation.org>
 <20101126080624.GA26764@elte.hu>
 <20101126000903.df846d3e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101126000903.df846d3e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Brice Goglin <Brice.Goglin@inria.fr>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 26 Nov 2010 09:06:24 +0100 Ingo Molnar <mingo@elte.hu> wrote:
> 
> > 
> > * Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Mon, 22 Nov 2010 12:28:47 +1030
> > > Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> > > 
> > > > Resending just in case the previous mail was missed rather than ignored :-)
> > > > I'd appreciate any comments....
> > > 
> > > Fear, uncertainty, doubt and resistance!
> > > 
> > > We have a bit of a track record of adding cool-looking syscalls and
> > > then regretting it a few years later.  Few people use them, and maybe
> > > they weren't so cool after all, and we have to maintain them for ever. 
> > 
> > They are often cut off at the libc level and never get into apps.
> > 
> > If we had tools/libc/ (mapped by the kernel automagically via the vDSO), where 
> > people could add new syscall usage to actual, existing, real-life libc functions, 
> > where the improvements could thus propagate into thousands of apps immediately, 
> > without requiring any rebuild of apps or even any touching of the user-space 
> > installation, we'd probably have _much_ more lively development in this area.
> > 
> > Right now it's slow and painful, and few new syscalls can break through the 
> > brick wall of implementation latency, app adoption disinterest due to backwards 
> > compatibility limitations and the resulting inevitable lack of testing and lack 
> > of tangible utility.
> 
> Can't people use libc's syscall(2)?

To get a new syscall enhancement used by existing libc functions, to say speed up 
Firefox?

How exactly?

syscall(2) is sporadically used by niche projects that only target a few CPU 
architectures (we dont have arch independent syscall numbers), and only if they are 
willing to complicate their code with various ugly backwards compatibility wrappers, 
so that it works on older kernels as well.

libc functionality is much wider - it's thousands of functions, used by tens of 
thousands of apps - the chance that the kernel can transparently help in small 
details (and with not so small features) here and there is much higher than what
we can do within the syscall ABI sandbox alone.

Some examples:

 - We could make use of Linux-only kernel features in libc functions with no 
   compatibility problems. Apps themselves are reluctant to use Linux-only syscalls 
   as it's a hassle to port.

 - The whole futex mess would be much less painful.

 - We could add various bits of instrumentation functionality.

 - We could even have done much bigger (and more controversial) things - for example 
   the existing posix AIO functions of libc, while being crap, could have served as 
   a seed to get at least _some_ apps use kernel accelerated AIO - or at least find 
   some threaded implementation that works best. We could have tried and pitted 
   various implementations against each other much more quickly and with much more
   tangible results.

 - I bet some graphics stuff could be exposed in such a way as well. libdrm and
   the drm ioctls are joined at the hip anyway.

 - etc. etc.

There's a lot of useful functionality that needs a 'single project' mentality and a 
single project workflow from kernel and libc.

And key to that is that 99.9% of apps link against libc. That's a _huge_ vector of 
quick prototyping and quick deployment. Apple and Google/Android understands that 
single-project mentality helps big time. We dont yet.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
