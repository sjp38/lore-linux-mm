Received: by wa-out-1112.google.com with SMTP id j37so2667805waf.22
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 09:57:31 -0700 (PDT)
Message-ID: <84144f020810070957y241a16d6y2d03f451aa3dd4a7@mail.gmail.com>
Date: Tue, 7 Oct 2008 19:57:31 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [BUG] SLOB's krealloc() seems bust
In-Reply-To: <1223397455.13453.385.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org>
	 <1223391655.13453.344.camel@calx>
	 <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
	 <1223397455.13453.385.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>
List-ID: <linux-mm.kvack.org>

Hi Matt,

On Tue, Oct 7, 2008 at 7:37 PM, Matt Mackall <mpm@selenic.com> wrote:
> SLOB: fix bogus ksize calculation
>
> SLOB's ksize calculation was braindamaged and generally harmlessly
> underreported the allocation size. But for very small buffers, it could
> in fact overreport them, leading code depending on krealloc to overrun
> the allocation and trample other data.
>
> Signed-off-by: Matt Mackall <mpm@selenic.com>
> Tested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> diff -r 5e32b09a1b2b mm/slob.c
> --- a/mm/slob.c Fri Oct 03 14:04:43 2008 -0500
> +++ b/mm/slob.c Tue Oct 07 11:27:47 2008 -0500
> @@ -515,7 +515,7 @@
>
>        sp = (struct slob_page *)virt_to_page(block);
>        if (slob_page(sp))
> -               return ((slob_t *)block - 1)->units + SLOB_UNIT;
> +               return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;

Hmm. I don't understand why we do the "minus one" thing here. Aren't
we underestimating the size now? Side note, why aren't we using
slob_units() here?

>        else
>                return sp->page.private;
>  }
>
>
>
>
>
> --
> Mathematics is the supreme nostalgia of our time.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
