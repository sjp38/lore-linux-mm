Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8406B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:28:05 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id t31so1741203uad.4
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:28:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor7889717uaa.198.2018.02.21.14.28.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 14:28:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <f33112e4-608f-ae8c-bf88-80ef83b61398@huawei.com>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-3-igor.stoppa@huawei.com> <CAGXu5jJNERp-yni1jdqJRYJ82xrP7=_O1vkxG1sJ-b8CxudP9g@mail.gmail.com>
 <f33112e4-608f-ae8c-bf88-80ef83b61398@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 14:28:03 -0800
Message-ID: <CAGXu5jLeC285BGDW29aHgFZRV6CnqBmmkZULW2pzYmqd0pe9UQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] genalloc: selftest
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Tue, Feb 20, 2018 at 8:59 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
>
> On 13/02/18 01:50, Kees Cook wrote:
>> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
> [...]
>
>>>  lib/genalloc-selftest.c           | 400 ++++++++++++++++++++++++++++++++++++++
>>
>> Nit: make this test_genalloc.c instead.
>
> ok
>
> [...]
>
>>> +       genalloc_selftest();
>>
>> I wonder if it's possible to make this module-loadable instead? That
>> way it could be built and tested separately.
>
> In my case modules are not an option.
> Of course it could be still built in, but what is the real gain?

The gain for it being a module is that it can be loaded and tested
separately from the final kernel image and module collection. For
example, Chrome OS builds lots of debugging test modules but doesn't
include them on the final image. They're only used for testing, and
can be separate from the kernel and "production" modules.

> [...]
>
>>> +       BUG_ON(compare_bitmaps(pool, action->pattern));
>>
>> There's been a lot recently on BUG vs WARN. It does seem crazy to not
>> BUG for an allocator selftest, but if we can avoid it, we should.
>
> If this fails, I would expect that memory corruption is almost guaranteed.
> Do we really want to allow the boot to continue, possibly mounting a
> filesystem, only to corrupt it? It seems very dangerous.

I would include the rationale in either a comment or the commit log.
BUG() tends to need to be very well justified these days.

>> Also, I wonder if it might make sense to split this series up a little
>> more, as in:
>>
>> 1/n: add genalloc selftest
>> 2/n: update bitmaps
>> 3/n: add/change bitmap tests to selftest
>>
>> Maybe I'm over-thinking it, but the great thing about this self test
>> is that it's checking much more than just the bitmap changes you're
>> making, and that can be used to "prove" that genalloc continues to
>> work after the changes (i.e. the selftest passes before the changes,
>> and after, rather than just after).
>
> If I really have to ... but to me the evidence that the changes to the
> bitmaps do really work is already provided by the bitmap patch itself.
>
> Since the patch doesn't remove the parameter indicating the space to be
> freed, it can actually compare what the kernel passes to it vs. what it
> thinks the space should be.
>
> If the values were different, it would complain, but it doesn't ...
> Isn't that even stronger evidence that the bitmap changes work as expected?
>
> (eventually the parameter can be removed, but I intentionally left it,
> for facilitating the merge)

I'll leave it up to the -mm folks, but that was just my thought.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
