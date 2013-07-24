Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C43546B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:22:07 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id cy12so1497003veb.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:22:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130724181516.GI8508@moon>
References: <20130724160826.GD24851@moon> <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon> <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon> <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com> <20130724181516.GI8508@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 24 Jul 2013 11:21:46 -0700
Message-ID: <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 11:15 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Wed, Jul 24, 2013 at 10:42:24AM -0700, Andy Lutomirski wrote:
>> >
>> > Lets just be clear about the problem first: the vmscan pass referred to
>> > above happens only on clean pages, so the soft dirty bit could only be
>> > set if the page was previously dirty and got written back.  Now it's an
>> > exercise for the reader whether we want to reinstantiate a cleaned
>> > evicted page for the purpose of doing an iterative migration or whether
>> > we want to flip the page in the migrated entity to be evicted (so if it
>> > gets referred to, it pulls in an up to date copy) ... assuming the
>> > backing file also gets transferred, of course.
>
> Good question! I rather forward it to Pavel as an author for soft dirty
> bit feature. Pavel?
>
>> I think I understand your distinction.  Nonetheless, given the loss of
>> the soft-dirty bit, the migration tool could fail to notice that the
>> pages was dirtied and subsequently cleaned and evicted.  I'm
>> unconvinced that doing this on a per-PTE basis is the right way,
>> though.
>
> I fear for tracking soft-dirty-bit for swapped entries we sinply have
> no other place than pte (still i'm quite open for ideas, maybe there
> are a better way which I've missed).

I know approximately nothing about how swap and anon_vma work.

For files, sticking it in struct page seems potentially nicer,
although finding a free bit might be tough.  (FWIW, I have plans to
free up a page flag on x86 some time moderately soon as part of a
completely unrelated project.)  I think this stuff really belongs to
the address_space more than it belongs to the pte.

How do you handle the write syscall?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
