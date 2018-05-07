Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A01AF6B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 17:48:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x205-v6so17821842pgx.19
        for <linux-mm@kvack.org>; Mon, 07 May 2018 14:48:51 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id b9-v6si23088954pli.427.2018.05.07.14.48.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 May 2018 14:48:50 -0700 (PDT)
Subject: Re: *alloc API changes
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org>
 <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
 <20180507113902.GC18116@bombadil.infradead.org>
 <CAGXu5jKq7uZsDN8qLzKTUC2eVQT2f3ZvVbr8s9oQFeikun9NjA@mail.gmail.com>
 <20180507201945.GB15604@bombadil.infradead.org>
 <CAGXu5jL_vYWs7eKY34ews2pW24fvOqNPybmuugg9ycfR1siOLA@mail.gmail.com>
From: John Johansen <john.johansen@canonical.com>
Message-ID: <45a048cc-6f80-113f-a508-b23e60251237@canonical.com>
Date: Mon, 7 May 2018 14:48:43 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL_vYWs7eKY34ews2pW24fvOqNPybmuugg9ycfR1siOLA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On 05/07/2018 01:27 PM, Kees Cook wrote:
> On Mon, May 7, 2018 at 1:19 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> On Mon, May 07, 2018 at 09:03:54AM -0700, Kees Cook wrote:
>>> On Mon, May 7, 2018 at 4:39 AM, Matthew Wilcox <willy@infradead.org> wrote:
>>>> On Fri, May 04, 2018 at 09:24:56PM -0700, Kees Cook wrote:
>>>>> On Fri, May 4, 2018 at 8:46 PM, Matthew Wilcox <willy@infradead.org> wrote:
>>>>> The only fear I have with the saturating helpers is that we'll end up
>>>>> using them in places that don't recognize SIZE_MAX. Like, say:
>>>>>
>>>>> size = mul(a, b) + 1;
>>>>>
>>>>> then *poof* size == 0. Now, I'd hope that code would use add(mul(a,
>>>>> b), 1), but still... it makes me nervous.
>>>>
>>>> That's reasonable.  So let's add:
>>>>
>>>> #define ALLOC_TOO_BIG   (PAGE_SIZE << MAX_ORDER)
>>>>
>>>> (there's a presumably somewhat obsolete CONFIG_FORCE_MAX_ZONEORDER on some
>>>> architectures which allows people to configure MAX_ORDER all the way up
>>>> to 64.  That config option needs to go away, or at least be limited to
>>>> a much lower value).
>>>>
>>>> On x86, that's 4k << 11 = 8MB.  On PPC, that might be 64k << 9 == 32MB.
>>>> Those values should be relatively immune to further arithmetic causing
>>>> an additional overflow.
>>>
>>> But we can do larger than 8MB allocations with vmalloc, can't we?
>>
>> Yes.  And today with kvmalloc.  However, I proposed to Linus that
>> kvmalloc() shouldn't allow it -- we should have kvmalloc_large() which
>> would, but kvmalloc wouldn't.  He liked that idea, so I'm going with it.
> 
> How would we handle size calculations for _large?
> 
>> There are very, very few places which should need kvmalloc_large.
>> That's one million 8-byte pointers.  If you need more than that inside
>> the kernel, you're doing something really damn weird and should do
>> something that looks obviously different.
> 
> I'm CCing John since I remember long ago running into problems loading
> the AppArmor DFA with kmalloc and switching it to kvmalloc. John, how
> large can the DFAs for AppArmor get? Would an 8MB limit be a problem?
> 

theoretically yes, and I have done tests with policy larger than that,
but in practice I have never seen it. The largest I have seen in
practice is about 1.5MB. The policy container that wraps the dfa,
could be larger if if its wrapping multiple policy sets (think
pre-loading policy for multiple containers in one go), but we don't do
that currently and there is no requirement for that to be handled with
a single allocation.

We have some improvements coming that will reduce our policy size, and
enable it so that we can split some of the larger dfas into multiple
allocations so I really don't expect this will be a problem.

If it becomes an issue we know the size of the allocation needed and
can just have a condition that calls vmalloc_large when needed.
