Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 142B56B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:42:46 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id m1so7166500ves.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:42:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374687373.7382.22.camel@dabdike>
References: <20130724160826.GD24851@moon> <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon> <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon> <1374687373.7382.22.camel@dabdike>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 24 Jul 2013 10:42:24 -0700
Message-ID: <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 10:36 AM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Wed, 2013-07-24 at 21:17 +0400, Cyrill Gorcunov wrote:
>> On Wed, Jul 24, 2013 at 10:06:53AM -0700, Andy Lutomirski wrote:
>> > > Hi Andy, if I understand you correctly "file-backed pages" are carried
>> > > in pte with _PAGE_FILE bit set and the swap soft-dirty bit won't be
>> > > used on them but _PAGE_SOFT_DIRTY will be set on write if only I've
>> > > not missed something obvious (Pavel?).
>> >
>> > If I understand this stuff correctly, the vmscan code calls
>> > try_to_unmap when it reclaims memory, which makes its way into
>> > try_to_unmap_one, which clears the pte (and loses the soft-dirty bit).
>>
>> Indeed, I was so stareing into swap that forgot about files. I'll do
>> a separate patch for that, thanks!
>
> Lets just be clear about the problem first: the vmscan pass referred to
> above happens only on clean pages, so the soft dirty bit could only be
> set if the page was previously dirty and got written back.  Now it's an
> exercise for the reader whether we want to reinstantiate a cleaned
> evicted page for the purpose of doing an iterative migration or whether
> we want to flip the page in the migrated entity to be evicted (so if it
> gets referred to, it pulls in an up to date copy) ... assuming the
> backing file also gets transferred, of course.

I think I understand your distinction.  Nonetheless, given the loss of
the soft-dirty bit, the migration tool could fail to notice that the
pages was dirtied and subsequently cleaned and evicted.  I'm
unconvinced that doing this on a per-PTE basis is the right way,
though.

I've long wanted a feature to efficiently see what changed on a
filesystem by comparing, say, a hash tree.  NTFS can do this (sort
of), but I don't think that anything else can.  I think that btrfs
should be able to, but there's no API that I've ever seen.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
