Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC089000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 15:49:48 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1337612vxg.14
        for <linux-mm@kvack.org>; Thu, 07 Jul 2011 12:49:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110707.122151.314840355798805828.davem@davemloft.net>
References: <alpine.DEB.2.00.1107071314320.21719@router.home>
	<1310064771.21902.55.camel@jaguar>
	<alpine.DEB.2.00.1107071402490.24248@router.home>
	<20110707.122151.314840355798805828.davem@davemloft.net>
Date: Thu, 7 Jul 2011 22:49:46 +0300
Message-ID: <CAOJsxLFsX3Q84QAeyRt5dZOdRxb3TiABPrP-YrWc91+BmR8ZBg@mail.gmail.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: cl@linux.com, marcin.slusarz@gmail.com, mpm@selenic.com, linux-kernel@vger.kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, Jul 7, 2011 at 10:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Christoph Lameter <cl@linux.com>
> Date: Thu, 7 Jul 2011 14:12:37 -0500 (CDT)
>
>> On Thu, 7 Jul 2011, Pekka Enberg wrote:
>>
>>> On Thu, 7 Jul 2011, Pekka Enberg wrote:
>>> > > Looks good to me. Christoph, David, ?
>>>
>>> On Thu, 2011-07-07 at 13:17 -0500, Christoph Lameter wrote:
>>> > The reason debug code is there is because it is useless overhead typi=
cally
>>> > not needed. There is no point in optimizing the code that is not run =
in
>>> > production environments unless there are gross performance issues tha=
t
>>> > make debugging difficult. A performance patch for debugging would hav=
e to
>>> > cause significant performance improvements. This patch does not do th=
at
>>> > nor was there such an issue to be addressed in the first place.
>>>
>>> Is there something technically wrong with the patch? Quoting the patch
>>> email:
>>>
>>> =A0 (Compiling some project with different options)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0make=
 -j12 =A0 =A0make clean
>>> =A0 slub_debug disabled: =A0 =A0 =A0 =A0 =A0 =A0 1m 27s =A0 =A0 =A0 1.2=
 s
>>> =A0 slub_debug enabled: =A0 =A0 =A0 =A0 =A0 =A0 =A01m 46s =A0 =A0 =A0 7=
.6 s
>>> =A0 slub_debug enabled + this patch: 1m 33s =A0 =A0 =A0 3.2 s
>>>
>>> =A0 check_bytes still shows up high, but not always at the top.
>>>
>>> That's significant enough speedup for me!
>>
>> Ok. I had a different set of numbers in mind from earlier posts.
>>
>> The benefit here comes from accessing memory in larger (word) chunks
>> instead of byte wise. This is a form of memscan() with inverse matching.
>>
>> Isnt there an asm optimized version that can do this much better (there =
is
>> one for memscan())? Optimizing this in core code by codeing something as
>> generic as that is not that good since the arch code can deliver better
>> performance and it seems that this is functionality that could be useful
>> elsewhere.
>
> You're being so unreasonable, just let the optimization in, refine it
> with follow-on patches.

I applied the patch. I think a follow up patch that moves the function
to lib/string.c with proper generic name would be in order. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
