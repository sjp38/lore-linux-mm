Date: Sun, 19 Oct 2008 11:25:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
Message-ID: <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de>  <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>  <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>  <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>  <20081018013258.GA3595@wotan.suse.de>  <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>  <20081018022541.GA19018@wotan.suse.de>  <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
  <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>  <Pine.LNX.4.64.0810191048410.11802@blonde.site> <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sun, 19 Oct 2008, Peter Zijlstra wrote:
> 
> Part of the confusion is that we don't clear those pointers at the end
> of their lifetimes (page_remove_rmap and anon_vma_unlink).
> 
> I guess the !page_mapping() test in page_lock_anon_vma() is meant to
> deal with this

Hmm. So that part I'm still not entirely convinced about.

The thing is, we have two issues on anon_vma usage, and the
page_lock_anon_vma() usage in particular:

 - the integrity of the list itself

   Here it should be sufficient to just always get the lock, to the point 
   where we don't need to care about anything else. So getting the lock 
   properly on new allocation makes all the other races irrelevant.

 - the integrity of the _result_ of traversing the list

   This is what the !page_mapping() thing is supposedly protecting 
   against, I think.

   But as far as I can tell, there's really two different use cases here: 
   (a) people who care deeply about the result and (b) people who don't.

   And the difference between the two cases is whether they had the page 
   locked or not. The "try_to_unmap()" callers care deeply, and lock the 
   page. In contrast, some "page_referenced()" callers (really just 
   shrink_active_list) don't care deeply, and to them the return value is 
   really just a heuristic.

As far as I can tell, all the people who care deeply will lock the page 
(and _have_ to lock the page), and thus 'page->mapping' should be stable 
for those cases.

And then we have the other cases, who just want a heuristic, and they 
don't hold the page lock, but if we look at the wrong active_vma that has 
gotten reallocated to something else, they don't even really care. 

So I'm not seeing the reason for that check for page_mapped() at the end. 
Does it actually protect against anything relevant?

Anyway, I _think_ the part that everybody agrees about is the initial 
locking of the anon_vma. Whether we then even need any memory barriers 
and/or the page_mapped() check is an independent question. Yes? No?

So I'm suggesting this commit as the part we at least all agree on. But I 
haven't pushed it out yet, so you can still holler.. But I think all the 
discussion is about other issues, and we all agree on at least this part?

		Linus

---
