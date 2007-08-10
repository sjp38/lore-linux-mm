Received: by wa-out-1112.google.com with SMTP id m33so729559wag
        for <linux-mm@kvack.org>; Thu, 09 Aug 2007 17:17:08 -0700 (PDT)
Message-ID: <4a5909270708091717n2f93fcb5i284d82edfd235145@mail.gmail.com>
Date: Thu, 9 Aug 2007 20:17:08 -0400
From: "Daniel Phillips" <daniel.raymond.phillips@gmail.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070806102922.907530000@chello.nl>
	 <200708061559.41680.phillips@phunq.net>
	 <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
	 <200708061649.56487.phillips@phunq.net>
	 <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
	 <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
	 <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
	 <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
	 <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On 8/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Thu, 9 Aug 2007, Daniel Phillips wrote:
> > On 8/8/07, Christoph Lameter <clameter@sgi.com> wrote:
> > > On Wed, 8 Aug 2007, Daniel Phillips wrote:
> > > Maybe we need to kill PF_MEMALLOC....
> > Shrink_caches needs to be able to recurse into filesystems at least,
> > and for the duration of the recursion the filesystem must have
> > privileged access to reserves.  Consider the difficulty of handling
> > that with anything other than a process flag.
>
> Shrink_caches needs to allocate memory? Hmmm... Maybe we can only limit
> the PF_MEMALLOC use.

PF_MEMALLOC is not such a bad thing.  It will usually be less code
than mempool for the same use case, besides being able to handle a
wider range of problems.  We  introduce __GPF_MEMALLOC for situations
where the need for reserve memory is locally known, as in the network
stack, which is similar or identical to the use case for mempool.  One
could reasonably ask why we need mempool with a lighter alternative
available.  But this is a case of to each their own I think.  Either
technique will work for reserve management.

> > In theory, we could reduce the size of the global memalloc pool by
> > including "easily freeable" memory in it.  This is just an
> > optimization and does not belong in this patch set, which fixes a
> > system integrity issue.
>
> I think the main thing would be to fix reclaim to not do stupid things
> like triggering writeout early in the reclaim pass and to allow reentry
> into reclaim. The idea of memory pools always sounded strange to me given
> that you have a lot of memory in a zone that is reclaimable as needed.

You can fix reclaim as much as you want and the basic deadlock will
still not go away.  When you finally do get to writing something out,
memory consumers in the writeout path are going to cause problems,
which this patch set fixes.

Agreed that the idea of mempool always sounded strange, and we show
how to get rid of them, but that is not the immediate purpose of this
patch set.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
