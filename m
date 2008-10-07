Received: by wf-out-1314.google.com with SMTP id 28so3671877wfc.11
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 10:31:16 -0700 (PDT)
Message-ID: <84144f020810071031n39c27966ubfafd86e5542ea75@mail.gmail.com>
Date: Tue, 7 Oct 2008 20:31:16 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [BUG] SLOB's krealloc() seems bust
In-Reply-To: <1223399619.13453.389.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org>
	 <1223391655.13453.344.camel@calx>
	 <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
	 <1223397455.13453.385.camel@calx>
	 <84144f020810070957y241a16d6y2d03f451aa3dd4a7@mail.gmail.com>
	 <1223399619.13453.389.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>
List-ID: <linux-mm.kvack.org>

Hi Matt,

On Tue, Oct 7, 2008 at 8:13 PM, Matt Mackall <mpm@selenic.com> wrote:
>> > @@ -515,7 +515,7 @@
>> >
>> >        sp = (struct slob_page *)virt_to_page(block);
>> >        if (slob_page(sp))
>> > -               return ((slob_t *)block - 1)->units + SLOB_UNIT;
>> > +               return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;
>>
>> Hmm. I don't understand why we do the "minus one" thing here. Aren't
>> we underestimating the size now?
>
> The first -1 takes us to the object header in front of the object
> pointer. The second -1 subtracts out the size of the header.
>
> But it's entirely possible I'm off by one, so I'll double-check. Nick?

Yeah, I was referring to the second subtraction. Looking at
slob_page_alloc(), for example, we compare the return value of
slob_units() to SLOB_UNITS(size), so I don't think we count the header
in ->units. I mean, we ought to be seeing the subtraction elsewhere in
the code as well, no?

                  Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
