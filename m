Date: Fri, 31 Jan 2003 00:50:26 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: New version of frlock (now called seqlock)
Message-ID: <20030130235026.GX18538@dualathlon.random>
References: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net> <3E39B8E6.5F668D28@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E39B8E6.5F668D28@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Stephen Hemminger <shemminger@osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 30, 2003 at 03:44:38PM -0800, Andrew Morton wrote:
> Stephen Hemminger wrote:
> > 
> > This is an update to the earlier frlock.
> > 
> 
> Sorry, but I have lost track of what version is what.  Please
> let me get my current act together and then prepare diffs
> against (or new versions of) that.
> 
> You appear to have not noticed my earlier suggestions wrt
> coding tweaks and inefficiencies in the new implementation.
> 
> - SEQ_INIT and seq_init can go away.
> 
> - do seq_write_begin/end need wmb(), or mb()?  Probably, we
>   should just remove these functions altogether.
> 
> -
> 	+static inline int seq_read_end(const seqcounter_t *s, unsigned iv)
> 	+{
> 	+       mb();
> 	+       return (s->counter != iv) || (iv & 1);
> 	+}
> 
>   So the barriers changed _again_!  Could we please at least
>   get Richard Henderson and Andrea to agree that this is the
>   right way to do it?

the right way is the one used by x86-64 vgettimeofday and
i_size_read/write in my tree (and frlock in my tree too for x86
gettimeofday)

that is pure rmb() in read_lock and pure wmb() in write_lock

never mb()

The only place where mb() could be somehow interesting is the
write_begin/end but it's mostly a theorical interest, and we both think
that write_begin/end is pointless, since the lock part is useless for
them, and in turn write_begin/end aren't that clean anyways.


> 
> -
> 	+typedef struct {
> 	+       volatile unsigned counter;
> 	+} seqcounter_t;
> 
>   Why did this become a struct?
> 
>   Why is it volatile?

it definitely doesn't need to be volatile

on the struct or not I don't mind either ways

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
