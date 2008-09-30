Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <48E205BE.8030908@cosmosbay.com>
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
	 <20080927161712.GA1525@elte.hu>
	 <200809301721.52148.nickpiggin@yahoo.com.au>
	 <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
	 <48E205BE.8030908@cosmosbay.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Sep 2008 13:16:19 +0200
Message-Id: <1222773379.12646.33.camel@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-30 at 12:55 +0200, Eric Dumazet wrote:
> Peter Zijlstra a A(C)crit :

> > On a regular modern Linux system, not much. But I've been told there are
> > applications out there that do indeed make heavy use of them - as
> > they're part of POSIX etc.. blah blah :-)
> 
> inter-process futexes are still used for pthread creation/join 
> (aka clear_child_tid / CLONE_CHILD_CLEARTID)
> 
> kernel/fork.c, functions mm_release() & sys_set_tid_address()
> 
> I am not sure how it could be converted to private futexes, since
> old binaries (static glibc) will use FUTEX_WAKE like calls.

Ah, thanks, didn't know that.

> > ---
> > Subject: futex: fixup get_futex_key() for private futexes
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > 
> > With the get_user_pages_fast() patches we made get_futex_key() obtain a
> > reference on the returned key, but failed to do so for private futexes.
> > 
> 
> Sorry I am lost...
> private futexes dont need to get references at all...

Ah, right - its a NOP, that's why it didn't show up in testing.

The thing is, I changed the semantics of get_futex_key() to return a key
with reference taken. And then noticed I didn't take one in the private
futex path, and failed to notice the ref ops are nops for private
futexes.

So yeah, the below patch is basically a NOP, but we might consider
retaining it to maintain the symmetry... dunno

> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> > diff --git a/kernel/futex.c b/kernel/futex.c
> > index 197fdab..beee9af 100644
> > --- a/kernel/futex.c
> > +++ b/kernel/futex.c
> > @@ -227,6 +227,7 @@ static int get_futex_key(u32 __user *uaddr, int
> > fshared, union futex_key *key)
> >  			return -EFAULT;
> >  		key->private.mm = mm;
> >  		key->private.address = address;
> > +		get_futex_key_refs(key);
> >  		return 0;
> >  	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
