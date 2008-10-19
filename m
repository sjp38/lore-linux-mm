Date: Sun, 19 Oct 2008 10:52:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <1224326299.28131.132.camel@twins>
Message-ID: <Pine.LNX.4.64.0810191048410.11802@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
 <20081018013258.GA3595@wotan.suse.de>  <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
  <20081018022541.GA19018@wotan.suse.de>  <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
  <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Oct 2008, Peter Zijlstra wrote:
> 
> fault_creation:
> 
>  anon_vma_prepare()
>  page_add_new_anon_rmap();
> 
> expand_creation:
> 
>  anon_vma_prepare()
>  anon_vma_lock();
> 
> rmap_lookup:
> 
>  page_referenced()/try_to_unmap()
>    page_lock_anon_vma()
> 
> vma_lookup:
> 
>  vma_adjust()/vma_*
>    vma->anon_vma
> 
> teardown:
> 
>  unmap_vmas()
>    zap_range()
>       page_remove_rmap()
>       free_page()
>  free_pgtables()
>    anon_vma_unlink()
>    free_range()
>   
> IOW we remove rmap, free the page (set mapping=NULL) and then unlink and
> free the anon_vma.
> 
> But at that time vma->anon_vma is still set.
> 
> 
> head starts to hurt,.. 

Comprehension isn't my strong suit at the moment: I don't grasp
what problem you're seeing here - if you can spell it out in more
detail for me, I'd like to try stopping your head hurt - though not
at cost of making mine hurt more!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
