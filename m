Date: Fri, 14 Jan 2005 20:37:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050113232214.84887.qmail@web14303.mail.yahoo.com>
Message-ID: <Pine.LNX.4.44.0501142012300.2938-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2005, Kanoj Sarcar wrote:
> 
> Thanks, I think this explains it. IE, if do_no_page()
> reads truncate_count, and then later goes on to
> acquire a lock in nopage(), the smp_rmb() is
> guaranteeing that the read of truncate_count completes
> before nopage() starts executing. 
> 
> For x86 at least, it seems to me that since the
> spin_lock (in nopage()) uses a "lock" instruction,
> that itself guarantees that the truncate_count read is
> completed, even without the smp_rmb(). (Refer to IA32
> SDM Vol 3 section 7.2.4 last para page 7-11). Thus for
> x86, the smp_rmb is superfluous.

You're making me nervous.  If you look at 2.6.11-rc1 you'll find
that I too couldn't see the point of that smp_rmb(), on any architecture,
and so removed it; while also removing the "atomicity" of truncate_count.

Here was my comment to that patch:
> Why is mapping->truncate_count atomic?  It's incremented inside
> i_mmap_lock (and i_sem), and the reads don't need it to be atomic.
> 
> And why smp_rmb() before call to ->nopage?  The compiler cannot reorder
> the initial assignment of sequence after the call to ->nopage, and no
> cpu (yet!) can read from the future, which is all that matters there.

Now I'm not so convinced by that "no cpu can read from the future".

I don't entirely follow your remarks above, but I do think people
on this thread have a better grasp of these matters than I have:
does anyone now think that smp_rmb() needs to be restored?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
