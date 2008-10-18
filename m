Date: Fri, 17 Oct 2008 19:53:49 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081018022541.GA19018@wotan.suse.de>
Message-ID: <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org> <20081018013258.GA3595@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org> <20081018022541.GA19018@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 18 Oct 2008, Nick Piggin wrote:
> @@ -171,6 +181,10 @@ static struct anon_vma *page_lock_anon_v
>  
>  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>  	spin_lock(&anon_vma->lock);
> +
> +	if (anon_mapping != (unsigned long)page->mapping)
> +		goto out;
> +
>  	return anon_vma;
>  out:
>  	rcu_read_unlock();

I see why you'd like to try to do this, but look a bit closer, and you'll 
realize that this is *really* wrong.

So there's the brown-paper-bag-reason why it's wrong: you need to unlock 
in this case, but there's a subtler reason why I doubt the whole approach 
works: I don't think we actually hold the anon_vma lock when we set 
page->mapping.

So I don't think you really fixed the race that you want to fix, and I 
don't think that does what you wanted to do.

But I might have missed something.

I'm off to play poker. It's Friday night, there's only so many memory 
ordering and locking issues I can take in one day. I'm hoping that by the 
time I look at this again, you and Hugh will have sorted it out.

			Linus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
