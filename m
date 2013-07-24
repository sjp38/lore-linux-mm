Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 7173A6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:55:54 -0400 (EDT)
Message-ID: <51F0232D.6060306@parallels.com>
Date: Wed, 24 Jul 2013 22:55:41 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
References: <20130724160826.GD24851@moon> <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com> <20130724163734.GE24851@moon> <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com> <20130724171728.GH8508@moon> <1374687373.7382.22.camel@dabdike> <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com> <20130724181516.GI8508@moon> <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com> <20130724185256.GA24365@moon>
In-Reply-To: <20130724185256.GA24365@moon>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On 07/24/2013 10:52 PM, Cyrill Gorcunov wrote:
> On Wed, Jul 24, 2013 at 11:21:46AM -0700, Andy Lutomirski wrote:
>>>
>>> I fear for tracking soft-dirty-bit for swapped entries we sinply have
>>> no other place than pte (still i'm quite open for ideas, maybe there
>>> are a better way which I've missed).
>>
>> I know approximately nothing about how swap and anon_vma work.
>>
>> For files, sticking it in struct page seems potentially nicer,
>> although finding a free bit might be tough.  (FWIW, I have plans to
>> free up a page flag on x86 some time moderately soon as part of a
>> completely unrelated project.)  I think this stuff really belongs to
>> the address_space more than it belongs to the pte.
> 
> Well, some part of information already lays in pte (such as 'file' bit,
> swap entries) so it looks natural i think to work on this level. but
> letme think if use page struct for that be more convenient...

It hardly will be. Consider we have a page shared between two tasks,
then first one "touches" it and soft-dirty is put onto his PTE and,
subsequently, the page itself. The we go and clear sofr-dirty for the
2nd task. What should we do with the soft-dirty bit on the page?

The soft-dirty thing watches changes in the virtual memory, not in
the physical one.

>>
>> How do you handle the write syscall?
> 
> I fear I somehow miss your point here, could please alaborate a bit?
> There is no additional code I know of being write() specific, just
> a code for #PF exceptions.
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
