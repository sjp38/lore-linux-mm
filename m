Message-ID: <20050113232214.84887.qmail@web14303.mail.yahoo.com>
Date: Thu, 13 Jan 2005 15:22:14 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050113215955.GB6309@krispykreme.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Anton,

Thanks, I think this explains it. IE, if do_no_page()
reads truncate_count, and then later goes on to
acquire a lock in nopage(), the smp_rmb() is
guaranteeing that the read of truncate_count completes
before nopage() starts executing. 

For x86 at least, it seems to me that since the
spin_lock (in nopage()) uses a "lock" instruction,
that itself guarantees that the truncate_count read is
completed, even without the smp_rmb(). (Refer to IA32
SDM Vol 3 section 7.2.4 last para page 7-11). Thus for
x86, the smp_rmb is superfluous.

See below also.

--- Anton Blanchard <anton@samba.org> wrote:

>  
> Hi Kanoj,
> 
> > Okay, I think I see what you and wli meant. But
> the assumption that
> > spin_lock will order memory operations is still
> correct, right?
> 
> A spin_lock will only guarantee loads and stores
> inside the locked
> region dont leak outside. Loads and stores before
> the spin_lock may leak
> into the critical region. Likewise loads and stores
> after the
> spin_unlock may leak into the critical region.

Looking at the membars in
include/asm-sparc64/spinlock.h, what the sparc port
seems to be doing is guranteeing that no stores prior
to the spinlock() can leak into the critical region,
and no stores in the critical region can leak outside
the spinunlock.

Thanks.

Kanoj

> 
> Also they dont guarantee ordering for cache
> inhibited loads and stores.
> 
> Anton
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org">
> aart@kvack.org </a>
> 



		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - Get yours free! 
http://my.yahoo.com 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
