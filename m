From: Neil Brown <neilb@suse.de>
Date: Tue, 12 Aug 2008 19:33:16 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18593.22748.791219.689521@notabene.brown>
Subject: Re: [PATCH 02/30] mm: gfp_to_alloc_flags()
In-Reply-To: message from Peter Zijlstra on Tuesday August 12
References: <20080724140042.408642539@chello.nl>
	<20080724141529.408041430@chello.nl>
	<18593.6448.132048.150818@notabene.brown>
	<1218526385.10800.165.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tuesday August 12, a.p.zijlstra@chello.nl wrote:
> On Tue, 2008-08-12 at 15:01 +1000, Neil Brown wrote:
> > Did I miss something?
> > If I did, maybe more text in the changelog entry (or the comment)
> > would help.
> 
> Ok, so the old code did:
> 
>   if (((p->flags & PF_MEMALLOC) || ...) && !in_interrupt) {
>     ....
>     goto nopage;
>   }
> 
> which avoid anything that has PF_MEMALLOC set from entering into direct
> reclaim, right?
> 
> Now, the new code reads:
> 
>   if (alloc_flags & ALLOC_NO_WATERMARK) {
>   }
> 
> Which might be false, even though we have PF_MEMALLOC set -
> __GFP_NOMEMALLOC comes to mind.
> 
> So we have to stop that recursion from happening.
> 
> so we add:
> 
>   if (p->flags & PF_MEMALLOC)
>     goto nopage;
> 
> Now, if it were done before the !wait check, we'd have to consider
> atomic contexts, but as those are - as you rightly pointed out - handled
> by the !wait case, we can plainly do this check.
> 
> 

Oh yes, obvious when you explain it, thanks.

cat << END >> Changelog

As the test
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
-		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
has been replaced with a slightly strong
+	if (alloc_flags & ALLOC_NO_WATERMARKS) {

we need to ensure we don't recurse when PF_MEMALLOC is set

END

??

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
