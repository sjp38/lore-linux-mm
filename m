Date: Sun, 1 Aug 2004 17:52:00 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <20040801040553.305f0275.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0408011747240.13053@dhcp030.home.surriel.com>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
 <20040801040553.305f0275.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, sjiang@cs.wm.edu
List-ID: <linux-mm.kvack.org>

On Sun, 1 Aug 2004, Andrew Morton wrote:
> Rik van Riel <riel@redhat.com> wrote:
> >
> > The following experimental patch implements token based thrashing
> >  protection, 
> 
> Thanks for this - it is certainly needed.

I'm glad you like it ;)

> As you say, qsbench throughput is greatly increased (4x here).  But the old
> `make -j4 vmlinux' with mem=64m shows no benefit at all.

I tested increasing make loads on my system here.  The system
is a dual pIII with 384MB RAM and a 180MB named daemon in the
background.

With -j 10, 20, 30, 40 and 50 the patch didn't make much of a
difference at all.  However, with 'make -j 60' it sped up the
average compile time about a factor of 2, from 1:20 down to
40 minutes.  CPU consumption also went up from ~26% to over 50%.

> I figured it was the short-lived processes, so I added the below, which
> passes the token to the child across exec, and back to the parent on exit. 
> Although it appears to work correctly, it too make no difference.

I've got some ideas for potential improvement, too.  However,
I'd like to get the simplest code tested first ;)

> btw, in page_referenced_one():
> 
> +	if (mm != current->mm && has_swap_token(mm))
> +		referenced++;
> 
> what's the reason for the `mm != current->mm' test?

It's possible that the process that's currently holding
the token wants more memory than the system has available.

In that case it needs to be able to page part of itself
out of memory, otherwise the system will deadlock until
the moment where the token is handed off to the next
task...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
