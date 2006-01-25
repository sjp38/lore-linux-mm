Date: Wed, 25 Jan 2006 11:57:37 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] non-refcounted pages, application to slab?
Message-ID: <20060125105737.GB30421@wotan.suse.de>
References: <20060125093909.GE32653@wotan.suse.de> <43D75239.90907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <43D75239.90907@cosmosbay.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 11:26:01AM +0100, Eric Dumazet wrote:
> Nick Piggin a ecrit :
> >If an allocator knows exactly the lifetime of its page, then there is no
> >need to do refcounting or the final put_page_zestzero (atomic op + mem
> >barriers).
> >
> >This is probably not worthwhile for most cases, but slab did strike me
> >as a potential candidate (however the complication here is that some
> >code I think uses the refcount of underlying pages of slab allocations
> >eg nommu code). So it is not a complete patch, but I wonder if anyone
> >thinks the savings might be worth the complexity?
> >
> >Is there any particular code that is really heavy on slab allocations?
> >That isn't mostly handled by the slab's internal freelists?
> 
> Hi Nick
> 
> After reading your patch, I have some crazy idea.
> 
> The atomic op + mem barrier you want to avoid could be avoided more 
> generally just by changing atomic_dec_and_test(atomic_t *v).
> 
> If the current thread is the last referer (refcnt = 1), then it can safely 
> set the value to 0 because no other CPU can be touching the value (or else 
> there must be a bug somewhere, as the 'other cpu' could touch the value 
> just after us and we could free an object still in use by 'other cpu'
> 

I think that would work for this case, but you change the semantics
of the function for all users which is bad.

Such a test could be open coded in __free_page, although that does
add a branch + some icache, but that might also be an option. (and
my patch does also add to total icache footprint and is much uglier ;))

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
