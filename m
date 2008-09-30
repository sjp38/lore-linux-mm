Message-ID: <48E205BE.8030908@cosmosbay.com>
Date: Tue, 30 Sep 2008 12:55:58 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
References: <20080926173219.885155151@twins.programming.kicks-ass.net>	 <20080927161712.GA1525@elte.hu>	 <200809301721.52148.nickpiggin@yahoo.com.au> <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
In-Reply-To: <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra a ecrit :
> Just to be sure, I only hold the page lock over the get_futex_key() op,
> and drop it after getting a ref on the futex key.
> 
> I then drop the futex key ref after the futex op is complete.
> 
> This assumes the futex key ref is suffucient to guarantee whatever is
> needed - which is the point I'm still not quite sure about myself.
> 
> The futex key ref was used between futex ops, with I assume the intent
> to ensure the futex backing stays valid. However, the key ref only takes
> a ref on either the inode or the mm, neither which avoid the specific
> address of the futex to get unmapped between ops.
> 
> So in that respect we're not worse off than before, and any application
> doing: futex_wait(), munmap(), futex_wake() is going to suffer. And as
> far as I understand it get the waiting task stuck in D state for
> ever-more or somesuch.
> 
> By now not holding the mmap_sem over the full futex op, but only over
> the get_futex_key(), that munmap() race gets larger and the actual futex
> could disappear while we're working on it, but in all cases I looked at
> that will make the futex op return -EFAULT, so we should be good there.
> 
> Gah, now that I look at it, it looks like I made get_futex_key()
> asymetric wrt private futexes, they don't take a ref on the key, but
> then do drop one... ouch.. Patch below.
> 
>> Nice work, Peter.
> 
> Thanks!
> 
>> BTW. what kinds of things use inter-process futexes as of now?
> 
> On a regular modern Linux system, not much. But I've been told there are
> applications out there that do indeed make heavy use of them - as
> they're part of POSIX etc.. blah blah :-)

inter-process futexes are still used for pthread creation/join 
(aka clear_child_tid / CLONE_CHILD_CLEARTID)

kernel/fork.c, functions mm_release() & sys_set_tid_address()

I am not sure how it could be converted to private futexes, since
old binaries (static glibc) will use FUTEX_WAKE like calls.

> 
> Also some legacy stuff that's stuck on an ancient glibc (but somehow did
> manage to upgrade the kernel) might benefit.
> 
> 
> ---
> Subject: futex: fixup get_futex_key() for private futexes
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> With the get_user_pages_fast() patches we made get_futex_key() obtain a
> reference on the returned key, but failed to do so for private futexes.
> 

Sorry I am lost...
private futexes dont need to get references at all...

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> diff --git a/kernel/futex.c b/kernel/futex.c
> index 197fdab..beee9af 100644
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -227,6 +227,7 @@ static int get_futex_key(u32 __user *uaddr, int
> fshared, union futex_key *key)
>  			return -EFAULT;
>  		key->private.mm = mm;
>  		key->private.address = address;
> +		get_futex_key_refs(key);
>  		return 0;
>  	}
>  
> 
> 
> 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
