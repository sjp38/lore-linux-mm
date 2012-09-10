Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 761436B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 01:16:42 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so1306165wib.8
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 22:16:40 -0700 (PDT)
Message-ID: <504D77D0.70705@gmail.com>
Date: Mon, 10 Sep 2012 07:17:04 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
References: <1340959739.2936.28.camel@lappy> <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com> <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com> <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com> <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com> <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com> <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com> <504CCA31.2000003@zytor.com>
In-Reply-To: <504CCA31.2000003@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On 09/09/2012 06:56 PM, H. Peter Anvin wrote:
>>
>> Anyway, that means that the BUG_ON() is likely bogus, but so is the
>> whole calling convention.
>>
>> The 4kB range starting at 0xfffffffffffff000 sounds like a *valid*
>> range, but that requires that we fix the calling convention to not
>> have that "end" (exclusive) thing. It should either be "end"
>> (inclusive), or just "len".
>>
> 
> On x86, it is definitely NOT a valid range.  There is no physical addresses
> there, and there will never be any.

This reminds me a similar issue: If you try to mmap /dev/kmem at an offset which
is not kernel owned (such as 0), you'll get all the way to __pa() before getting
a BUG() about addresses not making sense.

How come there's no arch-specific validation of attempts to access
virtual/physical addresses? In the kmem example I'd assume that something very
early on should be yelling at me about doing something like that, but for some
reason I get all the way to __pa() before getting a BUG() (!).


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
