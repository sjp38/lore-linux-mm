From: Davidlohr Bueso <davidlohr@hp.com>
Subject: Re: [PATCH] mm: per-thread vma caching
Date: Fri, 21 Feb 2014 20:57:26 -0800
Message-ID: <1393045046.2473.6.camel@buesod1.americas.hpqcorp.net>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
	 <1393016226.3039.44.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFzw24Mwk_xw3QM_36-TbDOya=XZCqUeSSBVNS1QfjnWEw@mail.gmail.com>
	 <1393044955.2473.5.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393044955.2473.5.camel@buesod1.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Fri, 2014-02-21 at 20:55 -0800, Davidlohr Bueso wrote:
> On Fri, 2014-02-21 at 13:24 -0800, Linus Torvalds wrote:
> > On Fri, Feb 21, 2014 at 12:57 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > >
> > > Btw, one concern I had is regarding seqnum overflows... if such
> > > scenarios should happen we'd end up potentially returning bogus vmas and
> > > getting bus errors and other sorts of issues. So we'd have to flush the
> > > caches, but, do we care? I guess on 32bit systems it could be a bit more
> > > possible to trigger given enough forking.
> > 
> > I guess we should do something like
> > 
> >     if (unlikely(!++seqnum))
> >         flush_vma_cache()
> > 
> > just to not have to worry about it.
> > 
> > And we can either use a "#ifndef CONFIG_64BIT" to disable it for the
> > 64-bit case (because no, we really don't need to worry about overflow
> > in 64 bits ;), or just decide that a 32-bit sequence number actually
> > packs better in the structures, and make it be an "u32" even on 64-bit
> > architectures?
> > 
> > It looks like a 32-bit sequence number might pack nicely next to the
> > 
> >     unsigned brk_randomized:1;
> 
> And probably specially so for structures like task and mm. I hadn't
> considered the benefits of packing vs overflowing. So we can afford
> flushing all tasks's vmacache every 4 billion forks.

ah, not quite that much, I was just thinking of dup_mmap, of course we
also increment upon invalidations.
