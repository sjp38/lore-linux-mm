Date: Wed, 25 Jan 2006 12:18:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] non-refcounted pages, application to slab?
Message-ID: <20060125111829.GD30421@wotan.suse.de>
References: <20060125093909.GE32653@wotan.suse.de> <43D75239.90907@cosmosbay.com> <20060125105737.GB30421@wotan.suse.de> <43D75CB8.9090101@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43D75CB8.9090101@cosmosbay.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 12:10:48PM +0100, Eric Dumazet wrote:
> 
> So we cannot change atomic_dec_and_test(atomic_t *v) but introduce a new 
> function like :
> 
> int atomic_dec_refcount(atomic_t *v)
> {
> #ifdef CONFIG_SMP
>        /* avoid an atomic op if we are the last user of this refcount */
>        if (atomic_read(v) == 1) {
>                atomic_set(v, 0); /* not a real atomic op on most machines */
>                return 1;
>        }
> #endif
> 	return atomic_dec_and_test(v);
> }
> 
> The cost of the extra conditional branch is worth, if it can avoid an 
> atomic op.
> 

If it can always avoid an atomic op then the conditional branch is
useless, and if it can avoid the atomic op in 20% of cases then it
might still be useless (especially considering the extra icache).

Actual measurements would be required I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
