Date: Thu, 9 Aug 2007 18:48:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <4a5909270708091717n2f93fcb5i284d82edfd235145@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708091844450.3185@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <200708061559.41680.phillips@phunq.net>
  <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
 <200708061649.56487.phillips@phunq.net>  <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
  <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
 <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
 <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
 <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
 <4a5909270708091717n2f93fcb5i284d82edfd235145@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.raymond.phillips@gmail.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007, Daniel Phillips wrote:

> You can fix reclaim as much as you want and the basic deadlock will
> still not go away.  When you finally do get to writing something out,
> memory consumers in the writeout path are going to cause problems,
> which this patch set fixes.

We currently also do *not* write out immediately. I/O is queued when 
submitted so it does *not* reduce memory. It is better to actually delay 
writeout until you have thrown out clean pages. At that point the free 
memory is at its high point. If memory goes below the high point again by 
these writes then we can again reclaim until things are right.

> Agreed that the idea of mempool always sounded strange, and we show
> how to get rid of them, but that is not the immediate purpose of this
> patch set.

Ok mempools are unrelated. The allocations problems that this patch 
addresses can be fixed by making reclaim more intelligent. This may likely 
make mempools less of an issue in the kernel. If we can reclaim in an 
emergency even in ATOMIC contexts then things get much easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
