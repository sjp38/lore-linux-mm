Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2C26B0007
	for <linux-mm@kvack.org>; Mon,  7 May 2018 16:27:41 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id v124-v6so3713060vke.15
        for <linux-mm@kvack.org>; Mon, 07 May 2018 13:27:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r189-v6sor7970355vkg.5.2018.05.07.13.27.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 13:27:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180507201945.GB15604@bombadil.infradead.org>
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org> <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
 <20180507113902.GC18116@bombadil.infradead.org> <CAGXu5jKq7uZsDN8qLzKTUC2eVQT2f3ZvVbr8s9oQFeikun9NjA@mail.gmail.com>
 <20180507201945.GB15604@bombadil.infradead.org>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 May 2018 13:27:38 -0700
Message-ID: <CAGXu5jL_vYWs7eKY34ews2pW24fvOqNPybmuugg9ycfR1siOLA@mail.gmail.com>
Subject: Re: *alloc API changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, John Johansen <john.johansen@canonical.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Mon, May 7, 2018 at 1:19 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Mon, May 07, 2018 at 09:03:54AM -0700, Kees Cook wrote:
>> On Mon, May 7, 2018 at 4:39 AM, Matthew Wilcox <willy@infradead.org> wrote:
>> > On Fri, May 04, 2018 at 09:24:56PM -0700, Kees Cook wrote:
>> >> On Fri, May 4, 2018 at 8:46 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> >> The only fear I have with the saturating helpers is that we'll end up
>> >> using them in places that don't recognize SIZE_MAX. Like, say:
>> >>
>> >> size = mul(a, b) + 1;
>> >>
>> >> then *poof* size == 0. Now, I'd hope that code would use add(mul(a,
>> >> b), 1), but still... it makes me nervous.
>> >
>> > That's reasonable.  So let's add:
>> >
>> > #define ALLOC_TOO_BIG   (PAGE_SIZE << MAX_ORDER)
>> >
>> > (there's a presumably somewhat obsolete CONFIG_FORCE_MAX_ZONEORDER on some
>> > architectures which allows people to configure MAX_ORDER all the way up
>> > to 64.  That config option needs to go away, or at least be limited to
>> > a much lower value).
>> >
>> > On x86, that's 4k << 11 = 8MB.  On PPC, that might be 64k << 9 == 32MB.
>> > Those values should be relatively immune to further arithmetic causing
>> > an additional overflow.
>>
>> But we can do larger than 8MB allocations with vmalloc, can't we?
>
> Yes.  And today with kvmalloc.  However, I proposed to Linus that
> kvmalloc() shouldn't allow it -- we should have kvmalloc_large() which
> would, but kvmalloc wouldn't.  He liked that idea, so I'm going with it.

How would we handle size calculations for _large?

> There are very, very few places which should need kvmalloc_large.
> That's one million 8-byte pointers.  If you need more than that inside
> the kernel, you're doing something really damn weird and should do
> something that looks obviously different.

I'm CCing John since I remember long ago running into problems loading
the AppArmor DFA with kmalloc and switching it to kvmalloc. John, how
large can the DFAs for AppArmor get? Would an 8MB limit be a problem?

And do we have any large IO or network buffers >8MB?

>> > I don't think it should go in the callers though ... where it goes in
>> > the allocator is up to the allocator maintainers ;-)
>>
>> We need a self-test regardless, so checking that each allocator
>> returns NULL with the saturated value can be done.
>
> Yes, absolutely.
>
>> >> > I'd rather have a mul_ab(), mul_abc(), mul_ab_add_c(), etc. than nest
>> >> > calls to mult().
>> >>
>> >> Agreed. I think having exactly those would cover almost everything,
>> >> and the two places where a 4-factor product is needed could just nest
>> >> them. (bikeshed: the very common mul_ab() should just be mul(), IMO.)
>> >>
>> >> > Nono, Linus had the better proposal, struct_size(p, member, n).
>> >>
>> >> Oh, yes! I totally missed that in the threads.
>> >
>> > so we're agreed on struct_size().  I think rather than the explicit 'mul',
>> > perhaps we should have array_size() and array3_size().
>>
>> I do like the symmetry there. My earlier "what if someone does +1"
>> continues to scratch at my brain, though I think it's likely
>> unimportant: there's no indication (in the name) that these calls
>> saturate. Will someone ever do something crazy like: array_size(a, b)
>> / array_size(c, d) and they can, effectively, a truncated value (if
>> "a, b" saturated and "c, d" didn't...)?
>
> Without CPU support for a saturated value, there's no "safe" saturated
> value.  You can always come up with some arithmetic that will bring it
> back into the valid range.  All we can do is go "large enough" and hope.
>
>> >> Right, no. I think if we can ditch *calloc() and _array() by using
>> >> saturating helpers, we'll have the API in a much better form:
>> >>
>> >> kmalloc(foo * bar, GFP_KERNEL);
>> >> into
>> >> kmalloc_array(foo, bar, GFP_KERNEL);
>> >> into
>> >> kmalloc(mul(foo, bar), GFP_KERNEL);
>> >
>> > kmalloc(array_size(foo, bar), GFP_KERNEL);
>>
>> I can't come up with a better name. :P When it was "mul()" I was
>> thinking "smul()" for "saturating multiply". sarray_size() seems ...
>> bonkers.
>
> smul would mean 'signed multiply' to me, having read the GCC manual:
>  -- Built-in Function: bool __builtin_smul_overflow (int a, int b, int *res)
>
> but I thought of another problem with array_size.  We already have
> ARRAY_SIZE and it means "the number of elements in the array".
>
> so ... struct_bytes(), array_bytes(), array3_bytes()?

Maybe "calc"? struct_calc(), array_calc(), array3_calc()? This has the
benefit of actually saying more about what it is doing, rather than
its return value... In the end, I don't care. :)

>> > I think we're broadly in agreement here!
>>
>> Do we want addition helpers? (And division and subtraction?)
>
> Keeping our focus on allocations ... do we have plain additions (as
> opposed to multiply-and-add?)  And subtraction?

All I've seen are just rare "weird" cases of lots of mult/add. Some
are way worse than others:
http://www.ozlabs.org/~akpm/mmotm/broken-out/exofs-avoid-vla-in-structures.patch

Just having the mult/add saturation would be lovely.

-Kees

-- 
Kees Cook
Pixel Security
