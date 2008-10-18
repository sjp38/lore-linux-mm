Date: Fri, 17 Oct 2008 17:25:26 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <Pine.LNX.4.64.0810180045370.8995@blonde.site>
Message-ID: <alpine.LFD.2.00.0810171717470.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site> <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810180045370.8995@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 18 Oct 2008, Hugh Dickins wrote:
> 
> But they're doing it to make the page's ptes accessible to
> memory reclaim, and the CPU doing memory reclaim will not
> (unless by coincidence) have done that anon_vma_prepare() -
> it's just reading the links which the faulters are providing.

Ahh. Good point. Then yes, those ones would really need the 
smp_read_barrier_depends() too.

Very annoying.

Of course, we _could_ just admit that the situation is really *really* 
unlikely, and there are probably something like five people running 
Linux/alpha, and that we don't care enough. With just the smp_wmb(), we 
cover all non-alpha people, since this is all through a pointer, so all 
the readers will inevitably be of the smp_read_barrier_depends kind.

If we want to guarantee the proper smp_read_barrier_depends() behaviour, 
then we'd need to find them all. Possibly by renaming the whole field 
(prepend an underscore like we usually do) and forcing all readers to use 
some "get_anon_vma(vma)" helper function, aka

  static inline struct anon_vma *get_anon_vma(struct vm_area_struct *vma)
  {
	struct anon_vma *anon_vma = vma->_anon_vma;
	smp_read_barrier_depends();
	return anon_vma;
  }

which would find them all.

Ugh. I really would have preferred not having something like that. 
Especially considering how limited that issue really is. Hmm. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
