Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 60FC16B00A8
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 08:45:55 -0500 (EST)
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
	 <AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
	 <AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 03 Jan 2011 08:45:51 -0500
Message-ID: <1294062351.3948.7.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-03 at 09:40 +0200, Pekka Enberg wrote:
> Hi,
> 
> On Mon, Jan 3, 2011 at 8:48 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> >> Given the patches being busily submitted by trivial patch submitters to
> >> make use kmem_cache_zalloc(), et. al, I believe we should remove the
> >> unlikely() tests around the (gfp_flags & __GFP_ZERO) tests, such as:
> >>
> >> -       if (unlikely((flags & __GFP_ZERO) && objp))
> >> +       if ((flags & __GFP_ZERO) && objp)
> >>                memset(objp, 0, obj_size(cachep));
> >>
> >> Agreed?  If so, I'll send a patch...
> 
> On Mon, Jan 3, 2011 at 5:46 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > I support it.
> 
> I guess the rationale here is that if you're going to take the hit of
> memset() you can take the hit of unlikely() as well. We're optimizing
> for hot call-sites that allocate a small amount of memory and
> initialize everything themselves. That said, I don't think the
> unlikely() annotation matters much either way and am for removing it
> unless people object to that.
> 
> On Mon, Jan 3, 2011 at 5:46 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > Recently Steven tried to gather the information.
> > http://thread.gmane.org/gmane.linux.kernel/1072767
> > Maybe he might have a number for that.
> 
> That would be interesting, sure.

Note, you could do it yourself too. Just enable:

  Kernel Hacking -> Tracers -> Branch Profiling
    (Trace likely/unlikely profiler)

   CONFIG_PROFILE_ANNOTATED_BRANCHES

Then search /debug/tracing/trace_stats/branch_annotated.

(hmm, the help in Kconfig is wrong, I need to fix that)


Anyway, here's my box. I just started it an hour ago, and have not been
doing too much on it yet. But here's what I got (using SLUB)


 correct incorrect  %        Function                  File              Line
 ------- ---------  -        --------                  ----              ----
 6890998  2784830  28        slab_alloc                slub.c            1719

That's incorrect 28% of the time.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
