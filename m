Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A75396B005C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:59:00 -0400 (EDT)
Received: by pxi40 with SMTP id 40so27806pxi.12
        for <linux-mm@kvack.org>; Tue, 16 Jun 2009 19:00:52 -0700 (PDT)
Date: Wed, 17 Jun 2009 11:00:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 2/2] mm: remove task assumptions from swap token
Message-Id: <20090617110034.db01479b.minchan.kim@barrios-desktop>
In-Reply-To: <1245189037-22961-2-git-send-email-hannes@cmpxchg.org>
References: <Pine.LNX.4.64.0906162152250.12770@sister.anvils>
	<1245189037-22961-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Hannes. 

How about adding Hugh's comment ?

I think that is more straightforward and easy.
And it explained even real example like KSM. 

So I suggest following as.. 

==
grab_swap_token() should not make any assumptions about the running
process as the swap token is an attribute of the address space and the
faulting mm is not necessarily current->mm.

If a kthread happens to use get_user_pages() on an mm (as KSM does),
there's a chance that it will end up trying to read in a swap page,
then oops in grab_swap_token() because the kthread has no mm: GUP
passes down the right mm, so grab_swap_token() ought to be using it.
==

Anyway, It looks good to me. 
It might be just nitpick :)
If you feel it, ignore me. 
Anyway I am OK. 

On Tue, 16 Jun 2009 23:50:37 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> grab_swap_token() should not make any assumptions about the running
> process as the swap token is an attribute of the address space and the
> faulting mm is not necessarily current->mm.
> 
> This fixes get_user_pages() from kernel threads which would blow up
> when encountering a swapped out page and grab_swap_token()
> dereferencing the unset for kernel threads current->mm.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
