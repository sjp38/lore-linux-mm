Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id BBECB6B0074
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 13:48:45 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so6611335dae.21
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 10:48:45 -0800 (PST)
Date: Wed, 2 Jan 2013 10:48:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] tmpfs mempolicy: fix /proc/mounts corrupting
 memory
In-Reply-To: <CA+55aFyH63agfbf+pYNRGHaprPqAJF=F19GR6ASP_RhoyDGLdA@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1301021031230.30549@eggly.anvils>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils> <0000013bfbfbb293-ccc455ed-2db6-46e2-8362-dc418bae0def-000000@email.amazonses.com> <CA+55aFyH63agfbf+pYNRGHaprPqAJF=F19GR6ASP_RhoyDGLdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 2 Jan 2013, Linus Torvalds wrote:
> On Wed, Jan 2, 2013 at 7:57 AM, Christoph Lameter <cl@linux.com> wrote:
> > On Wed, 2 Jan 2013, Hugh Dickins wrote:
> >
> >> @@ -2796,10 +2787,7 @@ int mpol_to_str(char *buffer, int maxlen
> >>       case MPOL_BIND:
> >>               /* Fall through */
> >>       case MPOL_INTERLEAVE:
> >> -             if (no_context)
> >> -                     nodes = pol->w.user_nodemask;
> >> -             else
> >> -                     nodes = pol->v.nodes;
> >> +             nodes = pol->v.nodes;
> >>               break;
> >>
> >
> > no_context was always true. Why is the code from the false branch kept?
> 
> no_context is zero in the caller in fs/proc/task_mmu.c, and one in the
> mm/shmem.c caller. So it's not always true (for mpol_parse_str() there
> is only one caller, and it's always true as Hugh said).

Yes, I think Christoph was remembering the old days when mpol_to_str()
started out just for tmpfs; later /proc/pid/numa_maps extended it for
use on vmas (the "contextualized" !no_context case).

> 
> Anyway, I do not know why Hugh took the true case, but I don't really
> imagine that it matters. So I'll take these two patches, but it would
> be good if you double-checked this, Hugh.

Thanks, yes, I played with a number of ways of fixing it (and sat on my
original fix for several days, rightly guessing this an area where more
problems would emerge - only later realizing mpol=prefer:Node wrong too).

I could probably have kept mpol_to_str()'s no_context arg, and done
something with it in the MPOL_PREFERRED case; perhaps would have chosen
that if the arg had been more understandably named than "no_context";
but in the end thought removing the need for the arg was simplest.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
