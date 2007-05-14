Received: by an-out-0708.google.com with SMTP id c10so390663ana
        for <linux-mm@kvack.org>; Mon, 14 May 2007 00:38:16 -0700 (PDT)
Message-ID: <89af10f90705140038u1a592909yf212294c4b28c967@mail.gmail.com>
Date: Mon, 14 May 2007 13:08:16 +0530
From: "ashwin chaugule" <ashwin.chaugule@gmail.com>
Subject: Re: [PATCH] Bug in mm/thrash.c function grab_swap_token()
In-Reply-To: <464771CA.3080906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070510122359.GA16433@srv1-m700-lanp.koti>
	 <20070510152957.edb26df3.akpm@linux-foundation.org>
	 <1178866168.4497.6.camel@localhost.localdomain>
	 <464771CA.3080906@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: ashwin.chaugule@celunite.com, Andrew Morton <akpm@linux-foundation.org>, mikukkon@iki.fi, Mika Kukkonen <mikukkon@miku.homelinux.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >>> @@ -48,9 +48,8 @@ void grab_swap_token(void)
> >>>             if (current_interval < current->mm->last_interval)
> >>>                     current->mm->token_priority++;
> >>>             else {
> >>> -                   current->mm->token_priority--;
> >>> -                   if (unlikely(current->mm->token_priority < 0))
> >>> -                           current->mm->token_priority = 0;
> >>> +                   if (likely(current->mm->token_priority > 0))
> >>> +                           current->mm->token_priority--;
> >>>             }
> >>>             /* Check if we deserve the token */
> >>>             if (current->mm->token_priority >
> >> argh.
> >>
> >> This has potential to cause large changes in system performance.
> >
> > I'm not sure how. Although, I think the logic still remains the same.
> > IOW, if the prio decrements to zero, it will remain zero until it
> > contends for token rapidly.
>
> The problem is that the original code would decrement an
> unsigned variable beyond zero, underflowing to a number
> just under 2^32...
>
> That would make the process basically a permanent owner
> of the swap token.


Hm. Although, the probability of token_prio going below zero in the
previous code was quite small. Nevertheless, I shall run the new fix
through some tests and post the results asap.

Cheers,
Ashwin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
