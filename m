Message-ID: <3BC9DFA3.D9699230@earthlink.net>
Date: Sun, 14 Oct 2001 18:55:31 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: VM question: side effect of not scanning Active pages?
References: <3BCA2015.5080306@ucla.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin Redelings I wrote:
> 
> Hello,
>         In both Andrea and Rik's VM, I have tried modifying try_to_swap_out so
> that a page would be skipped if it is "active".  For example, I have
> currently modified 2.4.13-pre2 by adding:
> 
>           if (PageActive(page))
>                   return 0;
> 
> after testing the hardware referenced bit.  This was motivated by
> sections of VM-improvement patches written by both Rik and Andrea.
>         This SEEMS to increase performance, but it has another side effect.  The
> RSS of unused daemons no longer EVER drops to 4k, which it does without
> this modification.  The RSS does decrease (usually) to the value of
> shared memory, but the amount of shared memory only gets down to about
> 200-300k instead of decreasing to 4k.
>         Can anyone tell me why not scanning Active page for swapout would have
> this effect?  Thanks!

Well, you will never unmap active page. Essentially,
that means that once a page gets onto the active
list, it is effectively pinned in memory until all processes
using the page exit. This is probably not what you want.
You'll still see some pages get swapped out, of course,
because not all pages in use by processes live on the
active list (anonymous pages that have never been unmapped,
for example, don't, at least in the kernels I'm familiar
with; though I understand there's some talk of changing
that).

Cheers,

-- Joe
# "You know how many remote castles there are along the
#  gorges? You can't MOVE for remote castles!" - Lu Tze re. Uberwald
# Linux MM docs:
http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
