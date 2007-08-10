Received: by rv-out-0910.google.com with SMTP id f1so507105rvb
        for <linux-mm@kvack.org>; Fri, 10 Aug 2007 01:15:56 -0700 (PDT)
Message-ID: <4a5909270708100115v4ad10c4es697d216edf29b07d@mail.gmail.com>
Date: Fri, 10 Aug 2007 04:15:56 -0400
From: "Daniel Phillips" <daniel.raymond.phillips@gmail.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <Pine.LNX.4.64.0708092045120.27164@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
	 <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
	 <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
	 <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
	 <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
	 <4a5909270708091717n2f93fcb5i284d82edfd235145@mail.gmail.com>
	 <Pine.LNX.4.64.0708091844450.3185@schroedinger.engr.sgi.com>
	 <4a5909270708092034yaa0a583w70084ef93266df48@mail.gmail.com>
	 <Pine.LNX.4.64.0708092045120.27164@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On 8/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> > If you believe that the deadlock problems we address here can be
> > better fixed by making reclaim more intelligent then please post a
> > patch and we will test it.  I am highly skeptical, but the proof is in
> > the patch.
>
> Then please test the patch that I posted here earlier to reclaim even if
> PF_MEMALLOC is set. It may require some fixups but it should address your
> issues in most vm load situations.

It is quite clear what is in your patch.  Instead of just grabbing a
page off the buddy free lists in a critical allocation situation you
go invoke shrink_caches.  Why oh why?  All the memory needed to get
through these crunches is already sitting right there on the buddy
free lists, ready to be used, why would you go off scanning instead?
And this does not work in atomic contexts at all, that is a whole
thing you would have to develop, and why?  You just offered us
functionality that we already have, except your idea has issues.

You do not do anything to prevent mixing of ordinary slab allocations
of unknown duration with critical allocations of controlled duration.
 This  is _very important_ for sk_alloc.  How are you going to take
care of that?

In short, you provide a piece we don't need because we already have it
in a more efficient form, your approach does not work in atomic
context, and you need to solve the slab object problem.  You also need
integration with sk_alloc.   That is just what I noticed on a
once-over-lightly.  Your patch has a _long_ way to go before it is
ready to try.

We have already presented a patch set that is tested and is known to
solve the deadlocks.  This patch set has been more than two years in
development.  It covers problems you have not even begun to think
about, which we have been aware of for years.  Your idea is not
anywhere close to working.  Why don't you just work with us instead?
There are certainly improvements that can be made to the posted patch
set.  Running off and learning from scratch how to do this is not
really helpful.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
